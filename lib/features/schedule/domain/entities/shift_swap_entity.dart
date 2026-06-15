import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fbro/core/enums/schedule_day.dart';
import 'package:fbro/core/enums/schedule_shift.dart';
import 'package:fbro/core/enums/swap_status.dart';

part 'shift_swap_entity.freezed.dart';

/// A shift-swap request (Phase 7). The [requesterId] employee asks the
/// [targetId] coworker to take one scheduled slot — a single (week, [day],
/// [shift]) cell of their branch's [WeeklyScheduleEntity]. The coworker approves
/// first, then the branch manager; on manager approval the schedule is updated
/// automatically (requester removed, target added on that slot).
///
/// Names are denormalized ([requesterName] / [targetName]) so the request can be
/// displayed without extra user lookups. Access is enforced server-side in
/// `firestore.rules` (`shift_swaps/{id}`): the two employees and the branch
/// manager/admin can see and act on it.
@freezed
class ShiftSwapEntity with _$ShiftSwapEntity {
  const factory ShiftSwapEntity({
    required String id,
    required String branchId,

    /// The week the slot belongs to (Sunday 00:00) — used to address the
    /// schedule document the swap mutates on approval.
    required DateTime weekStart,
    required ScheduleDay day,
    required ScheduleShift shift,

    /// The employee giving up the slot.
    required String requesterId,
    String? requesterName,

    /// The coworker asked to take the slot.
    required String targetId,
    String? targetName,
    @Default(SwapStatus.pending) SwapStatus status,

    /// Optional free-text note from the requester.
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ShiftSwapEntity;
}
