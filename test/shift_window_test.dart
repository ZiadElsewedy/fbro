import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/schedule_day.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/features/schedule/domain/shift_hours.dart';
import 'package:drop/features/schedule/domain/shift_window.dart';
import 'package:drop/features/schedule/domain/swap_eligibility.dart';

/// Pure time math for shift slots — the weekend-night midnight crossing is the
/// case the whole helper exists for: Thu/Fri/Sat nights end **00:30 the next
/// calendar day**, and a naive same-day end (00:30 < 16:30) would mark every
/// weekend evening "finished".
void main() {
  // Sunday 2026-01-04 00:00 — a known, stable week start.
  final weekStart = DateTime(2026, 1, 4);

  group('start/end instants', () {
    test('start delegates to the swap-eligibility source of truth', () {
      for (final day in ScheduleDay.values) {
        for (final shift in ScheduleShift.values) {
          expect(
            ShiftWindow.start(weekStart, day, shift),
            SwapEligibility.slotStart(weekStart, day, shift),
          );
        }
      }
    });

    test('weekday night ends 23:00 the same day', () {
      expect(
        ShiftWindow.endOf(
          weekStart,
          ScheduleDay.monday,
          ShiftHours.standard(ScheduleDay.monday, ScheduleShift.night),
        ),
        DateTime(2026, 1, 5, 23, 0),
      );
    });

    test('weekend night ends 00:30 the NEXT day', () {
      expect(
        ShiftWindow.endOf(
          weekStart,
          ScheduleDay.thursday,
          ShiftHours.standard(ScheduleDay.thursday, ScheduleShift.night),
        ),
        DateTime(2026, 1, 9, 0, 30), // Thursday 8th → Friday 9th 00:30
      );
    });

    test('morning ends 16:30 the same day', () {
      expect(
        ShiftWindow.endOf(
          weekStart,
          ScheduleDay.tuesday,
          ShiftHours.standard(ScheduleDay.tuesday, ScheduleShift.morning),
        ),
        DateTime(2026, 1, 6, 16, 30),
      );
    });

    test('configured starts and ends override the standing fallback', () {
      const custom = ShiftHours(600, 1560); // 10:00 → 02:00 next day
      expect(
        ShiftWindow.startOf(weekStart, ScheduleDay.friday, custom),
        DateTime(2026, 1, 9, 10),
      );
      expect(
        ShiftWindow.endOf(weekStart, ScheduleDay.friday, custom),
        DateTime(2026, 1, 10, 2),
      );
    });
  });

  group('phase', () {
    test(
      'weekend night is ACTIVE all evening and past midnight until 00:30',
      () {
        const day = ScheduleDay.friday; // Friday 2026-01-09
        const night = ScheduleShift.night;
        final hours = ShiftHours.standard(day, night);
        expect(
          ShiftWindow.phaseOf(
            weekStart,
            day,
            night,
            hours,
            DateTime(2026, 1, 9, 16, 0),
          ),
          ShiftPhase.upcoming,
        );
        expect(
          ShiftWindow.phaseOf(
            weekStart,
            day,
            night,
            hours,
            DateTime(2026, 1, 9, 20, 0),
          ),
          ShiftPhase.active,
          reason: 'naive end math would say finished here',
        );
        expect(
          ShiftWindow.phaseOf(
            weekStart,
            day,
            night,
            hours,
            DateTime(2026, 1, 10, 0, 15),
          ),
          ShiftPhase.active,
          reason: 'still on shift past midnight',
        );
        expect(
          ShiftWindow.phaseOf(
            weekStart,
            day,
            night,
            hours,
            DateTime(2026, 1, 10, 0, 30),
          ),
          ShiftPhase.finished,
          reason: 'the interval is [start, end)',
        );
      },
    );

    test('morning phases across its boundaries', () {
      const day = ScheduleDay.monday; // Monday 2026-01-05
      const morning = ScheduleShift.morning;
      final hours = ShiftHours.standard(day, morning);
      expect(
        ShiftWindow.phaseOf(
          weekStart,
          day,
          morning,
          hours,
          DateTime(2026, 1, 5, 8, 0),
        ),
        ShiftPhase.upcoming,
      );
      expect(
        ShiftWindow.phaseOf(
          weekStart,
          day,
          morning,
          hours,
          DateTime(2026, 1, 5, 8, 30),
        ),
        ShiftPhase.active,
        reason: 'start is inclusive',
      );
      expect(
        ShiftWindow.phaseOf(
          weekStart,
          day,
          morning,
          hours,
          DateTime(2026, 1, 5, 18, 0),
        ),
        ShiftPhase.finished,
      );
    });

    test('custom start participates in phase checks', () {
      const custom = ShiftHours(600, 900); // 10:00 → 15:00
      expect(
        ShiftWindow.phaseOf(
          weekStart,
          ScheduleDay.monday,
          ScheduleShift.morning,
          custom,
          DateTime(2026, 1, 5, 9, 30),
        ),
        ShiftPhase.upcoming,
      );
      expect(
        ShiftWindow.phaseOf(
          weekStart,
          ScheduleDay.monday,
          ScheduleShift.morning,
          custom,
          DateTime(2026, 1, 5, 10),
        ),
        ShiftPhase.active,
      );
    });
  });

  group('nightSpillEnd (the post-midnight carry-over window)', () {
    test('00:00–00:29 after a weekend night returns the end instant', () {
      // Friday 00:15 → Thursday night still running.
      expect(
        ShiftWindow.nightSpillEnd(
          DateTime(2026, 1, 9, 0, 15),
          ShiftHours.standard(ScheduleDay.thursday, ScheduleShift.night),
        ),
        DateTime(2026, 1, 9, 0, 30),
      );
      // Sunday 00:10 → Saturday night (previous week's doc).
      expect(
        ShiftWindow.nightSpillEnd(
          DateTime(2026, 1, 11, 0, 10),
          ShiftHours.standard(ScheduleDay.saturday, ScheduleShift.night),
        ),
        DateTime(2026, 1, 11, 0, 30),
      );
    });

    test('closes at 00:30 sharp', () {
      expect(
        ShiftWindow.nightSpillEnd(
          DateTime(2026, 1, 9, 0, 30),
          ShiftHours.standard(ScheduleDay.thursday, ScheduleShift.night),
        ),
        null,
      );
    });

    test('weekday nights never spill (they end 23:00 the same day)', () {
      // Tuesday 00:15 → Monday was not a weekend night.
      expect(
        ShiftWindow.nightSpillEnd(
          DateTime(2026, 1, 6, 0, 15),
          ShiftHours.standard(ScheduleDay.monday, ScheduleShift.night),
        ),
        null,
      );
    });

    test('daytime is never a spill window', () {
      expect(
        ShiftWindow.nightSpillEnd(
          DateTime(2026, 1, 9, 12, 0),
          ShiftHours.standard(ScheduleDay.thursday, ScheduleShift.night),
        ),
        null,
      );
    });

    test('custom overnight close defines the spill window', () {
      const late = ShiftHours(990, 1560); // 16:30 → 02:00
      expect(
        ShiftWindow.nightSpillEnd(DateTime(2026, 1, 9, 1, 45), late),
        DateTime(2026, 1, 9, 2),
      );
      expect(ShiftWindow.nightSpillEnd(DateTime(2026, 1, 9, 2), late), null);
    });
  });
}
