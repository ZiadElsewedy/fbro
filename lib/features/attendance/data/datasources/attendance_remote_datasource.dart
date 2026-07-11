import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:drop/core/constants/app_constants.dart';
import 'package:drop/core/enums/attendance_status.dart';
import 'package:drop/core/errors/exceptions.dart';
import 'package:drop/features/attendance/data/models/attendance_model.dart';
import 'package:drop/features/attendance/domain/attendance_break.dart';
import 'package:drop/features/attendance/domain/attendance_calculator.dart';
import 'package:drop/features/attendance/domain/entities/attendance_event.dart';

/// The finalized fields written at clock-out (the one place the minute snapshot
/// is persisted — see [AttendanceCalculator]).
class ClockOutWrite {
  final DateTime clockOut;
  final AttendanceStatus status;
  final AttendanceTotals totals;
  const ClockOutWrite({
    required this.clockOut,
    required this.status,
    required this.totals,
  });
}

/// Client data access for `attendance/{id}`.
///
/// **Audit is server-side.** Clock actions here are plain **record writes**; the
/// immutable audit trail in `attendance/{id}/events` is derived by an Admin-SDK
/// Cloud Function (mirroring `onRequestCreated`/`onRequestUpdated`), so clients
/// can't forge or mutate audit events — exactly the "reuse the existing audit
/// pattern, not a parallel system" contract. The client only *reads* the trail
/// ([watchEvents]).
abstract class AttendanceRemoteDataSource {
  /// A direct one-shot read of the deterministic-id record ("today"). No query.
  Future<AttendanceModel?> getRecord(String id);

  /// Realtime stream of one record doc (the live session).
  Stream<AttendanceModel?> watchRecord(String id);

  /// A user's own history, newest day first ([limit] most recent).
  Stream<List<AttendanceModel>> watchUserHistory(String uid, {int limit});

  /// Every record in [branchId] on the single [dayKey] — the manager live board
  /// (bounded to one day; served by the `branchId + dayKey` index).
  Stream<List<AttendanceModel>> watchBranchDay(String branchId, String dayKey);

  /// Every record in [branchId] over the inclusive `dayKey` range
  /// `[startKey, endKey]` — the bounded window the admin analytics reads.
  Stream<List<AttendanceModel>> watchBranchRange(
      String branchId, String startKey, String endKey);

  /// The record's server-written, append-only audit trail, oldest first.
  Stream<List<AttendanceEvent>> watchEvents(String id);

  /// Clock in — idempotent `set(merge)` of the record on its deterministic id
  /// (a double-tap / offline replay overwrites the same doc, never duplicates).
  Future<void> clockIn(AttendanceModel record);

  /// Clock out — writes the finalized fields + the minute snapshot.
  Future<void> clockOut(String id, ClockOutWrite write);

  /// Replace the breaks array (start / end a break). The minute snapshot is NOT
  /// written here — worked/break minutes are only persisted at clock-out.
  Future<void> updateBreaks(String id, List<AttendanceBreak> breaks);

  /// Soft-delete a record (admin) — stamps `deletedAt`; the doc stays as history.
  Future<void> softDelete(String id);

  /// Upload a clock-in selfie to `attendance/{recordId}/selfie/{id}.<ext>` and
  /// return its download URL. Optional (only when the branch requires a photo).
  Future<String> uploadSelfie({
    required String recordId,
    required File file,
    required String uploadedBy,
  });
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AttendanceRemoteDataSourceImpl(this._firestore, this._storage);

  static const String _eventsSub = 'events';

  CollectionReference<Map<String, dynamic>> get _records =>
      _firestore.collection(AppConstants.attendanceCollection);

  DocumentReference<Map<String, dynamic>> _record(String id) => _records.doc(id);

  CollectionReference<Map<String, dynamic>> _events(String id) =>
      _record(id).collection(_eventsSub);

  List<AttendanceModel> _mapSnap(QuerySnapshot<Map<String, dynamic>> snap) =>
      snap.docs.map((d) => AttendanceModel.fromMap(d.data(), id: d.id)).toList();

