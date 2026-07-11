import 'dart:io';

import 'package:drop/core/enums/attendance_status.dart';
import 'package:drop/core/errors/exceptions.dart';
import 'package:drop/core/errors/failures.dart';
import 'package:drop/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:drop/features/attendance/data/models/attendance_model.dart';
import 'package:drop/features/attendance/domain/attendance_break.dart';
import 'package:drop/features/attendance/domain/attendance_calculator.dart';
import 'package:drop/features/attendance/domain/entities/attendance_entity.dart';
import 'package:drop/features/attendance/domain/entities/attendance_event.dart';
import 'package:drop/features/attendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource _remote;

  AttendanceRepositoryImpl(this._remote);

  /// Models → entities, dropping soft-deleted records (client-side, like the
  /// Requests inbox: a `where(deletedAt, isNull)` query would exclude every doc
  /// missing the field, and per-scope volume is small).
  List<AttendanceEntity> _live(List<AttendanceModel> models) => [
        for (final m in models)
          if (m.deletedAt == null) m.toEntity(),
      ];

  @override
  Future<AttendanceEntity?> getRecord(String id) async {
    try {
      final m = await _remote.getRecord(id);
      if (m == null || m.deletedAt != null) return null;
      return m.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Stream<AttendanceEntity?> watchRecord(String id) => _remote
      .watchRecord(id)
      .map((m) => (m == null || m.deletedAt != null) ? null : m.toEntity());

  @override
  Stream<List<AttendanceEntity>> watchUserHistory(String uid, {int limit = 30}) =>
      _remote.watchUserHistory(uid, limit: limit).map(_live);

  @override
  Stream<List<AttendanceEntity>> watchBranchDay(String branchId, String dayKey) =>
      _remote.watchBranchDay(branchId, dayKey).map(_live);

  @override
  Stream<List<AttendanceEntity>> watchBranchRange(
          String branchId, String startKey, String endKey) =>
      _remote.watchBranchRange(branchId, startKey, endKey).map(_live);

  @override
  Stream<List<AttendanceEvent>> watchEvents(String id) => _remote.watchEvents(id);

  @override
  Future<void> clockIn(AttendanceEntity record) async {
    try {
      await _remote.clockIn(AttendanceModel.fromEntity(record));
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> clockOut(
    String id, {
    required DateTime clockOut,
    required AttendanceStatus status,
    required AttendanceTotals totals,
  }) async {
    try {
      await _remote.clockOut(
        id,
        ClockOutWrite(clockOut: clockOut, status: status, totals: totals),
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> updateBreaks(String id, List<AttendanceBreak> breaks) async {
    try {
      await _remote.updateBreaks(id, breaks);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> softDelete(String id) async {
    try {
      await _remote.softDelete(id);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<String> uploadSelfie({
    required String recordId,
    required File file,
    required String uploadedBy,
  }) async {
    try {
      return await _remote.uploadSelfie(
        recordId: recordId,
        file: file,
        uploadedBy: uploadedBy,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
