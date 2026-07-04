import 'dart:io';

import 'package:drop/core/enums/attachment_type.dart';
import 'package:drop/features/reports/domain/entities/report_entity.dart';
import 'package:drop/features/reports/domain/entities/report_identity.dart';
import 'package:drop/features/task/domain/entities/task_attachment.dart';

/// Contract for Reports Center data access. The branch/role access model is
/// enforced server-side by `firestore.rules` (admin: all reports · manager: own
/// branch, non-admin-routed · employee: their own reports); these methods are
/// the client surface the Reports UI builds on.
abstract class ReportRepository {
  /// All reports, newest-first — **admin only** (the rules reject a non-admin
  /// collection read).
  Stream<List<ReportEntity>> watchAllReports();

  /// Reports in a single branch that a manager may see — own-branch,
  /// non-admin-routed (`visibleToManager == true`). Realtime.
  Stream<List<ReportEntity>> watchBranchReports(String branchId);

  /// The caller's OWN reports (any privacy). Resolved via a collectionGroup
  /// query on the private `reporter` subdocs (the report doc carries no creator
  /// uid), then a per-report fetch. One-shot (the filer's list is small);
  /// refreshed on demand.
  Future<List<ReportEntity>> getMyReports(String uid);

  /// A single report by id, or null if it doesn't exist.
  Future<ReportEntity?> getReport(String reportId);

  /// Files a new report: writes the report doc AND its private
  /// `reporter/identity` subdoc atomically (one [WriteBatch]). Returns the
  /// report with its generated id.
  Future<ReportEntity> createReport(ReportEntity report, ReportIdentity identity);

  /// Updates a report (status transition / assign / comment). A single write
  /// that also carries the appended [ReportEntity.activityLog] — never split a
  /// status change and its timeline entry into two writes.
  Future<void> updateReport(ReportEntity report);

  /// Reads the private reporter identity — an **admin** revealing a confidential
  /// sender, or the owner reading their own. Returns null if missing.
  Future<ReportIdentity?> revealReporter(String reportId);

  /// Uploads one media file to `reports/{reportId}/attachments/{id}.<ext>`
  /// (unique id, never overwrites) and returns the resolved [TaskAttachment].
  Future<TaskAttachment> uploadAttachment({
    required String reportId,
    required File file,
    required AttachmentType type,
    required String uploadedBy,
    String? uploadedByName,
    int? durationMs,
    void Function(int transferred, int total)? onProgress,
  });

  /// Permanently deletes a report — **admin only** (reports are records).
  Future<void> deleteReport(String reportId);
}
