import 'package:drop/core/enums/report_severity.dart';
import 'package:drop/features/reports/domain/entities/report_entity.dart';

/// Client-side urgency / SLA engine for reports (the lean alternative to a
/// scheduled reminder function). Pure Dart: given a report and "now", it derives
/// whether the report has breached its severity SLA, an urgency level for
/// badges, and a rank for the queue ordering. No infrastructure, no writes —
/// mirrors how task/schedule urgency is already computed client-side.

/// Urgency tiers, used to tint a badge in the list/detail.
enum ReportUrgencyLevel {
  /// Settled, or low/untimed — no urgency treatment.
  calm,

  /// Active and high/critical, still within SLA — worth watching.
  watch,

  /// Active and past its severity SLA window — breached.
  breached,
}

/// Whether an OPEN report has sat past its severity SLA window. Settled reports
/// (resolved/closed/rejected) and untimed severities (low) never breach.
bool reportSlaBreached(ReportEntity report, DateTime now) {
  if (!report.status.isActive) return false;
  final window = report.severity.slaWindow;
  final created = report.createdAt;
  if (window == null || created == null) return false;
  return now.difference(created) > window;
}

ReportUrgencyLevel reportUrgencyLevel(ReportEntity report, DateTime now) {
  if (!report.status.isActive) return ReportUrgencyLevel.calm;
  if (reportSlaBreached(report, now)) return ReportUrgencyLevel.breached;
  if (report.severity == ReportSeverity.critical ||
      report.severity == ReportSeverity.high) {
    return ReportUrgencyLevel.watch;
  }
  return ReportUrgencyLevel.calm;
}

/// Sort rank (higher = surfaced first). Active reports outrank settled ones;
/// within active, SLA-breached first, then by severity weight. Deterministic and
/// pure so the list order is stable given the same inputs.
int reportRank(ReportEntity report, DateTime now) {
  var rank = 0;
  if (report.status.isActive) rank += 1000;
  if (reportSlaBreached(report, now)) rank += 500;
  rank += report.severity.weight * 10;
  return rank;
}

/// Orders reports for the Reports Center list: rank desc, then newest-first on a
/// tie (a stable, index-free client sort — report volume per scope is small).
List<ReportEntity> sortReportsByUrgency(
  List<ReportEntity> reports, {
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final sorted = [...reports];
  sorted.sort((a, b) {
    final byRank = reportRank(b, clock).compareTo(reportRank(a, clock));
    if (byRank != 0) return byRank;
    final at = a.createdAt;
    final bt = b.createdAt;
    if (at == null && bt == null) return 0;
    if (at == null) return 1; // nulls last
    if (bt == null) return -1;
    return bt.compareTo(at); // newest first
  });
  return sorted;
}
