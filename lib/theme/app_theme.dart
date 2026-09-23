import 'package:flutter/material.dart';

/// Centralizes the visual language shared by all DevAlias screens.
abstract final class AppTheme {
  static const Color primary = Color(0xFF635BFF);
  static const Color background = Color(0xFFF8F9FC);
  static const Color textPrimary = Color(0xFF1C1B1F);

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: textPrimary,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
      ),
      useMaterial3: true,
    );
  }
}
