import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/leave_type.dart';
import 'package:drop/core/enums/schedule_day.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/schedule/domain/entities/weekly_schedule_entity.dart';
import 'package:drop/features/schedule/domain/health/rules/conflict_rule.dart';
import 'package:drop/features/schedule/domain/health/rules/coverage_rule.dart';
import 'package:drop/features/schedule/domain/health/rules/fairness_rule.dart';
import 'package:drop/features/schedule/domain/health/rules/rest_rule.dart';
import 'package:drop/features/schedule/domain/health/rules/workload_rule.dart';
import 'package:drop/features/schedule/domain/health/schedule_health_analyzer.dart';
import 'package:drop/features/schedule/domain/schedule_health.dart';

UserEntity _member(String uid, String name) => UserEntity(
    uid: uid,
    email: '$uid@drop.test',
    displayName: name,
    authProvider: 'password');

WeeklyScheduleEntity _schedule(
  Map<ScheduleDay, Map<ScheduleShift, List<String>>> assignments, {
  Map<ScheduleDay, Map<String, LeaveType>> leave = const {},
}) =>
    WeeklyScheduleEntity(
      id: 'b1_2026-06-14',
      branchId: 'b1',
      weekStart: DateTime(2026, 6, 14),
      assignments: assignments,
      leave: leave,
    );

/// A single-shift day for a person, sugar for readable schedules.
Map<ScheduleShift, List<String>> _m(List<String> uids) =>
    {ScheduleShift.morning: uids};
Map<ScheduleShift, List<String>> _n(List<String> uids) =>
    {ScheduleShift.night: uids};

ScheduleAnalysis _analyze(
  WeeklyScheduleEntity schedule,
  List<UserEntity> members,
) =>
    ScheduleAnalysis.of(schedule, members);

