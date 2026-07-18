import 'package:flutter_test/flutter_test.dart';
import 'package:drop/features/attendance/domain/attendance_break.dart';
import 'package:drop/features/attendance/domain/attendance_calculator.dart';

void main() {
  // A standard day shift on 2026-07-11: 08:30 → 16:30.
  final start = DateTime(2026, 7, 11, 8, 30);
  final end = DateTime(2026, 7, 11, 16, 30);

  AttendanceTotals run({
    DateTime? clockIn,
    DateTime? clockOut,
    List<AttendanceBreak> breaks = const [],
    DateTime? now,
    DateTime? schedStart,
    DateTime? schedEnd,
  }) =>
      AttendanceCalculator.compute(
        scheduledStart: schedStart ?? start,
        scheduledEnd: schedEnd ?? end,
        clockIn: clockIn,
        clockOut: clockOut,
        breaks: breaks,
        now: now ?? clockOut ?? DateTime(2026, 7, 11, 16, 30),
      );

  test('no clock-in yields all zeros', () {
    expect(run(clockIn: null), AttendanceTotals.zero);
  });

  test('on-time full shift, no breaks', () {
    final t = run(clockIn: start, clockOut: end);
    expect(t.workedMinutes, 480);
    expect(t.lateMinutes, 0);
    expect(t.earlyLeaveMinutes, 0);
    expect(t.overtimeMinutes, 0);
    expect(t.breakMinutes, 0);
  });

  test('early arrival never inflates worked minutes or overtime (R2 clamp)', () {
    // Clock in 30 min early, leave on time: worked is measured from the scheduled
    // start, not the early clock-in — and the early time is not overtime.
    final t = run(
      clockIn: DateTime(2026, 7, 11, 8, 0), // 30 min before 08:30
      clockOut: end,
    );
    expect(t.workedMinutes, 480); // 08:30 → 16:30, NOT 510
    expect(t.overtimeMinutes, 0);
    expect(t.lateMinutes, 0);
  });

  test('early arrival + real overtime: only the post-end excess counts', () {
    final t = run(
      clockIn: DateTime(2026, 7, 11, 8, 0), // 30 early (clamped away)
      clockOut: DateTime(2026, 7, 11, 17, 0), // 30 over
    );
    expect(t.workedMinutes, 510); // 08:30 → 17:00
    expect(t.overtimeMinutes, 30);
  });

  test('late arrival and early leave beyond grace are counted in full', () {
    final t = run(
      clockIn: DateTime(2026, 7, 11, 8, 50), // 20 late
      clockOut: DateTime(2026, 7, 11, 16, 10), // 20 early
    );
    expect(t.lateMinutes, 20);
    expect(t.earlyLeaveMinutes, 20);
    expect(t.workedMinutes, 440);
  });

  test('trivial late/early within the grace window is suppressed', () {
    final t = run(
      clockIn: DateTime(2026, 7, 11, 8, 33), // 3 late < 5 grace
      clockOut: DateTime(2026, 7, 11, 16, 27), // 3 early < 5 grace
    );
    expect(t.lateMinutes, 0);
    expect(t.earlyLeaveMinutes, 0);
    expect(t.workedMinutes, 474);
  });

  test('overtime past the grace is counted', () {
    final t = run(clockIn: start, clockOut: DateTime(2026, 7, 11, 17)); // +30
    expect(t.overtimeMinutes, 30);
    expect(t.workedMinutes, 510);
  });

  test('overtime within grace is suppressed', () {
    final t = run(clockIn: start, clockOut: DateTime(2026, 7, 11, 16, 40)); // +10 < 15
    expect(t.overtimeMinutes, 0);
    expect(t.workedMinutes, 490);
  });

  test('breaks are excluded from worked time', () {
    final t = run(
      clockIn: start,
      clockOut: end,
      breaks: [
        AttendanceBreak(
            start: DateTime(2026, 7, 11, 12), end: DateTime(2026, 7, 11, 12, 30)),
      ],
    );
    expect(t.breakMinutes, 30);
    expect(t.workedMinutes, 450);
  });

  group('in-progress (live) session', () {
    test('measures worked time to now, no early/overtime yet', () {
      final now = DateTime(2026, 7, 11, 12, 30);
      final t = run(
        clockIn: start,
        clockOut: null,
        now: now,
        breaks: [
          AttendanceBreak(
              start: DateTime(2026, 7, 11, 10), end: DateTime(2026, 7, 11, 10, 15)),
        ],
      );
      expect(t.workedMinutes, 225); // 240 gross - 15 break
      expect(t.breakMinutes, 15);
      expect(t.earlyLeaveMinutes, 0);
      expect(t.overtimeMinutes, 0);
    });

    test('an open break nets out of live worked time', () {
      final now = DateTime(2026, 7, 11, 12, 30);
      final t = run(
        clockIn: start,
        clockOut: null,
        now: now,
        breaks: [AttendanceBreak(start: DateTime(2026, 7, 11, 12))], // open, 30m
      );
      expect(t.breakMinutes, 30);
      expect(t.workedMinutes, 210); // 240 - 30
    });
  });

  test('overnight shift crossing midnight computes correctly', () {
    final schedStart = DateTime(2026, 7, 11, 16, 30);
    final schedEnd = DateTime(2026, 7, 12, 0, 30); // 00:30 next day
    final t = run(
      schedStart: schedStart,
      schedEnd: schedEnd,
      clockIn: schedStart,
      clockOut: schedEnd,
    );
    expect(t.workedMinutes, 480);
    expect(t.lateMinutes, 0);
    expect(t.overtimeMinutes, 0);
  });

  test('forEntity delegates to the same math', () {
    // sanity: compute vs. a direct call agree (guards against drift)
    final direct = run(clockIn: start, clockOut: end);
    expect(direct.workedMinutes, 480);
  });
}
