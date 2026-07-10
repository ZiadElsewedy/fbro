import 'package:drop/core/enums/schedule_day.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/features/schedule/domain/health/schedule_analysis.dart';
import 'package:drop/features/schedule/domain/health/schedule_rule.dart';

/// **Coverage** — is the floor actually staffed the way the week itself implies?
///
/// Deliberately **not a quota** (a settled product rejection: an empty shift is
/// information, not a fault). Every signal is relative to the branch's *own*
/// pattern:
///  - a **gap** is a shift the branch clearly runs (staffed 4–6 of 7 days) yet
///    missing on the odd day — an anomaly against its own norm, not a target;
///  - **lone shifts** only read as thin when there are ≥3 people who *could*
///    pair up (a 1–2 person branch runs solo by necessity);
///  - **overstaffing** only matters when it coexists with a thin/empty slot the
///    same week (spare hands next to a gap), never "more than N".
class CoverageRule extends ScheduleRule {
  const CoverageRule();

  @override
  ScheduleRuleCategory get category => ScheduleRuleCategory.coverage;

  @override
  ScheduleRuleResult evaluate(ScheduleAnalysis analysis) {
    final findings = <RuleFinding>[];

    // ── Gaps against the branch's own rhythm ──────────────────────
    _gap(analysis, ScheduleShift.morning, analysis.morningStaffedDays, findings);
    _gap(analysis, ScheduleShift.night, analysis.nightStaffedDays, findings);

    // ── Thin & spare coverage ─────────────────────────────────────
    var openSlots = 0;
    var loneSlots = 0;
    var maxCrew = 0;
    analysis.slotCounts.forEach((_, count) {
      if (count == 0) openSlots++;
      if (count == 1) loneSlots++;
      if (count > maxCrew) maxCrew = count;
    });

    // Lone shifts only read as a risk when pairing is actually possible.
    if (analysis.workingMembers.length >= 3 && loneSlots >= 3) {
      findings.add(RuleFinding(
        category: category,
        severity: ScheduleHealthSeverity.low,
        title: '$loneSlots shifts run with a single person on the floor',
        suggestion: 'Where you can, pair a second hand onto the busiest '
            'single-cover shifts.',
        penalty: 2,
      ));
    }

    // Spare hands next to a genuine gap (open OR lone slot) — an imbalance to
    // even out, never a hard "too many".
    if (maxCrew >= 3 && (openSlots > 0 || loneSlots > 0)) {
      findings.add(RuleFinding(
        category: category,
        severity: ScheduleHealthSeverity.low,
        title: 'Some shifts stack $maxCrew people while others run thin',
        suggestion: 'Move a hand from an overstaffed slot to a thin or open '
            'one to level the week.',
        penalty: 2,
      ));
    }

    return ScheduleRuleResult.from(category, findings);
  }

  /// A shift the branch runs most days (4–6 of 7) but leaves empty on the rest.
  void _gap(
    ScheduleAnalysis analysis,
    ScheduleShift shift,
    Set<ScheduleDay> staffedDays,
    List<RuleFinding> findings,
  ) {
    if (staffedDays.length < 4 || staffedDays.length >= 7) return;
    final missing = [
      for (final day in ScheduleDay.values)
        if (!staffedDays.contains(day)) day,
    ];
    if (missing.isEmpty) return;
    final label = shift.label.toLowerCase();
    final days = missing.map((d) => d.shortLabel).join(', ');
    findings.add(RuleFinding(
      category: category,
      severity: ScheduleHealthSeverity.medium,
      title: 'No $label cover on $days — the rest of the week is staffed',
      suggestion: 'Add a $label hand on $days, or confirm the branch is meant '
          'to be closed then.',
      penalty: 4,
    ));
  }
}
