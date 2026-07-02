import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/core/enums/task_priority.dart';
import 'package:drop/core/enums/template_repeat_mode.dart';
import 'package:drop/features/task/domain/entities/checklist_item.dart';

part 'recurring_task_template_entity.freezed.dart';

/// A permanent blueprint for a **shift-assigned** task that repeats on its own
/// clock (Shift Assignment feature) — e.g. "Open Store" every day on the
/// Morning shift. Distinct from [TaskTemplateEntity], which is a one-shot
/// checklist blueprint a manager instantiates by hand; this one is read by the
/// `generateShiftTaskInstances` Cloud Function, which creates one real
/// `tasks/{id}` document per due date (so completion is trackable per day) and
/// links it back here via `TaskEntity.sourceTemplateId`.
///
/// Always branch-scoped (a shift only means something within one branch's
/// roster) and always [TaskAssignmentType.shift] — there is no
/// individual/team recurring-template path (existing per-task `RecurrenceConfig`
/// already covers that case).
@freezed
class RecurringTaskTemplateEntity with _$RecurringTaskTemplateEntity {
  const RecurringTaskTemplateEntity._();

  const factory RecurringTaskTemplateEntity({
    required String id,
    required String title,
    String? description,
    @Default(TaskPriority.normal) TaskPriority priority,
    @Default(<ChecklistItemTemplate>[]) List<ChecklistItemTemplate> checklistItems,
    required String branchId,
    required ScheduleShift shift,
    @Default(TemplateRepeatMode.daily) TemplateRepeatMode repeat,
    /// Target weekday when [repeat] is [TemplateRepeatMode.weekly]:
    /// `DateTime.monday` = 1 … `DateTime.sunday` = 7 (matches [RecurrenceConfig.weekday]).
    @Default(1) int weekday,
    /// Whether the generator should still produce instances from this template.
    /// A manager pausing/retiring a routine sets this false rather than
    /// deleting the template — past instances (and their analytics) are
    /// untouched either way.
    @Default(true) bool active,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RecurringTaskTemplateEntity;

  /// Builds the instance-level checklist (all items uncompleted) for a newly
  /// generated day's task.
  List<ChecklistItem> buildTaskChecklist() =>
      [for (final i in checklistItems) i.toTaskItem()];
}
