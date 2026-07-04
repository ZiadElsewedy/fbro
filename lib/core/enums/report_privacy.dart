/// Sender-visibility level of a report, stored in `reports/{id}.privacy`.
///
/// The reporter's identity is always kept in the private `reporter/identity`
/// subdoc (owner + admin only); this enum controls how much surfaces on the
/// manager-readable report doc + in the UI:
///
/// [normal]       — the sender's display name is denormalized onto the report
///                  doc (`reporterDisplayName`); recipients see who filed it.
/// [confidential] — no name on the report doc; managers see "Confidential
///                  Sender". Only an admin can reveal the identity.
enum ReportPrivacy {
  normal,
  confidential;

  String get value => name;

  bool get isNormal => this == ReportPrivacy.normal;
  bool get isConfidential => this == ReportPrivacy.confidential;

  /// Whether the sender's display name may be denormalized onto the (manager
  /// readable) report doc. Only [normal] exposes it — the split is what keeps a
  /// same-branch manager from resolving a confidential reporter.
  bool get exposesName => this == ReportPrivacy.normal;

  String get label => switch (this) {
        ReportPrivacy.normal => 'Normal',
        ReportPrivacy.confidential => 'Confidential',
      };

  String get hint => switch (this) {
        ReportPrivacy.normal => 'Your name is visible to recipients',
        ReportPrivacy.confidential => 'Only an admin can see who you are',
      };

  /// Parses the stored string; unknown/missing → [normal].
  static ReportPrivacy fromString(String? raw) =>
      raw == 'confidential' ? ReportPrivacy.confidential : ReportPrivacy.normal;
}
