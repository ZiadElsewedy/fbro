import 'package:drop/core/enums/schedule_day.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/schedule/domain/entities/weekly_schedule_entity.dart';
import 'package:drop/features/schedule/presentation/widgets/schedule_helpers.dart';

/// One (day, shift) slot in the weekly grid.
typedef SlotKey = (ScheduleDay, ScheduleShift);

/// The clickable insight categories on the schedule's insight strip. Each is a
/// **fact** derived from the roster — never a staffing target or quota (a
/// settled product rejection): an empty shift is information for the admin's
/// judgment, not a flagged fault.
enum ScheduleInsightKind { open, onePerson, doubleBooked }

/// Facts derived from the week's roster, computed once per build by
/// [computeScheduleInsights] and consumed by the insight strip (counts) and
/// the grid (cell highlighting + per-chip conflict dots).
class ScheduleInsights {
  const ScheduleInsights({
    required this.openSlots,
    required this.onePersonSlots,
    required this.conflictSlots,
    required this.doubleBookedByDay,
  });

  /// Slots with no (resolvable) assignee.
  final Set<SlotKey> openSlots;

  /// Slots covered by exactly one person.
  final Set<SlotKey> onePersonSlots;

  /// Both slots of any day that has at least one double-booked person.
  final Set<SlotKey> conflictSlots;

  /// Per day: the people assigned to BOTH shifts of that day — the one real
  /// conflict the current one-slot-per-shift model can express.
  final Map<ScheduleDay, Set<String>> doubleBookedByDay;

  int get openCount => openSlots.length;
  int get onePersonCount => onePersonSlots.length;
  int get doubleBookedCount =>
      doubleBookedByDay.values.fold(0, (sum, uids) => sum + uids.length);

  /// Nothing worth flagging — the strip collapses to a quiet all-clear line.
  bool get allClear =>
      openCount == 0 && onePersonCount == 0 && doubleBookedCount == 0;

  bool isDoubleBooked(ScheduleDay day, String uid) =>
      doubleBookedByDay[day]?.contains(uid) ?? false;

  Set<SlotKey> slotsFor(ScheduleInsightKind kind) => switch (kind) {
        ScheduleInsightKind.open => openSlots,
        ScheduleInsightKind.onePerson => onePersonSlots,
        ScheduleInsightKind.doubleBooked => conflictSlots,
      };
}

/// Derives the week's staffing facts from the schedule already in memory.
/// Orphaned (unresolvable) assignments never count as coverage — consistent
/// with [validAssignments] everywhere else. When a shift [filter] is active,
/// open / one-person facts consider only the visible shift; double-booking is
/// inherently cross-shift so it is always computed over both.
ScheduleInsights computeScheduleInsights(
  WeeklyScheduleEntity schedule,
  List<UserEntity> members, {
  ScheduleShift? filter,
}) {
  final open = <SlotKey>{};
  final onePerson = <SlotKey>{};
  final conflictSlots = <SlotKey>{};
  final doubleBookedByDay = <ScheduleDay, Set<String>>{};

  for (final day in ScheduleDay.values) {
    final morning = validAssignments(
        schedule.employeesFor(day, ScheduleShift.morning), members).toSet();
    final night = validAssignments(
        schedule.employeesFor(day, ScheduleShift.night), members).toSet();

    final both = morning.intersection(night);
    if (both.isNotEmpty) {
      doubleBookedByDay[day] = both;
      conflictSlots.add((day, ScheduleShift.morning));
      conflictSlots.add((day, ScheduleShift.night));
    }

    for (final shift in ScheduleShift.values) {
      if (filter != null && shift != filter) continue;
      final count =
          (shift == ScheduleShift.morning ? morning : night).length;
      if (count == 0) {
        open.add((day, shift));
      } else if (count == 1) {
        onePerson.add((day, shift));
      }
    }
  }

  return ScheduleInsights(
    openSlots: open,
    onePersonSlots: onePerson,
    conflictSlots: conflictSlots,
    doubleBookedByDay: doubleBookedByDay,
  );
}
