import '../entities/compass_state.dart';

class GetCompassReading {
  const GetCompassReading();

  CompassState execute({required double heading, required bool trueNorth, required double altitude, required double accuracy, String status = 'Ready'}) {
    return CompassState(
      heading: heading,
      isTrueNorth: trueNorth,
      altitudeMeters: altitude,
      accuracy: accuracy,
      status: status,
    );
  }
}
