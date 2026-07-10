import 'package:drop/features/schedule/domain/health/schedule_analysis.dart';
import 'package:drop/features/schedule/domain/health/schedule_rule.dart';

/// **Rest** — does the pattern leave people enough recovery? Grouped runs of the
/// same shift with a day off before switching (M·M·M·off·N·N·N) keep sleep
/// cycles stable; the tiring shapes are:
///  - a **short rest** — a night shift straight into the next morning (only
///    ~8–9h to commute, sleep, return), the cross-week Sat-night → Sun-morning
///    seam included;
///  - a **long night run** — several nights back to back;
///  - a **long streak** — 6–7 worked days without a break;
///  - **morning↔night churn** — flipping shift type repeatedly across the week.
class RestRule extends ScheduleRule {
  const RestRule();

  @override
  ScheduleRuleCategory get category => ScheduleRuleCategory.rest;

  @override
  ScheduleRuleResult evaluate(ScheduleAnalysis analysis) {
    final findings = <RuleFinding>[];

    for (final m in analysis.members) {
      if (m.shortRests > 0) {
        findings.add(RuleFinding(
          category: category,
          severity: m.shortRests >= 2
              ? ScheduleHealthSeverity.high
              : ScheduleHealthSeverity.medium,
          uid: m.uid,
          title: m.shortRests == 1
              ? '${m.name} opens a morning right after a night shift'
              : '${m.name} opens a morning right after a night shift '
                  '${m.shortRests}×',
          suggestion: 'Leave a day off (or another night) between a night and '
              'the next morning.',
          penalty: 10 * m.shortRests,
        ));
      }

      if (m.longestNightRun >= 4) {
        final heavy = m.longestNightRun >= 6;
        findings.add(RuleFinding(
          category: category,
          severity: heavy
              ? ScheduleHealthSeverity.high
              : ScheduleHealthSeverity.medium,
          uid: m.uid,
          title: '${m.name} works ${m.longestNightRun} night shifts in a row',
          suggestion: 'Break a long night run with a day off to let their sleep '
              'reset.',
          penalty: heavy ? 14 : 8,
        ));
      }

      if (m.longestRun >= 6) {
        final full = m.longestRun >= 7;
        findings.add(RuleFinding(
          category: category,
          severity:
              full ? ScheduleHealthSeverity.high : ScheduleHealthSeverity.medium,
          uid: m.uid,
          title: '${m.name} works ${m.longestRun} days in a row',
          suggestion: 'Add a day off mid-week to break the run.',
          penalty: full ? 16 : 8,
        ));
      }

      final flips = m.shortRests + m.alternations;
      if (flips >= 2) {
        findings.add(RuleFinding(
          category: category,
          severity: ScheduleHealthSeverity.low,
          uid: m.uid,
          title: '${m.name} flips between morning and night $flips× this week',
          suggestion: 'Group their mornings together, then their nights — a day '
              'off between the two runs keeps sleep steady.',
          penalty: 6,
        ));
      }
    }

    return ScheduleRuleResult.from(category, findings);
  }
}
