import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/attendance_status.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/features/attendance/domain/attendance_validation.dart';
import 'package:drop/features/attendance/domain/entities/attendance_entity.dart';

void main() {
  AttendanceEntity record({
    DateTime? clockIn,
    DateTime? clockOut,
    AttendanceStatus status = AttendanceStatus.pendingReview,
    DateTime? deletedAt,
  }) =>
      AttendanceEntity(
        id: 'u1_20260713_morning',
        userId: 'u1',
        shift: ScheduleShift.morning,
        date: DateTime(2026, 7, 13),
        clockIn: clockIn ?? DateTime(2026, 7, 13, 8, 30),
        clockOut: clockOut,
        status: status,
        deletedAt: deletedAt,
      );

  AttendanceCheck check({
    AttendanceEntity? existing,
    String reason = 'Forgot to clock out',
    DateTime? proposedClockIn,
    DateTime? proposedClockOut,
    AttendanceStatus? proposedStatus,
  }) =>
      AttendanceValidation.checkCorrection(
        existing: existing ?? record(),
        reason: reason,
        proposedClockIn: proposedClockIn,
        proposedClockOut: proposedClockOut ?? DateTime(2026, 7, 13, 16, 30),
        proposedStatus: proposedStatus,
      );

  test('a well-formed correction on a settled record is allowed', () {
    expect(check().allowed, isTrue);
  });

  test('no record → recordMissing', () {
    final c = AttendanceValidation.checkCorrection(
      existing: null,
      reason: 'x',
      proposedClockOut: DateTime(2026, 7, 13, 16, 30),
    );
    expect(c.reason, AttendanceBlock.recordMissing);
  });

  test('soft-deleted record → recordMissing', () {
    expect(
      check(existing: record(deletedAt: DateTime(2026, 7, 13, 20))).reason,
      AttendanceBlock.recordMissing,
    );
  });

  test('a still-open session → sessionOpen', () {
    expect(
      check(existing: record(status: AttendanceStatus.inProgress)).reason,
      AttendanceBlock.sessionOpen,
    );
  });

  test('empty reason → emptyReason', () {
    expect(check(reason: '   ').reason, AttendanceBlock.emptyReason);
  });

  test('nothing proposed → invalidTimes', () {
    final c = AttendanceValidation.checkCorrection(
      existing: record(),
      reason: 'x',
    );
    expect(c.reason, AttendanceBlock.invalidTimes);
  });

  test('clock-out not after clock-in → invalidTimes', () {
    final c = check(
      proposedClockIn: DateTime(2026, 7, 13, 16, 30),
      proposedClockOut: DateTime(2026, 7, 13, 8, 30),
    );
    expect(c.reason, AttendanceBlock.invalidTimes);
  });

  test('a status-only dispute (no times) is allowed', () {
    final c = AttendanceValidation.checkCorrection(
      existing: record(status: AttendanceStatus.absent),
      reason: 'I did work',
      proposedStatus: AttendanceStatus.completed,
    );
    expect(c.allowed, isTrue);
  });
}
