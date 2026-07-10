import 'package:drop/core/enums/schedule_day.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/core/enums/leave_type.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/schedule/domain/entities/weekly_schedule_entity.dart';

/// One (day, shift) slot key — the atom the coverage / conflict rules reason
/// over. A Dart record, so it is a structural map key for free.
typedef HealthSlot = (ScheduleDay day, ScheduleShift shift);

/// One person's whole week, reduced to the raw signals every health rule reads.
///
/// This is **derived once** (in [ScheduleAnalysis.of]) and never recomputed —
/// each rule is a pure function of these numbers, so the rules never re-walk the
/// roster. Kept intentionally flat (ints, not opinions): a rule decides what is
/// *healthy*; this object only states what *is*.
class MemberWeek {
  const MemberWeek({
    required this.uid,
    required this.name,
    required this.byDay,
    required this.workedDays,
    required this.shiftCount,
    required this.morningCount,
    required this.nightCount,
    required this.weekendShifts,
    required this.totalMinutes,
    required this.longestRun,
    required this.longestNightRun,
    required this.shortRests,
    required this.alternations,
    required this.doubleBookedDays,
    required this.duplicateSlots,
    required this.leaveClashDays,
  });

  final String uid;

  /// Display name, resolved once through the caller's `nameOf` (falls back to
  /// display name / email) so every finding reads the same as the grid.
  final String name;

  /// Shifts worked each day, in week order (index 0 = Sunday … 6 = Saturday).
  /// An empty list = a day off; `[morning, night]` = a double-booked day.
  final List<List<ScheduleShift>> byDay;

  /// Days with at least one shift.
  final int workedDays;

  /// Total shifts across the week — a double-booked day counts as 2.
  final int shiftCount;

  final int morningCount;
  final int nightCount;

  /// Shifts worked on the operational weekend (Thu/Fri/Sat).
  final int weekendShifts;

  /// Scheduled minutes across the week (each slot's resolved, overnight-aware
  /// duration), so a late weekend close counts its real length.
  final int totalMinutes;

  /// Longest run of consecutive worked days (any shift).
  final int longestRun;

  /// Longest run of consecutive days that include a night shift.
  final int longestNightRun;

  /// Night → next-morning turnarounds (incl. the cross-week Saturday-night →
  /// Sunday-morning seam). The single tightest rest problem there is.
  final int shortRests;

  /// Adjacent morning↔night flips that are *not* short rests (a morning
  /// followed by a night — 24h apart, a soft sleep-cycle churn when repeated).
  final int alternations;

  /// Days scheduled on both the morning and the night slot.
  final int doubleBookedDays;

  /// Slots where this uid is listed more than once — a data-integrity fault.
  final List<HealthSlot> duplicateSlots;

  /// Days this person is assigned a shift while marked on leave.
  final List<({ScheduleDay day, LeaveType leave})> leaveClashDays;

  bool get isEmpty => workedDays == 0;
}

/// The week reduced to the raw facts the health rules read — computed in **one
/// pass** over `members × 7 days` and shared by every rule (and by the
/// backward-compatible legacy projection). No rule re-walks the roster; they
/// only read these precomputed numbers, so adding a rule adds no traversal.
class ScheduleAnalysis {
  const ScheduleAnalysis({
    required this.members,
    required this.slotCounts,
    required this.morningStaffedDays,
    required this.nightStaffedDays,
    required this.totalNightShifts,
    required this.totalWeekendShifts,
    required this.totalMorningShifts,
  });

  /// Per-member week signals, in the caller's member order.
  final List<MemberWeek> members;

  /// Valid (current-member) crew size per slot.
  final Map<HealthSlot, int> slotCounts;

  /// Days with at least one morning / night person — for data-driven coverage
  /// gaps (a shift the branch clearly runs, missing on a stray day).
  final Set<ScheduleDay> morningStaffedDays;
  final Set<ScheduleDay> nightStaffedDays;

  /// Team-wide shift totals (valid members only) — the denominators the
  /// fairness rule shares out.
  final int totalNightShifts;
  final int totalWeekendShifts;
  final int totalMorningShifts;

  /// Members who work at least one shift this week.
  List<MemberWeek> get workingMembers =>
      [for (final m in members) if (!m.isEmpty) m];

