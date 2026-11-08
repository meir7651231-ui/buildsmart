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
      elevation: 6,
      shadowColor: Color(0x260D4151),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.fromLTRB(14, 0, 14, 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
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
      surfaceTintColor: Colors.transparent,
      indicatorColor: kMxPrimary,
      indicatorShape: const StadiumBorder(),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? Colors.white : kMxPrimary,
          size: 24,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontFamily: 'Heebo',
          fontSize: 12.5,
          fontWeight:
              s.contains(WidgetState.selected)
                  ? FontWeight.w800
                  : FontWeight.w600,
          color: kMxPrimary,
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(backgroundColor: kMxPrimary),
  );
}

// ── premium layer: pastel tints + soft tinted shadows ────────────────────────
// Tints echo the site's pastel stat cards (the pink "50 שנות ניסיון" card).
const Color kMxPink = kMxSiachSod ? Color(0xFFF6DDE2) : Color(0xFFFBE4E2);
const Color kMxGoldTint = kMxSiachSod ? Color(0xFFF6EDCB) : Color(0xFFFCEFD6);
const Color kMxTealTint = kMxSiachSod ? Color(0xFFDDEAEC) : Color(0xFFE2ECF7);
const Color kMxGreenTint = kMxSiachSod ? Color(0xFFDDEFE2) : Color(0xFFDDF0E4);

/// Tint for a status color (pastel background behind it).
Color mxTintOf(Color c) {
  if (c == kMxBad) return kMxPink;
  if (c == kMxWarn) return kMxGoldTint;
  if (c == kMxOk) return kMxGreenTint;
  return kMxTealTint;
}

/// Soft shadow tinted with the primary color — depth without borders.
const List<BoxShadow> kMxShadow = [
  BoxShadow(color: Color(0x140D4151), blurRadius: 22, offset: Offset(0, 8)),
  BoxShadow(color: Color(0x0A0D4151), blurRadius: 4, offset: Offset(0, 1)),
];
