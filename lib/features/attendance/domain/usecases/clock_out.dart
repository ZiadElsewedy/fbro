import 'package:drop/core/enums/attendance_status.dart';
import 'package:drop/features/attendance/domain/attendance_calculator.dart';
import 'package:drop/features/attendance/domain/attendance_config.dart';
import 'package:drop/features/attendance/domain/attendance_gps.dart';
import 'package:drop/features/attendance/domain/entities/attendance_entity.dart';
import 'package:drop/features/attendance/domain/repositories/attendance_repository.dart';

/// Clocks out — **finalizes** the record. This is the one place the minute
/// snapshot is persisted (everywhere else totals are computed live), via
/// [AttendanceCalculator]. Returns the computed totals for immediate UI feedback.
class ClockOut {
  final AttendanceRepository _repository;
  const ClockOut(this._repository);

  Future<AttendanceTotals> call(
    AttendanceEntity record, {
    required DateTime now,
    AttendanceConfig config = AttendanceConfig.defaults,
    AttendanceVerification? verification,
  }) async {
    final totals = AttendanceCalculator.compute(
      scheduledStart: record.scheduledStart,
      scheduledEnd: record.scheduledEnd,
      // The clock-in read back from the server timestamp; the GPS capture time
      // stands in if it hasn't synced yet, so worked-minutes are never computed
      // against a null start.
      clockIn: record.effectiveClockIn,
      clockOut: now,
      breaks: record.breaks,
      now: now,
      config: config,
    );
    await _repository.clockOut(
      record.id,
      clockOut: now,
      status: AttendanceStatus.completed,
      totals: totals,
      verification: verification,
    );
    return totals;
  }
}
