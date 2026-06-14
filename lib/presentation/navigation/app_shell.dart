import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../screens/altitude_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/sun_moon_screen.dart';
import '../screens/target_navigation_screen.dart';
import '../screens/permission_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

@override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(compassStateProvider.notifier);
      notifier.start();
    });
  }

  final List<String> _screenLabels = [
    'Home',
    'Target Navigation',
    'Sun & Moon',
    'Altitude',
    'Settings',
  ];

  final List<Widget> _screens = <Widget>[
    HomeScreen(),
    TargetNavigationScreen(),
    SunMoonScreen(),
    AltitudeScreen(),
    SettingsScreen(),
  ];

  final List<NavigationDestination> _destinations = [
    NavigationDestination(icon: Icon(Icons.explore), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.track_changes), label: 'Target'),
    NavigationDestination(icon: Icon(Icons.wb_sunny), label: 'Sun/Moon'),
    NavigationDestination(icon: Icon(Icons.speed), label: 'Altitude'),
    NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    ref.read(analyticsServiceProvider).whenData((analytics) {
      analytics.logScreenVisit(_screenLabels[index]);
      analytics.trackAccuracy(ref.read(compassStateProvider).accuracy);
    });

    if (index == 1) {
      ref.read(compassStateProvider.notifier).setTargetHeading(ref.read(targetHeadingProvider));
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionsGranted = ref.watch(permissionsGrantedProvider);

    if (!permissionsGranted) {
      return PermissionScreen(
        onPermissionsGranted: () {
          ref.read(permissionsGrantedProvider.notifier).state = true;
        },
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: _destinations,
      ),
    );
  }
}