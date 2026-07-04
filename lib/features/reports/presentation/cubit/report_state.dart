import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:drop/features/auth/domain/entities/user_entity.dart';
import 'package:drop/features/reports/domain/entities/report_entity.dart';

part 'report_state.freezed.dart';

@freezed
class ReportState with _$ReportState {
  const factory ReportState.initial() = _Initial;

  /// First load (full-screen spinner).
  const factory ReportState.loading() = _Loading;

  /// Reports loaded. [busy] marks an in-flight mutation (submit / transition /
  /// comment) while the list stays visible. [directory] resolves assignee /
  /// resolver uids → users so the detail panel can show real names; it fills in
  /// asynchronously after the reports arrive.
  const factory ReportState.loaded(
    List<ReportEntity> reports, {
    @Default(false) bool busy,
    @Default(<String, UserEntity>{}) Map<String, UserEntity> directory,
  }) = _Loaded;

  /// Transient — surfaced as a snackbar; the cubit immediately re-emits the
  /// last-known [loaded] list so the UI never loses its data.
  const factory ReportState.error(String message) = _Error;
}
