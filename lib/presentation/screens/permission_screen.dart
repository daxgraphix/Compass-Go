import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/services/permission_service.dart';

class PermissionScreen extends StatefulWidget {
  final VoidCallback onPermissionsGranted;

  const PermissionScreen({super.key, required this.onPermissionsGranted});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _sensorsGranted = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentPermissions();
  }

  Future<void> _checkCurrentPermissions() async {
    final sensorsStatus = await PermissionService.getSensorPermissionStatus();
    setState(() {
      _sensorsGranted = sensorsStatus == PermissionStatus.granted;
    });
  }

  Future<void> _handleAllowAccess() async {
    setState(() => _loading = true);

    try {
      final results = await PermissionService.requestAllPermissions();

      if (mounted) {
        setState(() {
          _sensorsGranted = results['sensors'] ?? false;
          _loading = false;
        });

        if (_sensorsGranted) {
          widget.onPermissionsGranted();
        } else {
          _showPermissionDeniedDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showErrorDialog(e.toString());
      }
    }
  }

  void _handleSkipMode() {
    // Allow limited mode without full permissions
    widget.onPermissionsGranted();
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sensor Permission Required'),
        content: const Text('COMPASS GO requires sensor access to function properly. Please enable sensors in app settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              PermissionService.openAppSettingsCompat();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to request permissions: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = const Color(0xFF0288D1);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0A1428), const Color(0xFF1A3A52)]
                : [Colors.blue.shade50, Colors.cyan.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Sensor Access Required',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  width: 140,
                  height: 140,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withAlpha(100),
                        blurRadius: 20,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.navigation,
                    size: 80,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'We require:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _PermissionItem(
                  icon: Icons.check_circle,
                  label: 'Motion Sensors',
                  description: 'For compass heading calculation',
                  granted: _sensorsGranted,
                ),
                const SizedBox(height: 12),
                const _PermissionItem(
                  icon: Icons.check_circle,
                  label: 'Location (Optional)',
                  description: 'For true north calibration',
                  granted: true,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _loading ? null : _handleAllowAccess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'ALLOW ACCESS',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1),
                        ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _loading ? null : _handleSkipMode,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: accentColor.withAlpha(150)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Skip (Limited Mode)',
                    style: TextStyle(fontSize: 16, color: accentColor.withAlpha(200)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool granted;

  const _PermissionItem({
    required this.icon,
    required this.label,
    required this.description,
    this.granted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: granted ? Colors.green : Colors.grey, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
