import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drop/core/enums/report_category.dart';
import 'package:drop/core/enums/report_privacy.dart';
import 'package:drop/core/enums/report_recipient.dart';
import 'package:drop/core/enums/report_severity.dart';
import 'package:drop/core/enums/report_status.dart';
import 'package:drop/features/reports/data/models/report_model.dart';
import 'package:drop/features/reports/domain/entities/report_entity.dart';
import 'package:drop/features/reports/domain/entities/report_identity.dart';

/// The report doc must NEVER carry the creator uid (privacy split), and the
/// denormalized sender name must ride the manager-readable doc ONLY for a
/// `normal` report — the core guarantee that keeps a confidential sender hidden
/// from a same-branch manager.
void main() {
  group('ReportModel.toMap privacy split', () {
    test('never writes a creator uid onto the report doc', () {
      final map = ReportModel.fromEntity(const ReportEntity(
        id: 'r1',
        title: 'Cash mismatch',
        branchId: 'b1',
      )).toMap();
      expect(map.containsKey('createdByUserId'), isFalse);
      expect(map.containsKey('createdBy'), isFalse);
    });

    test('exposes reporterDisplayName only for a normal report', () {
      final normal = ReportModel.fromEntity(const ReportEntity(
        id: 'r',
        title: 't',
        privacy: ReportPrivacy.normal,
        reporterDisplayName: 'Alice',
      )).toMap();
      expect(normal['reporterDisplayName'], 'Alice');

      // Even if a name is set on the entity, a confidential doc must never
      // persist it.
      final confidential = ReportModel.fromEntity(const ReportEntity(
        id: 'r',
        title: 't',
        privacy: ReportPrivacy.confidential,
        reporterDisplayName: 'Alice',
      )).toMap();
      expect(confidential['reporterDisplayName'], isNull);
    });

    test('privacy has exactly two levels (no anonymous)', () {
      expect(ReportPrivacy.values.length, 2);
    });

    test('visibleToManager is derived from the recipient', () {
      Map<String, dynamic> mapFor(ReportRecipient r) =>
          ReportModel.fromEntity(
                  ReportEntity(id: 'r', title: 't', recipient: r))
              .toMap();
      expect(mapFor(ReportRecipient.manager)['visibleToManager'], isTrue);
      expect(mapFor(ReportRecipient.both)['visibleToManager'], isTrue);
      expect(mapFor(ReportRecipient.admin)['visibleToManager'], isFalse);
    });
  });

  group('ReportModel round-trip', () {
    test('fromMap(toMap()) preserves the enums + fields', () {
      const entity = ReportEntity(
        id: 'r7',
        title: 'POS is down',
        description: 'Register 2 will not boot',
        branchId: 'b3',
        category: ReportCategory.operations,
        recipient: ReportRecipient.both,
        privacy: ReportPrivacy.normal,
        severity: ReportSeverity.high,
        status: ReportStatus.underReview,
        reporterDisplayName: 'Sam',
      );
      final round = ReportModel.fromMap(
        ReportModel.fromEntity(entity).toMap(),
        id: 'r7',
      ).toEntity();

      expect(round.title, 'POS is down');
      expect(round.description, 'Register 2 will not boot');
      expect(round.category, ReportCategory.operations);
      expect(round.recipient, ReportRecipient.both);
      expect(round.privacy, ReportPrivacy.normal);
      expect(round.severity, ReportSeverity.high);
      expect(round.status, ReportStatus.underReview);
      expect(round.reporterDisplayName, 'Sam');
      expect(round.visibleToManager, isTrue);
    });

    test('resolvedAt survives as a Timestamp', () {
      final at = DateTime(2026, 7, 3, 9, 30);
      final map = ReportModel.fromEntity(ReportEntity(
        id: 'r',
        title: 't',
        status: ReportStatus.resolved,
        resolvedAt: at,
      )).toMap();
      expect(map['resolvedAt'], isA<Timestamp>());
      expect((map['resolvedAt'] as Timestamp).toDate(), at);
      final back = ReportModel.fromMap(map, id: 'r').toEntity();
      expect(back.resolvedAt, at);
    });
  });

  group('reporter identity subdoc', () {
    test('round-trips the private identity payload', () {
      const identity = ReportIdentity(
        reportId: 'r1',
        createdByUserId: 'u-secret',
        createdByName: 'Alice',
        privacy: ReportPrivacy.confidential,
        branchId: 'b1',
      );
      final map = ReportModel.reporterIdentityToMap(identity);
      expect(map['createdByUserId'], 'u-secret');
      final back = ReportModel.reporterIdentityFromMap(map, reportId: 'r1');
      expect(back.createdByUserId, 'u-secret');
      expect(back.createdByName, 'Alice');
      expect(back.privacy, ReportPrivacy.confidential);
      expect(back.branchId, 'b1');
    });
  });
}
