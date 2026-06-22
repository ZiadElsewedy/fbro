import 'package:flutter_test/flutter_test.dart';
import 'package:fbro/features/communications/domain/entities/comms_analytics_entity.dart';

/// Phase 2 Commit 6 — the precomputed analytics entity parses a monthly rollup
/// and derives the broadcast + notification rates.
void main() {
  group('CommsAnalyticsEntity.fromMap', () {
    test('parses totals + per-day series (sorted by day)', () {
      final a = CommsAnalyticsEntity.fromMap(const {
        'totals': {
          'broadcastsSent': 10,
          'recipients': 200,
          'delivered': 180,
          'opened': 90,
          'notifSent': 300,
          'notifRead': 120,
        },
        'days': {
          '03': {'broadcastsSent': 2, 'notifSent': 40},
          '01': {'broadcastsSent': 1, 'opened': 5, 'notifSent': 10},
        },
      });

      expect(a.broadcastsSent, 10);
      expect(a.recipients, 200);
      expect(a.delivered, 180);
      expect(a.opened, 90);
      expect(a.notifSent, 300);
      expect(a.notifRead, 120);
      expect(a.daily.map((p) => p.day).toList(), [1, 3]); // sorted
      expect(a.daily.first.broadcastsSent, 1);
    });

    test('empty / missing doc → all zeros', () {
      final a = CommsAnalyticsEntity.fromMap(const {});
      expect(a.isEmpty, isTrue);
      expect(a.daily, isEmpty);
      expect(CommsAnalyticsEntity.empty.isEmpty, isTrue);
    });
  });

  group('CommsAnalyticsEntity derived rates', () {
    test('failed / delivery / open / read rates', () {
      const a = CommsAnalyticsEntity(
        broadcastsSent: 5,
        recipients: 100,
        delivered: 80,
        opened: 25,
        notifSent: 200,
        notifRead: 50,
      );
      expect(a.failed, 20); // 100 - 80
      expect(a.deliveryRate, 0.8);
      expect(a.openRate, 0.25);
      expect(a.unread, 150); // 200 - 50
      expect(a.readRate, 0.25);
    });

    test('zero recipients / notifications → zero rates (no divide-by-zero)', () {
      const a = CommsAnalyticsEntity();
      expect(a.openRate, 0);
      expect(a.deliveryRate, 0);
      expect(a.readRate, 0);
      expect(a.failed, 0);
      expect(a.unread, 0);
    });

    test('failed never goes negative', () {
      const a = CommsAnalyticsEntity(recipients: 5, delivered: 9);
      expect(a.failed, 0);
    });
  });
}
