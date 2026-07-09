import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/schedule_day.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/schedule/domain/entities/weekly_schedule_entity.dart';
import 'package:drop/features/schedule/domain/health/schedule_health_analyzer.dart';
import 'package:drop/features/schedule/presentation/widgets/schedule_health_card.dart';

/// Schedule V2 · Pillar 3 — the report-driven health card: overall score,
/// clickable category breakdown, richer findings.

UserEntity _member(String uid, String name) => UserEntity(
    uid: uid,
    email: '$uid@drop.test',
    displayName: name,
    authProvider: 'password');

WeeklyScheduleEntity _schedule(
        Map<ScheduleDay, Map<ScheduleShift, List<String>>> assignments) =>
    WeeklyScheduleEntity(
      id: 'b1_2026-06-14',
      branchId: 'b1',
      weekStart: DateTime(2026, 6, 14),
      assignments: assignments,
    );

ScheduleHealthReport _report(WeeklyScheduleEntity s, List<UserEntity> m) =>
    const ScheduleHealthAnalyzer().analyze(s, m);

void main() {
  final ahmed = _member('u1', 'Ahmed Maher');

  Future<void> pump(WidgetTester tester, ScheduleHealthReport report) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 420,
          child: ScheduleHealthCard(report: report),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the overall score and expands into a clickable breakdown',
      (tester) async {
    // M·N·M·N·M — a Fair week driven by the rest lens (score 74).
    final report = _report(
      _schedule({
        ScheduleDay.sunday: {ScheduleShift.morning: ['u1']},
        ScheduleDay.monday: {ScheduleShift.night: ['u1']},
        ScheduleDay.tuesday: {ScheduleShift.morning: ['u1']},
        ScheduleDay.wednesday: {ScheduleShift.night: ['u1']},
        ScheduleDay.thursday: {ScheduleShift.morning: ['u1']},
      }),
      [ahmed],
    );
    await pump(tester, report);

    // Collapsed: title + the /100 score.
    expect(find.text('Schedule health'), findsOneWidget);
    expect(find.text('74'), findsOneWidget);
    expect(find.text('/100'), findsOneWidget);
    // Findings are hidden until expanded.
    expect(find.textContaining('right after a night'), findsNothing);

    // Expand → the category breakdown + the findings appear.
    await tester.tap(find.text('Schedule health'));
    await tester.pumpAndSettle();
    expect(find.text('Rest'), findsOneWidget);
    expect(find.text('Conflicts'), findsOneWidget); // healthy chip still shown
    expect(find.textContaining('right after a night'), findsOneWidget);

    // Tapping the Rest lens filters to it (its findings stay visible).
    await tester.tap(find.text('Rest'));
    await tester.pumpAndSettle();
    expect(find.textContaining('right after a night'), findsOneWidget);
  });

  testWidgets('a healthy week reads calm and does not expand', (tester) async {
    // M·M·M·off·N·N·N — the canonical healthy shape.
    final report = _report(
      _schedule({
        ScheduleDay.sunday: {ScheduleShift.morning: ['u1']},
        ScheduleDay.monday: {ScheduleShift.morning: ['u1']},
        ScheduleDay.tuesday: {ScheduleShift.morning: ['u1']},
        ScheduleDay.thursday: {ScheduleShift.night: ['u1']},
        ScheduleDay.friday: {ScheduleShift.night: ['u1']},
        ScheduleDay.saturday: {ScheduleShift.night: ['u1']},
      }),
      [ahmed],
    );
    await pump(tester, report);

    expect(find.text('100'), findsOneWidget);
    expect(find.textContaining('Healthy'), findsOneWidget);
    // Nothing to expand → no breakdown chips.
    await tester.tap(find.text('Schedule health'));
    await tester.pumpAndSettle();
    expect(find.text('Rest'), findsNothing);
  });
}
