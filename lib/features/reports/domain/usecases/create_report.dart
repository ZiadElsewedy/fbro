import 'package:drop/features/reports/domain/entities/report_entity.dart';
import 'package:drop/features/reports/domain/entities/report_identity.dart';
import 'package:drop/features/reports/domain/repositories/report_repository.dart';

/// Files a new report — persists the report doc and its private
/// `reporter/identity` subdoc atomically. Returns it with its generated id.
class CreateReport {
  final ReportRepository _repository;
  const CreateReport(this._repository);

  Future<ReportEntity> call(ReportEntity report, ReportIdentity identity) =>
      _repository.createReport(report, identity);
}
