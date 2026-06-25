/// Lifecycle of a shift-swap request (Phase 7), stored as a string in
/// `shift_swaps/{swapId}.status`:
///
/// `pending → employeeApproved → managerApproved` (or `rejected` at any step).
///
/// An employee asks a coworker to take one of their scheduled slots. The coworker
/// approves first ([employeeApproved]); then the branch manager approves
/// ([managerApproved]), at which point the weekly schedule is updated
/// automatically. Either party (or the manager) can [rejected] it.
enum SwapStatus {
  /// Awaiting the coworker (the spec's `pendingCoworker`).
  pending,

  /// Coworker accepted; awaiting manager/admin (the spec's `pendingManager`).
  employeeApproved,

  /// Final approval — the schedule has been exchanged (the spec's `approved`).
  managerApproved,

  /// Declined by the coworker or the reviewer.
  rejected,

  /// Withdrawn by the requester before it resolved.
  cancelled;

  String get value => name;

  String get label {
    switch (this) {
      case SwapStatus.pending:
        return 'Pending coworker';
      case SwapStatus.employeeApproved:
        return 'Awaiting manager';
      case SwapStatus.managerApproved:
        return 'Approved';
      case SwapStatus.rejected:
        return 'Rejected';
      case SwapStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isPending => this == SwapStatus.pending;
  bool get isEmployeeApproved => this == SwapStatus.employeeApproved;
  bool get isManagerApproved => this == SwapStatus.managerApproved;
  bool get isRejected => this == SwapStatus.rejected;
  bool get isCancelled => this == SwapStatus.cancelled;

  /// Terminal states — no further action is possible.
  bool get isResolved => isManagerApproved || isRejected || isCancelled;

  /// Parses the stored string; unknown/missing → [pending].
  static SwapStatus fromString(String? raw) {
    for (final s in values) {
      if (s.name == raw) return s;
    }
    return SwapStatus.pending;
  }
}
