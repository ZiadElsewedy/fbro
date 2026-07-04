import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/report_category.dart';
import 'package:drop/core/enums/report_recipient.dart';
import 'package:drop/core/enums/report_status.dart';

/// Smart-routing defaults + the manager-visibility derivation that drives the
/// `visibleToManager` flag (the manager list query + Firestore rule), and the
/// simplified 4-step lifecycle.
void main() {
  group('ReportCategory (5 categories) defaultRecipient', () {
    test('there are exactly 5 categories', () {
      expect(ReportCategory.values.length, 5);
    });

    test('security routes to admin; everything else to the manager', () {
      expect(ReportCategory.security.defaultRecipient, ReportRecipient.admin);
      expect(ReportCategory.sales.defaultRecipient, ReportRecipient.manager);
      expect(ReportCategory.inventory.defaultRecipient, ReportRecipient.manager);
      expect(ReportCategory.staff.defaultRecipient, ReportRecipient.manager);
      expect(ReportCategory.operations.defaultRecipient, ReportRecipient.manager);
    });
  });

  group('ReportRecipient manager visibility', () {
    test('admin-routed reports are hidden from the manager', () {
      expect(ReportRecipient.admin.includesManager, isFalse);
    });

    test('manager + both reach the manager', () {
      expect(ReportRecipient.manager.includesManager, isTrue);
      expect(ReportRecipient.both.includesManager, isTrue);
    });

    test('admin is notified for admin + both, not manager-only', () {
      expect(ReportRecipient.admin.includesAdmin, isTrue);
      expect(ReportRecipient.both.includesAdmin, isTrue);
      expect(ReportRecipient.manager.includesAdmin, isFalse);
    });
  });

  group('ReportStatus lifecycle (New → Under Review → Waiting Reply → Resolved)', () {
    test('there are exactly 4 statuses', () {
      expect(ReportStatus.values.length, 4);
    });

    test('new advances or resolves', () {
      expect(ReportStatus.newReport.canTransitionTo(ReportStatus.underReview),
          isTrue);
      expect(
          ReportStatus.newReport.canTransitionTo(ReportStatus.resolved), isTrue);
      expect(ReportStatus.newReport.canTransitionTo(ReportStatus.waitingReply),
          isFalse);
    });

    test('under review can park on waiting reply or resolve', () {
      expect(ReportStatus.underReview.canTransitionTo(ReportStatus.waitingReply),
          isTrue);
      expect(ReportStatus.underReview.canTransitionTo(ReportStatus.resolved),
          isTrue);
    });

    test('resolved only reopens (→ under review)', () {
      expect(ReportStatus.resolved.canTransitionTo(ReportStatus.underReview),
          isTrue);
      expect(
          ReportStatus.resolved.canTransitionTo(ReportStatus.newReport), isFalse);
    });

    test('isActive covers everything except resolved', () {
      expect(ReportStatus.newReport.isActive, isTrue);
      expect(ReportStatus.underReview.isActive, isTrue);
      expect(ReportStatus.waitingReply.isActive, isTrue);
      expect(ReportStatus.resolved.isActive, isFalse);
    });
  });
}
