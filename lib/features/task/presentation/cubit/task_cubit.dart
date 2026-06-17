import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fbro/core/enums/task_priority.dart';
import 'package:fbro/core/enums/task_status.dart';
import 'package:fbro/core/enums/task_type.dart';
import 'package:fbro/core/errors/failures.dart';
import 'package:fbro/features/auth/domain/entities/user_entity.dart';
import 'package:fbro/features/auth/domain/usecases/get_users_by_branch.dart';
import 'package:fbro/features/branch/domain/entities/branch_entity.dart';
import 'package:fbro/features/branch/domain/repositories/branch_repository.dart';
import 'package:fbro/features/task/domain/entities/activity_entry.dart';
import 'package:fbro/features/task/domain/entities/checklist_item.dart';
import 'package:fbro/features/task/domain/entities/recurrence_config.dart';
import 'package:fbro/features/task/domain/entities/task_entity.dart';
import 'package:fbro/features/task/domain/entities/task_template_entity.dart';
import 'package:fbro/features/task/domain/repositories/task_repository.dart';
import 'package:fbro/features/task/domain/usecases/assign_task.dart';
import 'package:fbro/features/task/domain/usecases/change_task_status.dart';
import 'package:fbro/features/task/domain/usecases/create_task.dart';
import 'package:fbro/features/task/domain/usecases/delete_task.dart';
import 'package:fbro/features/task/domain/usecases/review_task.dart';
import 'package:fbro/features/task/domain/usecases/update_task.dart';
import 'package:fbro/features/task/domain/usecases/upload_task_proof.dart';
import 'task_state.dart';

