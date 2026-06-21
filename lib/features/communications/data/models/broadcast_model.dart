import 'package:fbro/core/enums/broadcast_audience.dart';
import 'package:fbro/core/enums/user_role.dart';
import 'package:fbro/core/extensions/firestore_extensions.dart';
import 'package:fbro/features/communications/domain/entities/broadcast_entity.dart';

/// Firestore (de)serialization for [BroadcastEntity] — collection
/// `broadcasts/{id}`.
///
/// An all-branches broadcast is stored with an **empty** `branchId` sentinel
/// (never null) so a branch member's `whereIn: [myBranch, '']` query catches it
/// while staying provably safe under `firestore.rules`.
class BroadcastModel {
  final String id;
  final String title;
  final String message;
  final String senderId;
  final String senderName;
  final UserRole senderRole;
  final BroadcastAudience audience;

  /// Empty string for an all-branches broadcast; a branch id otherwise.
  final String branchId;
  final DateTime? createdAt;

  const BroadcastModel({
    required this.id,
    required this.title,
    required this.message,
    required this.senderId,
    required this.senderName,
    this.senderRole = UserRole.manager,
    this.audience = BroadcastAudience.allBranches,
    this.branchId = '',
    this.createdAt,
  });

  factory BroadcastModel.fromMap(Map<String, dynamic> map, {String? id}) =>
      BroadcastModel(
        id: id ?? map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        message: map['message'] as String? ?? '',
        senderId: map['senderId'] as String? ?? '',
        senderName: map['senderName'] as String? ?? '',
        senderRole: UserRole.fromString(map['senderRole'] as String?),
        audience: BroadcastAudience.fromString(map['audience'] as String?),
        branchId: map['branchId'] as String? ?? '',
        createdAt: map.date('createdAt'),
      );

  factory BroadcastModel.fromEntity(BroadcastEntity e) => BroadcastModel(
        id: e.id,
        title: e.title,
        message: e.message,
        senderId: e.senderId,
        senderName: e.senderName,
        senderRole: e.senderRole,
        audience: e.audience,
        // All-branches → empty sentinel; branch → its id.
        branchId: e.audience.isBranch ? (e.branchId ?? '') : '',
        createdAt: e.createdAt,
      );

  /// Writable fields. `createdAt` is a server timestamp set by the datasource,
  /// so it is excluded here.
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'message': message,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole.value,
        'audience': audience.value,
        'branchId': branchId,
      };

  BroadcastModel copyWithId(String id) => BroadcastModel(
        id: id,
        title: title,
        message: message,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        audience: audience,
        branchId: branchId,
        createdAt: createdAt,
      );

  BroadcastEntity toEntity() => BroadcastEntity(
        id: id,
        title: title,
        message: message,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        audience: audience,
        branchId: branchId.isEmpty ? null : branchId,
        createdAt: createdAt,
      );
}
