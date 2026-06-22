import 'package:fbro/core/cache/cache_manager.dart';
import 'package:fbro/core/cache/cache_policy.dart';
import 'package:fbro/core/errors/exceptions.dart';
import 'package:fbro/core/errors/failures.dart';
import 'package:fbro/features/branch/data/datasources/branch_remote_datasource.dart';
import 'package:fbro/features/branch/data/models/branch_model.dart';
import 'package:fbro/features/branch/domain/entities/branch_entity.dart';
import 'package:fbro/features/branch/domain/repositories/branch_repository.dart';

class BranchRepositoryImpl implements BranchRepository {
  final BranchRemoteDataSource _remote;
  final CacheManager _cache;

  BranchRepositoryImpl(this._remote, this._cache);

  @override
  Future<List<BranchEntity>> getBranches({
    bool includeDeleted = false,
    bool forceRefresh = false,
  }) async {
    try {
      // The branch list is read by ~5 cubits per session; cache it (stable) so
      // only the first read hits Firestore. Writes below invalidate it.
      return await _cache.readOrLoad<List<BranchEntity>>(
        CacheKeys.branches(includeDeleted: includeDeleted),
        CachePolicy.stable,
        () async {
          final models =
              await _remote.getBranches(includeDeleted: includeDeleted);
          return models.map((m) => m.toEntity()).toList();
        },
        forceRefresh: forceRefresh,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<BranchEntity> createBranch(BranchEntity branch) async {
    try {
      final created = await _remote.createBranch(BranchModel.fromEntity(branch));
      _cache.invalidatePrefix(CacheKeys.branchesPrefix);
      return created.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> updateBranch(BranchEntity branch) async {
    try {
      await _remote.updateBranch(BranchModel.fromEntity(branch));
      _cache.invalidatePrefix(CacheKeys.branchesPrefix);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> setBranchActive(String branchId, bool isActive) async {
    try {
      await _remote.setBranchActive(branchId, isActive);
      _cache.invalidatePrefix(CacheKeys.branchesPrefix);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> deleteBranch(String branchId) async {
    try {
      await _remote.softDeleteBranch(branchId);
      _cache.invalidatePrefix(CacheKeys.branchesPrefix);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
