import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../../data/services/solar_service.dart';

class SunMoonScreen extends ConsumerWidget {
  const SunMoonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compassState = ref.watch(compassStateProvider);
    final scheme = Theme.of(context).colorScheme;
    final sunColor = Colors.orange.shade400;

    final latitude = compassState.latitude ?? 40.7128;
    final longitude = compassState.longitude ?? -74.0060;
    final now = DateTime.now();

    final sunData = SolarService.calculateSunriseSunset(latitude, longitude, now);
    final solarPos = SolarService.calculateSolarPosition(latitude, longitude, now);
    final moonPhase = SolarService.calculateMoonPhase(now);
    final moonIllum = SolarService.calculateMoonIllumination(now);

    return Scaffold(
      appBar: AppBar(title: const Text('Sun & Moon')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Today\'s Solar Events', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SolarEventTile(icon: Icons.wb_sunny, label: 'Sunrise', value: SolarService.formatTime(sunData['sunrise']), color: sunColor),
                      _SolarEventTile(icon: Icons.wb_sunny, label: 'Sunset', value: SolarService.formatTime(sunData['sunset']), color: sunColor),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Solar Azimuth: ${solarPos['azimuth']?.toStringAsFixed(0) ?? '--'}°', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.primary)),
                  Text('Elevation: ${solarPos['elevation']?.toStringAsFixed(1) ?? '--'}°', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface.withAlpha(150))),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Moon Phase', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.surfaceContainerHighest,
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withAlpha(60),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          moonIllum > 50 ? Icons.brightness_3 : Icons.nightlight_round,
                          color: moonIllum > 50 ? Colors.amber.shade700 : Colors.blueGrey.shade300,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(SolarService.getMoonPhaseName(moonPhase), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('${moonIllum.toStringAsFixed(0)}% illuminated', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurface.withAlpha(150))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Moon Age: ${(moonPhase * 29.5).toStringAsFixed(1)} days', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SolarEventTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SolarEventTile({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
