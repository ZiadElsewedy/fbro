import 'package:fbro/core/cache/cache_entry.dart';
import 'package:fbro/core/cache/cache_policy.dart';

/// A tiny in-memory, key→[CacheEntry] store shared across repositories (one
/// instance, injected via `AppDependencies` — **not** a static/global service
/// locator). It removes redundant Firestore reads of read-mostly reference data
/// within a session.
///
/// Invalidation is two-layered: **passive** TTL (per [CachePolicy]) and
/// **active** write-through — a repository invalidates the relevant key prefix
/// after any write, and the whole cache is cleared on sign-out. Live Firestore
/// streams (tasks, notifications) are intentionally **not** routed through here.
class CacheManager {
  final Map<String, CacheEntry> _store = {};

  /// The fresh cached value for [key], or null on a miss / stale entry (a stale
  /// entry is evicted on access).
  T? read<T>(String key) {
    final entry = _store[key];
    if (entry == null || entry.isStale) {
      if (entry != null) _store.remove(key);
      return null;
    }
    return entry.value as T;
  }

  /// Stores [value] under [key] with [policy].
  void write(String key, Object? value, CachePolicy policy) =>
      _store[key] = CacheEntry(value, policy);

  /// Cache-aside helper: returns the fresh cached value for [key], otherwise
  /// runs [load], stores the result under [policy], and returns it. Pass
  /// [forceRefresh] to bypass the cached value (still re-warms the cache).
  Future<T> readOrLoad<T>(
    String key,
    CachePolicy policy,
    Future<T> Function() load, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = read<T>(key);
      if (cached != null) return cached;
    }
    final value = await load();
    write(key, value, policy);
    return value;
  }

  /// Removes every key starting with [prefix] (e.g. all `branches:` entries).
  void invalidatePrefix(String prefix) =>
      _store.removeWhere((key, _) => key.startsWith(prefix));

  /// Drops every cached value — called on sign-out so a new session never sees
  /// the previous user's cached data.
  void clear() => _store.clear();
}

/// Canonical cache keys, kept in one place so producers (repositories) and
/// invalidators (write paths, possibly in a different feature) can't drift.
class CacheKeys {
  CacheKeys._();

  static const String branchesPrefix = 'branches:';
  static String branches({bool includeDeleted = false}) =>
      'branches:${includeDeleted ? 'all+deleted' : 'active'}';

  static const String branchMembersPrefix = 'members:';
  static String branchMembers(String branchId) => 'members:$branchId';

  static String profile(String uid) => 'profile:$uid';
}
