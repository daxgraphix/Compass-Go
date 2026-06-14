import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_strings.dart';
import 'core/utils/app_theme.dart';
import 'presentation/navigation/app_shell.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/screens/calibration_screen.dart';

void main() {
  runApp(const ProviderScope(child: CompassGoApp()));
}

class CompassGoApp extends ConsumerWidget {
  const CompassGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    ref.read(analyticsServiceProvider).whenData((analytics) {
      analytics.startSession();
    });

    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const AppShell(),
      routes: {
        '/calibration': (context) => const CalibrationScreen(),
      },
    );
  }
}