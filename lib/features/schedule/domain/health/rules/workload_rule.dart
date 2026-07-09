import 'package:drop/features/schedule/domain/health/schedule_analysis.dart';
import 'package:drop/features/schedule/domain/health/schedule_rule.dart';

/// **Workload** — how much is on each person, and is it shared evenly?
///
/// Hours are a wellbeing *fact*, not a cap: a long week is flagged for the
/// manager's judgment (part-timers, volunteers and crunch weeks are all leg
/// reasons to keep it). Three lenses:
///  - **weekly hours** past a long-week threshold;
///  - **shift volume** (a very full week, doubles included);
///  - an **uneven spread** between the busiest and quietest scheduled person.
class WorkloadRule extends ScheduleRule {
  const WorkloadRule();

  /// A long week (48h) and a heavy week (55h) — the wellbeing waterline, not a
  /// contractual cap.
  static const _longWeekMinutes = 48 * 60;
  static const _heavyWeekMinutes = 55 * 60;

  @override
  ScheduleRuleCategory get category => ScheduleRuleCategory.workload;

  @override
  ScheduleRuleResult evaluate(ScheduleAnalysis analysis) {
    final findings = <RuleFinding>[];

    for (final m in analysis.members) {
      if (m.totalMinutes > _longWeekMinutes) {
        final heavy = m.totalMinutes > _heavyWeekMinutes;
        findings.add(RuleFinding(
          category: category,
          severity: heavy
              ? ScheduleHealthSeverity.high
              : ScheduleHealthSeverity.medium,
          uid: m.uid,
          title: '${m.name} is scheduled ${_hours(m.totalMinutes)} this week',
          suggestion: 'Move a shift or two to a lighter teammate to keep the '
              'week sustainable.',
          penalty: heavy ? 12 : 6,
        ));
      }

      if (m.shiftCount >= 8) {
        findings.add(RuleFinding(
          category: category,
          severity: ScheduleHealthSeverity.medium,
          uid: m.uid,
          title: '${m.name} is on ${m.shiftCount} shifts this week',
          suggestion: 'Hand a couple of ${m.name}\'s shifts to the rest of the '
              'team.',
          penalty: 8,
        ));
      }
    }

    // Team spread — a caution (part-timers exist), so it stays low severity.
    final working = analysis.workingMembers;
    if (working.length >= 2) {
      var heaviest = working.first;
      var lightest = working.first;
      for (final m in working) {
        if (m.workedDays > heaviest.workedDays) heaviest = m;
        if (m.workedDays < lightest.workedDays) lightest = m;
      }
      final spread = heaviest.workedDays - lightest.workedDays;
      if (spread >= 4) {
        findings.add(RuleFinding(
          category: category,
          severity: ScheduleHealthSeverity.low,
          title: 'Uneven load — ${heaviest.name} ${heaviest.workedDays}d vs '
              '${lightest.name} ${lightest.workedDays}d',
          suggestion: 'If both are full-time, shift a day or two toward the '
              'lighter side of the roster.',
          penalty: 5,
        ));
      }
    }

    return ScheduleRuleResult.from(category, findings);
  }

  static String _hours(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}
