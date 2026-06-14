import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../data/services/sensor_service.dart';
import '../../data/services/magnetic_declination_service.dart';
import '../../domain/entities/compass_state.dart';

class CompassStateNotifier extends StateNotifier<CompassState> {
  final SensorService _sensorService;
  Timer? _updateTimer;
  bool _isCalibrationActive = false;
  double _calibrationProgress = 0;
  bool _lowPowerMode = false;
  static const _hapticAlignmentThreshold = 5.0;
  double? _targetHeading;
  DateTime? _lastHapticTime;

  CompassStateNotifier(this._sensorService)
      : super(const CompassState(
          heading: 0,
          isTrueNorth: true,
          altitudeMeters: 0,
          accuracy: 0,
          status: 'Initializing',
        ));

  void start() {
    _updateTimer?.cancel();
    final interval = _lowPowerMode ? const Duration(milliseconds: 750) : const Duration(milliseconds: 150);
    _updateTimer = Timer.periodic(interval, (_) {
      _checkAlignmentAndVibrate();
      _updateState();
    });
    _updateState();
  }

  void _updateState() {
    final sensorData = _sensorService.getAllSensorData();
    var heading = sensorData['heading'] as double;
    var isTrueNorth = state.isTrueNorth;

    if (isTrueNorth && sensorData['latitude'] != null && sensorData['longitude'] != null) {
      final declination = MagneticDeclinationService.calculateDeclination(
        sensorData['latitude']! as double,
        sensorData['longitude']! as double,
        DateTime.now(),
      );
      heading = MagneticDeclinationService.magneticToTrueHeading(heading, declination);
    }

    state = state.copyWith(
      heading: heading,
      accuracy: sensorData['accuracy'] as double,
      altitudeMeters: sensorData['altitude'] as double,
      latitude: sensorData['latitude'] as double?,
      longitude: sensorData['longitude'] as double?,
      pressure: sensorData['pressure'] as double,
      timestamp: DateTime.now(),
      isTrueNorth: isTrueNorth,
      status: _isCalibrationActive
          ? 'Calibrating... ${_calibrationProgress.toStringAsFixed(0)}%'
          : _sensorService.isInitialized
              ? 'Stable'
              : 'Initializing',
    );
  }

  void _checkAlignmentAndVibrate() {
    if (_targetHeading == null) return;

    final now = DateTime.now();
    if (_lastHapticTime != null && now.difference(_lastHapticTime!).inMilliseconds < 300) {
      return;
    }

    final currentHeading = state.heading;
    final diff = (currentHeading - _targetHeading!).abs();
    final angleDiff = diff > 180 ? 360 - diff : diff;

    if (angleDiff < _hapticAlignmentThreshold) {
      HapticFeedback.lightImpact();
      _lastHapticTime = now;
    }
  }

  void setTargetHeading(double heading) {
    _targetHeading = heading;
  }

  void toggleNorthMode() {
    state = state.copyWith(isTrueNorth: !state.isTrueNorth);
    _updateState();
  }

  void triggerAlignmentHaptic() {
    HapticFeedback.lightImpact();
  }

  void startCalibration() {
    _isCalibrationActive = true;
    _calibrationProgress = 0;
    _runCalibrationSequence();
  }

  void _runCalibrationSequence() {
    const steps = 5;
    for (int i = 0; i < steps; i++) {
      Timer(Duration(milliseconds: 300 * (i + 1)), () {
        _calibrationProgress = ((i + 1) * 100) / steps;
        if (i == steps - 1) {
          _isCalibrationActive = false;
          _calibrationProgress = 100;
        }
        _updateState();
      });
    }
  }

  void setLowPowerMode(bool enabled) {
    _lowPowerMode = enabled;
    start();
  }

  Future<void> setSeaLevelPressure(double pressure) async {
    _sensorService.setSeaLevelPressure(pressure);
  }

  Future<void> calibrateAltitude(double knownAltitude) async {
    await _sensorService.calibrateAltitude(knownAltitude);
  }
}