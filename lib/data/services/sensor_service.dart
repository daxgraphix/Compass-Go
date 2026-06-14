import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'location_service.dart';

class SensorService with ChangeNotifier {
  double _lastHeading = 0;
  double _lastAccuracy = 2.0;
  double _lastAltitude = 0;
  double _seaLevelPressure = 1013.25;
  double? _latitude;
  double? _longitude;
  DateTime? _lastUpdate;

  static const double _headingFilterAlpha = 0.15;
  static const int _bufferSize = 15;

  final List<double> _accelX = [];
  final List<double> _accelY = [];
  final List<double> _accelZ = [];
  final List<double> _pressureHistory = [];
  final List<double> _headingHistory = [];

StreamSubscription<MagnetometerEvent>? _magSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<BarometerEvent>? _baroSub;

  bool _isInitialized = false;
  String _errorMessage = '';

  bool get isInitialized => _isInitialized;
  String get errorMessage => _errorMessage;

  SensorService() {
    _initializeSensors();
  }

  void _initializeSensors() {
    try {
      _magSub = magnetometerEventStream().listen(
        (MagnetometerEvent event) {
          final heading = _calculateHeading(event);
          if (heading != null) {
            _headingHistory.add(heading);
            if (_headingHistory.length > _bufferSize) {
              _headingHistory.removeAt(0);
            }
            _lastHeading = _applyLowPassFilter(_lastHeading, heading, _headingFilterAlpha);
            _updateAccuracy();
            _notifyIfChanged();
          }
        },
        onError: (error) {
          _errorMessage = 'Magnetometer error: $error';
          debugPrint(_errorMessage);
        },
      );

      _accelSub = accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval)
          .listen(
        (AccelerometerEvent event) {
          _accelX.add(event.x);
          _accelY.add(event.y);
          _accelZ.add(event.z);

          if (_accelX.length > _bufferSize) {
            _accelX.removeAt(0);
            _accelY.removeAt(0);
            _accelZ.removeAt(0);
          }
        },
        onError: (error) {
          _errorMessage = 'Accelerometer error: $error';
          debugPrint(_errorMessage);
        },
      );

      _baroSub = barometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
        (BarometerEvent event) {
          _pressureHistory.add(event.pressure);
          if (_pressureHistory.length > _bufferSize) {
            _pressureHistory.removeAt(0);
          }
          _lastAltitude = _calculateAltitude(event.pressure);
          _notifyIfChanged();
        },
        onError: (error) {
          _errorMessage = 'Barometer error: $error';
          debugPrint(_errorMessage);
        },
      );

      _initializeLocation();
      _isInitialized = true;
      _notifyIfChanged();
    } catch (e) {
      _errorMessage = 'Sensor initialization failed: $e';
      debugPrint(_errorMessage);
    }
  }

  Future<void> _initializeLocation() async {
    try {
      final locationService = LocationService();
      final position = await locationService.getLastKnownLocation();
      if (position != null) {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _notifyIfChanged();
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  void _notifyIfChanged() {
    final now = DateTime.now();
    if (_lastUpdate == null || now.difference(_lastUpdate!).inMilliseconds >= 150) {
      _lastUpdate = now;
      notifyListeners();
    }
  }

  double? _calculateHeading(MagnetometerEvent mag) {
    if (_accelX.isEmpty) return null;

    final x = mag.x;
    final y = mag.y;

    final (rollAngle, pitchAngle) = _calculateTiltAngles();
    final (compX, compY) = _applyTiltCompensation(x, y, rollAngle, pitchAngle);

    var heading = atan2(compY, compX) * 180 / pi;
    if (heading < 0) {
      heading += 360;
    }

    if (heading >= 0 && heading <= 360) {
      return heading;
    }
    return null;
  }

  (double roll, double pitch) _calculateTiltAngles() {
    if (_accelX.isEmpty) return (0.0, 0.0);

    final avgX = _accelX.reduce((a, b) => a + b) / _accelX.length;
    final avgY = _accelY.reduce((a, b) => a + b) / _accelY.length;
    final avgZ = _accelZ.reduce((a, b) => a + b) / _accelZ.length;

    final pitch = atan2(avgX, sqrt(avgY * avgY + avgZ * avgZ)) * 180 / pi;
    final roll = atan2(avgY, sqrt(avgX * avgX + avgZ * avgZ)) * 180 / pi;

    return (roll, pitch);
  }

  (double x, double y) _applyTiltCompensation(double x, double y, double roll, double pitch) {
    final rollRad = roll * pi / 180;
    final pitchRad = pitch * pi / 180;

    final cosPitch = cos(pitchRad);
    final sinRoll = sin(rollRad);
    final sinPitch = sin(pitchRad);

    final compX = x * cosPitch + y * sinRoll * sinPitch;
    final compY = y * cos(rollRad);

    return (compX, compY);
  }

  double _applyLowPassFilter(double lastValue, double newValue, double alpha) {
    return lastValue + alpha * (newValue - lastValue);
  }

  void _updateAccuracy() {
    final (roll, pitch) = _calculateTiltAngles();
    final tiltMagnitude = sqrt(roll * roll + pitch * pitch);

    _lastAccuracy = 0.5 + (tiltMagnitude / 90) * 2.0;
    _lastAccuracy = (_lastAccuracy * 10).round() / 10;
  }

  double _calculateAltitude(double pressure) {
    if (_pressureHistory.isEmpty) return 0;
    final avgPressure = _pressureHistory.reduce((a, b) => a + b) / _pressureHistory.length;
    final altitude = 44330 * (1 - pow((avgPressure / _seaLevelPressure), 0.145).toDouble());
    return altitude.clamp(0.0, 10000.0);
  }

  void setSeaLevelPressure(double pressure) {
    _seaLevelPressure = pressure.clamp(800.0, 1200.0);
    notifyListeners();
  }

  double get seaLevelPressure => _seaLevelPressure;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  double getHeading() => _lastHeading;
  double getAccuracy() => _lastAccuracy;
  double getAltitudeMeters() => _lastAltitude;
  double getPressure() => _pressureHistory.isNotEmpty ? _pressureHistory.last : _seaLevelPressure;

  Map<String, dynamic> getAllSensorData() => {
        'heading': _lastHeading,
        'accuracy': _lastAccuracy,
        'altitude': _lastAltitude,
        'pressure': _pressureHistory.isNotEmpty ? _pressureHistory.last : _seaLevelPressure,
        'latitude': _latitude,
        'longitude': _longitude,
        'timestamp': DateTime.now().toIso8601String(),
      };

  Future<void> calibrateAltitude(double knownAltitude) async {
    final currentPressure = getPressure();
    _seaLevelPressure = currentPressure / pow(1 - (knownAltitude / 44330), 1 / 0.145);
    notifyListeners();
  }

  @override
  void dispose() {
    _magSub?.cancel();
    _accelSub?.cancel();
    _baroSub?.cancel();
    super.dispose();
  }
}