  /// Reduces the roster to the shared analysis in a single pass.
  ///
  /// [nameOf] renders a person's display name (the view passes its `shortName`
  /// helper so findings match the grid chips). [previousSaturdayNight] — last
  /// week's Saturday-night crew — lets the Sunday-morning turnaround count as a
  /// short rest too (the night slot lives in the previous week's doc).
  factory ScheduleAnalysis.of(
    WeeklyScheduleEntity schedule,
    List<UserEntity> members, {
    String Function(UserEntity user)? nameOf,
    Set<String> previousSaturdayNight = const {},
  }) {
    String resolveName(UserEntity u) =>
        nameOf?.call(u) ??
        (u.displayName?.trim().isNotEmpty == true
            ? u.displayName!.trim()
            : u.email);

    final memberSet = {for (final m in members) m.uid};
    final slotCounts = <HealthSlot, int>{};
    final morningStaffed = <ScheduleDay>{};
    final nightStaffed = <ScheduleDay>{};

    // Per-slot valid crew, computed once and reused by both the per-member
    // walk (below) and the coverage/fairness denominators.
    for (final day in ScheduleDay.values) {
      for (final shift in ScheduleShift.values) {
        final raw = schedule.employeesFor(day, shift);
        var count = 0;
        for (final uid in raw) {
          if (memberSet.contains(uid)) count++;
        }
        slotCounts[(day, shift)] = count;
        if (count > 0) {
          (shift == ScheduleShift.morning ? morningStaffed : nightStaffed)
              .add(day);
        }
      }
    }

    final weeks = <MemberWeek>[];
    var totalNight = 0;
    var totalWeekend = 0;
    var totalMorning = 0;

    for (final member in members) {
      final uid = member.uid;
      final byDay = <List<ScheduleShift>>[];
      // Single-shift-per-day pattern for the turnaround analysis: a day off or
      // a double-booked day is `null` (a double is a conflict, counted apart).
      final pattern = <ScheduleShift?>[];
      final duplicateSlots = <HealthSlot>[];
      final leaveClashDays = <({ScheduleDay day, LeaveType leave})>[];

      var workedDays = 0;
      var shiftCount = 0;
      var morning = 0;
      var night = 0;
      var weekendShifts = 0;
      var minutes = 0;
      var run = 0;
      var longestRun = 0;
      var nightRun = 0;
      var longestNightRun = 0;
      var doubleBookedDays = 0;

      for (final day in ScheduleDay.values) {
        final shifts = <ScheduleShift>[];
        for (final shift in ScheduleShift.values) {
          final raw = schedule.employeesFor(day, shift);
          if (!raw.contains(uid)) continue;
          shifts.add(shift);
          shiftCount++;
          if (shift == ScheduleShift.morning) {
            morning++;
          } else {
            night++;
          }
          if (day.isWeekend) weekendShifts++;
          minutes += schedule.hoursFor(day, shift).durationMinutes;
          // Listed twice in the same slot's list = a data-integrity fault.
          var seen = 0;
          for (final e in raw) {
            if (e == uid) seen++;
          }
          if (seen > 1) duplicateSlots.add((day, shift));
        }
        byDay.add(shifts);
        pattern.add(shifts.length == 1 ? shifts.first : null);

        if (shifts.isEmpty) {
          run = 0;
          nightRun = 0;
        } else {
          workedDays++;
          run++;
          if (run > longestRun) longestRun = run;
          if (shifts.contains(ScheduleShift.night)) {
            nightRun++;
            if (nightRun > longestNightRun) longestNightRun = nightRun;
          } else {
            nightRun = 0;
          }
          if (shifts.length > 1) doubleBookedDays++;
        }

        final leave = schedule.leaveTypeOf(uid, day);
        if (leave != null && shifts.isNotEmpty) {
          leaveClashDays.add((day: day, leave: leave));
        }
      }

      // Turnarounds over the single-shift pattern (matches the settled model:
      // night → next morning = short rest; morning → next night = alternation).
      var shortRests = 0;
      var alternations = 0;
      if (previousSaturdayNight.contains(uid) &&
          pattern.first == ScheduleShift.morning) {
        shortRests++;
      }
      for (var d = 1; d < pattern.length; d++) {
        final prev = pattern[d - 1];
        final curr = pattern[d];
        if (prev == null || curr == null || prev == curr) continue;
        if (prev == ScheduleShift.night && curr == ScheduleShift.morning) {
          shortRests++;
        } else {
          alternations++;
        }
      }

      totalNight += night;
      totalWeekend += weekendShifts;
      totalMorning += morning;

      weeks.add(MemberWeek(
        uid: uid,
        name: resolveName(member),
        byDay: byDay,
        workedDays: workedDays,
        shiftCount: shiftCount,
        morningCount: morning,
        nightCount: night,
        weekendShifts: weekendShifts,
        totalMinutes: minutes,
        longestRun: longestRun,
        longestNightRun: longestNightRun,
        shortRests: shortRests,
        alternations: alternations,
        doubleBookedDays: doubleBookedDays,
        duplicateSlots: duplicateSlots,
        leaveClashDays: leaveClashDays,
      ));
    }

    return ScheduleAnalysis(
      members: weeks,
      slotCounts: slotCounts,
      morningStaffedDays: morningStaffed,
      nightStaffedDays: nightStaffed,
      totalNightShifts: totalNight,
      totalWeekendShifts: totalWeekend,
      totalMorningShifts: totalMorning,
    );
  }
}
