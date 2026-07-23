import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drop/core/errors/failures.dart';
import 'package:drop/core/utils/app_logger.dart';
import 'package:drop/features/auth/domain/usecases/get_users_by_branch.dart';
import 'new_chat_state.dart';

/// Loads the teammate directory for the new-conversation picker. Read-only:
/// starting the conversation is [ChatListCubit.startChatWith] (the inbox owns
/// that, so the new thread lands in the list). Built per-open via
/// [AppDependencies.createNewChatCubit].
///
/// Scope: the caller's own branch (via [GetUsersByBranch]), which is the
/// natural "teammates" set and what Firestore rules permit. The current user
/// is excluded so you can never start a conversation with yourself (the server
/// also rejects that).
class NewChatCubit extends Cubit<NewChatState> {
  final GetUsersByBranch _getUsersByBranch;
  final String? _branchId;
  final String _currentUid;

  NewChatCubit({
    required this._getUsersByBranch,
    required this._branchId,
    required this._currentUid,
  })  : super(const NewChatLoading()) {
    load();
  }

  Future<void> load() async {
    if (!isClosed) emit(const NewChatLoading());
    final branchId = _branchId;
    if (branchId == null || branchId.isEmpty) {
      // No branch → no teammate directory to scope to. Show the empty state
      // rather than an error; it's a legitimate "nobody to chat with" case.
      if (!isClosed) emit(const NewChatLoaded([]));
      return;
    }
    try {
      final users = await _getUsersByBranch(branchId);
      final teammates =
          users.where((u) => u.uid != _currentUid).toList(growable: false);
      if (!isClosed) emit(NewChatLoaded(teammates));
    } on Failure catch (e) {
      if (!isClosed) emit(NewChatError(e.message));
    } catch (e) {
      AppLog.warning('chat', 'teammate directory load failed: $e');
      if (!isClosed) {
        emit(const NewChatError('Failed to load teammates. Please try again.'));
      }
    }
  }
}
