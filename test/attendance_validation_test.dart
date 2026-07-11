import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/attendance_status.dart';
import 'package:drop/core/enums/leave_type.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/features/attendance/domain/attendance_break.dart';
import 'package:drop/features/attendance/domain/attendance_config.dart';
import 'package:drop/features/attendance/domain/attendance_validation.dart';
import 'package:drop/features/attendance/domain/entities/attendance_entity.dart';

void main() {
  const enabled = AttendanceConfig(enabled: true);
  final start = DateTime(2026, 7, 11, 8, 30);
  final end = DateTime(2026, 7, 11, 16, 30);

  AttendanceEntity record({
    DateTime? clockIn,
    DateTime? clockOut,
    List<AttendanceBreak> breaks = const [],
    AttendanceStatus status = AttendanceStatus.inProgress,
  }) =>
      AttendanceEntity(
        id: 'u_20260711_morning',
        userId: 'u',
        shift: ScheduleShift.morning,
        date: DateTime(2026, 7, 11),
        scheduledStart: start,
        scheduledEnd: end,
        clockIn: clockIn,
        clockOut: clockOut,
        breaks: breaks,
        status: status,
      );

  group('checkClockIn', () {
    AttendanceCheck check({
      bool userActive = true,
      ScheduleShift? shift = ScheduleShift.morning,
      LeaveType? leave,
      DateTime? schedStart,
      DateTime? schedEnd,
      AttendanceEntity? existing,
      DateTime? now,
      AttendanceConfig config = enabled,
    }) =>
        AttendanceValidation.checkClockIn(
          userActive: userActive,
          todaysShift: shift,
          leave: leave,
          scheduledStart: schedStart ?? start,
          scheduledEnd: schedEnd ?? end,
          existing: existing,
          now: now ?? DateTime(2026, 7, 11, 8, 15),
          config: config,
        );

    test('blocked when the module is disabled', () {
      expect(check(config: AttendanceConfig.defaults).reason,
          AttendanceBlock.notEnabled);
    });

    test('blocked when the account is inactive', () {
      expect(check(userActive: false).reason, AttendanceBlock.userDisabled);
    });

    test('blocked when on leave', () {
      expect(check(leave: LeaveType.sick).reason, AttendanceBlock.onLeave);
    });

    test('blocked when no shift and unscheduled clock-in is off', () {
      expect(check(shift: null).reason, AttendanceBlock.noActiveShift);
    });

    test('allowed with no shift when unscheduled clock-in is on', () {
      final c = check(
        shift: null,
        schedStart: null,
        schedEnd: null,
        config: const AttendanceConfig(enabled: true, allowUnscheduledClockIn: true),
      );
      expect(c.allowed, isTrue);
    });

    test('blocked when already clocked in (open session)', () {
      expect(check(existing: record(clockIn: start)).reason,
          AttendanceBlock.alreadyClockedIn);
    });

    test('blocked when the shift is already completed', () {
      final done = record(
          clockIn: start, clockOut: end, status: AttendanceStatus.completed);
      expect(check(existing: done).reason, AttendanceBlock.alreadyClockedOut);
    });

    test('blocked before the clock-in window opens', () {
      // opens at 08:00 (08:30 - 30 lead); 07:30 is too early.
      expect(check(now: DateTime(2026, 7, 11, 7, 30)).reason,
          AttendanceBlock.outsideWindow);
    });

    test('blocked after the shift has ended', () {
      expect(check(now: DateTime(2026, 7, 11, 17)).reason,
          AttendanceBlock.outsideWindow);
    });

    test('allowed inside the window with no prior record', () {
      expect(check().allowed, isTrue);
    });
  });

  group('checkClockOut', () {
    AttendanceCheck check(AttendanceEntity? existing) =>
        AttendanceValidation.checkClockOut(
            existing: existing, now: DateTime(2026, 7, 11, 16, 30), config: enabled);

    test('blocked when not clocked in', () {
      expect(check(null).reason, AttendanceBlock.notClockedIn);
    });

    test('blocked when already clocked out', () {
      expect(
        check(record(clockIn: start, clockOut: end, status: AttendanceStatus.completed))
            .reason,
        AttendanceBlock.alreadyClockedOut,
      );
    });

    test('blocked while a break is running', () {
      final onBreak = record(
        clockIn: start,
        breaks: [AttendanceBreak(start: DateTime(2026, 7, 11, 12))],
      );
      expect(check(onBreak).reason, AttendanceBlock.openBreak);
    });

    test('allowed for an open session with no running break', () {
      expect(check(record(clockIn: start)).allowed, isTrue);
    });
  });

  group('break checks', () {
    test('start break needs an open session and no running break', () {
      expect(AttendanceValidation.checkStartBreak(existing: null).reason,
          AttendanceBlock.notClockedIn);
      expect(
          AttendanceValidation.checkStartBreak(existing: record(clockIn: start))
              .allowed,
          isTrue);
      final onBreak = record(
          clockIn: start, breaks: [AttendanceBreak(start: DateTime(2026, 7, 11, 12))]);
      expect(AttendanceValidation.checkStartBreak(existing: onBreak).reason,
          AttendanceBlock.openBreak);
    });

    test('end break needs a running break', () {
      final onBreak = record(
          clockIn: start, breaks: [AttendanceBreak(start: DateTime(2026, 7, 11, 12))]);
      expect(
          AttendanceValidation.checkEndBreak(existing: onBreak).allowed, isTrue);
      expect(AttendanceValidation.checkEndBreak(existing: record(clockIn: start)).reason,
          AttendanceBlock.noOpenBreak);
    });
  });
}
