import 'package:drop/core/enums/schedule_day.dart';
import 'package:drop/features/schedule/domain/health/schedule_analysis.dart';
import 'package:drop/features/schedule/domain/health/schedule_rule.dart';

/// **Conflicts** — the roster contradicting itself. Unlike the other lenses
/// (which weigh *wellbeing*), these are things that should not be true at all:
///  - a **double booking** — the same person on both shifts of one day;
///  - a **duplicate** — a uid listed twice in the same slot (a data fault);
///  - an **invalid placement** — someone scheduled on a day they're on leave.
///
/// Still advisory (a manager may knowingly override a leave, e.g. a pending
/// request), but these sort to the top — a schedule that disagrees with itself
/// is the first thing to fix.
class ConflictRule extends ScheduleRule {
  const ConflictRule();

  @override
  ScheduleRuleCategory get category => ScheduleRuleCategory.conflict;

  @override
  ScheduleRuleResult evaluate(ScheduleAnalysis analysis) {
    final findings = <RuleFinding>[];

    for (final m in analysis.members) {
      // Double bookings — read straight off the precomputed day pattern.
      final doubled = <ScheduleDay>[
        for (var i = 0; i < m.byDay.length; i++)
          if (m.byDay[i].length > 1) ScheduleDay.values[i],
      ];
      if (doubled.isNotEmpty) {
        final days = doubled.map((d) => d.label).join(', ');
        findings.add(RuleFinding(
          category: category,
          severity: ScheduleHealthSeverity.high,
          uid: m.uid,
          title: '${m.name} is on both shifts on $days',
          suggestion: 'Assign ${m.name} one shift per day.',
          penalty: 8 * doubled.length,
        ));
      }

      // Duplicate entries in a single slot.
      for (final slot in m.duplicateSlots) {
        findings.add(RuleFinding(
          category: category,
          severity: ScheduleHealthSeverity.high,
          uid: m.uid,
          title: '${m.name} is listed twice on ${slot.$1.label} '
              '${slot.$2.label.toLowerCase()}',
          suggestion: 'Remove the duplicate entry so the slot counts once.',
          penalty: 8,
        ));
      }

      // Scheduled while marked on leave.
      for (final clash in m.leaveClashDays) {
        findings.add(RuleFinding(
          category: category,
          severity: ScheduleHealthSeverity.medium,
          uid: m.uid,
          title: '${m.name} is scheduled on ${clash.day.label} while marked '
              '"${clash.leave.label}"',
          suggestion: 'Clear the shift or the leave so the day is consistent.',
          penalty: 5,
        ));
      }
    }

    return ScheduleRuleResult.from(category, findings);
  }
}
