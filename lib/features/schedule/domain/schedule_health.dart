import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/schedule/domain/entities/weekly_schedule_entity.dart';
import 'package:drop/features/schedule/domain/health/schedule_health_analyzer.dart';

/// Schedule Health — the **backward-compatible facade** over the modular
/// [ScheduleHealthAnalyzer] (Schedule V2 · Pillar 3). The rich, rule-based read
/// lives in `domain/health/` ([ScheduleHealthReport] + the coverage / workload /
/// fairness / rest / conflict rules); this file preserves the original public
/// surface — the [ScheduleHealth] value type and [computeScheduleHealth] — so
/// nothing that consumed the pre-analyzer engine has to change.
///
/// It reads a person's **weekly pattern** (not individual shifts): grouped runs
/// of the same shift with a day off before switching (M·M·M·off·N·N·N) keep
/// sleep cycles stable; frequent morning ↔ night flips, night → next-morning
/// turnarounds and 6–7-day runs wear people down.
///
/// This is **advice, never enforcement** — findings are recommendations for the
/// manager's judgment and can never block an edit or a publish.
enum HealthFindingKind { shortRest, alternation, longStreak, unevenLoad }

/// One recommendation surfaced by the Schedule Health card. Person-level
/// findings carry the [uid]; team-level findings (workload spread) don't.
class HealthFinding {
  const HealthFinding({
    required this.kind,
    required this.title,
    required this.recommendation,
    this.uid,
  });

  final HealthFindingKind kind;
  final String? uid;

  /// What was observed — e.g. `Ahmed M. flips morning ↔ night 3× this week`.
  final String title;

  /// What to do about it — one actionable sentence.
  final String recommendation;
}

/// The week's overall health read: a 0–100 [score], its label, and the
/// per-person / team [findings] that explain it.
class ScheduleHealth {
  const ScheduleHealth({required this.score, required this.findings});

  final int score;
  final List<HealthFinding> findings;

  bool get isHealthy => findings.isEmpty;

  String get label => score >= 85
      ? 'Healthy'
      : score >= 60
          ? 'Fair'
          : 'Strained';
}

/// Computes the legacy [ScheduleHealth] for a week. **Preserved verbatim** for
/// backward compatibility: it delegates to the [ScheduleHealthAnalyzer] and then
/// projects the analyzer's shared facts back through the original scoring
/// formula, so its score, findings and wording are byte-for-byte what they were
/// before the analyzer existed.
///
/// New surfaces should consume the richer [ScheduleHealthReport] via
/// `ScheduleHealthAnalyzer().analyze(...)`; this remains the compatibility path.
///
/// [nameOf] renders a person's display name (the view passes its `shortName`
/// helper so health text matches the grid chips). [previousSaturdayNight] —
/// last week's Saturday-night crew — lets the Sunday-morning turnaround count as
/// a short rest too.
ScheduleHealth computeScheduleHealth(
  WeeklyScheduleEntity schedule,
  List<UserEntity> members, {
  String Function(UserEntity user)? nameOf,
  Set<String> previousSaturdayNight = const {},
}) {
  final report = const ScheduleHealthAnalyzer().analyze(
    schedule,
    members,
    nameOf: nameOf,
    previousSaturdayNight: previousSaturdayNight,
  );
  return scheduleHealthFromReport(report);
}

/// Projects a [ScheduleHealthReport] onto the legacy [ScheduleHealth] shape
/// using the original scoring formula over the report's shared [ScheduleAnalysis]
/// — the single place the pre-analyzer numbers are reproduced. Kept separate
/// (not the report's own scoring) precisely so the modern rules stay free to use
/// their own wording and weights without disturbing this frozen contract.
ScheduleHealth scheduleHealthFromReport(ScheduleHealthReport report) {
  final a = report.analysis;
  final findings = <HealthFinding>[];
  var score = 100;

  for (final m in a.members) {
    if (m.shortRests > 0) {
      score -= 10 * m.shortRests;
      findings.add(HealthFinding(
        kind: HealthFindingKind.shortRest,
        uid: m.uid,
        title: m.shortRests == 1
            ? '${m.name} opens the morning right after a night shift'
            : '${m.name} opens the morning right after a night shift '
                '${m.shortRests}×',
        recommendation:
            'Leave a day off (or keep them on nights) between a night shift '
            'and their next morning.',
      ));
    }
    if (m.shortRests + m.alternations >= 2) {
      score -= 6;
      findings.add(HealthFinding(
        kind: HealthFindingKind.alternation,
        uid: m.uid,
        title: '${m.name} flips between morning and night '
            '${m.shortRests + m.alternations}× this week',
        recommendation:
            'Group their morning shifts together, then their night shifts — '
            'a day off between the two runs keeps their sleep steady.',
      ));
    }
    if (m.longestRun >= 6) {
      score -= m.longestRun >= 7 ? 16 : 8;
      findings.add(HealthFinding(
        kind: HealthFindingKind.longStreak,
        uid: m.uid,
        title: '${m.name} works ${m.longestRun} days in a row',
        recommendation: 'Add a day off mid-week to break the run.',
      ));
    }
    // Double-booked days quietly weigh on the score (the insight strip already
    // names them, so no duplicate finding here).
    score -= 8 * m.doubleBookedDays;
  }

  // Team-level: a big spread between the heaviest and lightest scheduled
  // person. A fact for judgment (part-timers exist), so caution not fault.
  final working = a.workingMembers;
  if (working.length >= 2) {
    var heaviest = working.first;
    var lightest = working.first;
    for (final m in working) {
      if (m.workedDays > heaviest.workedDays) heaviest = m;
      if (m.workedDays < lightest.workedDays) lightest = m;
    }
    final spread = heaviest.workedDays - lightest.workedDays;
    if (spread >= 4) {
      score -= 5;
      findings.add(HealthFinding(
        kind: HealthFindingKind.unevenLoad,
        title: 'Workload is uneven: ${heaviest.name} '
            '${heaviest.workedDays} days · ${lightest.name} '
            '${lightest.workedDays}',
        recommendation:
            'If both are full-time, shift a day or two toward the lighter '
            'side of the roster.',
      ));
    }
  }

  // Most pressing first: short rest > flips > long runs > balance.
  findings.sort((a, b) => a.kind.index.compareTo(b.kind.index));
  return ScheduleHealth(score: score.clamp(0, 100), findings: findings);
}
