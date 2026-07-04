/// Where a report is routed, stored as a string in `reports/{id}.recipient`.
///
/// [manager] — a branch-level issue the branch manager can handle.
/// [admin]   — must reach ownership / higher authority (a serious complaint, a
///             confidential concern, a policy/financial matter). An admin-routed
///             report is deliberately NOT visible to the branch manager (see
///             `reports` rules + the denormalized `visibleToManager` flag).
/// [both]    — impacts the branch AND ownership.
enum ReportRecipient {
  manager,
  admin,
  both;

  String get value => name;

  bool get isManager => this == ReportRecipient.manager;
  bool get isAdmin => this == ReportRecipient.admin;
  bool get isBoth => this == ReportRecipient.both;

  /// Whether a branch manager may see a report routed this way. Mirrored onto
  /// the report doc as `visibleToManager` (a denormalized bool the manager's
  /// list query + the Firestore rule key off — an admin-only report is hidden).
  bool get includesManager => this != ReportRecipient.admin;

  /// Whether an admin is a routed recipient (admin can read everything anyway;
  /// this drives whether the admin is *notified* on create).
  bool get includesAdmin => this != ReportRecipient.manager;

  String get label => switch (this) {
        ReportRecipient.manager => 'Branch Manager',
        ReportRecipient.admin => 'Admin',
        ReportRecipient.both => 'Manager & Admin',
      };

  /// Parses the stored string; unknown/missing → [manager] (the safe branch
  /// default — never silently escalates to admin).
  static ReportRecipient fromString(String? raw) {
    switch (raw) {
      case 'admin':
        return ReportRecipient.admin;
      case 'both':
        return ReportRecipient.both;
      case 'manager':
      default:
        return ReportRecipient.manager;
    }
  }
}
