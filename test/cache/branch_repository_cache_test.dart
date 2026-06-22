import 'package:flutter_test/flutter_test.dart';
import 'package:fbro/core/cache/cache_manager.dart';
import 'package:fbro/features/branch/data/datasources/branch_remote_datasource.dart';
import 'package:fbro/features/branch/data/models/branch_model.dart';
import 'package:fbro/features/branch/data/repositories/branch_repository_impl.dart';

/// Counts datasource reads/writes so the test can assert how many actually
/// reach Firestore through [BranchRepositoryImpl]'s cache.
class _CountingBranchRemote implements BranchRemoteDataSource {
  int getBranchesCalls = 0;
  int writes = 0;

  @override
  Future<List<BranchModel>> getBranches({bool includeDeleted = false}) async {
    getBranchesCalls++;
    return const [
      BranchModel(id: 'b1', name: 'Downtown'),
      BranchModel(id: 'b2', name: 'Airport'),
    ];
  }

  @override
  Future<BranchModel> createBranch(BranchModel branch) async {
    writes++;
    return branch.copyWithId('new');
  }

  @override
  Future<void> updateBranch(BranchModel branch) async => writes++;

  @override
  Future<void> setBranchActive(String branchId, bool isActive) async => writes++;

  @override
  Future<void> softDeleteBranch(String branchId) async => writes++;
}

void main() {
  group('BranchRepositoryImpl caching', () {
    late _CountingBranchRemote remote;
    late CacheManager cache;
    late BranchRepositoryImpl repo;

    setUp(() {
      remote = _CountingBranchRemote();
      cache = CacheManager();
      repo = BranchRepositoryImpl(remote, cache);
    });

    test('repeated reads hit Firestore only once (BEFORE: N, AFTER: 1)',
        () async {
      for (var i = 0; i < 5; i++) {
        final branches = await repo.getBranches();
        expect(branches, hasLength(2));
      }
      expect(remote.getBranchesCalls, 1,
          reason: '5 callers in a session → a single Firestore read');
    });

    test('active and includeDeleted lists are cached separately', () async {
      await repo.getBranches();
      await repo.getBranches(includeDeleted: true);
      await repo.getBranches();
      await repo.getBranches(includeDeleted: true);
      expect(remote.getBranchesCalls, 2, reason: 'one read per distinct key');
    });

    test('a write invalidates the cache so the next read re-fetches', () async {
      await repo.getBranches();
      expect(remote.getBranchesCalls, 1);

      await repo.createBranch(
          const BranchModel(id: '', name: 'New').toEntity());
      await repo.getBranches();
      expect(remote.getBranchesCalls, 2,
          reason: 'create invalidated branches:* → fresh read');

      await repo.setBranchActive('b1', false);
      await repo.getBranches();
      expect(remote.getBranchesCalls, 3);
    });

    test('forceRefresh bypasses a fresh cache', () async {
      await repo.getBranches();
      await repo.getBranches(forceRefresh: true);
      expect(remote.getBranchesCalls, 2);
    });
  });
}
