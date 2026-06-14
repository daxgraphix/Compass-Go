import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../../core/utils/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final lowPowerMode = ref.watch(lowPowerModeProvider);
    final analyticsAsync = ref.watch(analyticsServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Improve readability in low-light conditions'),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).state =
                        value ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
                const Divider(height: 1),
SwitchListTile(
                   secondary: const Icon(Icons.battery_saver),
                   title: const Text('Low Power Mode'),
                   subtitle: const Text('Reduced update rates to save battery'),
                   value: lowPowerMode,
                   onChanged: (value) {
                     ref.read(lowPowerModeProvider.notifier).state = value;
                     ref.read(compassStateProvider.notifier).setLowPowerMode(value);
                     ref.read(analyticsServiceProvider).whenData((analytics) {
                       analytics.logEvent('low_power_mode_changed', payload: {'enabled': value});
                     });
                   },
                 ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.height),
                  title: const Text('Zero Altitude'),
                  subtitle: const Text('Set current altitude as zero reference'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final notifier = ref.read(compassStateProvider.notifier);
                    await notifier.calibrateAltitude(0);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Navigation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Units'),
                  subtitle: const Text('Metric / Imperial'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.compass_calibration),
                  title: const Text('Calibration'),
                  subtitle: const Text('Build accuracy with live sensor checks'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/calibration');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Analytics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          analyticsAsync.when(
            data: (service) {
              final summary = service.getSummary();
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usage Summary',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context: context,
                            label: 'Screen Visits',
                            value: '${summary['total_screen_visits'] ?? 0}',
                          ),
                          _buildStatItem(
                            context: context,
                            label: 'Events',
                            value: '${summary['total_events'] ?? 0}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, stackTrace) => const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Analytics unavailable'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required BuildContext context, required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.accentBlue,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}