import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/schedule_day.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/branch/domain/entities/branch_entity.dart';
import 'package:drop/features/schedule/domain/entities/weekly_schedule_entity.dart';
import 'package:drop/features/schedule/presentation/pages/schedule_final_view.dart';

void main() {
  const member = UserEntity(
    uid: 'u1',
    email: 'salah@drop.test',
    authProvider: 'password',
    displayName: 'Salah Ahmed',
  );
  const branch = BranchEntity(id: 'b1', name: 'Drop The Shop | Arkan');
  final schedule = WeeklyScheduleEntity(
    id: 'b1_2026-07-05',
    branchId: 'b1',
    weekStart: DateTime(2026, 7, 5),
    assignments: const {
      ScheduleDay.sunday: {
        ScheduleShift.morning: ['u1'],
      },
    },
  );

  testWidgets('renders a branded read-only roster snapshot', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ScheduleFinalView(
          schedule: schedule,
          members: const [member],
          branch: branch,
        ),
      ),
    );

    expect(find.text('Drop The Shop | Arkan'), findsOneWidget);
    expect(find.text('05/07 – 11/07'), findsOneWidget);
    expect(find.text('Salah A.'), findsOneWidget);
    expect(find.text('assignment'), findsOneWidget);
    expect(find.byType(Draggable), findsNothing);
  });

  testWidgets('clean screenshot hides preview controls', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ScheduleFinalView(
          schedule: schedule,
          members: const [member],
          branch: branch,
        ),
      ),
    );

    expect(find.text('Clean screenshot'), findsOneWidget);
    await tester.tap(find.text('Clean screenshot'));
    await tester.pump();

    expect(find.text('Clean screenshot'), findsNothing);
    expect(find.byTooltip('Close preview (Esc)'), findsNothing);
    expect(find.text('Drop The Shop | Arkan'), findsOneWidget);
  });
}
