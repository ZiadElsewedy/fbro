import 'package:freezed_annotation/freezed_annotation.dart';

part 'shift_entity.freezed.dart';

/// A work shift (Phase 2). V1 has two shift types — `morning` (08:30–16:30) and
/// `night` (16:30–23:00/00:00) — but `name`/`startTime`/`endTime` are kept as
/// free-form strings so weekend / custom shifts can be added later without a
/// schema change. A shift belongs to one branch ([branchId]) and may be assigned
/// to one employee ([employeeId]); the user's `assignedShift` points back to it.
@freezed
class ShiftEntity with _$ShiftEntity {
  const factory ShiftEntity({
    required String id,
    required String name,
    required String startTime,
    required String endTime,
    /// Owning branch. admin: any; manager: their own branch. Null until set.
    String? branchId,
    /// Assigned employee uid; null while the shift is unassigned.
    String? employeeId,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ShiftEntity;
}
