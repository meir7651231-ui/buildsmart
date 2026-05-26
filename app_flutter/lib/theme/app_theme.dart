import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Theme factory. Renamed away from `BsTheme` because the settings
/// enum already owns that identifier.
class AppTheme {
  AppTheme._();

  static ThemeData dark({bool highContrast = false}) =>
      _build(Brightness.dark, highContrast: highContrast);
  static ThemeData light({bool highContrast = false}) =>
      _build(Brightness.light, highContrast: highContrast);

  static ThemeData _build(Brightness b, {bool highContrast = false}) {
    final isDark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: BsTokens.brand,
      brightness: b,
      primary: BsTokens.brand,
      surface: isDark ? BsTokens.cardDark : Colors.white,
    );
    // High contrast pushes body text to pure black/white and darkens dividers.
    final Color ink = highContrast
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? BsTokens.inkDark : Colors.black87);

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? BsTokens.bgDark : const Color(0xFFF5F6FA),
      fontFamily: 'Heebo',
      dividerColor: highContrast
          ? (isDark ? Colors.white70 : Colors.black54)
          : null,
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          color: ink,
          fontSize: 14,
          fontWeight: highContrast ? FontWeight.w600 : null,
        ),
        labelLarge: TextStyle(
          color: ink,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BsTokens.brand,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
    );
  }
}
