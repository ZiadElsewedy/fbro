import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/schedule_day.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/schedule/domain/entities/weekly_schedule_entity.dart';
import 'package:drop/features/schedule/presentation/schedule_insights.dart';

UserEntity _member(String uid) => UserEntity(
    uid: uid, email: '$uid@drop.test', authProvider: 'password');

WeeklyScheduleEntity _schedule(
        Map<ScheduleDay, Map<ScheduleShift, List<String>>> assignments) =>
    WeeklyScheduleEntity(
      id: 'b1_2026-06-14',
      branchId: 'b1',
      weekStart: DateTime(2026, 6, 14),
      assignments: assignments,
    );

void main() {
  final members = [_member('u1'), _member('u2'), _member('u3')];

  group('computeScheduleInsights', () {
    test('classifies open, one-person, and double-booked slots', () {
      final insights = computeScheduleInsights(
        _schedule({
          ScheduleDay.sunday: {
            ScheduleShift.morning: ['u1', 'u2'],
            ScheduleShift.night: ['u1'], // u1 double-booked on Sunday
          },
          ScheduleDay.monday: {
            ScheduleShift.morning: ['u3'], // one person
            // night missing → open
          },
        }),
        members,
      );

      // Sunday: both slots flagged as the conflict pair; u1 is the conflict.
      expect(insights.doubleBookedCount, 1);
      expect(insights.isDoubleBooked(ScheduleDay.sunday, 'u1'), isTrue);
      expect(insights.isDoubleBooked(ScheduleDay.sunday, 'u2'), isFalse);
      expect(
          insights.conflictSlots,
          containsAll({
            (ScheduleDay.sunday, ScheduleShift.morning),
            (ScheduleDay.sunday, ScheduleShift.night),
          }));

      // Monday morning has exactly one person; Sunday night too (u1).
      expect(insights.onePersonSlots,
          contains((ScheduleDay.monday, ScheduleShift.morning)));
      expect(insights.onePersonSlots,
          contains((ScheduleDay.sunday, ScheduleShift.night)));

      // Every unassigned slot of the week counts as open (12 remaining).
      expect(insights.openSlots,
          contains((ScheduleDay.monday, ScheduleShift.night)));
      expect(insights.openCount, 14 - 3);
      expect(insights.allClear, isFalse);
    });

    test('orphaned uids never count as coverage or conflicts', () {
      final insights = computeScheduleInsights(
        _schedule({
          ScheduleDay.tuesday: {
            ScheduleShift.morning: ['ghost'], // unresolvable
            ScheduleShift.night: ['ghost', 'u1'],
          },
        }),
        members,
      );
      // The ghost-only slot is effectively open; ghost is never a conflict.
      expect(insights.openSlots,
          contains((ScheduleDay.tuesday, ScheduleShift.morning)));
      expect(insights.doubleBookedCount, 0);
      expect(insights.onePersonSlots,
          contains((ScheduleDay.tuesday, ScheduleShift.night)));
    });

    test('shift filter scopes open/one-person facts, never conflicts', () {
      final schedule = _schedule({
        ScheduleDay.sunday: {
          ScheduleShift.morning: ['u1'],
          ScheduleShift.night: ['u1', 'u2'],
        },
      });
      final insights = computeScheduleInsights(schedule, members,
          filter: ScheduleShift.morning);

      // Only morning slots are counted for open/one-person…
      expect(insights.openCount, 6);
      expect(insights.onePersonSlots,
          equals({(ScheduleDay.sunday, ScheduleShift.morning)}));
      // …but the cross-shift double-booking is still detected.
      expect(insights.isDoubleBooked(ScheduleDay.sunday, 'u1'), isTrue);
    });

    test('a fully staffed, conflict-free week reads all clear', () {
      final four = [...members, _member('u4')];
      final clean = {
        for (final day in ScheduleDay.values)
          day: {
            ScheduleShift.morning: ['u1', 'u2'],
            ScheduleShift.night: ['u3', 'u4'],
          },
      };
      expect(
          computeScheduleInsights(_schedule(clean), four).allClear, isTrue);

      // Same week but u1 also covers nights → no longer all clear.
      final conflicted = {
        for (final day in ScheduleDay.values)
          day: {
            ScheduleShift.morning: ['u1', 'u2'],
            ScheduleShift.night: ['u3', 'u1'],
          },
      };
      expect(computeScheduleInsights(_schedule(conflicted), four).allClear,
          isFalse);
    });
  });
}
