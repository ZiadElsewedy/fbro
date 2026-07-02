import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/schedule_day.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:drop/features/auth/presentation/cubit/auth_state.dart';
import 'package:drop/features/schedule/domain/entities/weekly_schedule_entity.dart';
import 'package:drop/features/schedule/domain/schedule_week.dart';
import 'package:drop/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:drop/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:drop/features/schedule/presentation/cubit/shift_swap_cubit.dart';
import 'package:drop/features/schedule/presentation/cubit/shift_swap_state.dart';
import 'package:drop/features/schedule/presentation/pages/my_schedule_screen.dart';

/// Regression test for the mobile "blank My Week" bug: `TabBarView` disposes
/// the My Week tab when the user visits Swaps; on return the tab remounts with
/// its entrance AnimationController at 0.0, and — because the ScheduleCubit is
/// still `loaded` and emits nothing new — the BlocConsumer listener that plays
/// the animation never fires, leaving every section at opacity 0 forever.
///
/// The fakes emit loading→loaded back-to-back so the (infinitely pulsing)
/// DropLoadingState never mounts and pumpAndSettle terminates.

class _FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _FakeAuthCubit(UserEntity user) : super(AuthState.authenticated(user));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeScheduleCubit extends Cubit<ScheduleState>
    implements ScheduleCubit {
  _FakeScheduleCubit(this._view) : super(const ScheduleState.initial());
  final ScheduleState _view;

  @override
  Future<void> load({required String branchId, DateTime? weekStart}) async {
    emit(const ScheduleState.loading());
    emit(_view);
  }

  @override
  Future<void> refresh() => load(branchId: '');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeShiftSwapCubit extends Cubit<ShiftSwapState>
    implements ShiftSwapCubit {
  _FakeShiftSwapCubit() : super(const ShiftSwapState.initial());

  @override
  Future<void> loadMine(String uid, {bool force = false}) async {
    emit(const ShiftSwapState.loaded([]));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

UserEntity _employee() => const UserEntity(
      uid: 'u1',
      email: 'u1@drop.test',
      displayName: 'Ziad Sewedy',
      authProvider: 'password',
      branchId: 'b1',
    );

ScheduleState _loadedWeek(UserEntity user) {
  final weekStart = ScheduleWeek.currentWeekStart();
  return ScheduleState.loaded(
    branchId: 'b1',
    weekStart: weekStart,
    schedule: WeeklyScheduleEntity(
      id: 'b1_week',
      branchId: 'b1',
      weekStart: weekStart,
      assignments: {
        for (final day in ScheduleDay.values)
          day: {
            ScheduleShift.morning: [user.uid],
          },
      },
    ),
    members: [user],
  );
}

void main() {
  testWidgets('My Week stays visible after visiting Swaps and returning',
      (tester) async {
    final user = _employee();
    final scheduleCubit = _FakeScheduleCubit(_loadedWeek(user));
    final swapCubit = _FakeShiftSwapCubit();
    final authCubit = _FakeAuthCubit(user);
    addTearDown(() async {
      await scheduleCubit.close();
      await swapCubit.close();
      await authCubit.close();
    });

    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<ScheduleCubit>.value(value: scheduleCubit),
        BlocProvider<ShiftSwapCubit>.value(value: swapCubit),
      ],
      child: const MaterialApp(home: MyScheduleScreen()),
    ));
    // Post-frame _load() → loading → loaded → entrance animation plays.
    await tester.pumpAndSettle();

    // Nearest FadeTransition above the greeting = the entrance-stagger fade.
    double greetingOpacity() => tester
        .widget<FadeTransition>(find
            .ancestor(
              of: find.textContaining('👋'),
              matching: find.byType(FadeTransition),
            )
            .first)
        .opacity
        .value;

    expect(find.textContaining('👋'), findsOneWidget);
    expect(greetingOpacity(), 1.0, reason: 'initial entrance must complete');

    // Swaps tab and back — TabBarView disposes/remounts the My Week tab.
    await tester.tap(find.text('Swaps'));
    await tester.pumpAndSettle();
    expect(find.text('No swap requests'), findsOneWidget);

    await tester.tap(find.text('My Week'));
    await tester.pumpAndSettle();

    expect(find.textContaining('👋'), findsOneWidget);
    expect(
      greetingOpacity(),
      1.0,
      reason: 'the week must not remount invisible after returning from Swaps',
    );
  });
}
