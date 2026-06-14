import 'package:fbro/core/enums/task_status.dart';
import 'package:fbro/features/task/domain/entities/task_entity.dart';

/// Contract for task data access (Phase 3 foundation). The branch/role access
/// model is enforced server-side by `firestore.rules` (admin: all branches;
/// manager: own branch; employee: own assigned tasks, limited writes); these
/// methods are the client-side surface the task UI (next phase) builds on.
abstract class TaskRepository {
  /// All tasks — admin only (the rules reject a non-admin collection read).
  Future<List<TaskEntity>> getAllTasks();

  /// Tasks in a single branch — admin or that branch's manager.
  Future<List<TaskEntity>> getTasksByBranch(String branchId);

  /// Tasks assigned to [employeeId] (the employee's own view).
  Future<List<TaskEntity>> getEmployeeTasks(String employeeId);

  /// A single task by id, or null if it doesn't exist.
  Future<TaskEntity?> getTask(String taskId);

  /// Creates a task and returns it with its generated id.
  Future<TaskEntity> createTask(TaskEntity task);

  /// Updates an existing task (manager/admin full edit; employee limited fields).
  Future<void> updateTask(TaskEntity task);

  /// Deletes a task (manager/admin).
  Future<void> deleteTask(String taskId);

  /// Assigns an employee (and optionally a shift) to the task; pass null to
  /// unassign.
  Future<void> assignTask({
    required String taskId,
    required String? employeeId,
    String? assignedShiftId,
  });

  /// Moves the task to [status] (start/complete by the employee; approve/reject
  /// on review by a manager/admin).
  Future<void> updateStatus({
    required String taskId,
    required TaskStatus status,
  });
}
