import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/request_status.dart';
import 'package:drop/core/enums/request_type.dart';
import 'package:drop/features/requests/domain/entities/request_entity.dart';
import 'package:drop/features/requests/domain/request_metrics.dart';

void main() {
  final now = DateTime(2026, 7, 7, 15);

  RequestEntity r(
    String id, {
    RequestStatus status = RequestStatus.pending,
    RequestType type = RequestType.other,
    DateTime? createdAt,
    DateTime? decidedAt,
    DateTime? completedAt,
  }) =>
      RequestEntity(
        id: id,
        type: type,
        requesterId: 'u1',
        status: status,
        createdAt: createdAt,
        decidedAt: decidedAt,
        completedAt: completedAt,
      );

  group('RequestMetrics.from', () {
    test('empty snapshot yields zeros and no averages', () {
      final m = RequestMetrics.from(const [], now: now);
      expect(m.total, 0);
      expect(m.hasData, isFalse);
      expect(m.avgApprovalTime, isNull);
      expect(m.topTypeThisWeek, isNull);
    });

    test('counts each status bucket', () {
      final m = RequestMetrics.from([
        r('a', status: RequestStatus.pending),
        r('b', status: RequestStatus.pending),
        r('c', status: RequestStatus.approved),
        r('d', status: RequestStatus.rejected, decidedAt: now),
        r('e', status: RequestStatus.cancelled),
      ], now: now);
      expect(m.pending, 2);
      expect(m.approved, 1);
      expect(m.rejected, 1);
      expect(m.total, 5);
    });

    test('completedToday only counts completions from today', () {
      final m = RequestMetrics.from([
        r('today',
            status: RequestStatus.completed,
            completedAt: DateTime(2026, 7, 7, 9)),
        r('yesterday',
            status: RequestStatus.completed,
            completedAt: DateTime(2026, 7, 6, 9)),
      ], now: now);
      expect(m.completedToday, 1);
    });

    test('avgApprovalTime averages submission→decision durations', () {
      final m = RequestMetrics.from([
        // 2h to decide
        r('a',
            status: RequestStatus.approved,
            createdAt: DateTime(2026, 7, 7, 8),
            decidedAt: DateTime(2026, 7, 7, 10)),
        // 4h to decide
        r('b',
            status: RequestStatus.rejected,
            createdAt: DateTime(2026, 7, 7, 6),
            decidedAt: DateTime(2026, 7, 7, 10)),
        // pending — no decision, ignored
        r('c', status: RequestStatus.pending, createdAt: DateTime(2026, 7, 7, 9)),
      ], now: now);
      expect(m.avgApprovalTime, const Duration(hours: 3));
    });

    test('topTypeThisWeek finds the most common type in the last 7 days', () {
      final recent = DateTime(2026, 7, 6, 12);
      final old = DateTime(2026, 6, 1, 12); // outside the window
      final m = RequestMetrics.from([
        r('a', type: RequestType.leaveStore, createdAt: recent),
        r('b', type: RequestType.leaveStore, createdAt: recent),
        r('c', type: RequestType.maintenance, createdAt: recent),
        r('d', type: RequestType.maintenance, createdAt: old),
        r('e', type: RequestType.maintenance, createdAt: old),
      ], now: now);
      expect(m.topTypeThisWeek, RequestType.leaveStore);
      expect(m.topTypeCount, 2);
    });
  });
}
