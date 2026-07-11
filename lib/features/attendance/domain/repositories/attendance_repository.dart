import 'dart:io';

import 'package:drop/core/enums/attendance_status.dart';
import 'package:drop/features/attendance/domain/attendance_break.dart';
import 'package:drop/features/attendance/domain/attendance_calculator.dart';
import 'package:drop/features/attendance/domain/entities/attendance_entity.dart';
import 'package:drop/features/attendance/domain/entities/attendance_event.dart';

/// Contract for attendance data access. Branch/role access is enforced
/// server-side by `firestore.rules` (`attendance/{id}`): an employee reads +
/// clocks their own records; a manager reads/reviews their branch; an admin sees
/// all. Reads are deliberately cheap — "today" is a direct doc read (deterministic
/// id), history and the branch board are single bounded queries.
abstract class AttendanceRepository {
  /// One-shot read of a record by its deterministic id ("today").
  Future<AttendanceEntity?> getRecord(String id);

  /// Realtime stream of one record (the live session). Emits null when the record
  /// is absent or soft-deleted.
  Stream<AttendanceEntity?> watchRecord(String id);

  /// A user's own history, newest first ([limit] most recent), soft-deletes
  /// filtered out.
  Stream<List<AttendanceEntity>> watchUserHistory(String uid, {int limit});

  /// A branch's records for a single [dayKey] (`yyyyMMdd`) — the manager live
  /// board.
  Stream<List<AttendanceEntity>> watchBranchDay(String branchId, String dayKey);

  /// A branch's records over an inclusive `dayKey` range — the admin analytics
  /// window.
  Stream<List<AttendanceEntity>> watchBranchRange(
      String branchId, String startKey, String endKey);

  /// A record's server-written, append-only audit trail, oldest first.
  Stream<List<AttendanceEvent>> watchEvents(String id);

  /// Clock in: writes the record (idempotent on its deterministic id). The
  /// `clockedIn` audit event is derived server-side.
  Future<void> clockIn(AttendanceEntity record);

  /// Clock out: writes the finalized fields + minute [totals] snapshot. [totals]
  /// come from [AttendanceCalculator] — the single source of that math; this is
  /// the one place they're persisted.
  Future<void> clockOut(
    String id, {
    required DateTime clockOut,
    required AttendanceStatus status,
    required AttendanceTotals totals,
  });

  /// Start / end a break: replaces the breaks array. Minute totals are NOT
  /// persisted here (only at clock-out).
  Future<void> updateBreaks(String id, List<AttendanceBreak> breaks);

  /// Soft-delete a record (admin) — stamps `deletedAt`; the record stays as
  /// history.
  Future<void> softDelete(String id);

  /// Upload a clock-in selfie and return its download URL.
  Future<String> uploadSelfie({
    required String recordId,
    required File file,
    required String uploadedBy,
  });
}
