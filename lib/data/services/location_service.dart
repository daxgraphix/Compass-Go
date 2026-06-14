import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      // Graceful degradation
      return null;
    }
  }

  /// Get cached location if available (for offline operation)
  Future<Position?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      return position;
    } catch (e) {
      return null;
    }
  }

  /// Check and request location permission
  Future<bool> requestLocationPermission() async {
    try {
      final status = await Geolocator.requestPermission();
      return status == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }
}
