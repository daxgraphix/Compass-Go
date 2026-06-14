import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/analytics_service.dart';
import '../../data/services/location_service.dart';
import '../../data/services/permission_service.dart';
import '../../data/services/sensor_service.dart';
import '../../domain/entities/compass_state.dart';
import 'compass_notifier.dart';

final sensorServiceProvider = Provider<SensorService>((ref) {
  return SensorService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final permissionCheckProvider = FutureProvider<bool>((ref) async {
  return await PermissionService.areAllPermissionsGranted();
});

final permissionsGrantedProvider = StateProvider<bool>((ref) {
  return false;
});

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

final targetHeadingProvider = StateProvider<double>((ref) {
  return 0.0;
});

final lowPowerModeProvider = StateProvider<bool>((ref) {
  return false;
});

final analyticsServiceProvider = FutureProvider<AnalyticsService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return AnalyticsService(prefs);
});

final compassStateProvider = StateNotifierProvider<CompassStateNotifier, CompassState>((ref) {
  final sensorService = ref.watch(sensorServiceProvider);
  final notifier = CompassStateNotifier(sensorService);
  return notifier;
});