import 'dart:io';

import 'package:drop/core/enums/attachment_type.dart';
import 'package:drop/core/errors/exceptions.dart';
import 'package:drop/core/errors/failures.dart';
import 'package:drop/features/reports/data/datasources/report_remote_datasource.dart';
import 'package:drop/features/reports/data/models/report_model.dart';
import 'package:drop/features/reports/domain/entities/report_entity.dart';
import 'package:drop/features/reports/domain/entities/report_identity.dart';
import 'package:drop/features/reports/domain/report_urgency.dart';
import 'package:drop/features/reports/domain/repositories/report_repository.dart';
import 'package:drop/features/task/domain/entities/task_attachment.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _remote;

  ReportRepositoryImpl(this._remote);

  /// Maps models → entities and orders by urgency (SLA-breached / severity /
  /// recency) so every list surfaces the most pressing report first.
  List<ReportEntity> _ordered(List<ReportModel> models) =>
      sortReportsByUrgency(models.map((m) => m.toEntity()).toList());

  @override
  Stream<List<ReportEntity>> watchAllReports() =>
      _remote.watchAllReports().map(_ordered);

  @override
  Stream<List<ReportEntity>> watchBranchReports(String branchId) =>
      _remote.watchBranchReports(branchId).map(_ordered);

  @override
  Future<List<ReportEntity>> getMyReports(String uid) async {
    try {
      return _ordered(await _remote.getMyReports(uid));
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<ReportEntity?> getReport(String reportId) async {
    try {
      final model = await _remote.getReport(reportId);
      return model?.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<ReportEntity> createReport(
    ReportEntity report,
    ReportIdentity identity,
  ) async {
    try {
      final created =
          await _remote.createReport(ReportModel.fromEntity(report), identity);
      return created.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> updateReport(ReportEntity report) async {
    try {
      await _remote.updateReport(ReportModel.fromEntity(report));
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<ReportIdentity?> revealReporter(String reportId) async {
    try {
      return await _remote.revealReporter(reportId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<TaskAttachment> uploadAttachment({
    required String reportId,
    required File file,
    required AttachmentType type,
    required String uploadedBy,
    String? uploadedByName,
    int? durationMs,
    void Function(int transferred, int total)? onProgress,
  }) async {
    try {
      return await _remote.uploadAttachment(
        reportId: reportId,
        file: file,
        type: type,
        uploadedBy: uploadedBy,
        uploadedByName: uploadedByName,
        durationMs: durationMs,
        onProgress: onProgress,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> deleteReport(String reportId) async {
    try {
      await _remote.deleteReport(reportId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
