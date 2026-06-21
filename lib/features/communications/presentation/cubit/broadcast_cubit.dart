import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fbro/core/enums/broadcast_audience.dart';
import 'package:fbro/core/errors/failures.dart';
import 'package:fbro/features/auth/domain/entities/user_entity.dart';
import 'package:fbro/features/communications/domain/entities/broadcast_entity.dart';
import 'package:fbro/features/communications/domain/repositories/broadcast_repository.dart';
import 'package:fbro/features/communications/domain/usecases/send_broadcast.dart';
import 'package:fbro/features/communications/presentation/cubit/broadcast_state.dart';

/// Drives the Communications Center (Phase 1). A **hybrid** cubit, matching
/// `TaskCubit`: the write (`send`) goes through the [SendBroadcast] use case,
/// while the live feed subscribes to [BroadcastRepository.watchBroadcasts]
/// directly (the documented stream-access convention).
///
/// The sent broadcast appears in the feed via the same stream — no manual
/// refetch. WHO may send what (admin = any branch / all-branches; manager = own
/// branch only) is enforced server-side in `firestore.rules`.
class BroadcastCubit extends Cubit<BroadcastState> {
  final BroadcastRepository _repository;
  final SendBroadcast _sendBroadcast;

  BroadcastCubit({
    required this._repository,
    required this._sendBroadcast,
  }) : super(const BroadcastState.initial());

  StreamSubscription<List<BroadcastEntity>>? _sub;
  bool _hasSnapshot = false;

  List<BroadcastEntity> get _broadcasts =>
      state.maybeWhen(loaded: (b, _) => b, orElse: () => const []);

  bool get _sending =>
      state.maybeWhen(loaded: (_, sending) => sending, orElse: () => false);

  /// Subscribes to the live broadcast feed.
  ///
  /// - [branchId] `null` → admin feed (all branches).
  /// - [branchId] set → branch member feed (their branch + all-branches).
  Future<void> load({String? branchId}) async {
    _hasSnapshot = false;
    emit(const BroadcastState.loading());
    await _sub?.cancel();
    _sub = _repository.watchBroadcasts(branchId: branchId).listen(
      (broadcasts) {
        _hasSnapshot = true;
        emit(BroadcastState.loaded(broadcasts, sending: _sending));
      },
      onError: (Object e, StackTrace st) {
        developer.log('Broadcast: feed stream error',
            name: 'communications', error: e, stackTrace: st);
        // Only surface if no first snapshot arrived; otherwise keep the last
        // good feed visible (mirrors TaskCubit / BranchOperationsCubit).
        if (!_hasSnapshot) emit(BroadcastState.error(_message(e)));
      },
    );
  }

  /// Sends a broadcast from [sender]. Pass a non-empty [branchId] to scope it to
  /// that branch; omit it (or pass null/empty) for an all-branches broadcast
  /// (admin-only — the rules reject a manager's all-branches send).
  ///
  /// Returns `true` on success. The new broadcast surfaces through the feed
  /// stream, so no manual refetch is needed.
  Future<bool> send({
    required UserEntity sender,
    required String title,
    required String message,
    String? branchId,
  }) async {
    if (_sending) return false;

    final trimmedTitle = title.trim();
    final trimmedMessage = message.trim();
    if (trimmedTitle.isEmpty || trimmedMessage.isEmpty) {
      _emitError('A broadcast needs a title and a message.');
      return false;
    }

    final scoped = (branchId ?? '').trim();
    final broadcast = BroadcastEntity(
      id: '',
      title: trimmedTitle,
      message: trimmedMessage,
      senderId: sender.uid,
      senderName: _senderName(sender),
      senderRole: sender.role,
      audience: scoped.isEmpty
          ? BroadcastAudience.allBranches
          : BroadcastAudience.branch,
      branchId: scoped.isEmpty ? null : scoped,
    );

    final prev = _broadcasts;
    emit(BroadcastState.loaded(prev, sending: true));
    try {
      await _sendBroadcast(broadcast);
      // Keep the feed visible; the stream emits the new broadcast.
      emit(BroadcastState.loaded(_broadcasts));
      return true;
    } on Failure catch (e) {
      _emitError(e.message);
      return false;
    } catch (_) {
      _emitError('Could not send the broadcast. Please try again.');
      return false;
    }
  }

  /// Surface an error without losing the current feed (when one is loaded).
  void _emitError(String message) {
    final prev = _broadcasts;
    emit(BroadcastState.error(message));
    if (_hasSnapshot) emit(BroadcastState.loaded(prev));
  }

  String _senderName(UserEntity user) {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = user.email.trim();
    return email.isNotEmpty ? email : 'DROP';
  }

  String _message(Object e) =>
      e is Failure ? e.message : 'Could not load broadcasts. Please try again.';

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
