/// Sender-visibility level of a case, stored in `cases/{id}.privacy`.
///
/// The reporter's identity is always kept in the private `reporter/identity`
/// subdoc (owner + admin only); this enum controls how much surfaces on the
/// manager-readable case doc + in the UI:
///
/// [normal]       — the sender's display name is denormalized onto the case
///                  doc (`reporterDisplayName`); recipients see who filed it.
/// [confidential] — no name on the case doc; managers see "Confidential
///                  Sender". Only an admin can reveal the identity.
enum CasePrivacy {
  normal,
  confidential;

  String get value => name;

  bool get isNormal => this == CasePrivacy.normal;
  bool get isConfidential => this == CasePrivacy.confidential;

  /// Whether the sender's display name may be denormalized onto the (manager
  /// readable) case doc. Only [normal] exposes it — the split is what keeps a
  /// same-branch manager from resolving a confidential reporter.
  bool get exposesName => this == CasePrivacy.normal;

  String get label => switch (this) {
        CasePrivacy.normal => 'Normal',
        CasePrivacy.confidential => 'Confidential',
      };

  String get hint => switch (this) {
        CasePrivacy.normal => 'Your name is visible to recipients',
        CasePrivacy.confidential => 'Only an admin can see who you are',
      };

  /// Parses the stored string; unknown/missing → [normal].
  static CasePrivacy fromString(String? raw) =>
      raw == 'confidential' ? CasePrivacy.confidential : CasePrivacy.normal;
}
