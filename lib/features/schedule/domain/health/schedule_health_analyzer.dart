import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/schedule/domain/entities/weekly_schedule_entity.dart';
import 'package:drop/features/schedule/domain/health/rules/conflict_rule.dart';
import 'package:drop/features/schedule/domain/health/rules/coverage_rule.dart';
import 'package:drop/features/schedule/domain/health/rules/fairness_rule.dart';
import 'package:drop/features/schedule/domain/health/rules/rest_rule.dart';
import 'package:drop/features/schedule/domain/health/rules/workload_rule.dart';
import 'package:drop/features/schedule/domain/health/schedule_analysis.dart';
import 'package:drop/features/schedule/domain/health/schedule_health_report.dart';
import 'package:drop/features/schedule/domain/health/schedule_rule.dart';

// One import for the whole engine.
export 'package:drop/features/schedule/domain/health/schedule_analysis.dart';
export 'package:drop/features/schedule/domain/health/schedule_health_report.dart';
export 'package:drop/features/schedule/domain/health/schedule_rule.dart';

/// The **Schedule Health Analyzer** — the single source of truth for a week's
/// quality. It reduces the roster to one shared [ScheduleAnalysis] (a single
/// pass), runs every [ScheduleRule] over it independently, and aggregates the
/// results into a [ScheduleHealthReport].
///
/// The engine is a pure, synchronous fold — **no async, no isolates**. Adding a
/// lens is one rule file + one entry in [defaultRules]; nothing here (or in the
/// existing rules) changes. The five rules never see each other, so they can be
/// reasoned about and unit-tested in isolation.
class ScheduleHealthAnalyzer {
  const ScheduleHealthAnalyzer({List<ScheduleRule>? rules})
      : rules = rules ?? defaultRules;

  final List<ScheduleRule> rules;

  /// The Phase-1 rule set, in reporting order.
  static const List<ScheduleRule> defaultRules = [
    CoverageRule(),
    WorkloadRule(),
    FairnessRule(),
    RestRule(),
    ConflictRule(),
  ];

  /// Analyzes [schedule] for [members]. [nameOf] renders display names (pass the
  /// view's `shortName` so findings match the grid); [previousSaturdayNight] is
  /// last week's Saturday-night crew, which closes the cross-week rest seam.
  ScheduleHealthReport analyze(
    WeeklyScheduleEntity schedule,
    List<UserEntity> members, {
    String Function(UserEntity user)? nameOf,
    Set<String> previousSaturdayNight = const {},
  }) {
    final analysis = ScheduleAnalysis.of(
      schedule,
      members,
      nameOf: nameOf,
      previousSaturdayNight: previousSaturdayNight,
    );
    return analyzeFrom(analysis);
  }

  /// Runs the rules over an already-built [analysis] — useful when a caller has
  /// the shared facts in hand and wants to avoid a second pass.
  ScheduleHealthReport analyzeFrom(ScheduleAnalysis analysis) {
    final results = [for (final rule in rules) rule.evaluate(analysis)];
    return ScheduleHealthReport.from(analysis, results);
  }
}
