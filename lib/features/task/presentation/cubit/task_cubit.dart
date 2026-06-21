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
import 'package:fbro/core/enums/attachment_type.dart';
import 'package:fbro/features/task/domain/entities/activity_entry.dart';
import 'package:fbro/features/task/domain/entities/checklist_item.dart';
import 'package:fbro/features/task/domain/entities/recurrence_config.dart';
import 'package:fbro/features/task/domain/entities/task_attachment.dart';
import 'package:fbro/features/task/domain/entities/task_entity.dart';
import 'package:fbro/features/task/domain/entities/task_template_entity.dart';
import 'package:fbro/features/task/domain/repositories/task_repository.dart';
import 'package:fbro/features/task/domain/usecases/assign_task.dart';
import 'package:fbro/features/task/domain/usecases/create_task.dart';
import 'package:fbro/features/task/domain/usecases/delete_task.dart';
import 'package:fbro/features/task/domain/usecases/update_task.dart';
import 'package:fbro/features/task/domain/usecases/upload_task_attachment.dart';
import 'task_state.dart';

/// A media file the employee has picked but not yet uploaded — the input to
/// [TaskCubit.completeAndSubmit]. The cubit uploads each and turns it into a
/// [TaskAttachment] on the submission event.
class PickedAttachment {
  const PickedAttachment(this.file, this.type);
  final File file;
  final AttachmentType type;
}

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
  final UploadTaskAttachment _uploadTaskAttachment;
  final GetUsersByBranch _getUsersByBranch;

  UserEntity? _user;
  StreamSubscription<List<TaskEntity>>? _sub;
  bool _mutating = false;
  final Map<String, UserEntity> _directory = {};
  final Set<String> _fetchedBranches = {};
  final Map<String, String> _branchNames = {};

  Map<String, UserEntity> get directory => Map.unmodifiable(_directory);

  /// branchId → branch name, so screens (e.g. the review header) can show which
  /// branch a task belongs to. Populated once per session in [load].
  Map<String, String> get branchNames => Map.unmodifiable(_branchNames);

  TaskCubit({
    required this._repository,
    required this._branchRepository,
    required this._createTask,
    required this._updateTask,
    required this._deleteTask,
    required this._assignTask,
    required this._uploadTaskAttachment,
    required this._getUsersByBranch,
  }) : super(const TaskState.initial());

  List<TaskEntity> get _tasks =>
      state.maybeWhen(loaded: (t, _, _) => t, orElse: () => const []);

  Future<void> load(UserEntity user) async {
    if (_user?.uid != user.uid) {
      _directory.clear();
      _fetchedBranches.clear();
      _branchNames.clear();
    }
    _user = user;
    _loadBranchNames();
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

  /// Loads branchId → name once so the UI can label a task's branch. Re-emits a
  /// fresh loaded state (new directory map reference) so listeners rebuild when
  /// the names arrive. Best-effort — failure leaves names empty (no branch label).
  Future<void> _loadBranchNames() async {
    try {
      final list = await _branchRepository.getBranches();
      for (final b in list) {
        _branchNames[b.id] = b.name;
      }
      if (!isClosed) {
        state.mapOrNull(
          loaded: (s) => emit(s.copyWith(directory: Map.of(_directory))),
        );
      }
    } catch (_) {}
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
          final now = DateTime.now();
          await _updateTask(task.copyWith(
            status: TaskStatus.approved,
            approvedBy: _user?.uid,
            approvedAt: now,
            reviewNotes: reviewNotes,
            activityLog: [
              ...task.activityLog,
              ActivityEntry(
                status: TaskStatus.approved.value,
                actorId: _user?.uid ?? '',
                actorName: _user?.displayName,
                at: now,
                note: reviewNotes,
              ),
            ],
          ));
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
          final now = DateTime.now();
          await _updateTask(task.copyWith(
            status: TaskStatus.rejected,
            rejectedBy: _user?.uid,
            rejectedAt: now,
            reviewNotes: reviewNotes,
            activityLog: [
              ...task.activityLog,
              ActivityEntry(
                status: TaskStatus.rejected.value,
                actorId: _user?.uid ?? '',
                actorName: _user?.displayName,
                at: now,
                note: reviewNotes,
              ),
            ],
          ));
        },
      );

  // ─── Employee actions ──────────────────────────────────────────
  Future<void> startTask(TaskEntity task) => _transitionMutate(
        task,
        TaskStatus.started,
        () async {
          final now = DateTime.now();
          await _updateTask(task.copyWith(
            status: TaskStatus.started,
            startedAt: now,
            activityLog: [
              ...task.activityLog,
              ActivityEntry(
                status: TaskStatus.started.value,
                actorId: _user?.uid ?? '',
                actorName: _user?.displayName,
                at: now,
              ),
            ],
          ));
        },
      );

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
          final now = DateTime.now();
          await _updateTask(task.copyWith(
            status: TaskStatus.waitingReview,
            submittedAt: now,
            activityLog: [
              ...task.activityLog,
              ActivityEntry(
                status: TaskStatus.waitingReview.value,
                actorId: _user?.uid ?? '',
                actorName: _user?.displayName,
                at: now,
              ),
            ],
          ));
        },
      );

  /// Completes + submits a task for review in a single action (so the employee
  /// doesn't re-open the task to hit "Submit for Review").
  ///
  /// Media is uploaded **before** the status write: if any upload fails the
  /// whole transition is aborted — the task stays `started`, the real Storage
  /// error is surfaced, and the employee keeps their selected media to retry.
  /// Evidence the review depends on must never be silently dropped. The uploaded
  /// [attachments] are attached to the **submission event** (Phase 10), and the
  /// first image also mirrors to the legacy `proofImageUrl` so older surfaces
  /// keep working. Returns true only when the submission actually persisted.
  Future<bool> completeAndSubmit(
    TaskEntity task, {
    String? notes,
    List<PickedAttachment> attachments = const [],
  }) async {
    if (task.status != TaskStatus.started) {
      _emitTransientError(
          "That action isn't allowed for this task's current status.");
      return false;
    }
    if (!task.requiredChecklistComplete) {
      _emitTransientError(
          'Complete all required checklist items before submitting.');
      return false;
    }
    return _mutate(() async {
      // Upload in parallel (order preserved by Future.wait) — several photos no
      // longer queue behind each other. Any failure throws → _mutate aborts the
      // write and surfaces the real error, keeping the employee's selection.
      final uploaded = await Future.wait([
        for (final a in attachments)
          _uploadTaskAttachment(
            taskId: task.id,
            file: a.file,
            type: a.type,
            uploadedBy: _user?.uid ?? '',
            uploadedByName: _user?.displayName,
          ),
      ]);
      String? firstImage;
      for (final a in uploaded) {
        if (a.type == AttachmentType.image) {
          firstImage = a.url;
          break;
        }
      }
      final now = DateTime.now();
      await _updateTask(task.copyWith(
        status: TaskStatus.waitingReview,
        submittedAt: now,
        notes: notes ?? task.notes,
        // Mirror the first image to the legacy field for back-compat.
        proofImageUrl: firstImage ?? task.proofImageUrl,
        activityLog: [
          ...task.activityLog,
          ActivityEntry(
            status: TaskStatus.completed.value,
            actorId: _user?.uid ?? '',
            actorName: _user?.displayName,
            at: now,
            note: notes,
            attachments: uploaded,
          ),
          ActivityEntry(
            status: TaskStatus.waitingReview.value,
            actorId: _user?.uid ?? '',
            actorName: _user?.displayName,
            at: now.add(const Duration(milliseconds: 1)),
          ),
        ],
      ));
    });
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

  /// Runs a write [action] with optimistic busy state. Returns true on success;
  /// on failure it surfaces the error and rolls the list back to [prev].
  Future<bool> _mutate(Future<void> Function() action) async {
    if (_user == null || _mutating) return false;
    final prev = _tasks;
    _mutating = true;
    emit(TaskState.loaded(prev, busy: true, directory: _directory));
    try {
      await action();
      _mutating = false;
      emit(TaskState.loaded(_tasks, busy: false, directory: _directory));
      return true;
    } on Failure catch (e) {
      _mutating = false;
      emit(TaskState.error(e.message));
      emit(TaskState.loaded(prev, directory: _directory));
      return false;
    } catch (_) {
      _mutating = false;
      emit(const TaskState.error('Something went wrong. Please try again.'));
      emit(TaskState.loaded(prev, directory: _directory));
      return false;
    }
  }

  Future<bool> _transitionMutate(
    TaskEntity task,
    TaskStatus to,
    Future<void> Function() action,
  ) {
    if (!_canTransition(task.status, to)) {
      _emitTransientError(
          "That action isn't allowed for this task's current status.");
      return Future.value(false);
    }
    return _mutate(action);
  }

  /// Emits a one-shot error (for the UI's snackbar listener) then immediately
  /// restores the loaded list so the screen isn't left stuck on an error state.
  void _emitTransientError(String message) {
    final prev = _tasks;
    emit(TaskState.error(message));
    emit(TaskState.loaded(prev, directory: _directory));
  }

  static bool _canTransition(TaskStatus from, TaskStatus to) {
    switch (from) {
      case TaskStatus.pending:
        return to == TaskStatus.started;
      case TaskStatus.started:
        // completeAndSubmit goes started → waitingReview directly (skipping completed)
        return to == TaskStatus.completed || to == TaskStatus.waitingReview;
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
