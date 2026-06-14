import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../../core/utils/app_theme.dart';

class AltitudeScreen extends ConsumerWidget {
  const AltitudeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compassState = ref.watch(compassStateProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Altitude')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Altitude (MSL)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Text(
                    compassState.altitudeMeters.toStringAsFixed(0),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    'meters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: scheme.onSurface.withAlpha(150),
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Source', style: Theme.of(context).textTheme.labelMedium),
                          const SizedBox(height: 4),
                          Text('Barometer', style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      Chip(
                        label: const Text('Active'),
                        backgroundColor: AppTheme.successGreen.withAlpha(80),
                        labelStyle: TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Stability', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.8,
                      minHeight: 10,
                      backgroundColor: scheme.primary.withAlpha(40),
                      valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('80% - High', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.successGreen)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pressure', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Text(
                    '${compassState.pressure?.toStringAsFixed(2) ?? '--'} hPa',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: scheme.primary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showCalibrationDialog(context, ref, compassState.altitudeMeters),
            icon: const Icon(Icons.tune),
            label: const Text('Calibrate Altitude'),
          ),
        ],
      ),
    );
  }

  void _showCalibrationDialog(BuildContext context, WidgetRef ref, double currentAltitude) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calibrate Altitude'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current altitude: ${currentAltitude.toStringAsFixed(0)} m'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Known altitude (meters)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (value) {
                final altitude = double.tryParse(value);
                if (altitude != null) {
                  ref.read(compassStateProvider.notifier).calibrateAltitude(altitude);
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(compassStateProvider.notifier).calibrateAltitude(0);
              Navigator.pop(context);
            },
            child: const Text('Set to Zero'),
          ),
        ],
      ),
    );
  }
}
