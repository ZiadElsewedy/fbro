import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:drop/features/requests/domain/entities/request_entity.dart';

part 'requests_list_state.freezed.dart';

@freezed
class RequestsListState with _$RequestsListState {
  const factory RequestsListState.initial() = _Initial;

  /// First load (full-screen skeleton).
  const factory RequestsListState.loading() = _Loading;

  /// Requests loaded (already inbox-ordered by the repository). [busy] marks an
  /// in-flight mutation (submit / delete) while the list stays visible.
  /// [branchNames] resolves branchId → name for the cards (fills in async).
  /// [selectedId] is the request open in the desktop split-pane's right side.
  const factory RequestsListState.loaded(
    List<RequestEntity> requests, {
    @Default(false) bool busy,
    @Default(<String, String>{}) Map<String, String> branchNames,
    String? selectedId,
  }) = _Loaded;

  /// Transient — surfaced as a snackbar; the cubit immediately re-emits the
  /// last-known [loaded] list so the UI never loses its data.
  const factory RequestsListState.error(String message) = _Error;
}
