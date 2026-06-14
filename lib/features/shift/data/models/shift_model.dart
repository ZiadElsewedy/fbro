import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbro/features/shift/domain/entities/shift_entity.dart';

/// Firestore (de)serialization for [ShiftEntity] — collection `shifts/{shiftId}`.
class ShiftModel {
  final String id;
  final String name;
  final String startTime;
  final String endTime;
  final String? branchId;
  final String? employeeId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ShiftModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.branchId,
    this.employeeId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ShiftModel.fromMap(Map<String, dynamic> map, {String? id}) =>
      ShiftModel(
        id: id ?? map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        startTime: map['startTime'] as String? ?? '',
        endTime: map['endTime'] as String? ?? '',
        branchId: map['branchId'] as String?,
        employeeId: map['employeeId'] as String?,
        isActive: map['isActive'] as bool? ?? true,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      );

  factory ShiftModel.fromEntity(ShiftEntity e) => ShiftModel(
        id: e.id,
        name: e.name,
        startTime: e.startTime,
        endTime: e.endTime,
        branchId: e.branchId,
        employeeId: e.employeeId,
        isActive: e.isActive,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  /// Persisted fields. `createdAt`/`updatedAt` are written by the datasource as
  /// server timestamps, so they are intentionally not included here.
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'startTime': startTime,
        'endTime': endTime,
        'branchId': branchId,
        'employeeId': employeeId,
        'isActive': isActive,
      };

  /// Returns a copy with the Firestore-generated [id] applied (used on create).
  ShiftModel copyWithId(String id) => ShiftModel(
        id: id,
        name: name,
        startTime: startTime,
        endTime: endTime,
        branchId: branchId,
        employeeId: employeeId,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  ShiftEntity toEntity() => ShiftEntity(
        id: id,
        name: name,
        startTime: startTime,
        endTime: endTime,
        branchId: branchId,
        employeeId: employeeId,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
