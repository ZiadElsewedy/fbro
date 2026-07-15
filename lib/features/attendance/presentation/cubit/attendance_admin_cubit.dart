import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drop/core/enums/schedule_day.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/features/attendance/domain/attendance_board.dart';
import 'package:drop/features/attendance/domain/attendance_config.dart';
import 'package:drop/features/attendance/domain/attendance_id.dart';
import 'package:drop/features/attendance/domain/attendance_service.dart';
import 'package:drop/features/attendance/domain/entities/attendance_correction.dart';
import 'package:drop/features/attendance/domain/entities/attendance_entity.dart';
import 'package:drop/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:drop/features/attendance/domain/usecases/decide_correction.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/auth/domain/usecases/get_users_by_branch.dart';
import 'package:drop/features/branch/domain/entities/branch_entity.dart';
import 'package:drop/features/branch/domain/repositories/branch_repository.dart';
import 'package:drop/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:drop/features/schedule/domain/schedule_week.dart';
import 'package:drop/features/schedule/domain/shift_window.dart';
import 'attendance_admin_state.dart';

/// The **admin attendance dashboard** cubit — the schedule × attendance join for
/// one branch at a time. Combines the branch roster (schedule + branch users) with
/// today's live records ([AttendanceRepository.watchBranchDay]) through the pure
/// [computeAttendanceBoard], plus the branch's pending correction queue.
///
/// **Branch-scoped by design** — the admin switches branches ([selectBranch]); a
/// future Manager view would construct this exact cubit pinned to the manager's
/// own branch with `branches` limited to it. The dashboard renders the same board;
/// only the scope + who may switch differs (Firestore rules enforce access).
class AttendanceAdminCubit extends Cubit<AttendanceAdminState> {
  final AttendanceRepository _repository;
  final ScheduleRepository _scheduleRepository;
  final BranchRepository _branchRepository;
  final GetUsersByBranch _getUsersByBranch;
  final DecideCorrection _decideCorrection;
  final AttendanceService _service;
  final DateTime Function() _now;

  UserEntity? _admin;
  String? _branchId;
  List<BranchEntity> _branches = const [];
  List<AttendanceRosterEntry> _roster = const [];
  List<AttendanceEntity> _records = const [];
  List<AttendanceCorrectionEntity> _corrections = const [];
  AttendanceConfig _config = const AttendanceConfig(enabled: true);
  bool _deciding = false;

  StreamSubscription<List<AttendanceEntity>>? _recordsSub;
  StreamSubscription<List<AttendanceCorrectionEntity>>? _correctionsSub;
  Timer? _tick;

  AttendanceAdminCubit({
    required AttendanceRepository repository,
    required ScheduleRepository scheduleRepository,
    required BranchRepository branchRepository,
    required GetUsersByBranch getUsersByBranch,
    required DecideCorrection decideCorrection,
    required AttendanceService service,
    DateTime Function()? now,
  })  : _repository = repository,
        _scheduleRepository = scheduleRepository,
        _branchRepository = branchRepository,
        _getUsersByBranch = getUsersByBranch,
        _decideCorrection = decideCorrection,
        _service = service,
        _now = now ?? DateTime.now,
        super(const AttendanceAdminState.initial());
  // Named args read better at the call site than initializing formals here.
  // ignore_for_file: prefer_initializing_formals

  Future<void> load(UserEntity admin, {String? branchId}) async {
    _admin = admin;
    _config = _service.configFor(admin);
    final hasData = state.maybeMap(loaded: (_) => true, orElse: () => false);
    if (!hasData) emit(const AttendanceAdminState.loading());
    try {
      _branches =
          (await _branchRepository.getBranches()).where((b) => b.isActive).toList();
      final ownBranch = (admin.branchId ?? '').isNotEmpty ? admin.branchId : null;
      final target = branchId ??
          _branchId ??
          ownBranch ??
          (_branches.isNotEmpty ? _branches.first.id : null);
      if (target == null) {
        emit(const AttendanceAdminState.error('No branch to show yet.'));
        return;
      }
      await _scope(target);
    } catch (e, st) {
      developer.log('[ATTENDANCE-ADMIN] load failed: $e',
          name: 'ATTENDANCE', error: e, stackTrace: st);
      emit(const AttendanceAdminState.error('Failed to load attendance.'));
    }
  }