  @override
  Future<AttendanceModel?> getRecord(String id) async {
    try {
      final doc = await _record(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return AttendanceModel.fromMap(doc.data()!, id: doc.id);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load attendance.');
    }
  }

  @override
  Stream<AttendanceModel?> watchRecord(String id) =>
      _record(id).snapshots().map((doc) => (!doc.exists || doc.data() == null)
          ? null
          : AttendanceModel.fromMap(doc.data()!, id: doc.id));

  @override
  Stream<List<AttendanceModel>> watchUserHistory(String uid, {int limit = 30}) =>
      _records
          .where('userId', isEqualTo: uid)
          .orderBy('date', descending: true)
          .limit(limit)
          .snapshots()
          .map(_mapSnap);

  @override
  Stream<List<AttendanceModel>> watchBranchDay(String branchId, String dayKey) =>
      _records
          .where('branchId', isEqualTo: branchId)
          .where('dayKey', isEqualTo: dayKey)
          .snapshots()
          .map(_mapSnap);

  @override
  Stream<List<AttendanceModel>> watchBranchRange(
          String branchId, String startKey, String endKey) =>
      _records
          .where('branchId', isEqualTo: branchId)
          .where('dayKey', isGreaterThanOrEqualTo: startKey)
          .where('dayKey', isLessThanOrEqualTo: endKey)
          .snapshots()
          .map(_mapSnap);

  @override
  Stream<List<AttendanceEvent>> watchEvents(String id) => _events(id)
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => AttendanceModel.eventFromMap(d.data(), id: d.id))
          .toList());

  @override
  Future<void> clockIn(AttendanceModel record) async {
    try {
      await _record(record.id).set(
        {
          ...record.toCreateMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to clock in.');
    }
  }

  @override
  Future<void> clockOut(String id, ClockOutWrite write) async {
    try {
      await _record(id).update({
        'clockOut': Timestamp.fromDate(write.clockOut),
        'status': write.status.value,
        'workedMinutes': write.totals.workedMinutes,
        'lateMinutes': write.totals.lateMinutes,
        'earlyLeaveMinutes': write.totals.earlyLeaveMinutes,
        'overtimeMinutes': write.totals.overtimeMinutes,
        'breakMinutes': write.totals.breakMinutes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to clock out.');
    }
  }

  @override
  Future<void> updateBreaks(String id, List<AttendanceBreak> breaks) async {
    try {
      await _record(id).update({
        'breaks': AttendanceModel.breaksToList(breaks),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update your break.');
    }
  }

  @override
  Future<void> softDelete(String id) async {
    try {
      await _record(id).update({
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete the record.');
    }
  }

  static const _uploadTimeout = Duration(seconds: 120);

  @override
  Future<String> uploadSelfie({
    required String recordId,
    required File file,
    required String uploadedBy,
  }) async {
    final attId = _records.doc().id; // guaranteed-unique id
    final ext = _extensionFor(file.path);
    final upload = _storage
        .ref('${AppConstants.attendanceCollection}/$recordId/selfie/$attId.$ext')
        .putFile(file, SettableMetadata(contentType: _contentType(ext)));
    try {
      final snapshot = await upload.timeout(
        _uploadTimeout,
        onTimeout: () {
          upload.cancel();
          throw const ServerException(
              'Selfie upload timed out. Check your connection and try again.');
        },
      );
      return await snapshot.ref.getDownloadURL().timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw const ServerException(
          'Selfie upload timed out. Check your connection and try again.');
    } on FirebaseException catch (e) {
      throw ServerException(_storageError(e));
    }
  }

  static String _extensionFor(String path) {
    final dot = path.lastIndexOf('.');
    if (dot != -1 && dot < path.length - 1) {
      final ext = path.substring(dot + 1).toLowerCase();
      if (ext.isNotEmpty && ext.length <= 5) return ext;
    }
    return 'jpg';
  }

  static String _contentType(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }

  static String _storageError(FirebaseException e) {
    switch (e.code) {
      case 'unauthorized':
      case 'unauthenticated':
        return 'Selfie upload was blocked by Storage permissions (${e.code}). '
            'Storage rules likely need to be deployed.';
      case 'object-not-found':
      case 'bucket-not-found':
      case 'project-not-found':
        return 'Firebase Storage isn\'t set up for this project (${e.code}).';
      default:
        return e.message ?? 'Selfie upload failed (${e.code}).';
    }
  }
}
