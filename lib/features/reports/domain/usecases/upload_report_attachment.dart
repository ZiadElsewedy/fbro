import 'dart:io';
import 'package:drop/core/enums/attachment_type.dart';
import 'package:drop/features/reports/domain/repositories/report_repository.dart';
import 'package:drop/features/task/domain/entities/task_attachment.dart';

/// Uploads one media file (image / video) for a report and returns the resolved
/// [TaskAttachment] (id, download url, type, uploader, time).
class UploadReportAttachment {
  final ReportRepository _repository;
  const UploadReportAttachment(this._repository);

  Future<TaskAttachment> call({
    required String reportId,
    required File file,
    required AttachmentType type,
    required String uploadedBy,
    String? uploadedByName,
    int? durationMs,
    void Function(int transferred, int total)? onProgress,
  }) =>
      _repository.uploadAttachment(
        reportId: reportId,
        file: file,
        type: type,
        uploadedBy: uploadedBy,
        uploadedByName: uploadedByName,
        durationMs: durationMs,
        onProgress: onProgress,
      );
}
