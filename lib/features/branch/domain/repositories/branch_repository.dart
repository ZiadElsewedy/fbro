import 'package:fbro/features/branch/domain/entities/branch_entity.dart';

/// Contract for branch data access (Phase 5). Admin-only writes are enforced
/// server-side in `firestore.rules` (`branches/{branchId}`).
abstract class BranchRepository {
  /// The branch list. May return a recently-loaded result; pass [forceRefresh]
  /// (e.g. pull-to-refresh) to force a fresh read.
  Future<List<BranchEntity>> getBranches({
    bool includeDeleted = false,
    bool forceRefresh = false,
  });
  Future<BranchEntity> createBranch(BranchEntity branch);
  Future<void> updateBranch(BranchEntity branch);
  Future<void> setBranchActive(String branchId, bool isActive);

  /// Soft delete — marks the branch deleted/inactive rather than removing it.
  Future<void> deleteBranch(String branchId);
}
