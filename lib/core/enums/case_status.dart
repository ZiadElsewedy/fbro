/// Lifecycle of a case, stored in `cases/{id}.status`. A case is a private
/// conversation between an employee and a manager/admin about a specific issue,
/// kept open until resolution — so the lifecycle is a short conversation arc,
/// not a task workflow:
///
/// `Open → In Discussion → Waiting Response → Closed`
///
/// The reporter files an [open] case; the recipient (manager/admin) moves it
/// into [inDiscussion], optionally parking it on [waitingResponse] while they
/// wait for the reporter, and [closed] once resolved. A closed case is
/// **read-only** (no new messages) until a recipient reopens it → In Discussion.
enum CaseStatus {
  open,
  inDiscussion,
  waitingResponse,
  closed;

  String get value => name;

  bool get isOpen => this == CaseStatus.open;
  bool get isInDiscussion => this == CaseStatus.inDiscussion;
  bool get isWaitingResponse => this == CaseStatus.waitingResponse;
  bool get isClosed => this == CaseStatus.closed;

  /// Still an open conversation — counts as "active" and stays out of the
  /// collapsed archive section in the inbox.
  bool get isActive => this != CaseStatus.closed;

  String get label => switch (this) {
        CaseStatus.open => 'Open',
        CaseStatus.inDiscussion => 'In Discussion',
        CaseStatus.waitingResponse => 'Waiting Response',
        CaseStatus.closed => 'Closed',
      };

  /// The statuses a recipient may move this case to next (drives the header
  /// status control). Closing is always available while active; a closed case
  /// can only be reopened (→ In Discussion).
  List<CaseStatus> get allowedNext => switch (this) {
        CaseStatus.open => const [
            CaseStatus.inDiscussion,
            CaseStatus.closed,
          ],
        CaseStatus.inDiscussion => const [
            CaseStatus.waitingResponse,
            CaseStatus.closed,
          ],
        CaseStatus.waitingResponse => const [
            CaseStatus.inDiscussion,
            CaseStatus.closed,
          ],
        CaseStatus.closed => const [CaseStatus.inDiscussion], // reopen
      };

  bool canTransitionTo(CaseStatus to) => allowedNext.contains(to);

  /// Parses the stored string; unknown/missing → [open].
  static CaseStatus fromString(String? raw) {
    for (final s in CaseStatus.values) {
      if (s.name == raw) return s;
    }
    return CaseStatus.open;
  }
}
