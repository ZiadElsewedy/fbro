/// The urgency of an operations request, stored as a string in
/// `requests/{id}.priority`. Replaces an earlier boolean `urgent` flag so the
/// architecture supports a full spectrum even while the create UI initially
/// surfaces only a "High" toggle (High ⇄ Normal). Ordering + notification copy
/// can grow into [low] without a schema change.
enum RequestPriority {
  low,
  normal,
  high;

  String get value => name;

  bool get isHigh => this == RequestPriority.high;
  bool get isLow => this == RequestPriority.low;
  bool get isNormal => this == RequestPriority.normal;

  String get label => switch (this) {
        RequestPriority.low => 'Low',
        RequestPriority.normal => 'Normal',
        RequestPriority.high => 'High',
      };

  /// Sort weight — higher floats to the top of the active inbox section.
  int get weight => switch (this) {
        RequestPriority.high => 2,
        RequestPriority.normal => 1,
        RequestPriority.low => 0,
      };

  /// Parses the stored string; unknown/missing → [normal] (the neutral default).
  static RequestPriority fromString(String? raw) {
    for (final p in RequestPriority.values) {
      if (p.name == raw) return p;
    }
    return RequestPriority.normal;
  }
}
