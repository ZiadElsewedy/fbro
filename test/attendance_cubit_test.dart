import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/attendance_status.dart';
import 'package:drop/core/enums/schedule_day.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/core/enums/user_role.dart';
import 'package:drop/features/attendance/domain/attendance_break.dart';
import 'package:drop/features/attendance/domain/attendance_calculator.dart';
import 'package:drop/features/attendance/domain/attendance_validation.dart';
import 'package:drop/features/attendance/domain/entities/attendance_entity.dart';
import 'package:drop/features/attendance/domain/entities/attendance_event.dart';
import 'package:drop/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:drop/features/attendance/domain/usecases/clock_in.dart';
import 'package:drop/features/attendance/domain/usecases/clock_out.dart';
import 'package:drop/features/attendance/domain/usecases/end_break.dart';
import 'package:drop/features/attendance/domain/usecases/start_break.dart';
import 'package:drop/features/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:drop/features/attendance/presentation/cubit/attendance_state.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/schedule/domain/entities/weekly_schedule_entity.dart';
import 'package:drop/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:drop/features/schedule/domain/schedule_week.dart';

/// In-memory attendance repository — pushes the history stream + captures writes.
class _FakeAttendanceRepository implements AttendanceRepository {
  final _history = StreamController<List<AttendanceEntity>>.broadcast();

  final List<AttendanceEntity> clockedIn = [];
  final List<({String id, AttendanceStatus status, AttendanceTotals totals})>
      clockedOut = [];
  final List<List<AttendanceBreak>> breakWrites = [];

  void pushHistory(List<AttendanceEntity> h) => _history.add(h);

  @override
  Stream<List<AttendanceEntity>> watchUserHistory(String uid, {int limit = 30}) =>
      _history.stream;

  @override
  Future<void> clockIn(AttendanceEntity record) async => clockedIn.add(record);

  @override
  Future<void> clockOut(String id,
      {required DateTime clockOut,
      required AttendanceStatus status,
      required AttendanceTotals totals}) async {
    clockedOut.add((id: id, status: status, totals: totals));
  }

  @override
  Future<void> updateBreaks(String id, List<AttendanceBreak> breaks) async =>
      breakWrites.add(breaks);

  @override
  Future<String> uploadSelfie(
          {required String recordId,
          required File file,
          required String uploadedBy}) async =>
      'https://selfie';

  // Unused by these tests.
  @override
  Future<AttendanceEntity?> getRecord(String id) async => null;
  @override
  Stream<AttendanceEntity?> watchRecord(String id) => const Stream.empty();
  @override
  Stream<List<AttendanceEntity>> watchBranchDay(String b, String d) =>
      const Stream.empty();
  @override
  Stream<List<AttendanceEntity>> watchBranchRange(String b, String s, String e) =>
      const Stream.empty();
  @override
  Stream<List<AttendanceEvent>> watchEvents(String id) => const Stream.empty();
  @override
  Future<void> softDelete(String id) async {}
}

/// Minimal schedule repository fake — only [getSchedule] matters here.
class _FakeScheduleRepository implements ScheduleRepository {
  WeeklyScheduleEntity? schedule;
  _FakeScheduleRepository(this.schedule);

  @override
  Future<WeeklyScheduleEntity?> getSchedule(String branchId, DateTime weekStart) async =>
      schedule;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  final user = UserEntity(
    uid: 'u1',
    email: 'u@x.com',
    authProvider: 'password',
    displayName: 'Ziad',
    role: UserRole.employee,
    branchId: 'b1',
    isActive: true,
  );

  // A fixed "now": Monday 2026-07-13, 09:00 (inside a morning shift window).
  final now = DateTime(2026, 7, 13, 9);

  WeeklyScheduleEntity rosterAllMornings() => WeeklyScheduleEntity(
        id: 'b1_w',
        branchId: 'b1',
        weekStart: ScheduleWeek.startOf(now),
        assignments: {
          for (final d in ScheduleDay.values)
            d: {
              ScheduleShift.morning: ['u1']
            },
        },
      );

  late _FakeAttendanceRepository repo;

  AttendanceCubit build({DateTime? at, bool noSchedule = false}) {
    repo = _FakeAttendanceRepository();
    return AttendanceCubit(
      repository: repo,
      scheduleRepository:
          _FakeScheduleRepository(noSchedule ? null : rosterAllMornings()),
      clockIn: ClockIn(repo),
      clockOut: ClockOut(repo),
      startBreak: StartBreak(repo),
      endBreak: EndBreak(repo),
      now: () => at ?? now,
    );
  }

  Future<void> pump() => Future<void>.delayed(Duration.zero);

