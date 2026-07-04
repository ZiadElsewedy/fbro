/// How urgent a report is, stored in `reports/{id}.severity`. Drives the
/// client-side urgency engine (`report_urgency.dart`): severity sets the SLA
/// window and the base rank; age + open status escalate it.
enum ReportSeverity {
  low,
  medium,
  high,
  critical;

  String get value => name;

  bool get isLow => this == ReportSeverity.low;
  bool get isMedium => this == ReportSeverity.medium;
  bool get isHigh => this == ReportSeverity.high;
  bool get isCritical => this == ReportSeverity.critical;

  /// Sort/priority weight (higher = more urgent). Used by the urgency ranking.
  int get weight => switch (this) {
        ReportSeverity.low => 0,
        ReportSeverity.medium => 1,
        ReportSeverity.high => 2,
        ReportSeverity.critical => 3,
      };

  /// The SLA window: how long an OPEN report of this severity may sit before it
  /// is considered breached (surfaced as a warning badge + count). Null = no SLA
  /// (low severity is untimed). Mirrors the spec's examples (critical 15m,
  /// high 1h) with a sensible medium tier.
  Duration? get slaWindow => switch (this) {
        ReportSeverity.critical => const Duration(minutes: 15),
        ReportSeverity.high => const Duration(hours: 1),
        ReportSeverity.medium => const Duration(hours: 8),
        ReportSeverity.low => null,
      };

  String get label => switch (this) {
        ReportSeverity.low => 'Low',
        ReportSeverity.medium => 'Medium',
        ReportSeverity.high => 'High',
        ReportSeverity.critical => 'Critical',
      };

  /// Parses the stored string; unknown/missing → [medium] (a neutral default).
  static ReportSeverity fromString(String? raw) {
    switch (raw) {
      case 'low':
        return ReportSeverity.low;
      case 'high':
        return ReportSeverity.high;
      case 'critical':
        return ReportSeverity.critical;
      case 'medium':
      default:
        return ReportSeverity.medium;
    }
  }
}
