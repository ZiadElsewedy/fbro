import 'package:drop/core/enums/request_type.dart';
import 'package:drop/features/requests/domain/entities/request_entity.dart';

/// The light manager / admin analytics for the Requests overview — a few honest
/// numbers, no charts or trend engine (owner ruling: lean, "a premium retail
/// operations experience, not a ticketing platform"). Pure over a snapshot of the
/// role-scoped request list, so it recomputes instantly with the stream.
class RequestMetrics {
  final int pending;
  final int approved;
  final int completedToday;
  final int rejected;
  final int total;

  /// Average time from submission to decision (approved OR rejected). Null when
  /// nothing has been decided yet.
  final Duration? avgApprovalTime;

  /// The most common request type in the last 7 days, or null when none.
  final RequestType? topTypeThisWeek;
  final int topTypeCount;

  const RequestMetrics({
    required this.pending,
    required this.approved,
    required this.completedToday,
    required this.rejected,
    required this.total,
    required this.avgApprovalTime,
    required this.topTypeThisWeek,
    required this.topTypeCount,
  });

  static const empty = RequestMetrics(
    pending: 0,
    approved: 0,
    completedToday: 0,
    rejected: 0,
    total: 0,
    avgApprovalTime: null,
    topTypeThisWeek: null,
    topTypeCount: 0,
  );

  /// Whether there is anything worth rendering the strip for.
  bool get hasData => total > 0;

  factory RequestMetrics.from(List<RequestEntity> requests, {DateTime? now}) {
    final clock = now ?? DateTime.now();
    final startOfToday = DateTime(clock.year, clock.month, clock.day);
    final weekAgo = clock.subtract(const Duration(days: 7));

    var pending = 0, approved = 0, completedToday = 0, rejected = 0;
    final decisionDurations = <Duration>[];
    final typeCounts = <RequestType, int>{};

    for (final r in requests) {
      if (r.status.isPending) {
        pending++;
      } else if (r.status.isApproved) {
        approved++;
      } else if (r.status.isRejected) {
        rejected++;
      } else if (r.status.isCompleted) {
        final done = r.completedAt ?? r.decidedAt;
        if (done != null && !done.isBefore(startOfToday)) completedToday++;
      }

      final ttd = r.timeToDecision;
      if (ttd != null) decisionDurations.add(ttd);

      final created = r.createdAt;
      if (created != null && created.isAfter(weekAgo)) {
        typeCounts[r.type] = (typeCounts[r.type] ?? 0) + 1;
      }
    }

    Duration? avg;
    if (decisionDurations.isNotEmpty) {
      final totalMicros = decisionDurations
          .map((d) => d.inMicroseconds)
          .reduce((a, b) => a + b);
      avg = Duration(microseconds: totalMicros ~/ decisionDurations.length);
    }

    RequestType? topType;
    var topCount = 0;
    typeCounts.forEach((t, c) {
      if (c > topCount) {
        topCount = c;
        topType = t;
      }
    });

    return RequestMetrics(
      pending: pending,
      approved: approved,
      completedToday: completedToday,
      rejected: rejected,
      total: requests.length,
      avgApprovalTime: avg,
      topTypeThisWeek: topType,
      topTypeCount: topCount,
    );
  }
}
