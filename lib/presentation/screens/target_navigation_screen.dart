import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class TargetNavigationScreen extends ConsumerWidget {
  const TargetNavigationScreen({super.key});

  double _calculateDeviation(double current, double target) {
    final difference = (target - current + 540) % 360 - 180;
    return double.parse(difference.toStringAsFixed(1));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetHeading = ref.watch(targetHeadingProvider);
    final compassHeading = ref.watch(compassStateProvider).heading;
    final deviation = _calculateDeviation(compassHeading, targetHeading);
    final direction = deviation.abs() < 1 ? 'Locked' : deviation > 0 ? 'Right' : 'Left';
    final deviationColor = deviation.abs() < 5 ? Colors.green : deviation.abs() < 15 ? Colors.orange : Colors.red;

    return Scaffold(
      appBar: AppBar(title: const Text('Target Navigation')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Target Heading', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text('${targetHeading.toStringAsFixed(0)}°', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 18),
                  Slider(
                    value: targetHeading,
                    min: 0,
                    max: 360,
                    divisions: 360,
                    label: '${targetHeading.toStringAsFixed(0)}°',
                    onChanged: (value) {
                      ref.read(targetHeadingProvider.notifier).state = value;
                      ref.read(compassStateProvider.notifier).setTargetHeading(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Current Heading: ${compassHeading.toStringAsFixed(0)}°', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: deviationColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: deviationColor.withAlpha(80)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          deviation.abs() < 1 ? Icons.check_circle : Icons.navigation,
                          color: deviationColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Deviation: ${deviation.abs().toStringAsFixed(1)}° • $direction',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: deviationColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Targets', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildQuickTargetChip(context, ref, 'N', 0),
                      _buildQuickTargetChip(context, ref, 'NE', 45),
                      _buildQuickTargetChip(context, ref, 'E', 90),
                      _buildQuickTargetChip(context, ref, 'SE', 135),
                      _buildQuickTargetChip(context, ref, 'S', 180),
                      _buildQuickTargetChip(context, ref, 'SW', 225),
                      _buildQuickTargetChip(context, ref, 'W', 270),
                      _buildQuickTargetChip(context, ref, 'NW', 315),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              ref.read(analyticsServiceProvider).whenData((analytics) {
                analytics.logEvent('align_to_target', payload: {
                  'target': targetHeading,
                  'heading': compassHeading,
                  'deviation': deviation,
                });
              });
            },
            icon: const Icon(Icons.navigation),
            label: const Text('Log Target Alignment'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTargetChip(BuildContext context, WidgetRef ref, String label, double heading) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        ref.read(targetHeadingProvider.notifier).state = heading;
        ref.read(compassStateProvider.notifier).setTargetHeading(heading);
      },
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}
