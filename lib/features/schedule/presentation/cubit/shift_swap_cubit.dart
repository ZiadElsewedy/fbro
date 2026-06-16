import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fbro/core/enums/schedule_day.dart';
import 'package:fbro/core/enums/schedule_shift.dart';
import 'package:fbro/core/enums/swap_status.dart';
import 'package:fbro/core/errors/failures.dart';
import 'package:fbro/features/schedule/domain/entities/shift_swap_entity.dart';
import 'package:fbro/features/schedule/domain/repositories/schedule_repository.dart';
import 'shift_swap_state.dart';

/// Drives the shift-swap workflow (Phase 7). An employee requests a swap on one
/// of their slots; the target coworker approves; the branch manager approves —
/// which rewrites the schedule. The list shown depends on the view: an employee
/// sees swaps involving them ([loadMine]); a manager sees their branch's queue
/// ([loadBranch]). Calls [ScheduleRepository] directly (no use-case layer).
class ShiftSwapCubit extends Cubit<ShiftSwapState> {
  final ScheduleRepository _repository;

  /// Reload context — true = branch queue (manager), false = own swaps (employee).
  bool _branchMode = false;
  String _key = '';

  ShiftSwapCubit(this._repository) : super(const ShiftSwapState.initial());

  List<ShiftSwapEntity> get _swaps =>
      state.maybeWhen(loaded: (s, _) => s, orElse: () => const []);

  bool get _busy => state.maybeWhen(
        loaded: (_, busy) => busy,
        loading: () => true,
        orElse: () => false,
      );

  /// Employee view — swaps where [uid] is requester or target.
  Future<void> loadMine(String uid) async {
    _branchMode = false;
    _key = uid;
    await _load();
  }

  /// Manager view — the branch's swap queue.
  Future<void> loadBranch(String branchId) async {
    _branchMode = true;
    _key = branchId;
    await _load();
  }

  Future<void> refresh() => _load();

  // ── Employee actions ───────────────────────────────────────────
  Future<void> requestSwap({
    required String branchId,
    required DateTime weekStart,
    required ScheduleDay day,
    required ScheduleShift shift,
    required String requesterId,
    String? requesterName,
    required String targetId,
    String? targetName,
    String? note,
  }) =>
      _mutate(() => _repository.createSwap(ShiftSwapEntity(
            id: '',
            branchId: branchId,
            weekStart: weekStart,
            day: day,
            shift: shift,
            requesterId: requesterId,
            requesterName: requesterName,
            targetId: targetId,
            targetName: targetName,
            note: note,
          )));

  /// Target coworker approves → awaiting manager.
  Future<void> coworkerApprove(ShiftSwapEntity swap) => _mutate(() => _repository
      .updateSwapStatus(swapId: swap.id, status: SwapStatus.employeeApproved));

  /// Reject the swap (requester cancel, coworker decline, or manager reject).
  Future<void> reject(ShiftSwapEntity swap) => _mutate(() =>
      _repository.updateSwapStatus(swapId: swap.id, status: SwapStatus.rejected));

  // ── Manager action ─────────────────────────────────────────────
  /// Manager approves → schedule updates automatically.
  Future<void> managerApprove(ShiftSwapEntity swap) =>
      _mutate(() => _repository.managerApproveSwap(swap));

  // ── Internals ──────────────────────────────────────────────────
  Future<List<ShiftSwapEntity>> _fetch() => _branchMode
      ? _repository.getBranchSwaps(_key)
      : _repository.getEmployeeSwaps(_key);

  Future<void> _load() async {
    if (_key.isEmpty) {
      emit(const ShiftSwapState.loaded([]));
      return;
    }
    emit(const ShiftSwapState.loading());
    try {
      emit(ShiftSwapState.loaded(await _fetch()));
    } on Failure catch (e) {
      emit(ShiftSwapState.error(e.message));
    } catch (_) {
      emit(const ShiftSwapState.error('Failed to load swap requests.'));
    }
  }

  Future<void> _mutate(Future<void> Function() action) async {
    if (_busy || _key.isEmpty) return;
    final prev = _swaps;
    emit(ShiftSwapState.loaded(prev, busy: true));
    try {
      await action();
      emit(ShiftSwapState.loaded(await _fetch()));
    } on Failure catch (e) {
      emit(ShiftSwapState.error(e.message));
      emit(ShiftSwapState.loaded(prev));
    } catch (_) {
      emit(const ShiftSwapState.error('Something went wrong. Please try again.'));
      emit(ShiftSwapState.loaded(prev));
    }
  }
}
