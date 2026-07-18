/// A captured clock-in location — an **extension point**, not a live feature.
/// It is carried on the record only when the branch's [AttendanceConfig]
/// `locationPolicy` opts in (default off), and the geofence check lives in the
/// validation engine. Pure value object; serialized by `AttendanceModel`.
class AttendanceLocation {
  final double latitude;
  final double longitude;

  /// Reported accuracy radius in metres, when the platform provides it.
  final double? accuracyMeters;
  final DateTime? capturedAt;

  const AttendanceLocation({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    this.capturedAt,
  });

  @override
  bool operator ==(Object other) =>
      other is AttendanceLocation &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.accuracyMeters == accuracyMeters &&
      other.capturedAt == capturedAt;

  @override
  int get hashCode =>
      Object.hash(latitude, longitude, accuracyMeters, capturedAt);

  @override
  String toString() => 'AttendanceLocation($latitude, $longitude)';
}
