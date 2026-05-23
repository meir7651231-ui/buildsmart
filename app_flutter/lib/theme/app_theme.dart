import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Dark theme — the Preact app is dark-only by default (R-rules don't
/// allow theme switching for now). Light scheme is registered so the
/// system theme toggle in iOS/Android doesn't break.
class BsTheme {
  BsTheme._();

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: BsTokens.brand,
      brightness: Brightness.dark,
      primary: BsTokens.brand,
      surface: BsTokens.cardDark,
    ).copyWith(
      surfaceContainerHighest: BsTokens.cardDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: BsTokens.bgDark,
      fontFamily: 'Heebo',
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: BsTokens.inkDark, fontSize: 14),
        labelLarge: TextStyle(
          color: BsTokens.inkDark,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: BsTokens.inkDark,
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
