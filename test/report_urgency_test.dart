import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/report_severity.dart';
import 'package:drop/core/enums/report_status.dart';
import 'package:drop/features/reports/domain/entities/report_entity.dart';
import 'package:drop/features/reports/domain/report_urgency.dart';

/// The client-side SLA / urgency engine — the lean alternative to a scheduled
/// reminder function. Pure, so it's unit-tested directly.
void main() {
  final now = DateTime(2026, 7, 3, 12, 0);

  ReportEntity report({
    required ReportSeverity severity,
    required ReportStatus status,
    required Duration age,
  }) =>
      ReportEntity(
        id: 'r',
        title: 't',
        severity: severity,
        status: status,
        createdAt: now.subtract(age),
      );

  group('reportSlaBreached', () {
    test('critical breaches after 15 minutes', () {
      final within = report(
          severity: ReportSeverity.critical,
          status: ReportStatus.newReport,
          age: const Duration(minutes: 10));
      final past = report(
          severity: ReportSeverity.critical,
          status: ReportStatus.newReport,
          age: const Duration(minutes: 20));
      expect(reportSlaBreached(within, now), isFalse);
      expect(reportSlaBreached(past, now), isTrue);
    });

    test('high breaches after 1 hour', () {
      final past = report(
          severity: ReportSeverity.high,
          status: ReportStatus.underReview,
          age: const Duration(hours: 2));
      expect(reportSlaBreached(past, now), isTrue);
    });

    test('low severity never breaches (untimed)', () {
      final old = report(
          severity: ReportSeverity.low,
          status: ReportStatus.newReport,
          age: const Duration(days: 5));
      expect(reportSlaBreached(old, now), isFalse);
    });

    test('a resolved report never breaches, however old', () {
      final resolved = report(
          severity: ReportSeverity.critical,
          status: ReportStatus.resolved,
          age: const Duration(days: 1));
      expect(reportSlaBreached(resolved, now), isFalse);
    });
  });

  group('reportUrgencyLevel', () {
    test('breached when past SLA', () {
      final r = report(
          severity: ReportSeverity.critical,
          status: ReportStatus.newReport,
          age: const Duration(minutes: 30));
      expect(reportUrgencyLevel(r, now), ReportUrgencyLevel.breached);
    });

    test('watch when high/critical but within SLA', () {
      final r = report(
          severity: ReportSeverity.high,
          status: ReportStatus.newReport,
          age: const Duration(minutes: 5));
      expect(reportUrgencyLevel(r, now), ReportUrgencyLevel.watch);
    });

    test('calm when resolved', () {
      final r = report(
          severity: ReportSeverity.critical,
          status: ReportStatus.resolved,
          age: const Duration(minutes: 30));
      expect(reportUrgencyLevel(r, now), ReportUrgencyLevel.calm);
    });
  });

  group('sortReportsByUrgency', () {
    test('active breached criticals sort ahead of resolved and calm', () {
      final settled = report(
          severity: ReportSeverity.critical,
          status: ReportStatus.resolved,
          age: const Duration(minutes: 30));
      final breached = report(
          severity: ReportSeverity.critical,
          status: ReportStatus.newReport,
          age: const Duration(minutes: 30));
      final calmLow = report(
          severity: ReportSeverity.low,
          status: ReportStatus.newReport,
          age: const Duration(minutes: 5));

      final sorted = sortReportsByUrgency([settled, calmLow, breached], now: now);
      expect(sorted.first, same(breached));
      // The active low outranks the resolved critical (active beats settled).
      expect(sorted[1], same(calmLow));
      expect(sorted.last, same(settled));
    });
  });
}
