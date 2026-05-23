import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Theme factory. Renamed away from `BsTheme` because the settings
/// enum already owns that identifier.
class AppTheme {
  AppTheme._();

  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: BsTokens.brand,
      brightness: b,
      primary: BsTokens.brand,
      surface: isDark ? BsTokens.cardDark : Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? BsTokens.bgDark : const Color(0xFFF5F6FA),
      fontFamily: 'Heebo',
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          color: isDark ? BsTokens.inkDark : Colors.black87,
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          color: isDark ? BsTokens.inkDark : Colors.black87,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: isDark ? BsTokens.inkDark : Colors.black87,
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
