/// A branch's attendance **geofence** — the location a GPS clock-in/out is
/// verified against. Pure value object, serialized inline on
/// `branches/{id}.geofence` (mirrors `SwapPolicy`). A null geofence on a branch
/// means attendance GPS isn't configured there yet, so a location-verified
/// clock-in can't happen until an admin sets it.
class BranchGeofence {
  final double latitude;
  final double longitude;

  /// Allowed distance from ([latitude], [longitude]) in **metres** within which
  /// a clock-in counts as "at the branch".
  final double radiusMeters;

  /// The worst GPS accuracy (reported radius, metres) still trusted — a reading
  /// less precise than this is rejected, because the distance can't be believed.
  final double minAccuracyMeters;

  const BranchGeofence({
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 150,
    this.minAccuracyMeters = 50,
  });

  /// Standing defaults for a freshly-configured branch (150 m radius, 50 m
  /// accuracy floor) centred on ([lat], [lng]).
  factory BranchGeofence.at(double lat, double lng) =>
      BranchGeofence(latitude: lat, longitude: lng);

  factory BranchGeofence.fromMap(Map<String, dynamic> map) => BranchGeofence(
        latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
        radiusMeters: (map['radiusMeters'] as num?)?.toDouble() ?? 150,
        minAccuracyMeters: (map['minAccuracyMeters'] as num?)?.toDouble() ?? 50,
      );

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'radiusMeters': radiusMeters,
        'minAccuracyMeters': minAccuracyMeters,
      };

  /// Validates raw editor input (already parsed to numbers), returning a
  /// user-facing error message, or null when the values are a valid geofence.
  /// Pure — the admin editor + a unit test both use it.
  static String? validateInput({
    required double? latitude,
    required double? longitude,
    required double? radiusMeters,
    required double? minAccuracyMeters,
  }) {
    if (latitude == null || longitude == null) {
      return 'Set the branch location first.';
    }
    if (latitude < -90 || latitude > 90) {
      return 'Latitude must be between -90 and 90.';
    }
    if (longitude < -180 || longitude > 180) {
      return 'Longitude must be between -180 and 180.';
    }
    if (radiusMeters == null || radiusMeters <= 0) {
      return 'Allowed radius must be greater than 0 m.';
    }
    if (minAccuracyMeters == null || minAccuracyMeters <= 0) {
      return 'Minimum accuracy must be greater than 0 m.';
    }
    return null;
  }

  BranchGeofence copyWith({
    double? latitude,
    double? longitude,
    double? radiusMeters,
    double? minAccuracyMeters,
  }) =>
      BranchGeofence(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        radiusMeters: radiusMeters ?? this.radiusMeters,
        minAccuracyMeters: minAccuracyMeters ?? this.minAccuracyMeters,
      );

  @override
  bool operator ==(Object other) =>
      other is BranchGeofence &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.radiusMeters == radiusMeters &&
      other.minAccuracyMeters == minAccuracyMeters;

  @override
  int get hashCode =>
      Object.hash(latitude, longitude, radiusMeters, minAccuracyMeters);

  @override
  String toString() =>
      'BranchGeofence($latitude, $longitude, r=${radiusMeters}m, acc=${minAccuracyMeters}m)';
}
