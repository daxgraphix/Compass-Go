import 'package:flutter/material.dart';

class AppTheme {
  static const Color primarySeed = Color(0xFF0288D1);
  static const Color accentBlue = Color(0xFF0288D1);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      textTheme: Typography.blackMountainView.copyWith(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 56,
          height: 1.1,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      iconTheme: IconThemeData(
        color: scheme.onSurface.withAlpha(180),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF08101F),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF121F35),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A2332),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      textTheme: Typography.whiteMountainView.copyWith(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 56,
          height: 1.1,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.white.withAlpha(180),
      ),
    );
  }

  static Widget buildProgressIndicator(double value, {double? height, Color? color}) {
    return LinearProgressIndicator(
      value: value,
      minHeight: height ?? 8,
      borderRadius: BorderRadius.circular(4),
      color: color,
      backgroundColor: color?.withAlpha(40) ?? Colors.blue.withAlpha(40),
    );
  }
}