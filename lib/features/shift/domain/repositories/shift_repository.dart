import 'package:fbro/features/shift/domain/entities/shift_entity.dart';

/// Contract for shift data access (Phase 2 foundation). The branch/role access
/// model is enforced server-side by `firestore.rules` (admin: all branches;
/// manager: own branch; employee: own assigned shift); these methods are the
/// client-side surface the shift UI (next phase) builds on.
abstract class ShiftRepository {
  /// All shifts — admin only (the rules reject a non-admin collection read).
  Future<List<ShiftEntity>> getAllShifts();

  /// Shifts in a single branch — admin or that branch's manager.
  Future<List<ShiftEntity>> getShiftsByBranch(String branchId);

  /// A single shift by id, or null if it doesn't exist.
  Future<ShiftEntity?> getShift(String shiftId);

  /// The shift assigned to [employeeId] (the employee's own view), or null.
  Future<ShiftEntity?> getEmployeeShift(String employeeId);

  /// Creates a shift and returns it with its generated id.
  Future<ShiftEntity> createShift(ShiftEntity shift);

  /// Updates an existing shift.
  Future<void> updateShift(ShiftEntity shift);

  /// Deletes a shift.
  Future<void> deleteShift(String shiftId);

  /// Assigns [employeeId] to the shift (pass null to unassign).
  Future<void> assignEmployee({
    required String shiftId,
    required String? employeeId,
  });
}
