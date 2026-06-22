import 'package:fbro/core/cache/cache_policy.dart';

/// A single cached value with the time it was stored and the [CachePolicy] that
/// governs its freshness. The value is held as `Object?` — the store is
/// heterogeneous (lists, entities), so callers cast on read; a per-entry type
/// parameter would only be cosmetic.
class CacheEntry {
  final Object? value;
  final DateTime storedAt;
  final CachePolicy policy;

  CacheEntry(this.value, this.policy, {DateTime? storedAt})
      : storedAt = storedAt ?? DateTime.now();

  /// True once the value has outlived its policy's TTL and should be discarded.
  bool get isStale => DateTime.now().difference(storedAt) >= policy.ttl;
}
