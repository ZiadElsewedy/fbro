import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:drop/core/constants/app_constants.dart';
import 'package:drop/core/enums/attachment_type.dart';
import 'package:drop/core/errors/exceptions.dart';
import 'package:drop/features/reports/data/models/report_model.dart';
import 'package:drop/features/reports/domain/entities/report_identity.dart';
import 'package:drop/features/task/domain/entities/task_attachment.dart';

abstract class ReportRemoteDataSource {
  Stream<List<ReportModel>> watchAllReports();
  Stream<List<ReportModel>> watchBranchReports(String branchId);
  Future<List<ReportModel>> getMyReports(String uid);
  Future<ReportModel?> getReport(String reportId);

  /// Writes the report doc + its private `reporter/identity` subdoc atomically.
  Future<ReportModel> createReport(ReportModel report, ReportIdentity identity);
  Future<void> updateReport(ReportModel report);
  Future<ReportIdentity?> revealReporter(String reportId);
  Future<void> deleteReport(String reportId);

  Future<TaskAttachment> uploadAttachment({
    required String reportId,
    required File file,
    required AttachmentType type,
    required String uploadedBy,
    String? uploadedByName,
    int? durationMs,
    void Function(int transferred, int total)? onProgress,
  });
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ReportRemoteDataSourceImpl(this._firestore, this._storage);

  /// The private identity subcollection under a report. Named `reporter` (NOT
  /// `private`) so a collectionGroup('reporter') query never collides with
  /// `users/{uid}/private/compensation`.
  static const String _reporterSub = 'reporter';
  static const String _identityDoc = 'identity';

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection(AppConstants.reportsCollection);

  DocumentReference<Map<String, dynamic>> _identityRef(String reportId) =>
      _reports.doc(reportId).collection(_reporterSub).doc(_identityDoc);

  List<ReportModel> _mapSnap(QuerySnapshot<Map<String, dynamic>> snap) =>
      snap.docs.map((d) => ReportModel.fromMap(d.data(), id: d.id)).toList();

  @override
  Stream<List<ReportModel>> watchAllReports() => _reports
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(_mapSnap);

  @override
  Stream<List<ReportModel>> watchBranchReports(String branchId) => _reports
      // Two equality filters (branch + manager-visibility) are served by
      // single-field indexes (zigzag merge) — no composite index needed. Order
      // is applied client-side in the repository (per-branch volume is small).
      .where('branchId', isEqualTo: branchId)
      .where('visibleToManager', isEqualTo: true)
      .snapshots()
      .map(_mapSnap);

  @override
  Future<List<ReportModel>> getMyReports(String uid) async {
    // DIAGNOSTIC ([REPORTS]): the owner list is the ONE mobile-only query that
    // needs a collection-group index (the admin desktop list is a plain
    // `reports` orderBy that Firestore auto-indexes). Log the query + the EXACT
    // FirebaseException code so a missing index (failed-precondition) is
    // distinguishable from a rules block (permission-denied).
    developer.log(
      '[REPORTS] query start: collectionGroup("$_reporterSub")'
      '.where(createdByUserId == $uid)',
      name: 'REPORTS',
    );
    try {
      // The report doc carries no creator uid (privacy split), so the owner's
      // list comes from the private `reporter` subdocs (collectionGroup), then
      // a per-report fetch. Report volume per filer is small.
      final identitySnap = await _firestore
          .collectionGroup(_reporterSub)
          .where('createdByUserId', isEqualTo: uid)
          .get();
      developer.log(
        '[REPORTS] collectionGroup ok: ${identitySnap.docs.length} identity doc(s)',
        name: 'REPORTS',
      );
      final reportIds = <String>{
        for (final d in identitySnap.docs)
          if (d.reference.parent.parent != null) d.reference.parent.parent!.id,
      };
      if (reportIds.isEmpty) return const [];
      final reports = await Future.wait(reportIds.map((id) async {
        final doc = await _reports.doc(id).get();
        if (!doc.exists || doc.data() == null) return null;
        return ReportModel.fromMap(doc.data()!, id: doc.id);
      }));
      final resolved = reports.whereType<ReportModel>().toList();
      developer.log('[REPORTS] resolved ${resolved.length} report(s)',
          name: 'REPORTS');
      return resolved;
    } on FirebaseException catch (e, st) {
      developer.log('[REPORTS] exception code: ${e.code}', name: 'REPORTS');
      developer.log('[REPORTS] exception message: ${e.message}',
          name: 'REPORTS');
      developer.log('[REPORTS] exception stackTrace',
          name: 'REPORTS', error: e, stackTrace: st);
      // Keep the code in the thrown message so it also reaches any higher log.
      throw ServerException(
          '[${e.code}] ${e.message ?? 'Failed to load your reports.'}');
    }
  }

