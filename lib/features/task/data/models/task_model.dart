import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbro/core/enums/task_type.dart';
import 'package:fbro/core/enums/task_status.dart';
import 'package:fbro/core/enums/task_priority.dart';
import 'package:fbro/features/task/domain/entities/task_entity.dart';

/// Firestore (de)serialization for [TaskEntity] — collection `tasks/{taskId}`.
class TaskModel {
  final String id;
  final String title;
  final String? description;
  final TaskType type;
  final TaskStatus status;
  final TaskPriority priority;
  final String? branchId;
  final String? assignedEmployeeId;
  final String? createdBy;
  final String? assignedShiftId;
  final DateTime? deadline;
  final String? notes;
  final String? proofImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.type = TaskType.daily,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.normal,
    this.branchId,
    this.assignedEmployeeId,
    this.createdBy,
    this.assignedShiftId,
    this.deadline,
    this.notes,
    this.proofImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, {String? id}) => TaskModel(
        id: id ?? map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        description: map['description'] as String?,
        type: TaskType.fromString(map['type'] as String?),
        status: TaskStatus.fromString(map['status'] as String?),
        priority: TaskPriority.fromString(map['priority'] as String?),
        branchId: map['branchId'] as String?,
        assignedEmployeeId: map['assignedEmployeeId'] as String?,
        createdBy: map['createdBy'] as String?,
        assignedShiftId: map['assignedShiftId'] as String?,
        deadline: (map['deadline'] as Timestamp?)?.toDate(),
        notes: map['notes'] as String?,
        proofImageUrl: map['proofImageUrl'] as String?,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      );

  factory TaskModel.fromEntity(TaskEntity e) => TaskModel(
        id: e.id,
        title: e.title,
        description: e.description,
        type: e.type,
        status: e.status,
        priority: e.priority,
        branchId: e.branchId,
        assignedEmployeeId: e.assignedEmployeeId,
        createdBy: e.createdBy,
        assignedShiftId: e.assignedShiftId,
        deadline: e.deadline,
        notes: e.notes,
        proofImageUrl: e.proofImageUrl,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  /// Persisted fields. `createdAt`/`updatedAt` are written by the datasource as
  /// server timestamps, so they are intentionally not included here. `deadline`
  /// is converted to a [Timestamp] when present.
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.value,
        'status': status.value,
        'priority': priority.value,
        'branchId': branchId,
        'assignedEmployeeId': assignedEmployeeId,
        'createdBy': createdBy,
        'assignedShiftId': assignedShiftId,
        'deadline': deadline == null ? null : Timestamp.fromDate(deadline!),
        'notes': notes,
        'proofImageUrl': proofImageUrl,
      };

  /// Returns a copy with the Firestore-generated [id] applied (used on create).
  TaskModel copyWithId(String id) => TaskModel(
        id: id,
        title: title,
        description: description,
        type: type,
        status: status,
        priority: priority,
        branchId: branchId,
        assignedEmployeeId: assignedEmployeeId,
        createdBy: createdBy,
        assignedShiftId: assignedShiftId,
        deadline: deadline,
        notes: notes,
        proofImageUrl: proofImageUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  TaskEntity toEntity() => TaskEntity(
        id: id,
        title: title,
        description: description,
        type: type,
        status: status,
        priority: priority,
        branchId: branchId,
        assignedEmployeeId: assignedEmployeeId,
        createdBy: createdBy,
        assignedShiftId: assignedShiftId,
        deadline: deadline,
        notes: notes,
        proofImageUrl: proofImageUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
