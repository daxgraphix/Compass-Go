import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static const _screenPrefix = 'analytics_screen_visit_';
  static const _eventPrefix = 'analytics_event_';
  static const _sessionPrefix = 'analytics_session_';
  static const _timestampKey = 'analytics_last_timestamp';

  final SharedPreferences _prefs;
  final List<Map<String, dynamic>> _eventBuffer = [];
  static const int _maxBufferSize = 50;

  AnalyticsService(this._prefs);

  Future<void> logScreenVisit(String screenName) async {
    final key = '$_screenPrefix$screenName';
    final count = _prefs.getInt(key) ?? 0;
    await _prefs.setInt(key, count + 1);
    await _logToBuffer('screen_visit', {'screen': screenName});
  }

  Future<void> logEvent(String eventName, {Map<String, dynamic>? payload}) async {
    final key = '$_eventPrefix$eventName';
    final count = _prefs.getInt(key) ?? 0;
    await _prefs.setInt(key, count + 1);
    if (payload != null && payload.isNotEmpty) {
      await _prefs.setString('${key}_last_payload', jsonEncode(payload));
    }
    await _logToBuffer(eventName, payload);
  }

  Future<void> _logToBuffer(String eventName, Map<String, dynamic>? payload) async {
    _eventBuffer.add({
      'event': eventName,
      'payload': payload ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (_eventBuffer.length > _maxBufferSize) {
      _eventBuffer.removeAt(0);
    }
  }

  int getScreenVisits(String screenName) {
    return _prefs.getInt('$_screenPrefix$screenName') ?? 0;
  }

  int getEventCount(String eventName) {
    return _prefs.getInt('$_eventPrefix$eventName') ?? 0;
  }

  Map<String, int> getAllScreenVisits() {
    return _prefs.getKeys().where((key) => key.startsWith(_screenPrefix)).fold(<String, int>{},
        (values, key) {
      final screen = key.replaceFirst(_screenPrefix, '');
      values[screen] = _prefs.getInt(key) ?? 0;
      return values;
    });
  }

  Map<String, int> getAllEvents() {
    return _prefs.getKeys().where((key) => key.startsWith(_eventPrefix) && !key.contains('last_payload')).fold(<String, int>{},
        (values, key) {
      final event = key.replaceFirst(_eventPrefix, '');
      final count = _prefs.getInt(key) ?? 0;
      values[event] = count;
      return values;
    });
  }

  Future<void> startSession() async {
    final now = DateTime.now().toIso8601String();
    final sessionKey = '$_sessionPrefix$now';
    await _prefs.setString(sessionKey, now);
    await _prefs.setString(_timestampKey, now);
  }

  Future<void> endSession() async {
    final lastTimestamp = _prefs.getString(_timestampKey) ?? '';
    if (lastTimestamp.isNotEmpty) {
      final sessionKey = '$_sessionPrefix$lastTimestamp';
      await _prefs.remove(sessionKey);
    }
  }

  Future<void> logSensorReading({
    required double heading,
    required double accuracy,
    required double altitude,
    required bool lowPowerMode,
  }) async {
    await logEvent('sensor_reading', payload: {
      'heading': heading,
      'accuracy': accuracy,
      'altitude': altitude,
      'low_power_mode': lowPowerMode,
    });
  }

  Future<void> logCalibrationComplete(double durationSeconds) async {
    await logEvent('calibration_complete', payload: {
      'duration_seconds': durationSeconds,
    });
  }

  Future<void> logHapticFeedback(String trigger) async {
    await logEvent('haptic_triggered', payload: {
      'trigger': trigger,
    });
  }

  Future<void> logError(String error, {String? context}) async {
    await logEvent('error_occurred', payload: {
      'error': error,
      'context': context ?? 'unknown',
    });
  }

  Future<void> logUserAction(String action, {Map<String, dynamic>? metadata}) async {
    await logEvent('user_action_$action', payload: metadata);
  }

  List<Map<String, dynamic>> getEventBuffer() => List.unmodifiable(_eventBuffer);

  Map<String, dynamic> getSummary() {
    final screenVisits = getAllScreenVisits();
    final events = getAllEvents();
    final totalScreenVisits = screenVisits.values.fold(0, (sum, count) => sum + count);
    final totalEvents = events.values.fold(0, (sum, count) => sum + count);

    final accuracySum = _prefs.getDouble('analytics_accuracy_sum') ?? 0;
    final accuracyCount = _prefs.getInt('analytics_accuracy_count') ?? 0;
    final avgAccuracy = accuracyCount > 0 ? accuracySum / accuracyCount : 0.0;

    return {
      'total_screen_visits': totalScreenVisits,
      'total_events': totalEvents,
      'screens': screenVisits,
      'events': events,
      'average_accuracy': avgAccuracy.toStringAsFixed(1),
      'session_count': _prefs.getKeys().where((k) => k.startsWith(_sessionPrefix)).length,
    };
  }

  Future<void> trackAccuracy(double accuracy) async {
    final count = _prefs.getInt('analytics_accuracy_count') ?? 0;
    final sum = _prefs.getDouble('analytics_accuracy_sum') ?? 0;
    await _prefs.setInt('analytics_accuracy_count', count + 1);
    await _prefs.setDouble('analytics_accuracy_sum', sum + accuracy);
  }

  Future<void> clearAllData() async {
    final screenKeys = _prefs.getKeys().where((key) => key.startsWith(_screenPrefix));
    final eventKeys = _prefs.getKeys().where((key) => key.startsWith(_eventPrefix));
    final sessionKeys = _prefs.getKeys().where((key) => key.startsWith(_sessionPrefix));

    for (final key in [...screenKeys, ...eventKeys, ...sessionKeys]) {
      await _prefs.remove(key);
    }
    _eventBuffer.clear();
  }

  Future<void> exportData() async {
    // Placeholder for export functionality
  }
}