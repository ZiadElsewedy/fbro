import 'package:drop/core/extensions/firestore_extensions.dart';
import 'package:drop/core/enums/schedule_shift.dart';
import 'package:drop/core/enums/task_priority.dart';
import 'package:drop/core/enums/template_repeat_mode.dart';
import 'package:drop/features/task/data/models/task_template_model.dart'
    show checklistTemplatesFromList, checklistTemplatesToList;
import 'package:drop/features/task/domain/entities/checklist_item.dart';
import 'package:drop/features/task/domain/entities/recurring_task_template_entity.dart';

/// Firestore (de)serialization for [RecurringTaskTemplateEntity] — collection
/// `recurringTaskTemplates/{id}`. Reuses the existing checklist-template
/// (de)serialization helpers from `task_template_model.dart` (same
/// `{id, title, isRequired}` shape) rather than duplicating them.
class RecurringTaskTemplateModel {
  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final List<ChecklistItemTemplate> checklistItems;
  final String branchId;
  final ScheduleShift shift;
  final TemplateRepeatMode repeat;
  final int weekday;
  final bool active;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RecurringTaskTemplateModel({
    required this.id,
    required this.title,
    this.description,
    this.priority = TaskPriority.normal,
    this.checklistItems = const [],
    required this.branchId,
    required this.shift,
    this.repeat = TemplateRepeatMode.daily,
    this.weekday = 1,
    this.active = true,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory RecurringTaskTemplateModel.fromMap(Map<String, dynamic> map,
          {String? id}) =>
      RecurringTaskTemplateModel(
        id: id ?? map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        description: map['description'] as String?,
        priority: TaskPriority.fromString(map['priority'] as String?),
        checklistItems: checklistTemplatesFromList(map['checklistItems']),
        branchId: map['branchId'] as String? ?? '',
        shift: ScheduleShift.fromString(map['shift'] as String?),
        repeat: TemplateRepeatMode.fromString(map['repeat'] as String?),
        weekday: (map['weekday'] as num?)?.toInt() ?? 1,
        active: map['active'] as bool? ?? true,
        createdBy: map['createdBy'] as String?,
        createdAt: map.date('createdAt'),
        updatedAt: map.date('updatedAt'),
      );

  factory RecurringTaskTemplateModel.fromEntity(
          RecurringTaskTemplateEntity e) =>
      RecurringTaskTemplateModel(
        id: e.id,
        title: e.title,
        description: e.description,
        priority: e.priority,
        checklistItems: e.checklistItems,
        branchId: e.branchId,
        shift: e.shift,
        repeat: e.repeat,
        weekday: e.weekday,
        active: e.active,
        createdBy: e.createdBy,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  /// Persisted fields. `createdAt`/`updatedAt` are written by the datasource as
  /// server timestamps, so they are intentionally not included here.
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority.value,
        'checklistItems': checklistTemplatesToList(checklistItems),
        'branchId': branchId,
        'shift': shift.value,
        'repeat': repeat.value,
        'weekday': weekday,
        'active': active,
        'createdBy': createdBy,
      };

  /// Returns a copy with the Firestore-generated [id] applied (used on create).
  RecurringTaskTemplateModel copyWithId(String id) => RecurringTaskTemplateModel(
        id: id,
        title: title,
        description: description,
        priority: priority,
        checklistItems: checklistItems,
        branchId: branchId,
        shift: shift,
        repeat: repeat,
        weekday: weekday,
        active: active,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  RecurringTaskTemplateEntity toEntity() => RecurringTaskTemplateEntity(
        id: id,
        title: title,
        description: description,
        priority: priority,
        checklistItems: checklistItems,
        branchId: branchId,
        shift: shift,
        repeat: repeat,
        weekday: weekday,
        active: active,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