/// Drives the task workflow for all three roles. The list loaded depends on the
/// signed-in user's role (admin: all · manager: own branch · employee: tasks
/// they're assigned to) and is **realtime** — a Firestore snapshot stream.
///
/// Phase 9+: tasks support **multiple assignees**, an optional **checklist**,
/// **recurring schedules** (auto-creates the next instance on approve), and an
/// **activity timeline** (one entry per status transition). The cubit resolves
/// assignee uids → [UserEntity] (the [directory]) so cards show real names.
class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _repository;
  final BranchRepository _branchRepository;
  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;
  final AssignTask _assignTask;
  final ChangeTaskStatus _changeTaskStatus;
  final ReviewTask _reviewTask;
  final UploadTaskProof _uploadTaskProof;
  final GetUsersByBranch _getUsersByBranch;

  UserEntity? _user;
  StreamSubscription<List<TaskEntity>>? _sub;
  bool _mutating = false;
  final Map<String, UserEntity> _directory = {};
  final Set<String> _fetchedBranches = {};

  Map<String, UserEntity> get directory => Map.unmodifiable(_directory);

  TaskCubit({
    required this._repository,
    required this._branchRepository,
    required this._createTask,
    required this._updateTask,
    required this._deleteTask,
    required this._assignTask,
    required this._changeTaskStatus,
    required this._reviewTask,
    required this._uploadTaskProof,
    required this._getUsersByBranch,
  }) : super(const TaskState.initial());

  List<TaskEntity> get _tasks =>
      state.maybeWhen(loaded: (t, _, _) => t, orElse: () => const []);

  Future<void> load(UserEntity user) async {
    if (_user?.uid != user.uid) {
      _directory.clear();
      _fetchedBranches.clear();
    }
    _user = user;
    emit(const TaskState.loading());
    await _sub?.cancel();
    _sub = _streamFor(user).listen(
      (tasks) {
        emit(TaskState.loaded(tasks, busy: _mutating, directory: _directory));
        _ensureDirectory(tasks);
      },
      onError: (_) =>
          emit(const TaskState.error('Failed to load tasks. Please try again.')),
    );
  }

  Future<void> refresh() async {
    final user = _user;
    if (user != null) await load(user);
  }

  Stream<List<TaskEntity>> _streamFor(UserEntity user) {
    if (user.role.isAdmin) return _repository.watchAllTasks();
    if (user.role.isManager) {
      return _repository.watchTasksByBranch(user.branchId ?? '');
    }
    return _repository.watchEmployeeTasks(user.uid);
  }

  Future<void> _ensureDirectory(List<TaskEntity> tasks) async {
    final branchIds = <String>{
      for (final t in tasks)
        if ((t.branchId ?? '').isNotEmpty) t.branchId!,
    }..removeAll(_fetchedBranches);
    if (branchIds.isEmpty) return;

    var changed = false;
    for (final branchId in branchIds) {
      _fetchedBranches.add(branchId);
      try {
        final users = await _getUsersByBranch(branchId);
        for (final u in users) {
          _directory[u.uid] = u;
          changed = true;
        }
      } catch (_) {}
    }
    if (changed && !isClosed) {
      state.mapOrNull(
        loaded: (s) => emit(s.copyWith(directory: Map.of(_directory))),
      );
    }
  }

  // ─── Manager / admin actions ───────────────────────────────────
  Future<void> createTask({
    required String title,
    String? description,
    required TaskType type,
    required TaskPriority priority,
    required String branchId,
    DateTime? deadline,
    List<ChecklistItem> checklist = const [],
    RecurrenceConfig? recurrence,
  }) =>
      _mutate(() => _createTask(TaskEntity(
            id: '',
            title: title,
            description: description,
            type: type,
            priority: priority,
            branchId: branchId,
            checklist: checklist,
            recurrence: recurrence,
            createdBy: _user?.uid,
            deadline: deadline,
            activityLog: [
              ActivityEntry(
                status: TaskStatus.pending.value,
                actorId: _user?.uid ?? '',
                actorName: _user?.displayName,
                at: DateTime.now(),
              ),
            ],
          )));

  Future<void> editTask(TaskEntity task) => _mutate(() => _updateTask(task));

  Future<void> deleteTask(String taskId) =>
      _mutate(() => _deleteTask(taskId));

  Future<void> assignEmployees({
    required String taskId,
    required List<String> employeeIds,
    String? shiftId,
  }) =>
      _mutate(() => _assignTask(
            taskId: taskId,
            employeeIds: employeeIds,
            assignedShiftId: shiftId,
          ));

  Future<void> approveTask(TaskEntity task, {String? reviewNotes}) =>
      _transitionMutate(
        task,
        TaskStatus.approved,
        () async {
          await _reviewTask(
            taskId: task.id,
            approved: true,
            reviewerId: _user?.uid ?? '',
            reviewNotes: reviewNotes,
          );
          // Persist activity + auto-generate the next recurring instance.
          await _appendActivity(task, TaskStatus.approved, note: reviewNotes);
          if (task.recurrence != null &&
              task.recurrence!.frequency.value != 'none') {
            await _spawnNextRecurrence(task);
          }
        },
      );

  Future<void> rejectTask(TaskEntity task, {String? reviewNotes}) =>
      _transitionMutate(
        task,
        TaskStatus.rejected,
        () async {
          await _reviewTask(
            taskId: task.id,
            approved: false,
            reviewerId: _user?.uid ?? '',
            reviewNotes: reviewNotes,
          );
          await _appendActivity(task, TaskStatus.rejected, note: reviewNotes);
        },
      );

  // ─── Employee actions ──────────────────────────────────────────
  Future<void> startTask(TaskEntity task) => _transitionMutate(
        task,
        TaskStatus.started,
        () async {
          await _changeTaskStatus(
              taskId: task.id, status: TaskStatus.started);
          await _appendActivity(task, TaskStatus.started);
        },
      );

  Future<void> completeTask(
    TaskEntity task, {
    String? notes,
    File? proof,
  }) async {
    if (!task.requiredChecklistComplete) {
      final prev = _tasks;
      emit(const TaskState.error(
          'Complete all required checklist items before marking this task done.'));
      emit(TaskState.loaded(prev, directory: _directory));
      return;
    }
    String? uploadWarning;
    await _transitionMutate(task, TaskStatus.completed, () async {
      String? proofUrl;
      if (proof != null) {
        try {
          proofUrl = await _uploadTaskProof(task.id, proof);
        } catch (_) {
          uploadWarning =
              'Task marked complete, but the photo could not be uploaded. '
              'Enable Firebase Storage and deploy storage.rules, then re-attach it.';
        }
      }
      final updated = task.copyWith(
        status: TaskStatus.completed,
        notes: notes ?? task.notes,
        proofImageUrl: proofUrl ?? task.proofImageUrl,
        activityLog: [
          ...task.activityLog,
          ActivityEntry(
            status: TaskStatus.completed.value,
            actorId: _user?.uid ?? '',
            actorName: _user?.displayName,
            at: DateTime.now(),
            note: notes,
          ),
        ],
      );
      await _updateTask(updated);
    });
    if (uploadWarning != null && !isClosed) {
      emit(TaskState.error(uploadWarning!));
      emit(TaskState.loaded(_tasks, directory: _directory));
    }
  }

  Future<void> toggleChecklistItem(TaskEntity task, String itemId) {
    final updated = [
      for (final i in task.checklist)
        if (i.id == itemId)
          ChecklistItem(
            id: i.id,
            title: i.title,
            isRequired: i.isRequired,
            completed: !i.completed,
            completedAt: i.completed ? null : DateTime.now(),
          )
        else
          i,
    ];
    return _mutate(() => _updateTask(task.copyWith(checklist: updated)));
  }

  Future<void> submitForReview(TaskEntity task) => _transitionMutate(
        task,
        TaskStatus.waitingReview,
        () async {
          await _changeTaskStatus(
            taskId: task.id,
            status: TaskStatus.waitingReview,
          );
          await _appendActivity(task, TaskStatus.waitingReview);
        },
      );

  /// Combines completion + submit-for-review into a single action so the
  /// employee doesn't have to re-open the task to hit "Submit for Review".
  /// Uploads proof, sets status to [TaskStatus.waitingReview] in one write, and
  /// appends both activity entries. Proof upload failures are surfaced as a
  /// warning but never block the status transition.
  Future<void> completeAndSubmit(
    TaskEntity task, {
    String? notes,
    File? proof,
  }) async {
    if (task.status != TaskStatus.started) {
      final prev = _tasks;
      emit(const TaskState.error(
          "That action isn't allowed for this task's current status."));
      emit(TaskState.loaded(prev, directory: _directory));
      return;
    }
    if (!task.requiredChecklistComplete) {
      final prev = _tasks;
      emit(const TaskState.error(
          'Complete all required checklist items before submitting.'));
      emit(TaskState.loaded(prev, directory: _directory));
      return;
    }
    String? uploadWarning;
    await _mutate(() async {
      String? proofUrl;
      if (proof != null) {
        try {
          proofUrl = await _uploadTaskProof(task.id, proof);
        } catch (_) {
          uploadWarning =
              'Task submitted, but the photo could not be uploaded. '
              'Enable Firebase Storage and deploy storage.rules, then re-attach it.';
        }
      }
      final now = DateTime.now();
      final updated = task.copyWith(
        status: TaskStatus.waitingReview,
        notes: notes ?? task.notes,
        proofImageUrl: proofUrl ?? task.proofImageUrl,
        activityLog: [
          ...task.activityLog,
          ActivityEntry(
            status: TaskStatus.completed.value,
            actorId: _user?.uid ?? '',
            actorName: _user?.displayName,
            at: now,
            note: notes,
          ),
          ActivityEntry(
            status: TaskStatus.waitingReview.value,
            actorId: _user?.uid ?? '',
            actorName: _user?.displayName,
            at: now.add(const Duration(milliseconds: 1)),
          ),
        ],
      );
      await _updateTask(updated);
    });
    if (uploadWarning != null && !isClosed) {
      emit(TaskState.error(uploadWarning!));
      emit(TaskState.loaded(_tasks, directory: _directory));
    }
  }

  // ─── Picker support ────────────────────────────────────────────
  Future<List<UserEntity>> branchEmployees(String branchId) async {
    try {
      final users = await _getUsersByBranch(branchId);
      return users.where((u) => u.role.isEmployee).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<BranchEntity>> branches() async {
    try {
      final list = await _branchRepository.getBranches();
      return list.where((b) => b.isActive).toList();
    } catch (_) {
      return const [];
    }
  }

  // ─── Task templates ────────────────────────────────────────────
  Future<List<TaskTemplateEntity>> templates({String? branchId}) async {
    try {
      final all = await _repository.getTemplates();
      if (branchId == null || branchId.isEmpty) return all;
      return all
          .where((t) =>
              (t.branchId ?? '').isEmpty || t.branchId == branchId)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveTemplate({
    required String title,
    String? description,
    required TaskType type,
    required TaskPriority priority,
    String? branchId,
    List<ChecklistItemTemplate> checklistItems = const [],
  }) =>
      _repository.createTemplate(TaskTemplateEntity(
        id: '',
        title: title,
        description: description,
        type: type,
        priority: priority,
        branchId: branchId,
        checklistItems: checklistItems,
        createdBy: _user?.uid,
      ));

  Future<void> deleteTemplate(String templateId) =>
      _repository.deleteTemplate(templateId);

  // ─── Internals ─────────────────────────────────────────────────
  /// Appends an [ActivityEntry] to the task's log by updating the Firestore doc.
  Future<void> _appendActivity(
    TaskEntity task,
    TaskStatus status, {
    String? note,
  }) async {
    try {
      final entry = ActivityEntry(
        status: status.value,
        actorId: _user?.uid ?? '',
        actorName: _user?.displayName,
        at: DateTime.now(),
        note: note,
      );
      await _updateTask(task.copyWith(
        activityLog: [...task.activityLog, entry],
      ));
    } catch (_) {
      // Activity log is best-effort; never fail the primary action.
    }
  }

  /// Creates the next instance of a recurring task immediately after [source]
  /// is approved. Resets checklist items to uncompleted; inherits everything
  /// else (title, description, type, priority, branchId, assignees, recurrence).
  Future<void> _spawnNextRecurrence(TaskEntity source) async {
    final recurrence = source.recurrence!;
    final nextDeadline =
        recurrence.nextOccurrence(source.deadline ?? DateTime.now());
    final freshChecklist = [
      for (final item in source.checklist)
        ChecklistItem(
          id: item.id,
          title: item.title,
          isRequired: item.isRequired,
          completed: false,
          completedAt: null,
        ),
    ];
    try {
      await _createTask(TaskEntity(
        id: '',
        title: source.title,
        description: source.description,
        type: source.type,
        priority: source.priority,
        branchId: source.branchId,
        assigneeIds: source.assigneeIds,
        checklist: freshChecklist,
        recurrence: recurrence,
        createdBy: source.createdBy,
        deadline: nextDeadline,
        activityLog: [
          ActivityEntry(
            status: TaskStatus.pending.value,
            actorId: _user?.uid ?? '',
            actorName: _user?.displayName,
            at: DateTime.now(),
            note: 'Auto-created (recurring)',
          ),
        ],
      ));
    } catch (_) {
      // Recurrence spawn is best-effort; the approval itself already succeeded.
    }
  }

  Future<void> _mutate(Future<void> Function() action) async {
    if (_user == null || _mutating) return;
    final prev = _tasks;
    _mutating = true;
    emit(TaskState.loaded(prev, busy: true, directory: _directory));
    try {
      await action();
      _mutating = false;
      emit(TaskState.loaded(_tasks, busy: false, directory: _directory));
    } on Failure catch (e) {
      _mutating = false;
      emit(TaskState.error(e.message));
      emit(TaskState.loaded(prev, directory: _directory));
    } catch (_) {
      _mutating = false;
      emit(const TaskState.error('Something went wrong. Please try again.'));
      emit(TaskState.loaded(prev, directory: _directory));
    }
  }

  Future<void> _transitionMutate(
    TaskEntity task,
    TaskStatus to,
    Future<void> Function() action,
  ) {
    if (!_canTransition(task.status, to)) {
      final prev = _tasks;
      emit(const TaskState.error(
          "That action isn't allowed for this task's current status."));
      emit(TaskState.loaded(prev, directory: _directory));
      return Future.value();
    }
    return _mutate(action);
  }

  static bool _canTransition(TaskStatus from, TaskStatus to) {
    switch (from) {
      case TaskStatus.pending:
        return to == TaskStatus.started;
      case TaskStatus.started:
        return to == TaskStatus.completed;
      case TaskStatus.completed:
        return to == TaskStatus.waitingReview;
      case TaskStatus.waitingReview:
        return to == TaskStatus.approved || to == TaskStatus.rejected;
      case TaskStatus.rejected:
        return to == TaskStatus.started;
      case TaskStatus.approved:
        return false;
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
