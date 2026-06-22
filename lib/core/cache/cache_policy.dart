/// How long a cached value stays fresh before a read is treated as a miss.
///
/// Policies are chosen by **data volatility** (see the caching strategy in
/// CURRENT_STATE.md): rarely-changing reference data (profile, role, branch
/// metadata) tolerates a long TTL; data that another device can change out from
/// under us (branch membership) or snapshot aggregations (statistics) use a
/// short one. Live data (the task / notification Firestore streams) is **never**
/// cached through this layer — the stream is the source of truth.
class CachePolicy {
  /// Time a cached value remains valid after it was stored.
  final Duration ttl;

  const CachePolicy(this.ttl);

  /// Reference data that changes rarely and is edited by its owner (user
  /// profile, role, branch list/metadata). 30 minutes, backed by write-through
  /// invalidation so a user's own mutation is reflected immediately.
  static const stable = CachePolicy(Duration(minutes: 30));

  /// Data that changes often or can be changed on **another** device (branch
  /// membership, dashboard statistics). Short TTL so a cross-device change is
  /// never more than a minute stale, while still collapsing per-navigation reads.
  static const volatile = CachePolicy(Duration(seconds: 60));
}
