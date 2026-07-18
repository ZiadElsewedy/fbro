/// How strictly a branch validates the **location** of a clock-in. Attendance is
/// designed so GPS can be switched on later without a refactor: the policy lives
/// in `AttendanceConfig` and is [none] by default, so no coordinates are captured
/// or checked unless a branch opts in. The validation engine consults this — it
/// is the single knob for the whole geofence behaviour.
enum AttendanceLocationPolicy {
  /// No location captured, no geofence check (the default). Clock-in is a pure
  /// time action.
  none,

  /// Capture the location and **warn** if it's outside the branch geofence, but
  /// never block — the record is flagged, not refused.
  soft,

  /// Capture the location and **block** a clock-in outside the branch geofence.
  strict;

  String get value => name;

  String get label => switch (this) {
        AttendanceLocationPolicy.none => 'Off',
        AttendanceLocationPolicy.soft => 'Warn only',
        AttendanceLocationPolicy.strict => 'Enforced',
      };

  /// Whether a location should be captured at all (soft or strict).
  bool get capturesLocation => this != AttendanceLocationPolicy.none;

  /// Whether being outside the geofence should *block* the clock-in.
  bool get blocksOutside => this == AttendanceLocationPolicy.strict;

  /// Parses the stored string; unknown/missing → [none].
  static AttendanceLocationPolicy fromString(String? raw) {
    for (final p in AttendanceLocationPolicy.values) {
      if (p.name == raw) return p;
    }
    return AttendanceLocationPolicy.none;
  }
}
