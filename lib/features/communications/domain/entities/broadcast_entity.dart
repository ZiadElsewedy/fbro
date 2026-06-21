import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fbro/core/enums/broadcast_audience.dart';
import 'package:fbro/core/enums/user_role.dart';

part 'broadcast_entity.freezed.dart';

/// A one-way announcement in the Communications Center (Phase 1). A manager or
/// admin "sends" a broadcast to a single branch ([BroadcastAudience.branch]) or
/// to every branch ([BroadcastAudience.allBranches], admin-only); branch members
/// read it. Persisted at `broadcasts/{id}`.
///
/// Access is enforced server-side in `firestore.rules`: admin reads/writes all,
/// an own-branch manager writes their branch, branch members read their branch's
/// broadcasts plus all-branches ones. The queryable targeting field is
/// [branchId] (`null`/empty == all branches).
@freezed
class BroadcastEntity with _$BroadcastEntity {
  const BroadcastEntity._();

  const factory BroadcastEntity({
    required String id,
    required String title,
    required String message,
    /// Who sent it.
    required String senderId,
    required String senderName,
    @Default(UserRole.manager) UserRole senderRole,
    @Default(BroadcastAudience.allBranches) BroadcastAudience audience,
    /// Target branch when [audience] is [BroadcastAudience.branch]; null for an
    /// all-branches broadcast.
    String? branchId,
    DateTime? createdAt,
  }) = _BroadcastEntity;

  /// Whether this targets a single branch (vs. every branch).
  bool get isBranchScoped => audience == BroadcastAudience.branch;
}
