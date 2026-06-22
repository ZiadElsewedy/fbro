import 'package:fbro/features/communications/domain/entities/comms_analytics_entity.dart';

/// Read contract for the precomputed communications analytics (Phase 2 Commit 6).
/// Reads the monthly rollup doc maintained by Cloud Functions — no live scans.
abstract class CommsAnalyticsRepository {
  /// The analytics for [monthKey] (`YYYY-MM`); the **current** month when null.
  /// Returns [CommsAnalyticsEntity.empty] when no rollup exists yet.
  Future<CommsAnalyticsEntity> load({String? monthKey});
}
