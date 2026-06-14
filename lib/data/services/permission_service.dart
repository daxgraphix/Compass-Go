import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request sensor permissions (motion/accelerometer/magnetometer)
  static Future<bool> requestSensorPermissions() async {
    try {
      final status = await Permission.sensors.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      return status == PermissionStatus.granted || status == PermissionStatus.limited;
    } catch (e) {
      return false;
    }
  }

  /// Check if all required permissions are granted
  static Future<bool> areAllPermissionsGranted() async {
    try {
      final sensorStatus = await Permission.sensors.status;
      return sensorStatus == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  /// Check sensor permission status
  static Future<PermissionStatus> getSensorPermissionStatus() async {
    try {
      return await Permission.sensors.status;
    } catch (e) {
      return PermissionStatus.denied;
    }
  }

  /// Check location permission status
  static Future<PermissionStatus> getLocationPermissionStatus() async {
    try {
      return await Permission.location.status;
    } catch (e) {
      return PermissionStatus.denied;
    }
  }

  /// Request all necessary permissions
  static Future<Map<String, bool>> requestAllPermissions() async {
    try {
      final sensorGranted = await requestSensorPermissions();
      final locationGranted = await requestLocationPermission();

      return {
        'sensors': sensorGranted,
        'location': locationGranted,
      };
    } catch (e) {
      return {'sensors': false, 'location': false};
    }
  }

  /// Open app settings for permission management
  static Future<bool> openAppSettingsCompat() async {
    try {
      return await openAppSettings();
    } catch (e) {
      return false;
    }
  }
}
