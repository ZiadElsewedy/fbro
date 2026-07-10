import 'package:drop/features/schedule/domain/health/schedule_analysis.dart';

/// How serious one finding (or a whole rule / report) is. Ordered — a higher
/// [index] is worse — so aggregation is a plain `max`. **Advisory only:** even
/// [high] never blocks an edit or a publish (the settled advice-never-gate
/// stance); it just sorts to the top and colours the status dot.
enum ScheduleHealthSeverity {
  none,
  low,
  medium,
  high;

  /// The worse of two severities.
  ScheduleHealthSeverity orWorse(ScheduleHealthSeverity other) =>
      index >= other.index ? this : other;

  /// The worst severity across [severities], or [none] when empty.
  static ScheduleHealthSeverity worst(
      Iterable<ScheduleHealthSeverity> severities) {
    var worst = ScheduleHealthSeverity.none;
    for (final s in severities) {
      worst = worst.orWorse(s);
    }
    return worst;
  }
}

/// The five independent lenses the analyzer reads the week through. Each maps to
/// exactly one [ScheduleRule]; nothing branches on this beyond presentation
/// labelling, so a sixth lens is a new rule + a new value here — never an edit
/// to an existing rule (Open/Closed).
enum ScheduleRuleCategory {
  coverage,
  workload,
  fairness,
  rest,
  conflict;

  String get label => switch (this) {
        ScheduleRuleCategory.coverage => 'Coverage',
        ScheduleRuleCategory.workload => 'Workload',
        ScheduleRuleCategory.fairness => 'Fairness',
        ScheduleRuleCategory.rest => 'Rest',
        ScheduleRuleCategory.conflict => 'Conflicts',
      };
}

/// One thing a rule noticed: what was observed ([title]) and what to do about
/// it ([suggestion]). Person-level findings carry the [uid]; team-level ones
/// (workload spread, coverage gaps) leave it null. [penalty] is how many points
/// it removes from the category's — and the overall — 0–100 score.
class RuleFinding {
  const RuleFinding({
    required this.category,
    required this.severity,
    required this.title,
    required this.suggestion,
    this.uid,
    this.penalty = 0,
  });

  final ScheduleRuleCategory category;
  final ScheduleHealthSeverity severity;
  final String title;
  final String suggestion;
  final String? uid;
  final int penalty;
}

/// The outcome of running one [ScheduleRule] — a 0–100 [score] (100 = nothing
/// to flag), the worst [severity] among its [findings], and the de-duplicated
/// [suggestions] pulled from them. Built with [ScheduleRuleResult.from] so score
/// and severity can never drift from the findings that justify them.
class ScheduleRuleResult {
  const ScheduleRuleResult({
    required this.category,
    required this.score,
    required this.severity,
    required this.findings,
    required this.suggestions,
  });

  final ScheduleRuleCategory category;
  final int score;
  final ScheduleHealthSeverity severity;
  final List<RuleFinding> findings;
  final List<String> suggestions;

  bool get isHealthy => findings.isEmpty;

  /// Derives the score (100 − Σ penalties, clamped), severity (worst finding)
  /// and unique suggestions from [findings]. Findings are kept worst-first so
  /// the UI shows the most pressing item at the top of each category.
  factory ScheduleRuleResult.from(
    ScheduleRuleCategory category,
    List<RuleFinding> findings,
  ) {
    final sorted = [...findings]
      ..sort((a, b) => b.severity.index.compareTo(a.severity.index));
    var penalty = 0;
    for (final f in sorted) {
      penalty += f.penalty;
    }
    final suggestions = <String>[];
    for (final f in sorted) {
      if (f.suggestion.isNotEmpty && !suggestions.contains(f.suggestion)) {
        suggestions.add(f.suggestion);
      }
    }
    return ScheduleRuleResult(
      category: category,
      score: (100 - penalty).clamp(0, 100),
      severity: ScheduleHealthSeverity.worst(sorted.map((f) => f.severity)),
      findings: sorted,
      suggestions: suggestions,
    );
  }

  /// A clean bill of health for [category] — no findings, full score.
  factory ScheduleRuleResult.healthy(ScheduleRuleCategory category) =>
      ScheduleRuleResult(
        category: category,
        score: 100,
        severity: ScheduleHealthSeverity.none,
        findings: const [],
        suggestions: const [],
      );
}

/// A single, independent health check. Every rule is a **pure function** of the
/// shared [ScheduleAnalysis] — it reads precomputed signals, never the roster,
/// and never another rule. That is what keeps the set free of giant
/// switch/if-else chains: five small rules, each ~one screen, composed by the
/// analyzer.
abstract class ScheduleRule {
  const ScheduleRule();

  ScheduleRuleCategory get category;

  /// Evaluate this rule against the precomputed [analysis]. Pure and cheap —
  /// no I/O, no async, no allocation of new week walks.
  ScheduleRuleResult evaluate(ScheduleAnalysis analysis);
}
