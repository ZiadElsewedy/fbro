/// Who a broadcast (Communications Center — Phase 1) is addressed to.
///
/// - [allBranches] — an org-wide announcement, visible to every signed-in user.
///   Only an admin may send one. Stored with an empty `branchId` sentinel.
/// - [branch] — scoped to a single store branch (its manager + employees + any
///   admin). Stored with that branch's `branchId`.
///
/// The audience is the human-facing intent; the queryable dimension is the
/// broadcast's `branchId` (`''` for [allBranches]), so reads stay index-free and
/// provably safe under `firestore.rules` (a `whereIn: [branch, '']` query).
enum BroadcastAudience {
  allBranches,
  branch;

  /// The string persisted in Firestore (`broadcasts/{id}.audience`).
  String get value => name;

  /// Capitalized label for the UI.
  String get label =>
      this == BroadcastAudience.allBranches ? 'All branches' : 'Branch';

  bool get isAllBranches => this == BroadcastAudience.allBranches;
  bool get isBranch => this == BroadcastAudience.branch;

  /// Parses the stored string; unknown / missing → [allBranches] (the widest,
  /// least-surprising default for a legacy or malformed document).
  static BroadcastAudience fromString(String? raw) =>
      raw == 'branch' ? BroadcastAudience.branch : BroadcastAudience.allBranches;
}
