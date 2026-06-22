import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fbro/core/errors/failures.dart';
import 'package:fbro/features/auth/domain/entities/user_entity.dart';
import 'package:fbro/features/statistics/domain/repositories/statistics_repository.dart';
import 'statistics_state.dart';

/// Loads the role-scoped operational statistics for the dashboards (Phase 6).
/// Admin = global · manager = own branch · employee = own data.
///
/// [load] is **idempotent within a short TTL**: a dashboard's `initState` (which
/// re-fires whenever the home tab is re-entered) becomes a no-op when the same
/// scope was loaded under [_ttl] ago — without this, every Home visit re-ran a
/// full multi-collection aggregation (`users` + `tasks` + `branches` +
/// `schedules`). Pull-to-refresh passes `force: true` to bypass the guard.
class StatisticsCubit extends Cubit<StatisticsState> {
  final StatisticsRepository _repository;

  StatisticsCubit(this._repository) : super(const StatisticsState.initial());

  /// Statistics are snapshot aggregations — short-lived freshness window.
  static const Duration _ttl = Duration(seconds: 60);

  String? _scopeKey;
  DateTime? _loadedAt;

  Future<void> load(UserEntity user, {bool force = false}) async {
    final scopeKey = user.role.isAdmin
        ? 'admin'
        : user.role.isManager
            ? 'manager:${user.branchId}'
            : 'employee:${user.uid}';

    final isLoaded = state.maybeWhen(loaded: (_) => true, orElse: () => false);
    if (!force &&
        isLoaded &&
        _scopeKey == scopeKey &&
        _loadedAt != null &&
        DateTime.now().difference(_loadedAt!) < _ttl) {
      return;
    }

    emit(const StatisticsState.loading());
    try {
      final stats = user.role.isAdmin
          ? await _repository.adminStats()
          : user.role.isManager
              ? await _repository.managerStats(user.branchId ?? '')
              : await _repository.employeeStats(user.uid, user.branchId);
      emit(StatisticsState.loaded(stats));
      _scopeKey = scopeKey;
      _loadedAt = DateTime.now();
    } on Failure catch (e) {
      emit(StatisticsState.error(e.message));
    } catch (_) {
      emit(const StatisticsState.error('Failed to load statistics.'));
    }
  }
}
