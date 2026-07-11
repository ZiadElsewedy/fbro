import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drop/core/enums/leave_type.dart';
import 'package:drop/core/enums/schedule_day.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/core/errors/failures.dart';
import 'package:drop/features/attendance/domain/attendance_config.dart';
import 'package:drop/features/attendance/domain/attendance_id.dart';
import 'package:drop/features/attendance/domain/attendance_validation.dart';
import 'package:drop/features/attendance/domain/entities/attendance_entity.dart';
import 'package:drop/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:drop/features/attendance/domain/usecases/clock_in.dart';
import 'package:drop/features/attendance/domain/usecases/clock_out.dart';
import 'package:drop/features/attendance/domain/usecases/end_break.dart';
import 'package:drop/features/attendance/domain/usecases/start_break.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/schedule/domain/entities/weekly_schedule_entity.dart';
import 'package:drop/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:drop/features/schedule/domain/shift_window.dart';
import 'package:drop/features/schedule/domain/schedule_week.dart';
import 'attendance_state.dart';

/// The employee-facing attendance cubit — today's shift, the clock in/out/break
/// actions, the live session timer, and the employee's own history.
///
/// The whole surface is driven by **one** realtime stream — the employee's own
/// history ([AttendanceRepository.watchUserHistory]) — from which the active
/// session and today's record are derived. This keeps reads minimal and naturally
/// surfaces an **overnight** session (a night shift still open past midnight lives
/// in yesterday's record, which the recent-history window still contains).
///
/// Today's rostered shift + its scheduled instants are resolved once from the
/// existing schedule seam ([ScheduleRepository.getSchedule] +
/// `WeeklyScheduleEntity.shiftsFor` / `hoursFor` → [ShiftWindow]) — no attendance
/// re-derivation. Every clock action is gated by the pure [AttendanceValidation]
/// engine before a write, so the cubit never issues a write the rules would
/// reject.
class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepository _repository;
  final ScheduleRepository _scheduleRepository;
  final ClockIn _clockIn;
  final ClockOut _clockOut;
  final StartBreak _startBreak;
  final EndBreak _endBreak;

  /// Injectable clock (defaults to [DateTime.now]) — the single time source, so
  /// the clock-in window and the live timer are deterministic under test.
  final DateTime Function() _now;

  UserEntity? _user;
  _TodayContext? _ctx;
  AttendanceConfig _config = const AttendanceConfig(enabled: true);
  List<AttendanceEntity> _history = const [];
  StreamSubscription<List<AttendanceEntity>>? _sub;
  Timer? _timer;
  bool _busy = false;
  late DateTime _tick = _now();

  AttendanceCubit({
    required AttendanceRepository repository,
    required ScheduleRepository scheduleRepository,
    required ClockIn clockIn,
    required ClockOut clockOut,
    required StartBreak startBreak,
    required EndBreak endBreak,
    DateTime Function()? now,
  })  : _repository = repository,
        _scheduleRepository = scheduleRepository,
        _clockIn = clockIn,
        _clockOut = clockOut,
        _startBreak = startBreak,
        _endBreak = endBreak,
        _now = now ?? DateTime.now,
        super(const AttendanceState.initial());
  // Fields are assigned explicitly (named args read better at the call site than
  // `_`-prefixed initializing formals would).
  // ignore_for_file: prefer_initializing_formals

  // ─── Derived views over the current history + context ────────────────
  /// The live open session (in-progress, not clocked out), if any — may be an
  /// overnight session from yesterday.
  AttendanceEntity? get _activeRecord {
    for (final r in _history) {
      if (r.isOpen) return r;
    }
    return null;
  }

  /// Today's record for the resolved target shift (may be completed, or null).
  AttendanceEntity? get _todayTargetRecord {
    final id = _ctx?.targetRecordId;
    if (id == null) return null;
    for (final r in _history) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// The record the clock UI acts on.
  AttendanceEntity? get _clockRecord => _activeRecord ?? _todayTargetRecord;

  /// Whether the employee can clock in right now (and why not).
  AttendanceCheck get clockInCheck {
    final ctx = _ctx, user = _user;
    if (ctx == null || user == null) {
      return const AttendanceCheck(AttendanceBlock.notEnabled, 'Loading…');
    }
    return AttendanceValidation.checkClockIn(
      userActive: user.isActive,
      todaysShift: ctx.shift,
      leave: ctx.leave,
      scheduledStart: ctx.scheduledStart,
      scheduledEnd: ctx.scheduledEnd,
      existing: _todayTargetRecord,
      now: _now(),
      config: _config,
    );
  }

  /// Whether the employee can clock out right now (and why not).
  AttendanceCheck get clockOutCheck => AttendanceValidation.checkClockOut(
        existing: _activeRecord,
        now: _now(),
        config: _config,
      );

  static String _scopeKey(UserEntity u) => '${u.uid}:${u.branchId ?? ''}';

  Future<void> load(UserEntity user, {bool forceRefresh = false}) async {
    final sameScope = _user != null && _scopeKey(_user!) == _scopeKey(user);
    final inError = state.maybeWhen(error: (_) => true, orElse: () => false);
    if (!forceRefresh && !inError && _sub != null && sameScope) return;

    _user = user;
    _config = _resolveConfig(user);

    final hasData = state.maybeMap(loaded: (_) => true, orElse: () => false);
    if (!hasData) emit(const AttendanceState.loading());

    await _resolveContext(user);

    await _sub?.cancel();
    _sub = _repository.watchUserHistory(user.uid).listen(
      (history) {
        _history = history;
        _emitLoaded();
        _syncTimer();
      },
      onError: (Object e, StackTrace st) {
        developer.log('[ATTENDANCE] history stream error: $e',
            name: 'ATTENDANCE', error: e, stackTrace: st);
        emit(const AttendanceState.error('Failed to load attendance.'));
      },
    );
  }

  Future<void> refresh() async {
    final user = _user;
    if (user != null) await load(user, forceRefresh: true);
  }

  /// Config seam (branch-configurable later): today every branch runs the
  /// standing defaults with the module enabled. This is the single place to later
  /// read `branches/{id}/attendanceConfig` — no call site changes.
  AttendanceConfig _resolveConfig(UserEntity user) =>
      const AttendanceConfig(enabled: true);

  /// Resolve today's rostered shift + scheduled window from the schedule (one
  /// cached read). Degrades gracefully to "no shift" when nothing is rostered.
  Future<void> _resolveContext(UserEntity user) async {
    final now = _now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final day = ScheduleDay.fromDate(now);
    try {
      final branchId = user.branchId;
      if (branchId == null || branchId.isEmpty) {
        _ctx = _TodayContext(todayDate: todayDate);
        return;
      }
      final weekStart = ScheduleWeek.startOf(now);
      final schedule = await _scheduleRepository.getSchedule(branchId, weekStart);
      if (schedule == null) {
        _ctx = _TodayContext(todayDate: todayDate);
        return;
      }
      final leave = schedule.leaveTypeOf(user.uid, day);
      final shifts = schedule.shiftsFor(user.uid, day);
      final target = _pickTargetShift(shifts, schedule, weekStart, day, now);
      if (target == null) {
        _ctx = _TodayContext(todayDate: todayDate, leave: leave);
        return;
      }
      final hours = schedule.hoursFor(day, target);
      _ctx = _TodayContext(
        todayDate: todayDate,
        shift: target,
        leave: leave,
        scheduledStart: ShiftWindow.startOf(weekStart, day, hours),
        scheduledEnd: ShiftWindow.endOf(weekStart, day, hours),
        targetRecordId:
            attendanceDocId(uid: user.uid, date: todayDate, shift: target),
      );
    } catch (e, st) {
      developer.log('[ATTENDANCE] resolveContext failed: $e',
          name: 'ATTENDANCE', error: e, stackTrace: st);
      _ctx = _TodayContext(todayDate: todayDate);
    }
  }

  /// Of the shift(s) rostered today, the one the clock should target now: the
  /// first slot that hasn't finished yet (morning before night); if both are
  /// done, the later one.
  ScheduleShift? _pickTargetShift(
    List<ScheduleShift> shifts,
    WeeklyScheduleEntity schedule,
    DateTime weekStart,
    ScheduleDay day,
    DateTime now,
  ) {
    if (shifts.isEmpty) return null;
    if (shifts.length == 1) return shifts.first;
    ScheduleShift? last;
    for (final s in shifts) {
      last = s;
      final end = ShiftWindow.endOf(weekStart, day, schedule.hoursFor(day, s));
      if (now.isBefore(end)) return s;
    }
    return last;
  }

  void _emitLoaded() {
    if (isClosed) return;
    final ctx = _ctx;
    emit(AttendanceState.loaded(
      today: _clockRecord,
      history: _history,
      shift: ctx?.shift,
      scheduledStart: ctx?.scheduledStart,
      scheduledEnd: ctx?.scheduledEnd,
      leave: ctx?.leave,
      config: _config,
      tick: _tick,
      busy: _busy,
    ));
  }

  // ─── Clock actions ───────────────────────────────────────────────────
  Future<void> clockIn({File? selfie}) async {
    final user = _user, ctx = _ctx;
    if (user == null || ctx == null || _busy) return;
    final check = clockInCheck;
    if (check.blocked) {
      _surface(check.message);
      return;
    }
    final id = ctx.targetRecordId;
    final shift = ctx.shift;
    if (id == null || shift == null) return;

    _setBusy(true);
    try {
      final now = _now();
      String? photoUrl;
      if (selfie != null) {
        photoUrl = await _repository.uploadSelfie(
          recordId: id,
          file: selfie,
          uploadedBy: user.uid,
        );
      }
      final record = AttendanceEntity(
        id: id,
        userId: user.uid,
        userName: user.displayName,
        branchId: user.branchId,
        shift: shift,
        date: ctx.todayDate,
        scheduledStart: ctx.scheduledStart,
        scheduledEnd: ctx.scheduledEnd,
        clockIn: now,
        photoUrl: photoUrl,
      );
      await _clockIn(record);
    } on Failure catch (e) {
      _surface(e.message);
    } catch (_) {
      _surface('Something went wrong clocking in.');
    } finally {
      _setBusy(false);
    }
  }

  Future<void> clockOut() async {
    final user = _user;
    final record = _activeRecord;
    if (user == null || record == null || _busy) return;
    final check = clockOutCheck;
    if (check.blocked) {
      _surface(check.message);
      return;
    }
    _setBusy(true);
    try {
      await _clockOut(record, now: _now(), config: _config);
    } on Failure catch (e) {
      _surface(e.message);
    } catch (_) {
      _surface('Something went wrong clocking out.');
    } finally {
      _setBusy(false);
    }
  }

  Future<void> startBreak() async {
    final user = _user;
    final record = _activeRecord;
    if (user == null || record == null || _busy) return;
    final check = AttendanceValidation.checkStartBreak(existing: record);
    if (check.blocked) {
      _surface(check.message);
      return;
    }
    _setBusy(true);
    try {
      await _startBreak(record, now: _now());
    } on Failure catch (e) {
      _surface(e.message);
    } catch (_) {
      _surface('Something went wrong starting your break.');
    } finally {
      _setBusy(false);
    }
  }

  Future<void> endBreak() async {
    final user = _user;
    final record = _activeRecord;
    if (user == null || record == null || _busy) return;
    final check = AttendanceValidation.checkEndBreak(existing: record);
    if (check.blocked) {
      _surface(check.message);
      return;
    }
    _setBusy(true);
    try {
      await _endBreak(record, now: _now());
    } on Failure catch (e) {
      _surface(e.message);
    } catch (_) {
      _surface('Something went wrong ending your break.');
    } finally {
      _setBusy(false);
    }
  }

  // ─── Live timer (only while a session is open) ───────────────────────
  void _syncTimer() {
    final open = _activeRecord != null;
    if (open && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 30), (_) {
        _tick = _now();
        _emitLoaded();
      });
    } else if (!open && _timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  void _setBusy(bool busy) {
    _busy = busy;
    _emitLoaded();
  }

  /// Surface a transient error as a snackbar, then restore the loaded snapshot so
  /// the UI never loses its data.
  void _surface(String message) {
    if (isClosed) return;
    emit(AttendanceState.error(message));
    _emitLoaded();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _sub?.cancel();
    return super.close();
  }
}

/// Today's resolved rostered context (immutable snapshot taken at load).
class _TodayContext {
  final DateTime todayDate;
  final ScheduleShift? shift;
  final LeaveType? leave;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final String? targetRecordId;

  const _TodayContext({
    required this.todayDate,
    this.shift,
    this.leave,
    this.scheduledStart,
    this.scheduledEnd,
    this.targetRecordId,
  });
}
