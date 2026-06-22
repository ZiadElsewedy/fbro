import 'package:fbro/core/errors/exceptions.dart';
import 'package:fbro/core/errors/failures.dart';
import 'package:fbro/features/communications/data/datasources/comms_analytics_remote_datasource.dart';
import 'package:fbro/features/communications/domain/entities/comms_analytics_entity.dart';
import 'package:fbro/features/communications/domain/repositories/comms_analytics_repository.dart';

class CommsAnalyticsRepositoryImpl implements CommsAnalyticsRepository {
  final CommsAnalyticsRemoteDataSource _remote;

  CommsAnalyticsRepositoryImpl(this._remote);

  @override
  Future<CommsAnalyticsEntity> load({String? monthKey}) async {
    try {
      return await _remote.getMonth(monthKey ?? _currentMonthKey());
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  String _currentMonthKey() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }
}
