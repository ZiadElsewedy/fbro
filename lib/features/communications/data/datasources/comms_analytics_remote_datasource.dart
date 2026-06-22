import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbro/core/constants/app_constants.dart';
import 'package:fbro/core/errors/exceptions.dart';
import 'package:fbro/features/communications/domain/entities/comms_analytics_entity.dart';

abstract class CommsAnalyticsRemoteDataSource {
  Future<CommsAnalyticsEntity> getMonth(String monthKey);
}

class CommsAnalyticsRemoteDataSourceImpl
    implements CommsAnalyticsRemoteDataSource {
  final FirebaseFirestore _firestore;

  CommsAnalyticsRemoteDataSourceImpl(this._firestore);

  @override
  Future<CommsAnalyticsEntity> getMonth(String monthKey) async {
    try {
      final snap = await _firestore
          .collection(AppConstants.analyticsCollection)
          .doc(monthKey)
          .get();
      if (!snap.exists) return CommsAnalyticsEntity.empty;
      return CommsAnalyticsEntity.fromMap(snap.data() ?? const {});
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load analytics.');
    }
  }
}
