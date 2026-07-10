import 'package:drop/features/schedule/domain/health/schedule_analysis.dart';
import 'package:drop/features/schedule/domain/health/schedule_rule.dart';

/// The week's whole health read — the single object the UI consumes. It carries
/// the [overallScore] + [overallSeverity], each rule's [ScheduleRuleResult]
/// (coverage / workload / fairness / rest / conflicts) for a clickable
/// breakdown, and the flattened [findings] / [suggestions] across all of them.
///
/// **Advisory, never a gate** — a low score never blocks an edit or a publish;
/// it is a prompt for the manager's judgment.
class ScheduleHealthReport {
  const ScheduleHealthReport({
    required this.overallScore,
    required this.overallSeverity,
    required this.coverage,
    required this.workload,
    required this.fairness,
    required this.rest,
    required this.conflicts,
    required this.findings,
    required this.suggestions,
    required this.analysis,
  });

  /// 0–100, where 100 is nothing to flag. Aggregates every rule's penalties, so
  /// one badly-off category pulls the overall score down honestly (rather than
  /// being averaged away by the healthy ones).
  final int overallScore;
  final ScheduleHealthSeverity overallSeverity;

  final ScheduleRuleResult coverage;
  final ScheduleRuleResult workload;
  final ScheduleRuleResult fairness;
  final ScheduleRuleResult rest;
  final ScheduleRuleResult conflicts;

  /// Every finding across all rules, most-pressing first (severity, then
  /// conflict → rest → coverage → workload → fairness).
  final List<RuleFinding> findings;

  /// Every distinct suggestion across all rules, most-pressing first.
  final List<String> suggestions;

  /// The shared single-pass facts the rules read — exposed so the
  /// backward-compatible legacy projection reads the same numbers, and any
  /// other consumer can reuse them without re-walking the roster.
  final ScheduleAnalysis analysis;

  bool get isHealthy => findings.isEmpty;

  /// The five rule results in a fixed order, for the breakdown UI.
  List<ScheduleRuleResult> get results =>
      [coverage, workload, fairness, rest, conflicts];

  /// The label the compact health row shows — same thresholds the pre-analyzer
  /// card used, so the wording never jumps.
  String get label => overallScore >= 85
      ? 'Healthy'
      : overallScore >= 60
          ? 'Fair'
          : 'Strained';

  ScheduleRuleResult resultFor(ScheduleRuleCategory category) =>
      switch (category) {
        ScheduleRuleCategory.coverage => coverage,
        ScheduleRuleCategory.workload => workload,
        ScheduleRuleCategory.fairness => fairness,
        ScheduleRuleCategory.rest => rest,
        ScheduleRuleCategory.conflict => conflicts,
      };

  /// This person's findings across every rule (for the inspector's per-employee
  /// wellbeing flags).
  List<RuleFinding> findingsFor(String uid) =>
      [for (final f in findings) if (f.uid == uid) f];

  /// Assembles the report from the rule [results], flattening + ranking their
  /// findings and summing penalties into the overall score.
  factory ScheduleHealthReport.from(
    ScheduleAnalysis analysis,
    List<ScheduleRuleResult> results,
  ) {
    ScheduleRuleResult pick(ScheduleRuleCategory c) =>
        results.firstWhere((r) => r.category == c,
            orElse: () => ScheduleRuleResult.healthy(c));

    final all = <RuleFinding>[for (final r in results) ...r.findings];
    var penalty = 0;
    for (final f in all) {
      penalty += f.penalty;
    }
    all.sort((a, b) {
      final bySeverity = b.severity.index.compareTo(a.severity.index);
      if (bySeverity != 0) return bySeverity;
      return _urgency(a.category).compareTo(_urgency(b.category));
    });

    final suggestions = <String>[];
    for (final f in all) {
      if (f.suggestion.isNotEmpty && !suggestions.contains(f.suggestion)) {
        suggestions.add(f.suggestion);
      }
    }

    return ScheduleHealthReport(
      overallScore: (100 - penalty).clamp(0, 100),
      overallSeverity: ScheduleHealthSeverity.worst(all.map((f) => f.severity)),
      coverage: pick(ScheduleRuleCategory.coverage),
      workload: pick(ScheduleRuleCategory.workload),
      fairness: pick(ScheduleRuleCategory.fairness),
      rest: pick(ScheduleRuleCategory.rest),
      conflicts: pick(ScheduleRuleCategory.conflict),
      findings: all,
      suggestions: suggestions,
      analysis: analysis,
    );
  }

  /// Ranking of categories when severities tie — a self-contradicting roster
  /// (conflict) leads, cosmetic fairness trails.
  static int _urgency(ScheduleRuleCategory category) => switch (category) {
        ScheduleRuleCategory.conflict => 0,
        ScheduleRuleCategory.rest => 1,
        ScheduleRuleCategory.coverage => 2,
        ScheduleRuleCategory.workload => 3,
        ScheduleRuleCategory.fairness => 4,
      };
}
