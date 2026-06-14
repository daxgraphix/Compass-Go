import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/compass_ring_widget.dart';
import '../providers/app_providers.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compassState = ref.watch(compassStateProvider);
    final scheme = Theme.of(context).colorScheme;
    final targetHeading = ref.watch(targetHeadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _showNavigationDrawer(context, ref),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.pushNamed(context, '/calibration'),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Chip(
              label: Text(
                compassState.isTrueNorth ? 'TRUE NORTH' : 'MAGNETIC',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppTheme.accentBlue.withAlpha(80),
              labelStyle: const TextStyle(color: AppTheme.accentBlue),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateToSettings(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: scheme.surface.withAlpha(scheme.brightness == Brightness.dark ? 150 : 200),
            child: Column(
              children: [
                Text(
                  '${compassState.heading.toStringAsFixed(1)}°',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 64,
                      ),
                ),
                Text(
                  _getCardinalDirection(compassState.heading),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onSurface.withAlpha(180),
                        fontWeight: FontWeight.w300,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Card(
                  elevation: 8,
                  shadowColor: scheme.primary.withAlpha(40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: CompassRingWidget(
                      heading: compassState.heading,
                      targetHeading: targetHeading != 0 ? targetHeading : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusChip(
                  context: context,
                  icon: Icons.radio_button_checked,
                  label: 'Accuracy',
                  value: '${compassState.accuracy.toStringAsFixed(1)}°',
                  color: compassState.accuracy < 2 ? AppTheme.successGreen : AppTheme.warningOrange,
                ),
                const SizedBox(width: 16),
                _buildStatusChip(
                  context: context,
                  icon: Icons.height,
                  label: 'Altitude',
                  value: '${compassState.altitudeMeters.toStringAsFixed(0)} m',
                  color: scheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _getCardinalDirection(double heading) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((heading + 22.5) ~/ 45) % 8;
    return directions[index];
  }

  void _showNavigationDrawer(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text('Target Navigation'),
              onTap: () {
                Navigator.pop(context);
                ref.read(analyticsServiceProvider).whenData((analytics) {
                  analytics.logEvent('quick_nav_target');
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny),
              title: const Text('Sun & Moon'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Altitude'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _navigateToSettings(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  Widget _buildStatusChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}