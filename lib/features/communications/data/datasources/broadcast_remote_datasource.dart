import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fbro/core/constants/app_constants.dart';
import 'package:fbro/core/errors/exceptions.dart';
import 'package:fbro/features/communications/data/models/broadcast_model.dart';

abstract class BroadcastRemoteDataSource {
  /// Sends a broadcast through the **callable `sendBroadcast` Cloud Function**
  /// (the authoritative engine: validates permissions, resolves recipients,
  /// persists the doc, pushes the notification). Returns the model carrying the
  /// generated id + the resolved recipient count.
  Future<BroadcastModel> sendBroadcast(BroadcastModel broadcast);

  /// [branchId] null → all broadcasts (admin). Set → that branch's broadcasts
  /// plus all-branches ones (the `''` sentinel). Direct messages never appear
  /// here (they use the [BroadcastModel.directBranchMarker]).
  Stream<List<BroadcastModel>> watchBroadcasts({String? branchId});
}

class BroadcastRemoteDataSourceImpl implements BroadcastRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  BroadcastRemoteDataSourceImpl(this._firestore, this._functions);

  CollectionReference<Map<String, dynamic>> get _broadcasts =>
      _firestore.collection(AppConstants.broadcastsCollection);

  @override
  Future<BroadcastModel> sendBroadcast(BroadcastModel broadcast) async {
    try {
      final callable = _functions.httpsCallable('sendBroadcast');
      final result = await callable.call<Map<String, dynamic>>(
        broadcast.toCallablePayload(),
      );
      final data = result.data;
      return broadcast.copyWith(
        id: data['broadcastId'] as String? ?? '',
        recipientCount: (data['recipientCount'] as num?)?.toInt(),
      );
    } on FirebaseFunctionsException catch (e) {
      // The function throws HttpsError('permission-denied' | 'invalid-argument'
      // | …) with a user-facing message; surface it verbatim.
      throw ServerException(e.message ?? 'Failed to send broadcast.');
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to send broadcast.');
    }
  }

  @override
  Stream<List<BroadcastModel>> watchBroadcasts({String? branchId}) {
    // Admin (no branch): server-side newest-first (single-field order, index-free).
    // Branch member: a `whereIn` on the single `branchId` field — their branch +
    // the all-branches `''` sentinel — which is provably safe under the read rule
    // and uses the automatic index. A filter + orderBy on a different field would
    // need a composite index (the project avoids those), so the branch feed is
    // ordered client-side via [_newestFirst]. Direct messages carry the
    // [BroadcastModel.directBranchMarker] branchId, so neither query returns them.
    final Query<Map<String, dynamic>> query = branchId == null
        ? _broadcasts.orderBy('createdAt', descending: true)
        : _broadcasts.where('branchId', whereIn: [branchId, '']);

    return query.snapshots().map((snap) {
      final models =
          snap.docs.map((d) => BroadcastModel.fromMap(d.data(), id: d.id));
      return branchId == null
          ? models.toList()
          : (models.toList()..sort(_newestFirst));
    });
  }

  /// Newest first; a doc with a pending server timestamp (`createdAt == null`)
  /// sorts to the top.
  int _newestFirst(BroadcastModel a, BroadcastModel b) {
    final ad = a.createdAt, bd = b.createdAt;
    if (ad == null && bd == null) return 0;
    if (ad == null) return -1;
    if (bd == null) return 1;
    return bd.compareTo(ad);
  }
}
