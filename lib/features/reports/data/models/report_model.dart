import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drop/core/enums/attachment_type.dart';
import 'package:drop/core/enums/report_category.dart';
import 'package:drop/core/enums/report_privacy.dart';
import 'package:drop/core/enums/report_recipient.dart';
import 'package:drop/core/enums/report_severity.dart';
import 'package:drop/core/enums/report_status.dart';
import 'package:drop/core/extensions/firestore_extensions.dart';
import 'package:drop/features/reports/domain/entities/report_entity.dart';
import 'package:drop/features/reports/domain/entities/report_identity.dart';
import 'package:drop/features/task/domain/entities/activity_entry.dart';
import 'package:drop/features/task/domain/entities/task_attachment.dart';

/// Firestore (de)serialization for [ReportEntity] — collection `reports/{id}`.
///
/// The creator uid is deliberately **absent** from this doc (privacy split — it
/// lives in the private `reporter/identity` subdoc; see
/// [reporterIdentityToMap]). `reporterDisplayName` is written only when the
/// report's privacy is `normal`, so a confidential sender is never exposed on
/// the manager-readable doc. `visibleToManager` is a denormalized bool derived
/// from `recipient` for the manager list query + Firestore rule.
class ReportModel {
  final String id;
  final String? branchId;
  final String title;
  final String? description;
  final ReportCategory category;
  final ReportRecipient recipient;
  final ReportPrivacy privacy;
  final ReportSeverity severity;
  final ReportStatus status;
  final String? reporterDisplayName;
  final List<TaskAttachment> attachments;
  final List<ActivityEntry> activityLog;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;

