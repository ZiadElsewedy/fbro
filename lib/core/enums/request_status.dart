/// Lifecycle of an operations request, stored as a string in
/// `requests/{id}.status`:
///
/// `Pending → Approved → Completed`   (the happy path)
/// `Pending → Rejected`               (declined by an approver)
/// `Pending → Cancelled`              (withdrawn by the requester)
///
/// An approver (manager/admin, per the request's [RequestApprovalPolicy]) moves a
/// [pending] request to [approved] or [rejected]; an approved request is later
/// marked [completed] once the action is done. The requester may [cancel] their
/// own request while it is still pending. [rejected] / [completed] / [cancelled]
/// are terminal — a read-only record.
enum RequestStatus {
  pending,
  approved,
  completed,
  rejected,
  cancelled;

  String get value => name;

  bool get isPending => this == RequestStatus.pending;
  bool get isApproved => this == RequestStatus.approved;
  bool get isCompleted => this == RequestStatus.completed;
  bool get isRejected => this == RequestStatus.rejected;
  bool get isCancelled => this == RequestStatus.cancelled;

  /// Still moving through the workflow (Pending or Approved) — stays in the
  /// active inbox section; terminal states sink to the archive.
  bool get isActive =>
      this == RequestStatus.pending || this == RequestStatus.approved;

  bool get isTerminal => !isActive;

  /// A negative outcome (drives the muted "rejected/cancelled" status colour).
  bool get isNegative =>
      this == RequestStatus.rejected || this == RequestStatus.cancelled;

  String get label => switch (this) {
        RequestStatus.pending => 'Pending',
        RequestStatus.approved => 'Approved',
        RequestStatus.completed => 'Completed',
        RequestStatus.rejected => 'Rejected',
        RequestStatus.cancelled => 'Cancelled',
      };

  /// The statuses an APPROVER may move this request to next (drives the header
  /// status control):
  ///   pending  → approved | rejected
  ///   approved → completed
  ///   terminal → (none)
  List<RequestStatus> get approverNext => switch (this) {
        RequestStatus.pending => const [
            RequestStatus.approved,
            RequestStatus.rejected,
          ],
        RequestStatus.approved => const [RequestStatus.completed],
        _ => const <RequestStatus>[],
      };

  /// Whether an approver moving to this status is recording a *decision* (stamps
  /// `decidedBy`/`decidedAt`).
  bool get isDecision =>
      this == RequestStatus.approved || this == RequestStatus.rejected;

  /// Whether the requester may cancel from this state (only while pending).
  bool get requesterCanCancel => this == RequestStatus.pending;

  /// Parses the stored string; unknown/missing → [pending].
  static RequestStatus fromString(String? raw) {
    for (final s in RequestStatus.values) {
      if (s.name == raw) return s;
    }
    return RequestStatus.pending;
  }
}
