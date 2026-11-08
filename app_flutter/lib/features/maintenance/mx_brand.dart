/// Maintenance module — client branding.
///
/// `MX_BRAND=siachsod` (the default for this module's demo) applies the
/// visual language of Siach Sod's own site (seeachsod.org, Elementor kit):
///   primary   #0D4151  deep petrol            (hero, headers)
///   secondary #B51734  crimson                (call-to-action buttons)
///   accent    #D7B42C  gold                   (highlights)
///   surface   #F5F5F0 / #EFEEE8  warm cream   (page background)
///   text      #323232
///   green     #248440  (logo stem)            (OK / done)
/// Their font (Leon) is licensed, so we use the bundled Heebo — the closest
/// geometric Hebrew sans already shipped with the app. Their LOGO is NOT
/// embedded: a text wordmark only, until the client approves using it.
///
/// `MX_BRAND=neutral` gives a plain blue theme for any other organization.
/// Colors are compile-time consts so every `const` widget stays const.
library;

import 'package:flutter/material.dart';

const String _brandName = String.fromEnvironment(
  'MX_BRAND',
  defaultValue: 'siachsod',
);
const bool kMxSiachSod = _brandName == 'siachsod';

/// Primary (headers, app bar, links).
const Color kMxPrimary = kMxSiachSod ? Color(0xFF0D4151) : Color(0xFF1F5FA8);

/// Call-to-action (main buttons) and errors.
const Color kMxCta = kMxSiachSod ? Color(0xFFB51734) : Color(0xFFC0362C);

/// Highlight accent.
const Color kMxAccent = kMxSiachSod ? Color(0xFFD7B42C) : Color(0xFFF0A83A);

/// Status colors (AA contrast on the light surfaces).
const Color kMxBad = kMxCta;
const Color kMxWarn = kMxSiachSod ? Color(0xFF8A6A00) : Color(0xFFB86E00);
const Color kMxOk = kMxSiachSod ? Color(0xFF248440) : Color(0xFF1E8A4C);

/// Page background and soft panels.
const Color kMxSurface = kMxSiachSod ? Color(0xFFF5F5F0) : Color(0xFFF4F6F8);
const Color kMxPanel = kMxSiachSod ? Color(0xFFEFEEE8) : Color(0xFFE9EEF3);
const Color kMxLine = kMxSiachSod ? Color(0xFFD1D1C0) : Color(0xFFE2E7EC);
const Color kMxInk = kMxSiachSod ? Color(0xFF323232) : Color(0xFF16202A);

/// Wordmark + subtitle in the app bar.
const String kMxWordmark = kMxSiachSod ? 'שיח סוד' : 'ניהול אחזקה';
const String kMxSubtitle = kMxSiachSod ? 'אחזקה ורכש' : 'ורכש';

ThemeData mxBrandTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kMxPrimary,
    primary: kMxPrimary,
    secondary: kMxCta,
    tertiary: kMxAccent,
    surface: Colors.white,
    error: kMxBad,
  );
  const radius = BorderRadius.all(Radius.circular(18));
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Heebo',
    scaffoldBackgroundColor: kMxSurface,
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: kMxInk,
      displayColor: kMxInk,
      fontFamily: 'Heebo',
    ),
    cardTheme: const CardTheme(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.fromLTRB(12, 0, 12, 10),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: kMxLine),
      ),
    ),
    dividerTheme: const DividerThemeData(color: kMxLine, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kMxCta,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: 'Heebo',
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kMxPrimary,
        side: const BorderSide(color: kMxPrimary),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: 'Heebo',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: kMxPrimary.withValues(alpha: 0.12),
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontFamily: 'Heebo',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: kMxPrimary,
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(backgroundColor: kMxPrimary),
  );
}