  const ReportModel({
    required this.id,
    this.branchId,
    required this.title,
    this.description,
    this.category = ReportCategory.operations,
    this.recipient = ReportRecipient.manager,
    this.privacy = ReportPrivacy.normal,
    this.severity = ReportSeverity.medium,
    this.status = ReportStatus.newReport,
    this.reporterDisplayName,
    this.attachments = const [],
    this.activityLog = const [],
    this.createdAt,
    this.updatedAt,
    this.resolvedAt,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map, {String? id}) =>
      ReportModel(
        id: id ?? map['id'] as String? ?? '',
        branchId: map['branchId'] as String?,
        title: map['title'] as String? ?? '',
        description: map['description'] as String?,
        category: ReportCategory.fromString(map['category'] as String?),
        recipient: ReportRecipient.fromString(map['recipient'] as String?),
        privacy: ReportPrivacy.fromString(map['privacy'] as String?),
        severity: ReportSeverity.fromString(map['severity'] as String?),
        status: ReportStatus.fromString(map['status'] as String?),
        reporterDisplayName: map['reporterDisplayName'] as String?,
        attachments: _attachmentsFromList(map['attachments']),
        activityLog: _activityLogFromList(map['activityLog']),
        createdAt: map.date('createdAt'),
        updatedAt: map.date('updatedAt'),
        resolvedAt: map.date('resolvedAt'),
      );

  factory ReportModel.fromEntity(ReportEntity e) => ReportModel(
        id: e.id,
        branchId: e.branchId,
        title: e.title,
        description: e.description,
        category: e.category,
        recipient: e.recipient,
        privacy: e.privacy,
        severity: e.severity,
        status: e.status,
        reporterDisplayName: e.reporterDisplayName,
        attachments: e.attachments,
        activityLog: e.activityLog,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
        resolvedAt: e.resolvedAt,
      );

  /// Persisted fields. `createdAt`/`updatedAt` are written by the datasource as
  /// server timestamps, so they're intentionally not included here.
  Map<String, dynamic> toMap() => {
        'id': id,
        'branchId': branchId,
        'title': title,
        'description': description,
        'category': category.value,
        'recipient': recipient.value,
        'privacy': privacy.value,
        'severity': severity.value,
        'status': status.value,
        // Denormalized manager-visibility flag (drives the manager query + rule).
        'visibleToManager': recipient.includesManager,
        // Privacy split: the sender's name rides the manager-readable doc ONLY
        // for a `normal` report; confidential never exposes it here.
        'reporterDisplayName':
            privacy.exposesName ? reporterDisplayName : null,
        'attachments': _attachmentsToList(attachments),
        'activityLog': _activityLogToList(activityLog),
        'resolvedAt':
            resolvedAt == null ? null : Timestamp.fromDate(resolvedAt!),
      };

  ReportModel copyWithId(String newId) => ReportModel(
        id: newId,
        branchId: branchId,
        title: title,
        description: description,
        category: category,
        recipient: recipient,
        privacy: privacy,
        severity: severity,
        status: status,
        reporterDisplayName: reporterDisplayName,
        attachments: attachments,
        activityLog: activityLog,
        createdAt: createdAt,
        updatedAt: updatedAt,
        resolvedAt: resolvedAt,
      );

  ReportEntity toEntity() => ReportEntity(
        id: id,
        branchId: branchId,
        title: title,
        description: description,
        category: category,
        recipient: recipient,
        privacy: privacy,
        severity: severity,
        status: status,
        reporterDisplayName: reporterDisplayName,
        attachments: attachments,
        activityLog: activityLog,
        createdAt: createdAt,
        updatedAt: updatedAt,
        resolvedAt: resolvedAt,
      );

  // ─── Reporter identity subdoc (`reports/{id}/reporter/identity`) ──────
  /// The private identity payload. `createdAt` is written as a server timestamp
  /// by the datasource, so it's not included here.
  static Map<String, dynamic> reporterIdentityToMap(ReportIdentity i) => {
        'reportId': i.reportId,
        'createdByUserId': i.createdByUserId,
        'createdByName': i.createdByName,
        'privacy': i.privacy.value,
        'branchId': i.branchId,
      };

  static ReportIdentity reporterIdentityFromMap(
    Map<String, dynamic> map, {
    String? reportId,
  }) =>
      ReportIdentity(
        reportId: reportId ?? map['reportId'] as String? ?? '',
        createdByUserId: map['createdByUserId'] as String? ?? '',
        createdByName: map['createdByName'] as String?,
        privacy: ReportPrivacy.fromString(map['privacy'] as String?),
        branchId: map['branchId'] as String?,
        createdAt: map.date('createdAt'),
      );

  // ─── Embedded (de)serializers (mirror TaskModel) ──────────────────────
  static List<ActivityEntry> _activityLogFromList(dynamic raw) {
    if (raw is! List) return const [];
    final result = <ActivityEntry>[];
    for (final e in raw) {
      if (e is Map) {
        final at = (e['at'] as Timestamp?)?.toDate();
        if (at == null) continue;
        result.add(ActivityEntry(
          status: e['status'] as String? ?? '',
          actorId: e['actorId'] as String? ?? '',
          actorName: e['actorName'] as String?,
          at: at,
          note: e['note'] as String?,
          attachments: _attachmentsFromList(e['attachments']),
        ));
      }
    }
    return result;
  }

  static List<Map<String, dynamic>> _activityLogToList(
          List<ActivityEntry> log) =>
      [
        for (final e in log)
          {
            'status': e.status,
            'actorId': e.actorId,
            'actorName': e.actorName,
            'at': Timestamp.fromDate(e.at),
            'note': e.note,
            'attachments': _attachmentsToList(e.attachments),
          },
      ];

  static List<TaskAttachment> _attachmentsFromList(dynamic raw) {
    if (raw is! List) return const [];
    final result = <TaskAttachment>[];
    for (final a in raw) {
      if (a is Map) {
        final url = a['url'] as String? ?? '';
        if (url.isEmpty) continue;
        result.add(TaskAttachment(
          id: a['id'] as String? ?? '',
          url: url,
          type: AttachmentType.fromString(a['type'] as String?),
          uploadedAt: (a['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          uploadedBy: a['uploadedBy'] as String? ?? '',
          uploadedByName: a['uploadedByName'] as String?,
          durationMs: (a['durationMs'] as num?)?.toInt(),
        ));
      }
    }
    return result;
  }

  static List<Map<String, dynamic>> _attachmentsToList(
          List<TaskAttachment> items) =>
      [
        for (final a in items)
          {
            'id': a.id,
            'url': a.url,
            'type': a.type.value,
            'uploadedAt': Timestamp.fromDate(a.uploadedAt),
            'uploadedBy': a.uploadedBy,
            'uploadedByName': a.uploadedByName,
            'durationMs': a.durationMs,
          },
      ];
}
