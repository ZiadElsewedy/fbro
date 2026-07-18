/// How an attendance record came to be (or was last mutated) — stored in
/// `attendance/{id}.source`. It keeps the record **honest**: a value written by
/// the employee's own clock action reads differently from one the system
/// auto-closed or a manager edited, so nothing silently rewrites attendance
/// without leaving a trace (paired with the append-only `events` audit log).
enum AttendanceSource {
  /// The employee's own clock-in / clock-out / break action.
  clock,

  /// The system auto-closed a session the employee never clocked out of
  /// (→ `pendingReview`). Written by the `autoCloseAttendance` Cloud Function.
  autoClose,

  /// The record was set from an approved correction request.
  correction,

  /// A manager created or overrode the record by hand (manual edit / override).
  managerEdit;

  String get value => name;

  String get label => switch (this) {
        AttendanceSource.clock => 'Clocked',
        AttendanceSource.autoClose => 'Auto-closed',
        AttendanceSource.correction => 'Corrected',
        AttendanceSource.managerEdit => 'Manager edit',
      };

  /// Whether the record's times came from the employee's own clock actions
  /// (vs. a system/manager intervention) — drives the trust hint on the card.
  bool get isSelfClocked => this == AttendanceSource.clock;

  /// Parses the stored string; unknown/missing → [clock].
  static AttendanceSource fromString(String? raw) {
    for (final s in AttendanceSource.values) {
      if (s.name == raw) return s;
    }
    return AttendanceSource.clock;
  }
}