  AttendanceEntity openRecord({List<AttendanceBreak> breaks = const []}) =>
      AttendanceEntity(
        id: 'u1_20260713_morning',
        userId: 'u1',
        branchId: 'b1',
        shift: ScheduleShift.morning,
        date: DateTime(2026, 7, 13),
        scheduledStart: DateTime(2026, 7, 13, 8, 30),
        scheduledEnd: DateTime(2026, 7, 13, 16, 30),
        clockIn: DateTime(2026, 7, 13, 8, 30),
        breaks: breaks,
        status: AttendanceStatus.inProgress,
      );

  test('load resolves today\'s shift + scheduled window', () async {
    final cubit = build();
    await cubit.load(user);
    repo.pushHistory([]);
    await pump();

    final loaded = cubit.state.maybeMap(loaded: (s) => s, orElse: () => null);
    expect(loaded, isNotNull);
    expect(loaded!.shift, ScheduleShift.morning);
    expect(loaded.scheduledStart, DateTime(2026, 7, 13, 8, 30));
    expect(loaded.scheduledEnd, DateTime(2026, 7, 13, 16, 30));
    expect(loaded.today, isNull);
    expect(loaded.config.enabled, isTrue);
    expect(cubit.clockInCheck.allowed, isTrue);
    await cubit.close();
  });

  test('clockIn inside the window writes an in-progress record', () async {
    final cubit = build();
    await cubit.load(user);
    repo.pushHistory([]);
    await pump();

    await cubit.clockIn();
    expect(repo.clockedIn, hasLength(1));
    final rec = repo.clockedIn.single;
    expect(rec.id, 'u1_20260713_morning');
    expect(rec.status, AttendanceStatus.inProgress);
    expect(rec.clockIn, now);
    expect(rec.scheduledStart, DateTime(2026, 7, 13, 8, 30));
    await cubit.close();
  });

  test('clockIn before the window opens is blocked (no write)', () async {
    final cubit = build(at: DateTime(2026, 7, 13, 7)); // opens 08:00
    await cubit.load(user);
    repo.pushHistory([]);
    await pump();

    expect(cubit.clockInCheck.reason, AttendanceBlock.outsideWindow);

    // The block surfaces a transient error, then the cubit re-emits loaded, so
    // capture the emissions rather than reading the final state.
    final states = <AttendanceState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.clockIn();
    await pump();
    await sub.cancel();

    expect(repo.clockedIn, isEmpty);
    expect(
      states.any((s) => s.maybeMap(error: (_) => true, orElse: () => false)),
      isTrue,
    );
    await cubit.close();
  });

  test('clockIn with no rostered shift is blocked', () async {
    final cubit = build(noSchedule: true); // getSchedule → null
    await cubit.load(user);
    repo.pushHistory([]);
    await pump();

    expect(cubit.clockInCheck.reason, AttendanceBlock.noActiveShift);
    await cubit.clockIn();
    expect(repo.clockedIn, isEmpty);
    await cubit.close();
  });

  test('clockOut finalizes with computed totals', () async {
    final cubit = build(at: DateTime(2026, 7, 13, 17)); // 30m overtime
    await cubit.load(user);
    repo.pushHistory([openRecord()]); // clocked in 08:30
    await pump();

    await cubit.clockOut();
    expect(repo.clockedOut, hasLength(1));
    final out = repo.clockedOut.single;
    expect(out.id, 'u1_20260713_morning');
    expect(out.status, AttendanceStatus.completed);
    expect(out.totals.workedMinutes, 510); // 08:30 → 17:00
    expect(out.totals.overtimeMinutes, 30);
    await cubit.close();
  });

  test('startBreak appends an open break; endBreak closes it', () async {
    final cubit = build(at: DateTime(2026, 7, 13, 12));
    await cubit.load(user);
    repo.pushHistory([openRecord()]);
    await pump();

    await cubit.startBreak();
    expect(repo.breakWrites, hasLength(1));
    expect(repo.breakWrites.last, hasLength(1));
    expect(repo.breakWrites.last.first.isOpen, isTrue);

    // Record now carries that open break; end it.
    repo.pushHistory([
      openRecord(breaks: [AttendanceBreak(start: DateTime(2026, 7, 13, 12))]),
    ]);
    await pump();
    await cubit.endBreak();
    expect(repo.breakWrites, hasLength(2));
    expect(repo.breakWrites.last.first.isOpen, isFalse); // closed
    await cubit.close();
  });

  test('clockOut is blocked while a break is running', () async {
    final cubit = build(at: DateTime(2026, 7, 13, 16));
    await cubit.load(user);
    repo.pushHistory([
      openRecord(breaks: [AttendanceBreak(start: DateTime(2026, 7, 13, 12))]),
    ]);
    await pump();

    expect(cubit.clockOutCheck.reason, AttendanceBlock.openBreak);
    await cubit.clockOut();
    expect(repo.clockedOut, isEmpty);
    await cubit.close();
  });

  test('the live timer is cancelled on close (no pending timer)', () async {
    final cubit = build();
    await cubit.load(user);
    repo.pushHistory([openRecord()]); // open session → timer starts
    await pump();
    await cubit.close(); // must cancel the periodic timer
  });
}