  Future<void> refresh() async {
    final admin = _admin;
    if (admin != null) await load(admin, branchId: _branchId);
  }

  Future<void> selectBranch(String branchId) async {
    if (branchId == _branchId) return;
    await _scope(branchId);
  }

  Future<void> _scope(String branchId) async {
    _branchId = branchId;
    _records = const [];
    _corrections = const [];
    await _recordsSub?.cancel();
    await _correctionsSub?.cancel();

    _roster = await _buildRoster(branchId);
    final dayKey = attendanceDayKey(_today());

    _recordsSub = _repository.watchBranchDay(branchId, dayKey).listen(
      (records) {
        _records = records;
        _emit();
      },
      onError: (Object e) => developer.log('[ATTENDANCE-ADMIN] records: $e',
          name: 'ATTENDANCE', error: e),
    );
    _correctionsSub =
        _repository.watchBranchPendingCorrections(branchId).listen(
      (corrections) {
        _corrections = corrections;
        _emit();
      },
      onError: (Object e) => developer.log('[ATTENDANCE-ADMIN] corrections: $e',
          name: 'ATTENDANCE', error: e),
    );
    _startTick();
    _emit();
  }

  /// Resolve the branch roster for today from the schedule + branch users.
  Future<List<AttendanceRosterEntry>> _buildRoster(String branchId) async {
    final now = _now();
    final day = ScheduleDay.fromDate(now);
    final weekStart = ScheduleWeek.startOf(now);
    final schedule = await _scheduleRepository.getSchedule(branchId, weekStart);
    if (schedule == null) return const [];

    final users = await _getUsersByBranch(branchId);
    final names = {
      for (final u in users) u.uid: (u.displayName ?? u.email),
    };

    final out = <AttendanceRosterEntry>[];
    for (final shift in ScheduleShift.values) {
      final hours = schedule.hoursFor(day, shift);
      for (final uid in schedule.employeesFor(day, shift)) {
        out.add(AttendanceRosterEntry(
          uid: uid,
          name: names[uid] ?? 'Unknown',
          shift: shift,
          scheduledStart: ShiftWindow.startOf(weekStart, day, hours),
          scheduledEnd: ShiftWindow.endOf(weekStart, day, hours),
          leave: schedule.leaveTypeOf(uid, day),
        ));
      }
    }
    return out;
  }

  /// A correction decision. The parent record is fetched by id (a correction may
  /// target an older record not in today's set); `DecideCorrection` computes the
  /// resolution through `AttendanceCalculator`, and the Cloud Function applies it.
  Future<void> decideCorrection(
    AttendanceCorrectionEntity correction, {
    required bool approve,
    String? note,
  }) async {
    final admin = _admin;
    if (admin == null || _deciding) return;
    _deciding = true;
    _emit();
    try {
      final record = await _repository.getRecord(correction.attendanceId);
      if (record == null) {
        emit(const AttendanceAdminState.error(
            'The attendance record for this correction is missing.'));
      } else {
        await _decideCorrection(
          correction,
          record: record,
          approve: approve,
          decidedBy: admin.uid,
          decidedByName: admin.displayName,
          decisionNote: note,
          now: _now(),
          config: _config,
        );
      }
    } catch (e, st) {
      developer.log('[ATTENDANCE-ADMIN] decide failed: $e',
          name: 'ATTENDANCE', error: e, stackTrace: st);
      emit(const AttendanceAdminState.error('Failed to save the decision.'));
    } finally {
      _deciding = false;
      _emit();
    }
  }

  DateTime _today() {
    final n = _now();
    return DateTime(n.year, n.month, n.day);
  }

  void _startTick() {
    _tick?.cancel();
    // A minute tick so no-shows roll Not started → Late → Absent over time.
    _tick = Timer.periodic(const Duration(seconds: 60), (_) => _emit());
  }

  void _emit() {
    if (isClosed || _branchId == null) return;
    final board = computeAttendanceBoard(
      roster: _roster,
      records: _records,
      now: _now(),
      config: _config,
    );
    emit(AttendanceAdminState.loaded(
      branchId: _branchId!,
      branches: _branches,
      board: board,
      corrections: _corrections,
      now: _now(),
      deciding: _deciding,
    ));
  }

  @override
  Future<void> close() {
    _tick?.cancel();
    _recordsSub?.cancel();
    _correctionsSub?.cancel();
    return super.close();
  }
}
