import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:drop/core/constants/app_constants.dart';
import 'package:drop/core/errors/exceptions.dart';
import 'package:drop/features/notifications/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  /// Creates notifications via the validated `sendNotification` callable
  /// (M2 fix, 2026-07-03) — direct `notifications/{id}` writes are denied by
  /// rules, so type whitelist / branch-scoped recipients / length caps /
  /// server-stamped senderUid are enforced for every client-produced doc.
  Future<void> create(NotificationModel notification);
  Future<void> createMany(List<NotificationModel> notifications);

  /// Realtime feed of the most recent [limit] notifications for [uid], newest
  /// first (server-ordered — uses the `recipientUid + createdAt` composite
  /// index). A growing [limit] gives offline-resilient infinite pagination.
  Stream<List<NotificationModel>> watch(String uid, {int limit = 30});
  Future<void> markRead(String id);
  Future<void> markAllRead(String uid);

  /// Permanently deletes one notification (the recipient dismissing it).
  Future<void> delete(String id);

  /// Archives / unarchives one notification (sets / clears `archivedAt`).
  Future<void> setArchived(String id, bool archived);

  /// Pins / unpins one notification (sets / clears `pinnedAt`).
  Future<void> setPinned(String id, bool pinned);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  NotificationRemoteDataSourceImpl(this._firestore, this._functions);

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection(AppConstants.notificationsCollection);

  @override
  Future<void> create(NotificationModel notification) =>
      createMany([notification]);

  @override
  Future<void> createMany(List<NotificationModel> notifications) async {
    if (notifications.isEmpty) return;
    try {
      // The callable validates + writes with the Admin SDK; `senderUid` is
      // server-stamped from the caller's auth, so it is not sent here.
      final callable = _functions.httpsCallable('sendNotification');
      await callable.call<Map<String, dynamic>>({
        'notifications': [
          for (final n in notifications)
            {
              'recipientUid': n.recipientUid,
              'type': n.type.value,
              'title': n.title,
              'body': n.body,
              'payload': n.payload,
            },
        ],
      });
    } on FirebaseFunctionsException catch (e) {
      throw ServerException(e.message ?? 'Failed to send notifications.');
    }
  }

  @override
  Stream<List<NotificationModel>> watch(String uid, {int limit = 30}) {
    // recipientUid equality + createdAt order → the `recipientUid + createdAt`
    // composite index (firestore.indexes.json). A growing [limit] window keeps
    // reads bounded while supporting infinite pagination + realtime updates.
    return _notifications
        .where('recipientUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => NotificationModel.fromMap(d.data(), id: d.id)).toList());
  }

  @override
  Future<void> markRead(String id) async {
    try {
      await _notifications
          .doc(id)
          .set({'readAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update notification.');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _notifications.doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete notification.');
    }
  }

  @override
  Future<void> setArchived(String id, bool archived) async {
    try {
      await _notifications.doc(id).set(
        {'archivedAt': archived ? FieldValue.serverTimestamp() : null},
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update notification.');
    }
  }

  @override
  Future<void> setPinned(String id, bool pinned) async {
    try {
      await _notifications.doc(id).set(
        {'pinnedAt': pinned ? FieldValue.serverTimestamp() : null},
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update notification.');
    }
  }

  @override
  Future<void> markAllRead(String uid) async {
    try {
      // Single-field query (no composite index); filter unread client-side.
      final snap =
          await _notifications.where('recipientUid', isEqualTo: uid).get();
      final unread =
          snap.docs.where((d) => d.data()['readAt'] == null).toList();
      if (unread.isEmpty) return;
      final batch = _firestore.batch();
      for (final d in unread) {
        batch.set(d.reference, {'readAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true));
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update notifications.');
    }
  }
}
