/// Where a case is routed, stored as a string in `cases/{id}.recipient`.
///
/// [manager] — a branch-level issue the branch manager can handle.
/// [admin]   — must reach ownership / higher authority (a serious complaint, a
///             confidential concern, a personal/policy matter). An admin-routed
///             case is deliberately NOT visible to the branch manager (see
///             `cases` rules + the denormalized `visibleToManager` flag).
/// [both]    — impacts the branch AND ownership.
enum CaseRecipient {
  manager,
  admin,
  both;

  String get value => name;

  bool get isManager => this == CaseRecipient.manager;
  bool get isAdmin => this == CaseRecipient.admin;
  bool get isBoth => this == CaseRecipient.both;

  /// Whether a branch manager may see a case routed this way. Mirrored onto the
  /// case doc as `visibleToManager` (a denormalized bool the manager's list
  /// query + the Firestore rule key off — an admin-only case is hidden).
  bool get includesManager => this != CaseRecipient.admin;

  /// Whether an admin is a routed recipient (admin can read everything anyway;
  /// this drives whether the admin is *notified* on create).
  bool get includesAdmin => this != CaseRecipient.manager;

  String get label => switch (this) {
        CaseRecipient.manager => 'Branch Manager',
        CaseRecipient.admin => 'Admin',
        CaseRecipient.both => 'Manager & Admin',
      };

  /// Parses the stored string; unknown/missing → [manager] (the safe branch
  /// default — never silently escalates to admin).
  static CaseRecipient fromString(String? raw) {
    switch (raw) {
      case 'admin':
        return CaseRecipient.admin;
      case 'both':
        return CaseRecipient.both;
      case 'manager':
      default:
        return CaseRecipient.manager;
    }
  }
}
