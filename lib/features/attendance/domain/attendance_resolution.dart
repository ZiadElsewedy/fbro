import 'package:drop/core/enums/attendance_status.dart';
import 'package:drop/features/attendance/domain/attendance_calculator.dart';

/// The concrete result an **approved** correction applies to its parent record:
/// the settled clock-in / clock-out, the resulting [status], and the recomputed
/// minute snapshot. Pure + framework-free (serialized by `AttendanceCorrectionModel`).
///
/// It is computed once, on approval, by `DecideCorrection` through
/// [AttendanceCalculator] — the single source of the minute math — and stored on
/// the correction doc. The `onAttendanceCorrectionWritten` Cloud Function then
/// copies it verbatim onto `attendance/{id}` (server-authoritative apply), so the
/// client never recomputes totals and the numbers can't drift from the clock-out
/// path.
class AttendanceResolution {
  final DateTime? clockIn;
  final DateTime? clockOut;
  final AttendanceStatus status;
  final int workedMinutes;
  final int lateMinutes;
  final int earlyLeaveMinutes;
  final int overtimeMinutes;
  final int breakMinutes;

  const AttendanceResolution({
    this.clockIn,
    this.clockOut,
    this.status = AttendanceStatus.completed,
    this.workedMinutes = 0,
    this.lateMinutes = 0,
    this.earlyLeaveMinutes = 0,
    this.overtimeMinutes = 0,
    this.breakMinutes = 0,
  });

  /// Builds a resolution from settled [clockIn]/[clockOut] and the [totals] the
  /// [AttendanceCalculator] produced for them.
  factory AttendanceResolution.fromTotals({
    DateTime? clockIn,
    DateTime? clockOut,
    AttendanceStatus status = AttendanceStatus.completed,
    required AttendanceTotals totals,
  }) =>
      AttendanceResolution(
        clockIn: clockIn,
        clockOut: clockOut,
        status: status,
        workedMinutes: totals.workedMinutes,
        lateMinutes: totals.lateMinutes,
        earlyLeaveMinutes: totals.earlyLeaveMinutes,
        overtimeMinutes: totals.overtimeMinutes,
        breakMinutes: totals.breakMinutes,
      );

  AttendanceTotals get totals => AttendanceTotals(
        workedMinutes: workedMinutes,
        lateMinutes: lateMinutes,
        earlyLeaveMinutes: earlyLeaveMinutes,
        overtimeMinutes: overtimeMinutes,
        breakMinutes: breakMinutes,
      );

  @override
  bool operator ==(Object other) =>
      other is AttendanceResolution &&
      other.clockIn == clockIn &&
      other.clockOut == clockOut &&
      other.status == status &&
      other.workedMinutes == workedMinutes &&
      other.lateMinutes == lateMinutes &&
      other.earlyLeaveMinutes == earlyLeaveMinutes &&
      other.overtimeMinutes == overtimeMinutes &&
      other.breakMinutes == breakMinutes;

  @override
  int get hashCode => Object.hash(clockIn, clockOut, status, workedMinutes,
      lateMinutes, earlyLeaveMinutes, overtimeMinutes, breakMinutes);
}
