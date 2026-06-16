/// Lifecycle of a task, stored as a string in `tasks/{taskId}.status`:
///
/// `pending → started → completed → waitingReview → approved | rejected`
///
/// Employees drive a task up to [waitingReview] (start / complete their own
/// work); only a manager/admin sets the terminal [approved] / [rejected] on
/// review (enforced by `firestore.rules`).
enum TaskStatus {
  pending,
  started,
  completed,
  waitingReview,
  approved,
  rejected;

  String get value => name;

  bool get isPending => this == TaskStatus.pending;
  bool get isStarted => this == TaskStatus.started;
  bool get isCompleted => this == TaskStatus.completed;
  bool get isWaitingReview => this == TaskStatus.waitingReview;
  bool get isApproved => this == TaskStatus.approved;
  bool get isRejected => this == TaskStatus.rejected;

  /// Whether this is a terminal review outcome (approved / rejected) that only
  /// a manager/admin may set.
  bool get isReviewed => isApproved || isRejected;

  /// Parses the stored string; unknown/missing → [pending].
  static TaskStatus fromString(String? raw) {
    switch (raw) {
      case 'started':
        return TaskStatus.started;
      case 'completed':
        return TaskStatus.completed;
      case 'waitingReview':
        return TaskStatus.waitingReview;
      case 'approved':
        return TaskStatus.approved;
      case 'rejected':
        return TaskStatus.rejected;
      case 'pending':
      default:
        return TaskStatus.pending;
    }
  }
}
