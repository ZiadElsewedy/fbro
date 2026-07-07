import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:drop/core/constants/app_constants.dart';
import 'package:drop/core/enums/attachment_type.dart';
import 'package:drop/core/enums/request_status.dart';
import 'package:drop/core/errors/exceptions.dart';
import 'package:drop/features/requests/data/models/request_model.dart';
import 'package:drop/features/requests/domain/entities/request_event.dart';
import 'package:drop/features/task/domain/entities/task_attachment.dart';

abstract class RequestRemoteDataSource {
  Stream<List<RequestModel>> watchAllRequests();
  Stream<List<RequestModel>> watchBranchRequests(String branchId);
  Stream<List<RequestModel>> watchMyRequests(String uid);
  Future<RequestModel?> getRequest(String requestId);
  Stream<RequestModel?> watchRequest(String requestId);
  Stream<List<RequestEvent>> watchEvents(String requestId);

  /// A fresh, guaranteed-unique request id — generated up front so opening media
  /// can be uploaded to `requests/{id}/attachments/...` before the doc is written.
  String newRequestId();

  Future<RequestModel> createRequest(RequestModel request);

  /// Single targeted update — status + decision/completion stamps only.
  Future<void> changeStatus(
    String requestId,
    RequestStatus to, {
    String? decidedBy,
    String? decidedByName,
  });

  /// Single `add` of one event document (no whole-array rewrite).
  Future<void> addEvent(String requestId, RequestEvent event);

  Future<void> deleteRequest(String requestId);

  Future<TaskAttachment> uploadAttachment({
    required String requestId,
    required File file,
    required AttachmentType type,
    required String uploadedBy,
    String? uploadedByName,
    int? durationMs,
    void Function(int transferred, int total)? onProgress,
  });
}

class RequestRemoteDataSourceImpl implements RequestRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  RequestRemoteDataSourceImpl(this._firestore, this._storage);

  static const String _eventsSub = 'events';

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection(AppConstants.requestsCollection);

  CollectionReference<Map<String, dynamic>> _eventsRef(String requestId) =>
      _requests.doc(requestId).collection(_eventsSub);

  List<RequestModel> _mapSnap(QuerySnapshot<Map<String, dynamic>> snap) =>
      snap.docs.map((d) => RequestModel.fromMap(d.data(), id: d.id)).toList();

  @override
  String newRequestId() => _requests.doc().id;

  @override
  Stream<List<RequestModel>> watchAllRequests() => _requests
      .orderBy('lastEventAt', descending: true)
      .snapshots()
      .map(_mapSnap);

  @override
  Stream<List<RequestModel>> watchBranchRequests(String branchId) => _requests
      // Single equality filter (served by the automatic single-field index);
      // ordering is applied client-side in the repository (per-branch volume is
      // small), so no composite index is needed.
      .where('branchId', isEqualTo: branchId)
      .snapshots()
      .map(_mapSnap);

  @override
  Stream<List<RequestModel>> watchMyRequests(String uid) => _requests
      .where('requesterId', isEqualTo: uid)
      .snapshots()
      .map(_mapSnap);

  @override
  Future<RequestModel?> getRequest(String requestId) async {
    try {
      final doc = await _requests.doc(requestId).get();
      if (!doc.exists || doc.data() == null) return null;
      return RequestModel.fromMap(doc.data()!, id: doc.id);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load request.');
    }
  }

  @override
  Stream<RequestModel?> watchRequest(String requestId) =>
      _requests.doc(requestId).snapshots().map((doc) =>
          (!doc.exists || doc.data() == null)
              ? null
              : RequestModel.fromMap(doc.data()!, id: doc.id));

  @override
  Stream<List<RequestEvent>> watchEvents(String requestId) =>
      _eventsRef(requestId)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => RequestModel.eventFromMap(d.data(), id: d.id))
              .toList());

  @override
  Future<RequestModel> createRequest(RequestModel request) async {
    try {
      // Honor a pre-generated id (from [newRequestId], so opening media is already
      // uploaded under it); otherwise mint a fresh one.
      final docRef =
          request.id.isNotEmpty ? _requests.doc(request.id) : _requests.doc();
      final created =
          request.id.isNotEmpty ? request : request.copyWithId(docRef.id);
      await docRef.set({
        ...created.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Seed ordering before `onRequestCreated` writes the opening event.
        'lastEventAt': FieldValue.serverTimestamp(),
      });
      return created;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to file the request.');
    }
  }

  @override
  Future<void> changeStatus(
    String requestId,
    RequestStatus to, {
    String? decidedBy,
    String? decidedByName,
  }) async {
    try {
      final data = <String, dynamic>{
        'status': to.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (to.isDecision) {
        data['decidedBy'] = decidedBy;
        data['decidedByName'] = decidedByName;
        data['decidedAt'] = FieldValue.serverTimestamp();
      }
      await _requests.doc(requestId).update(data);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update the request.');
    }
  }

  @override
  Future<void> addEvent(String requestId, RequestEvent event) async {
    try {
      await _eventsRef(requestId).add({
        ...RequestModel.eventToMap(event),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to add your comment.');
    }
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    try {
      // The events subcollection is left in place — deleting a request is a rare
      // admin-only operation and the subdocs are orphaned harmlessly.
      await _requests.doc(requestId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete request.');
    }
  }

  static const _uploadTimeout = Duration(seconds: 180);

  @override
  Future<TaskAttachment> uploadAttachment({
    required String requestId,
    required File file,
    required AttachmentType type,
    required String uploadedBy,
    String? uploadedByName,
    int? durationMs,
    void Function(int transferred, int total)? onProgress,
  }) async {
    final id = _requests.doc().id; // guaranteed-unique 20-char id
    final ext = _extensionFor(file.path, type);
    final upload = _storage
        .ref('${AppConstants.requestsCollection}/$requestId/attachments/$id.$ext')
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
