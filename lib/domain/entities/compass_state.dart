class CompassState {
  final double heading;
  final bool isTrueNorth;
  final double altitudeMeters;
  final double accuracy;
  final String status;
  final double? latitude;
  final double? longitude;
  final double? pressure;
  final DateTime? timestamp;

  const CompassState({
    required this.heading,
    required this.isTrueNorth,
    required this.altitudeMeters,
    required this.accuracy,
    required this.status,
    this.latitude,
    this.longitude,
    this.pressure,
    this.timestamp,
  });

  CompassState copyWith({
    double? heading,
    bool? isTrueNorth,
    double? altitudeMeters,
    double? accuracy,
    String? status,
    double? latitude,
    double? longitude,
    double? pressure,
    DateTime? timestamp,
  }) {
    return CompassState(
      heading: heading ?? this.heading,
      isTrueNorth: isTrueNorth ?? this.isTrueNorth,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
      accuracy: accuracy ?? this.accuracy,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pressure: pressure ?? this.pressure,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
