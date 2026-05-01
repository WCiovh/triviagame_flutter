import 'package:flutter/material.dart';

class AppTheme {
  // Kolory
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color background = Color(0xFF0F0F1A);
  static const Color surface = Color(0xFF1C1C2E);
  static const Color error = Color(0xFFCF6679);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFFE0E0E0);
  static const Color onSurface = Color(0xFFB0B0C3);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          background: background,
          surface: surface,
          error: error,
          onPrimary: onPrimary,
          onBackground: onBackground,
          onSurface: onSurface,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: onPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: onPrimary,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          labelStyle: const TextStyle(color: onSurface),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: onPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            color: onPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(
            color: onBackground,
            fontSize: 16,
          ),
        ),
      );
}