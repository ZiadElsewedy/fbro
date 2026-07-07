/// Lifecycle of an operations request, stored as a string in
/// `requests/{id}.status`:
///
/// `Pending → Approved`   (granted)
/// `Pending → Rejected`   (declined)
///
/// Deliberately minimal — a Request is "someone asking approval before doing
/// something", not a ticket with an SLA/queue/lifecycle. An approver (the
/// own-branch manager or any admin) moves a [pending] request to [approved] or
/// [rejected]; both are terminal, a read-only record.
enum RequestStatus {
  pending,
  approved,
  rejected;

  String get value => name;

  bool get isPending => this == RequestStatus.pending;
  bool get isApproved => this == RequestStatus.approved;
  bool get isRejected => this == RequestStatus.rejected;

  /// Still awaiting a decision — stays in the active inbox section; decided
  /// requests sink to the archive.
  bool get isActive => this == RequestStatus.pending;

  bool get isTerminal => !isActive;

  /// A negative outcome (drives the muted "rejected" status colour).
  bool get isNegative => this == RequestStatus.rejected;

  String get label => switch (this) {
        RequestStatus.pending => 'Pending',
        RequestStatus.approved => 'Approved',
        RequestStatus.rejected => 'Rejected',
      };

  /// The statuses an APPROVER may move this request to next (drives the header
  /// approve/reject control): `pending → approved | rejected`; terminal → none.
  List<RequestStatus> get approverNext => switch (this) {
        RequestStatus.pending => const [
            RequestStatus.approved,
            RequestStatus.rejected,
          ],
        _ => const <RequestStatus>[],
      };

  /// Whether an approver moving to this status records a *decision* (stamps
  /// `decidedBy`/`decidedAt`). Both approve and reject do.
  bool get isDecision =>
      this == RequestStatus.approved || this == RequestStatus.rejected;

  /// Parses the stored string; unknown/missing → [pending].
  static RequestStatus fromString(String? raw) {
    for (final s in RequestStatus.values) {
      if (s.name == raw) return s;
    }
    return RequestStatus.pending;
  }
}
