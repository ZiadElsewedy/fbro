import 'package:flutter_test/flutter_test.dart';
import 'package:fbro/core/cache/cache_entry.dart';
import 'package:fbro/core/cache/cache_manager.dart';
import 'package:fbro/core/cache/cache_policy.dart';

/// Pure-logic verification of the in-memory cache primitives (no Firebase).
/// These prove the freshness, invalidation and read-savings behaviour the
/// repository caches rely on.
void main() {
  group('CacheEntry.isStale', () {
    test('fresh within TTL, stale past TTL', () {
      final fresh = CacheEntry('v', const CachePolicy(Duration(minutes: 5)),
          storedAt: DateTime.now().subtract(const Duration(minutes: 1)));
      final stale = CacheEntry('v', const CachePolicy(Duration(minutes: 5)),
          storedAt: DateTime.now().subtract(const Duration(minutes: 6)));
      expect(fresh.isStale, isFalse);
      expect(stale.isStale, isTrue);
    });
  });

  group('CacheManager read/write', () {
    test('miss returns null then hit returns the stored value', () {
      final cache = CacheManager();
      expect(cache.read<String>('k'), isNull);
      cache.write('k', 'hello', CachePolicy.stable);
      expect(cache.read<String>('k'), 'hello');
    });

    test('a zero-TTL entry is treated as an immediate miss and evicted', () {
      final cache = CacheManager();
      cache.write('k', 'hello', const CachePolicy(Duration.zero));
      expect(cache.read<String>('k'), isNull);
    });

    test('invalidatePrefix removes every matching key, others survive', () {
      final cache = CacheManager()
        ..write('members:b1', 'x', CachePolicy.stable)
        ..write('members:b2', 'y', CachePolicy.stable)
        ..write('branches:active', 'z', CachePolicy.stable);
      cache.invalidatePrefix(CacheKeys.branchMembersPrefix);
      expect(cache.read<String>('members:b1'), isNull);
      expect(cache.read<String>('members:b2'), isNull);
      expect(cache.read<String>('branches:active'), 'z');
    });

    test('clear empties the store', () {
      final cache = CacheManager()..write('a', 1, CachePolicy.stable);
      cache.clear();
      expect(cache.read<int>('a'), isNull);
    });
  });

  group('CacheManager.readOrLoad', () {
    test('loads once, then serves from cache (= reads saved)', () async {
      final cache = CacheManager();
      var loads = 0;
      Future<int> loader() async {
        loads++;
        return 42;
      }

      expect(await cache.readOrLoad('k', CachePolicy.stable, loader), 42);
      expect(await cache.readOrLoad('k', CachePolicy.stable, loader), 42);
      expect(await cache.readOrLoad('k', CachePolicy.stable, loader), 42);
      expect(loads, 1, reason: '3 reads must hit the loader only once');
    });

    test('forceRefresh bypasses the cached value and re-warms it', () async {
      final cache = CacheManager();
      var loads = 0;
      Future<int> loader() async => ++loads;

      await cache.readOrLoad('k', CachePolicy.stable, loader); // loads=1
      await cache.readOrLoad('k', CachePolicy.stable, loader,
          forceRefresh: true); // loads=2
      expect(loads, 2);
      // The re-warmed value is now served from cache.
      expect(await cache.readOrLoad('k', CachePolicy.stable, loader), 2);
      expect(loads, 2);
    });
  });
}
