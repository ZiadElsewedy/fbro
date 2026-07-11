/// The **lifecycle** of one attendance record, stored as a string in
/// `attendance/{id}.status`.
///
/// This is the *attendance lifecycle only*. It deliberately carries **no
/// approve/reject state** — a disputed record is fixed through an *Attendance
/// Correction Request* (which owns its own Pending/Approved/Rejected decision,
/// reusing the Operations Requests infrastructure), not by moving the record
/// into an "approved" status. Likewise, facts like "late", "left early" or
/// "worked overtime" are **derived** from the minute fields on the entity
/// (`isLate` / `hasEarlyLeave` / `hasOvertime`), not extra statuses — so the
/// state space stays small and can't drift (mirrors `task_schedule.dart`, which
/// derives a phase instead of persisting one).
///
/// Transitions:
/// ```
/// (no record) → inProgress            clock in
/// inProgress  → completed             clock out
/// inProgress  → pendingReview         auto-closed (never clocked out)
/// pendingReview → completed           a manager/correction supplies the missing
///                                     clock-out (source: correction / managerEdit)
/// (roster)    → absent                rostered, never showed
/// (roster)    → onLeave               on leave that day (from the schedule)
/// ```
///
/// [scheduled] / [absent] / [onLeave] are also used **virtually** by the live
/// board for a rostered employee with no record yet — no document is written
/// until someone clocks in (or a manager marks absent), so these stay cheap.
enum AttendanceStatus {
  scheduled,
  inProgress,
  completed,
  pendingReview,
  absent,
  onLeave;

  /// The string persisted in Firestore (the lower-case name).
  String get value => name;

  String get label => switch (this) {
        AttendanceStatus.scheduled => 'Scheduled',
        AttendanceStatus.inProgress => 'Working',
        AttendanceStatus.completed => 'Completed',
        AttendanceStatus.pendingReview => 'Pending review',
        AttendanceStatus.absent => 'Absent',
        AttendanceStatus.onLeave => 'On leave',
      };

  /// Clocked in and not yet clocked out — the live session the timer runs on.
  bool get isInProgress => this == AttendanceStatus.inProgress;

  /// A settled record that needs no further action. [pendingReview] is **not**
  /// terminal — it's waiting on a correction/edit to supply the missing data.
  bool get isTerminal =>
      this == AttendanceStatus.completed ||
      this == AttendanceStatus.absent ||
      this == AttendanceStatus.onLeave;

  /// Waiting on a manager to resolve it (auto-closed, or flagged).
  bool get needsReview => this == AttendanceStatus.pendingReview;

  /// The person physically showed up for this shift (or is showing up now) —
  /// includes a pending-review record (they clocked in, just never clocked out).
  bool get isPresent =>
      this == AttendanceStatus.inProgress ||
      this == AttendanceStatus.completed ||
      this == AttendanceStatus.pendingReview;

  /// A didn't-show outcome — feeds the absence count + the "absent" board lane.
  bool get isAbsence => this == AttendanceStatus.absent;

  /// Parses the stored string; unknown/missing → [scheduled] (the safe,
  /// no-record-yet default).
  static AttendanceStatus fromString(String? raw) {
    for (final s in AttendanceStatus.values) {
      if (s.name == raw) return s;
    }
    return AttendanceStatus.scheduled;
  }
}
