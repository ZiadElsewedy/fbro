import 'package:drop/features/reports/domain/entities/report_entity.dart';
import 'package:drop/features/reports/domain/repositories/report_repository.dart';

/// Updates a report — status transitions, assignment, and comments all flow
/// through here as a single write that carries the appended activity timeline
/// (never split a status change and its timeline entry into two writes).
class UpdateReport {
  final ReportRepository _repository;
  const UpdateReport(this._repository);

  Future<void> call(ReportEntity report) => _repository.updateReport(report);
}
