/// What an [AttendanceCorrectionEntity] is asking to fix, stored as a string in
/// `attendance_corrections/{id}.kind`. It drives the reviewer's triage label and
/// the notification copy — the *lifecycle* (Pending/Approved/Rejected) is carried
/// separately by `RequestStatus`, reused so a correction and an operations request
/// share one decision vocabulary.
enum AttendanceCorrectionKind {
  /// Clocked in but never clocked out (the session was auto-closed to
  /// `pendingReview`); the employee supplies the real clock-out.
  missingClockOut,

  /// A recorded clock-in / clock-out time is wrong and should be adjusted.
  wrongTime,

  /// Marked absent (or never rostered) but the employee says they did work.
  absenceDispute,

  /// Anything else — free-form, explained in the reason.
  other;

  String get value => name;

  String get label => switch (this) {
        AttendanceCorrectionKind.missingClockOut => 'Missing clock-out',
        AttendanceCorrectionKind.wrongTime => 'Wrong time',
        AttendanceCorrectionKind.absenceDispute => 'Absence dispute',
        AttendanceCorrectionKind.other => 'Other',
      };

  /// Parses the stored string; unknown/missing → [other] (the safe catch-all).
  static AttendanceCorrectionKind fromString(String? raw) {
    for (final k in AttendanceCorrectionKind.values) {
      if (k.name == raw) return k;
    }
    return AttendanceCorrectionKind.other;
  }
}
