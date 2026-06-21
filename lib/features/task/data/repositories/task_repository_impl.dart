import 'dart:io';

import 'package:fbro/core/enums/attachment_type.dart';
import 'package:fbro/core/errors/exceptions.dart';
import 'package:fbro/core/errors/failures.dart';
import 'package:fbro/features/task/data/datasources/task_remote_datasource.dart';
import 'package:fbro/features/task/data/models/task_model.dart';
import 'package:fbro/features/task/data/models/task_template_model.dart';
import 'package:fbro/features/task/domain/entities/task_attachment.dart';
import 'package:fbro/features/task/domain/entities/task_entity.dart';
import 'package:fbro/features/task/domain/entities/task_template_entity.dart';
import 'package:fbro/features/task/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remote;

  TaskRepositoryImpl(this._remote);

  /// Newest first. Firestore already orders by `createdAt` desc, but a task just
  /// created locally has a *pending* server timestamp (null until the server
  /// confirms), which Firestore would sort to the bottom — so we re-sort with
  /// pending (null) treated as newest, keeping the new task on top instantly.
  List<TaskEntity> _newestFirst(List<TaskModel> models) {
    final tasks = models.map((m) => m.toEntity()).toList();
    tasks.sort((a, b) {
      final ad = a.createdAt;
      final bd = b.createdAt;
      if (ad == null && bd == null) return 0;
      if (ad == null) return -1;
      if (bd == null) return 1;
      return bd.compareTo(ad);
    });
    return tasks;
  }

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    try {
      return _newestFirst(await _remote.getAllTasks());
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<TaskEntity>> getTasksByBranch(String branchId) async {
    try {
      return _newestFirst(await _remote.getTasksByBranch(branchId));
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<TaskEntity>> getEmployeeTasks(String employeeId) async {
    try {
      return _newestFirst(await _remote.getEmployeeTasks(employeeId));
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Stream<List<TaskEntity>> watchAllTasks() =>
      _remote.watchAllTasks().map(_newestFirst);

  @override
  Stream<List<TaskEntity>> watchTasksByBranch(String branchId) =>
      _remote.watchTasksByBranch(branchId).map(_newestFirst);

  @override
  Stream<List<TaskEntity>> watchEmployeeTasks(String employeeId) =>
      _remote.watchEmployeeTasks(employeeId).map(_newestFirst);

  @override
  Future<TaskEntity?> getTask(String taskId) async {
    try {
      final model = await _remote.getTask(taskId);
      return model?.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<TaskEntity> createTask(TaskEntity task) async {
    try {
      final created = await _remote.createTask(TaskModel.fromEntity(task));
      return created.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    try {
      await _remote.updateTask(TaskModel.fromEntity(task));
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _remote.deleteTask(taskId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> assignTask({
    required String taskId,
    required List<String> employeeIds,
    String? assignedShiftId,
  }) async {
    try {
      await _remote.assignTask(
        taskId: taskId,
        employeeIds: employeeIds,
        assignedShiftId: assignedShiftId,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<TaskAttachment> uploadAttachment({
    required String taskId,
    required File file,
    required AttachmentType type,
    required String uploadedBy,
    String? uploadedByName,
  }) async {
    try {
      return await _remote.uploadAttachment(
        taskId: taskId,
        file: file,
        type: type,
        uploadedBy: uploadedBy,
        uploadedByName: uploadedByName,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  // ─── Task templates ────────────────────────────────────────────
  @override
  Future<List<TaskTemplateEntity>> getTemplates() async {
    try {
      final models = await _remote.getTemplates();
      return models.map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<TaskTemplateEntity> createTemplate(TaskTemplateEntity template) async {
    try {
      final created =
          await _remote.createTemplate(TaskTemplateModel.fromEntity(template));
      return created.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> deleteTemplate(String templateId) async {
    try {
      await _remote.deleteTemplate(templateId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
