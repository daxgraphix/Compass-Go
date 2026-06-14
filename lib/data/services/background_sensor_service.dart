import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundSensorService {
  static const String _prefKey = 'last_altitude';
  static const String _prefPressure = 'last_pressure';

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);
  }

  static Future<double> getAltitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_prefKey) ?? 0.0;
  }

  static Future<void> saveAltitude(double altitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefKey, altitude);
  }

  static Future<double> getPressure() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_prefPressure) ?? 1013.25;
  }

  static Future<void> savePressure(double pressure) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefPressure, pressure);
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'sensor_channel',
      'Sensor Updates',
      importance: Importance.low,
      priority: Priority.low,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _notifications.show(0, title, body, details);
  }
}

@pragma('vm:entry-point')
void backgroundSensorEntryPoints() {
  BackgroundSensorService.initialize();
}