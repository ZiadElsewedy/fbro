/// Why an employee is away on a given schedule day. Stored lower-case in
/// `weekly_schedules/{id}.leave.<day>.<uid>` — leave is a **day-level** fact
/// (a person is away for the day, not for one shift), managed by the branch
/// manager/admin from the schedule's day sheet.
enum LeaveType {
  annual,
  sick,
  dayOff,
  pending;

  /// The string persisted in Firestore (the lower-case name).
  String get value => name;

  /// Full label for sheets and tooltips.
  String get label => switch (this) {
        LeaveType.annual => 'Annual leave',
        LeaveType.sick => 'Sick leave',
        LeaveType.dayOff => 'Day off',
        LeaveType.pending => 'Pending request',
      };

  /// Compact tag for grid mini-chips (schedule cells are dense).
  String get shortLabel => switch (this) {
        LeaveType.annual => 'Leave',
        LeaveType.sick => 'Sick',
        LeaveType.dayOff => 'Off',
        LeaveType.pending => 'Pending',
      };

  /// A pending request is a question, not a settled absence — surfaces
  /// differently (outline vs filled) so managers can tell them apart.
  bool get isPending => this == LeaveType.pending;

  /// Parses the stored string **preserving absence** — unknown/null → null,
  /// so a bad value can never invent a leave entry.
  static LeaveType? fromStringOrNull(String? raw) {
    for (final t in values) {
      if (t.name == raw) return t;
    }
    return null;
  }
}