void main() {
  final ahmed = _member('u1', 'Ahmed Maher');
  final omar = _member('u2', 'Omar Ali');
  final sara = _member('u3', 'Sara Nabil');

  // ── Individual, independent rules ──────────────────────────────
  group('CoverageRule', () {
    test('flags a gap in a shift the branch clearly runs most days', () {
      // Morning covered Sun–Thu, missing Fri + Sat → a gap against its own
      // rhythm. (Two people per slot keeps lone-cover out of it.)
      final result = const CoverageRule().evaluate(_analyze(
        _schedule({
          for (final d in [
            ScheduleDay.sunday,
            ScheduleDay.monday,
            ScheduleDay.tuesday,
            ScheduleDay.wednesday,
            ScheduleDay.thursday,
          ])
            d: _m(['u1', 'u2']),
        }),
        [ahmed, omar],
      ));

      expect(result.findings, hasLength(1));
      expect(result.findings.single.title, contains('No morning cover'));
      expect(result.findings.single.title, contains('Fri, Sat'));
      expect(result.severity, ScheduleHealthSeverity.medium);
      expect(result.score, 96);
    });

    test('flags many single-person shifts only when pairing is possible', () {
      // Three people, every slot a lone shift → coverage note. Fewer than three
      // working people would exempt it (solo cover by necessity).
      final result = const CoverageRule().evaluate(_analyze(
        _schedule({
          ScheduleDay.sunday: {
            ScheduleShift.morning: ['u1'],
            ScheduleShift.night: ['u2'],
          },
          ScheduleDay.monday: {
            ScheduleShift.morning: ['u2'],
            ScheduleShift.night: ['u3'],
          },
          ScheduleDay.tuesday: {
            ScheduleShift.morning: ['u3'],
            ScheduleShift.night: ['u1'],
          },
        }),
        [ahmed, omar, sara],
      ));

      expect(result.findings, hasLength(1));
      expect(result.findings.single.title,
          contains('single person on the floor'));
      expect(result.severity, ScheduleHealthSeverity.low);
    });

    test('flags spare hands stacked next to a thin slot', () {
      final result = const CoverageRule().evaluate(_analyze(
        _schedule({
          ScheduleDay.sunday: _m(['u1', 'u2', 'u3']),
          ScheduleDay.monday: _m(['u1']),
        }),
        [ahmed, omar, sara],
      ));

      expect(result.findings.any((f) => f.title.contains('stack 3 people')),
          isTrue);
    });

    test('a two-person branch running solo is not a coverage fault', () {
      // Both cover every day, single-handed — unavoidable at two people.
      final result = const CoverageRule().evaluate(_analyze(
        _schedule({
          for (final d in ScheduleDay.values)
            d: {
              ScheduleShift.morning: ['u1'],
              ScheduleShift.night: ['u2'],
            },
        }),
        [ahmed, omar],
      ));
      expect(result.isHealthy, isTrue);
    });
  });

  group('WorkloadRule', () {
    test('flags a heavy weekly-hours load', () {
      final result = const WorkloadRule().evaluate(_analyze(
        _schedule({for (final d in ScheduleDay.values) d: _m(['u1'])}),
        [ahmed],
      ));
      final hours = result.findings.where((f) => f.title.contains('scheduled'));
      expect(hours, hasLength(1));
      expect(hours.single.title, contains('56h'));
      expect(hours.single.severity, ScheduleHealthSeverity.high);
    });

    test('flags a person carrying too many shifts', () {
      // 7 mornings + one extra night = 8 shifts.
      final result = const WorkloadRule().evaluate(_analyze(
        _schedule({
          for (final d in ScheduleDay.values) d: _m(['u1']),
          ScheduleDay.sunday: {
            ScheduleShift.morning: ['u1'],
            ScheduleShift.night: ['u1'],
          },
        }),
        [ahmed],
      ));
      expect(result.findings.any((f) => f.title.contains('8 shifts')), isTrue);
    });

    test('flags an uneven spread across the team', () {
      final result = const WorkloadRule().evaluate(_analyze(
        _schedule({
          ScheduleDay.sunday: _m(['u1']),
          ScheduleDay.monday: _m(['u1']),
          ScheduleDay.tuesday: _m(['u1']),
          ScheduleDay.wednesday: _m(['u1']),
          ScheduleDay.thursday: _m(['u1']),
          ScheduleDay.saturday: _n(['u2']),
        }),
        [ahmed, omar],
      ));
      final uneven = result.findings.where((f) => f.uid == null).toList();
      expect(uneven, hasLength(1));
      expect(uneven.single.title, contains('Uneven load'));
      expect(uneven.single.title, contains('Ahmed'));
      expect(uneven.single.title, contains('Omar'));
    });
  });

  group('FairnessRule', () {
    test('flags nights concentrated on one person', () {
      final result = const FairnessRule().evaluate(_analyze(
        _schedule({
          ScheduleDay.sunday: _n(['u1']),
          ScheduleDay.monday: _n(['u1']),
          ScheduleDay.tuesday: _n(['u1']),
          ScheduleDay.wednesday: _n(['u1']),
          ScheduleDay.thursday: _n(['u2']),
        }),
        [ahmed, omar],
      ));
      expect(result.findings, hasLength(1));
      expect(result.findings.single.title, contains('Night shifts lean on'));
      expect(result.findings.single.title, contains('4 of 5'));
      expect(result.findings.single.uid, 'u1');
    });

    test('flags weekend shifts concentrated on one person', () {
      final result = const FairnessRule().evaluate(_analyze(
        _schedule({
          ScheduleDay.thursday: _m(['u1']),
          ScheduleDay.friday: _m(['u1']),
          ScheduleDay.saturday: _m(['u1']),
          ScheduleDay.sunday: _m(['u2']),
        }),
        [ahmed, omar],
      ));
      expect(
          result.findings.any((f) => f.title.contains('Weekend shifts lean on')),
          isTrue);
    });

    test('balanced nights and mornings are fair', () {
      final result = const FairnessRule().evaluate(_analyze(
        _schedule({
          ScheduleDay.sunday: {
            ScheduleShift.morning: ['u1'],
            ScheduleShift.night: ['u2'],
          },
          ScheduleDay.monday: {
            ScheduleShift.morning: ['u1'],
            ScheduleShift.night: ['u2'],
          },
          ScheduleDay.tuesday: {
            ScheduleShift.morning: ['u1'],
            ScheduleShift.night: ['u2'],
          },
          ScheduleDay.thursday: {
            ScheduleShift.morning: ['u2'],
            ScheduleShift.night: ['u1'],
          },
          ScheduleDay.friday: {
            ScheduleShift.morning: ['u2'],
            ScheduleShift.night: ['u1'],
          },
          ScheduleDay.saturday: {
            ScheduleShift.morning: ['u2'],
            ScheduleShift.night: ['u1'],
          },
        }),
        [ahmed, omar],
      ));
      expect(result.isHealthy, isTrue);
    });

    test('a one-person branch cannot be unfair', () {
      final result = const FairnessRule().evaluate(_analyze(
        _schedule({for (final d in ScheduleDay.values) d: _n(['u1'])}),
        [ahmed],
      ));
      expect(result.isHealthy, isTrue);
    });
  });

  group('RestRule', () {
    test('flags a night → next-morning short rest', () {
      final result = const RestRule().evaluate(_analyze(
        _schedule({
          ScheduleDay.monday: _n(['u1']),
          ScheduleDay.tuesday: _m(['u1']),
        }),
        [ahmed],
      ));
      expect(result.findings, hasLength(1));
      expect(result.findings.single.title, contains('right after a night'));
      expect(result.findings.single.severity, ScheduleHealthSeverity.medium);
      expect(result.score, 90);
    });

    test('flags a long run of consecutive nights', () {
      final result = const RestRule().evaluate(_analyze(
        _schedule({
          ScheduleDay.sunday: _n(['u1']),
          ScheduleDay.monday: _n(['u1']),
          ScheduleDay.tuesday: _n(['u1']),
          ScheduleDay.wednesday: _n(['u1']),
        }),
        [ahmed],
      ));
      expect(result.findings, hasLength(1));
      expect(result.findings.single.title, contains('4 night shifts in a row'));
    });

    test('flags a six-day run without a break', () {
      final result = const RestRule().evaluate(_analyze(
        _schedule({
          for (final d in [
            ScheduleDay.sunday,
            ScheduleDay.monday,
            ScheduleDay.tuesday,
            ScheduleDay.wednesday,
            ScheduleDay.thursday,
            ScheduleDay.friday,
          ])
            d: _m(['u1']),
        }),
        [ahmed],
      ));
      expect(result.findings.any((f) => f.title.contains('6 days in a row')),
          isTrue);
    });
  });

  group('ConflictRule', () {
    test('flags a person double-booked on both shifts of a day', () {
      final result = const ConflictRule().evaluate(_analyze(
        _schedule({
          ScheduleDay.monday: {
            ScheduleShift.morning: ['u1'],
            ScheduleShift.night: ['u1'],
          },
        }),
        [ahmed],
      ));
      expect(result.findings, hasLength(1));
      expect(result.findings.single.title, contains('both shifts on Monday'));
      expect(result.findings.single.severity, ScheduleHealthSeverity.high);
    });

    test('flags a uid listed twice in the same slot', () {
      final result = const ConflictRule().evaluate(_analyze(
        _schedule({
          ScheduleDay.monday: {
            ScheduleShift.morning: ['u1', 'u1'],
          },
        }),
        [ahmed],
      ));
      expect(result.findings.any((f) => f.title.contains('listed twice')),
          isTrue);
    });

    test('flags a shift assigned on a day the person is on leave', () {
      final result = const ConflictRule().evaluate(_analyze(
        _schedule(
          {ScheduleDay.monday: _m(['u1'])},
          leave: {
            ScheduleDay.monday: {'u1': LeaveType.sick},
          },
        ),
        [ahmed],
      ));
      expect(result.findings, hasLength(1));
      expect(result.findings.single.title, contains('Monday'));
      expect(result.findings.single.title, contains('Sick'));
      expect(result.findings.single.severity, ScheduleHealthSeverity.medium);
    });
  });

  // ── Analyzer aggregation ───────────────────────────────────────
  group('ScheduleHealthAnalyzer', () {
    test('a grouped week with rest between switches is fully healthy', () {
      final report = const ScheduleHealthAnalyzer().analyze(
        _schedule({
          ScheduleDay.sunday: _m(['u1']),
          ScheduleDay.monday: _m(['u1']),
          ScheduleDay.tuesday: _m(['u1']),
          ScheduleDay.thursday: _n(['u1']),
          ScheduleDay.friday: _n(['u1']),
          ScheduleDay.saturday: _n(['u1']),
        }),
        [ahmed],
      );
      expect(report.isHealthy, isTrue);
      expect(report.overallScore, 100);
      expect(report.overallSeverity, ScheduleHealthSeverity.none);
      expect(report.label, 'Healthy');
      for (final r in report.results) {
        expect(r.isHealthy, isTrue, reason: '${r.category} should be healthy');
      }
    });

    test('aggregates penalties and ranks the most pressing finding first', () {
      // M·N·M·N·M — two short rests + a churn flag, all from the rest lens.
      final report = const ScheduleHealthAnalyzer().analyze(
        _schedule({
          ScheduleDay.sunday: _m(['u1']),
          ScheduleDay.monday: _n(['u1']),
          ScheduleDay.tuesday: _m(['u1']),
          ScheduleDay.wednesday: _n(['u1']),
          ScheduleDay.thursday: _m(['u1']),
        }),
        [ahmed],
      );
      expect(report.overallScore, 74);
      expect(report.overallSeverity, ScheduleHealthSeverity.high);
      expect(report.label, 'Fair');
      expect(report.findings, hasLength(2));
      expect(report.findings.first.category, ScheduleRuleCategory.rest);
      expect(report.findings.first.severity, ScheduleHealthSeverity.high);
      expect(report.rest.isHealthy, isFalse);
      expect(report.coverage.isHealthy, isTrue);
      expect(report.workload.isHealthy, isTrue);
      expect(report.fairness.isHealthy, isTrue);
      expect(report.conflicts.isHealthy, isTrue);
      expect(report.suggestions, isNotEmpty);
    });

    test('a self-conflicting roster leads with the conflict, still labelled', () {
      final report = const ScheduleHealthAnalyzer().analyze(
        _schedule({
          ScheduleDay.monday: {
            ScheduleShift.morning: ['u1'],
            ScheduleShift.night: ['u1'],
          },
        }),
        [ahmed],
      );
      expect(report.overallSeverity, ScheduleHealthSeverity.high);
      expect(report.findings.first.category, ScheduleRuleCategory.conflict);
      expect(report.overallScore, 92);
      expect(report.suggestions, isNotEmpty);
    });

    test('exposes the five results in order and per-person findings', () {
      final report = const ScheduleHealthAnalyzer().analyze(
        _schedule({
          ScheduleDay.monday: _n(['u1']),
          ScheduleDay.tuesday: _m(['u1']),
        }),
        [ahmed],
      );
      expect(report.results.map((r) => r.category), [
        ScheduleRuleCategory.coverage,
        ScheduleRuleCategory.workload,
        ScheduleRuleCategory.fairness,
        ScheduleRuleCategory.rest,
        ScheduleRuleCategory.conflict,
      ]);
      expect(report.findingsFor('u1'), isNotEmpty);
      expect(report.findingsFor('nobody'), isEmpty);
    });

    test('is open/closed — a custom rule set only runs those rules', () {
      expect(ScheduleHealthAnalyzer.defaultRules, hasLength(5));
      final report = const ScheduleHealthAnalyzer(rules: [RestRule()]).analyze(
        _schedule({
          ScheduleDay.monday: _n(['u1']),
          ScheduleDay.tuesday: _m(['u1']),
        }),
        [ahmed],
      );
      expect(report.rest.isHealthy, isFalse);
      // The other four fall back to a clean bill (never evaluated).
      expect(report.coverage.isHealthy, isTrue);
      expect(report.conflicts.isHealthy, isTrue);
    });
  });

  // ── Backward compatibility with computeScheduleHealth ──────────
  group('backward compatibility', () {
    test('computeScheduleHealth delegates to the analyzer, same result', () {
      final schedule = _schedule({
        ScheduleDay.sunday: _m(['u1']),
        ScheduleDay.monday: _n(['u1']),
        ScheduleDay.tuesday: _m(['u1']),
        ScheduleDay.wednesday: _n(['u1']),
        ScheduleDay.thursday: _m(['u1']),
      });
      final legacy = computeScheduleHealth(schedule, [ahmed]);
      final viaReport = scheduleHealthFromReport(
          const ScheduleHealthAnalyzer().analyze(schedule, [ahmed]));
      expect(viaReport.score, legacy.score);
      expect(viaReport.findings.map((f) => f.kind),
          legacy.findings.map((f) => f.kind));
      expect(legacy.score, 74);
    });

    test('a double booking keeps its silent legacy penalty (no legacy finding) '
        'while the report surfaces it', () {
      final schedule = _schedule({
        ScheduleDay.monday: {
          ScheduleShift.morning: ['u1'],
          ScheduleShift.night: ['u1'],
        },
      });
      // Legacy: −8, no finding (the pre-analyzer contract).
      final legacy = computeScheduleHealth(schedule, [ahmed]);
      expect(legacy.score, 92);
      expect(legacy.findings, isEmpty);
      // Report: the conflict is now a first-class finding.
      final report = const ScheduleHealthAnalyzer().analyze(schedule, [ahmed]);
      expect(report.conflicts.findings, hasLength(1));
    });
  });
}
