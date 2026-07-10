import 'package:drop/features/schedule/domain/health/schedule_analysis.dart';
import 'package:drop/features/schedule/domain/health/schedule_rule.dart';

/// **Fairness** — are the *unpopular* shifts shared, or do they always land on
/// the same person? Nights, weekends and (more rarely) mornings are the load
/// nobody wants stacked on them week after week.
///
/// Purely comparative, so it needs **≥2 people who work** — a one-person branch
/// can't be "unfair". A lens is only flagged when one person holds a **strict
/// majority** of that shift type *and* there are enough of them to matter
/// (spreading two nights isn't a fairness problem).
class FairnessRule extends ScheduleRule {
  const FairnessRule();

  @override
  ScheduleRuleCategory get category => ScheduleRuleCategory.fairness;

  @override
  ScheduleRuleResult evaluate(ScheduleAnalysis analysis) {
    final working = analysis.workingMembers;
    if (working.length < 2) {
      return ScheduleRuleResult.healthy(category);
    }

    final findings = <RuleFinding>[];

    _concentration(
      findings,
      working,
      total: analysis.totalNightShifts,
      of: (m) => m.nightCount,
      noun: 'Night shifts',
      minShare: 3,
      penalty: 6,
    );
    _concentration(
      findings,
      working,
      total: analysis.totalWeekendShifts,
      of: (m) => m.weekendShifts,
      noun: 'Weekend shifts',
      minShare: 3,
      penalty: 6,
    );
    _concentration(
      findings,
      working,
      total: analysis.totalMorningShifts,
      of: (m) => m.morningCount,
      noun: 'Morning shifts',
      // Mornings are plentiful, so only an overwhelming skew is worth a note.
      minShare: 5,
      onlyOverwhelming: true,
      penalty: 4,
    );

    return ScheduleRuleResult.from(category, findings);
  }

  /// Flags [noun] when one person carries a strict majority (and ≥ [minShare]).
  void _concentration(
    List<RuleFinding> findings,
    List<MemberWeek> working, {
    required int total,
    required int Function(MemberWeek) of,
    required String noun,
    required int minShare,
    required int penalty,
    bool onlyOverwhelming = false,
  }) {
    if (total < minShare) return;
    var top = working.first;
    for (final m in working) {
      if (of(m) > of(top)) top = m;
    }
    final share = of(top);
    if (share < minShare) return;
    // Strict majority — more than half of that shift type on one person.
    if (share * 2 <= total) return;
    // ≥75% reads as "overwhelming"; the morning lens needs that to fire at all.
    final overwhelming = share * 4 >= total * 3;
    if (onlyOverwhelming && !overwhelming) return;
    findings.add(RuleFinding(
      category: category,
      severity:
          overwhelming ? ScheduleHealthSeverity.medium : ScheduleHealthSeverity.low,
      uid: top.uid,
      title: '$noun lean on ${top.name} — $share of $total this week',
      suggestion: 'Spread the ${noun.toLowerCase()} across more of the team.',
      penalty: penalty,
    ));
  }
}