  @override
  Future<ReportModel?> getReport(String reportId) async {
    try {
      final doc = await _reports.doc(reportId).get();
      if (!doc.exists || doc.data() == null) return null;
      return ReportModel.fromMap(doc.data()!, id: doc.id);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load report.');
    }
  }

  @override
  Future<ReportModel> createReport(
    ReportModel report,
    ReportIdentity identity,
  ) async {
    try {
      final docRef = _reports.doc();
      final created = report.copyWithId(docRef.id);
      final batch = _firestore.batch();
      batch.set(docRef, {
        ...created.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.set(_identityRef(docRef.id), {
        ...ReportModel.reporterIdentityToMap(identity),
        'reportId': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      return created;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to submit report.');
    }
  }

  @override
  Future<void> updateReport(ReportModel report) async {
    try {
      await _reports.doc(report.id).set({
        ...report.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update report.');
    }
  }

  @override
  Future<ReportIdentity?> revealReporter(String reportId) async {
    try {
      final doc = await _identityRef(reportId).get();
      if (!doc.exists || doc.data() == null) return null;
      return ReportModel.reporterIdentityFromMap(doc.data()!, reportId: reportId);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to read the reporter.');
    }
  }

  @override
  Future<void> deleteReport(String reportId) async {
    try {
      // The private reporter subdoc is left in place; deleting a report is an
      // admin-only, rare operation and the subdoc is orphaned harmlessly.
      await _reports.doc(reportId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete report.');
    }
  }

  static const _uploadTimeout = Duration(seconds: 180);

  @override
  Future<TaskAttachment> uploadAttachment({
    required String reportId,
    required File file,
    required AttachmentType type,
    required String uploadedBy,
    String? uploadedByName,
    int? durationMs,
    void Function(int transferred, int total)? onProgress,
  }) async {
    final id = _reports.doc().id; // guaranteed-unique 20-char id
    final ext = _extensionFor(file.path, type);
    final upload = _storage
        .ref('${AppConstants.reportsCollection}/$reportId/attachments/$id.$ext')
        .putFile(file, SettableMetadata(contentType: _contentType(ext, type)));
    final sub = upload.snapshotEvents
        .listen((s) => onProgress?.call(s.bytesTransferred, s.totalBytes));
    try {
      final snapshot = await upload.timeout(
        _uploadTimeout,
        onTimeout: () {
          upload.cancel();
          throw const ServerException(
              'Upload timed out. Check your connection and try again.');
        },
      );
      final url = await snapshot.ref
          .getDownloadURL()
          .timeout(const Duration(seconds: 30));
      return TaskAttachment(
        id: id,
        url: url,
        type: type,
        uploadedAt: DateTime.now(),
        uploadedBy: uploadedBy,
        uploadedByName: uploadedByName,
        durationMs: durationMs,
      );
    } on TimeoutException {
      throw const ServerException(
          'Upload timed out. Check your connection and try again.');
    } on FirebaseException catch (e) {
      throw ServerException(_storageError(e));
    } finally {
      await sub.cancel();
    }
  }

  static String _extensionFor(String path, AttachmentType type) {
    final dot = path.lastIndexOf('.');
    if (dot != -1 && dot < path.length - 1) {
      final ext = path.substring(dot + 1).toLowerCase();
      if (ext.isNotEmpty && ext.length <= 5) return ext;
    }
    return type.isVideo ? 'mp4' : 'jpg';
  }

  static String _contentType(String ext, AttachmentType type) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'm4v':
        return 'video/x-m4v';
      case 'webm':
        return 'video/webm';
      default:
        return type.isVideo ? 'video/mp4' : 'image/jpeg';
    }
  }

  static String _storageError(FirebaseException e) {
    switch (e.code) {
      case 'unauthorized':
      case 'unauthenticated':
        return 'Upload was blocked by Storage permissions (${e.code}). '
            'Firebase Storage rules likely need to be deployed.';
      case 'object-not-found':
      case 'bucket-not-found':
      case 'project-not-found':
        return 'Firebase Storage isn\'t set up for this project (${e.code}). '
            'Enable Storage in the Firebase console, then retry.';
      case 'retry-limit-exceeded':
      case 'canceled':
        return 'Upload failed — check your connection and try again.';
      default:
        return e.message ?? 'Upload failed (${e.code}).';
    }
  }
}
