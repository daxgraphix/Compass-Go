import 'package:flutter/material.dart';

import '../../core/utils/app_theme.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  double _calibrationProgress = 0;
  String _calibrationStatus = 'Ready to calibrate';
  bool _isRunning = false;

  void _startCalibration() {
    setState(() {
      _calibrationStatus = 'Perform figure-8 motion...';
      _isRunning = true;
      _calibrationProgress = 0;
    });

    const steps = 5;
    for (int i = 0; i < steps; i++) {
      Future.delayed(Duration(milliseconds: 400 * (i + 1)), () {
        if (mounted) {
          setState(() {
            _calibrationProgress = ((i + 1) * 100) / steps;
            if (i == steps - 1) {
              _calibrationStatus = 'Calibration Complete!';
              _isRunning = false;
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calibration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sensor Calibration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Improve accuracy with live sensor checks',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.compass_calibration,
                      size: 48,
                      color: AppTheme.accentBlue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Status: $_calibrationStatus',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    AppTheme.buildProgressIndicator(
                      _calibrationProgress / 100,
                      color: AppTheme.accentBlue,
                    ),
                    const SizedBox(height: 8),
                    Text('${_calibrationProgress.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instructions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const _CalibrationStep(
                      number: 1,
                      text: 'Hold device flat and slowly rotate in a figure-8 motion',
                    ),
                    const _CalibrationStep(number: 2, text: 'Keep movements slow and steady'),
                    const _CalibrationStep(number: 3, text: 'Complete all steps for best accuracy'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isRunning ? null : _startCalibration,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Calibration'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalibrationStep extends StatelessWidget {
  final int number;
  final String text;

  const _CalibrationStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: AppTheme.accentBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}