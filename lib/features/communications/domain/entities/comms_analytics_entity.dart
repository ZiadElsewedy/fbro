/// Precomputed communications analytics (Communications Center — Phase 2
/// Commit 6). Built from a monthly rollup doc (`analytics/{YYYY-MM}`) that Cloud
/// Functions maintain incrementally, so the dashboard reads **one doc**, never a
/// collection scan.
///
/// Plain immutable value object (no Firebase imports) with a pure [fromMap] so
/// the parsing + derived metrics are unit-testable.
class CommsAnalyticsEntity {
  final int broadcastsSent;
  final int recipients;
  final int delivered;
  final int opened;
  final int notifSent;
  final int notifRead;

  /// Per-day series for the month, ascending by day-of-month.
  final List<CommsDailyPoint> daily;

  const CommsAnalyticsEntity({
    this.broadcastsSent = 0,
    this.recipients = 0,
    this.delivered = 0,
    this.opened = 0,
    this.notifSent = 0,
    this.notifRead = 0,
    this.daily = const [],
  });

  static const empty = CommsAnalyticsEntity();

  // ── Derived broadcast metrics ──
  int get failed => (recipients - delivered).clamp(0, recipients);
  double get deliveryRate => recipients == 0 ? 0 : delivered / recipients;
  double get openRate => recipients == 0 ? 0 : opened / recipients;

  // ── Derived notification metrics ──
  int get unread => (notifSent - notifRead).clamp(0, notifSent);
  double get readRate => notifSent == 0 ? 0 : notifRead / notifSent;

  bool get isEmpty => broadcastsSent == 0 && notifSent == 0;

  static int _i(dynamic v) => (v as num?)?.toInt() ?? 0;

  /// Parses a monthly rollup doc: `{ totals: {...}, days: { "01": {...} } }`.
  factory CommsAnalyticsEntity.fromMap(Map<String, dynamic> map) {
    final totals = (map['totals'] as Map?)?.cast<String, dynamic>() ?? const {};
    final days = (map['days'] as Map?)?.cast<String, dynamic>() ?? const {};

    final daily = <CommsDailyPoint>[];
    days.forEach((key, value) {
      final d = (value as Map?)?.cast<String, dynamic>() ?? const {};
      daily.add(CommsDailyPoint(
        day: int.tryParse(key.toString()) ?? 0,
        broadcastsSent: _i(d['broadcastsSent']),
        opened: _i(d['opened']),
        notifSent: _i(d['notifSent']),
        notifRead: _i(d['notifRead']),
      ));
    });
    daily.sort((a, b) => a.day.compareTo(b.day));

    return CommsAnalyticsEntity(
      broadcastsSent: _i(totals['broadcastsSent']),
      recipients: _i(totals['recipients']),
      delivered: _i(totals['delivered']),
      opened: _i(totals['opened']),
      notifSent: _i(totals['notifSent']),
      notifRead: _i(totals['notifRead']),
      daily: daily,
    );
  }
}

/// One day's counters in the monthly series.
class CommsDailyPoint {
  final int day;
  final int broadcastsSent;
  final int opened;
  final int notifSent;
  final int notifRead;

  const CommsDailyPoint({
    required this.day,
    this.broadcastsSent = 0,
    this.opened = 0,
    this.notifSent = 0,
    this.notifRead = 0,
  });
}
