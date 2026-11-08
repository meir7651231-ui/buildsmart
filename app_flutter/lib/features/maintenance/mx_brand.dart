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
// Brand-only palette: "attention" is the dark shade of the gold accent (AA on
// white), "done / OK" is the petrol primary itself — no off-brand green.
const Color kMxWarn = kMxSiachSod ? Color(0xFF6B5200) : Color(0xFFB86E00);
const Color kMxOk = kMxSiachSod ? Color(0xFF0D4151) : Color(0xFF1E8A4C);

/// Page background and soft panels.
const Color kMxSurface = kMxSiachSod ? Color(0xFFF5F5F0) : Color(0xFFF4F6F8);
const Color kMxPanel = kMxSiachSod ? Color(0xFFEFEEE8) : Color(0xFFE9EEF3);
const Color kMxLine = kMxSiachSod ? Color(0xFFD1D1C0) : Color(0xFFE2E7EC);
const Color kMxInk = kMxSiachSod ? Color(0xFF323232) : Color(0xFF16202A);

/// Wordmark + subtitle in the app bar.
const String kMxWordmark = kMxSiachSod ? 'שיח סוד' : 'ניהול אחזקה';
const String kMxSubtitle = kMxSiachSod ? 'אחזקה ורכש' : 'ורכש';

/// Design tokens (design round 2): one radius scale, three weights, a 4/8
/// spacing grid, and semantic color roles — red is ONLY safety / overdue /
/// destructive; every primary action is petrol; waiting is gold.
const double kMxR6 = 6; // status badge
const double kMxR12 = 12; // input, chip, tile, segmented
const double kMxR16 = 16; // card, toast, list group
const double kMxR24 = 24; // sheet top, dialog
const BorderRadius kMxCardRadius = BorderRadius.all(Radius.circular(kMxR16));

/// Secondary text and "zero / nothing to do" numbers.
const Color kMxMuted = Color(0xFF5C5C55);
const Color kMxZero = Color(0xFF9A9A90);

/// Input border (quiet) — focus turns petrol.
const Color kMxField = Color(0xFFD9D7C8);

/// Tabular figures for every number, price and date.
const List<FontFeature> kMxTabular = [FontFeature.tabularFigures()];

ThemeData mxBrandTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kMxPrimary,
    primary: kMxPrimary,
    secondary: kMxAccent,
    tertiary: kMxAccent,
    surface: Colors.white,
    error: kMxBad,
  );
  const btnShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(kMxR12)),
  );
  const label = TextStyle(
    fontFamily: 'Heebo',
    fontSize: 16,
    fontWeight: FontWeight.w700,
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
    iconTheme: const IconThemeData(color: kMxPrimary),
    cardTheme: const CardTheme(
      color: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.fromLTRB(16, 0, 16, 12),
      shape: RoundedRectangleBorder(borderRadius: kMxCardRadius),
    ),
    dividerTheme: const DividerThemeData(color: kMxLine, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.disabled)
                  ? kMxPrimary.withValues(alpha: 0.3)
                  : kMxPrimary,
        ),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        minimumSize: const WidgetStatePropertyAll(Size(64, 48)),
        shape: const WidgetStatePropertyAll(btnShape),
        textStyle: const WidgetStatePropertyAll(label),
        overlayColor: WidgetStatePropertyAll(
          Colors.white.withValues(alpha: 0.08),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kMxPrimary,
        disabledForegroundColor: kMxPrimary.withValues(alpha: 0.35),
        side: const BorderSide(color: kMxPrimary),
        minimumSize: const Size(64, 44),
        shape: btnShape,
        textStyle: label.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kMxPrimary,
        minimumSize: const Size(44, 44),
        shape: btnShape,
        textStyle: label.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: kMxPrimary,
        disabledForegroundColor: kMxPrimary.withValues(alpha: 0.35),
        minimumSize: const Size(44, 44),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: kMxPrimary,
      side: BorderSide(color: Color(0xFFC9C7B4)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(kMxR12)),
      ),
      labelStyle: TextStyle(
        fontFamily: 'Heebo',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: kMxInk,
      ),
      showCheckmark: false,
      padding: EdgeInsets.symmetric(horizontal: 12),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: kMxZero, fontSize: 16),
      labelStyle: TextStyle(color: kMxMuted, fontSize: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(kMxR12)),
        borderSide: BorderSide(color: kMxField),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(kMxR12)),
        borderSide: BorderSide(color: kMxField),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(kMxR12)),
        borderSide: BorderSide(color: kMxPrimary, width: 2),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      // No Material pill: the active tab is marked by a small gold arch.
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? kMxPrimary : kMxMuted,
          size: 24,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontFamily: 'Heebo',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color:
              s.contains(WidgetState.selected)
                  ? kMxPrimary
                  : const Color(0xFF7C7A70),
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: kMxPrimary,
      behavior: SnackBarBehavior.floating,
      insetPadding: EdgeInsets.fromLTRB(16, 0, 16, 12),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: kMxCardRadius),
      contentTextStyle: TextStyle(
        fontFamily: 'Heebo',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(kMxR24)),
      ),
      titleTextStyle: TextStyle(
        fontFamily: 'Heebo',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: kMxInk,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Color(0x660D2730),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kMxR24)),
      ),
    ),
    // One chrome everywhere: petrol bar, white title (design round 2).
    appBarTheme: const AppBarTheme(
      backgroundColor: kMxPrimary,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 56,
      titleTextStyle: TextStyle(
        fontFamily: 'Heebo',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

// ── premium layer: pastel tints + soft tinted shadows ────────────────────────
// Tints echo the site's pastel stat cards (the pink "50 שנות ניסיון" card).
const Color kMxPink = kMxSiachSod ? Color(0xFFF6DDE2) : Color(0xFFFBE4E2);
const Color kMxGoldTint = kMxSiachSod ? Color(0xFFFBF4DA) : Color(0xFFFCEFD6);
const Color kMxTealTint = kMxSiachSod ? Color(0xFFDDEAEC) : Color(0xFFE2ECF7);
const Color kMxGreenTint = kMxSiachSod ? Color(0xFFDDEFE2) : Color(0xFFDDF0E4);

/// Tint for a status color (pastel background behind it).
Color mxTintOf(Color c) {
  if (c == kMxBad) return kMxPink;
  if (c == kMxWarn) return kMxGoldTint;
  if (c == kMxOk || c == kMxPrimary) return kMxTealTint;
  return kMxTealTint;
}

/// Elevation 1 (cards): border OR shadow, never both.
const List<BoxShadow> kMxShadow = [
  BoxShadow(color: Color(0x140D4151), blurRadius: 3, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0F0D4151), blurRadius: 12, offset: Offset(0, 4)),
];

/// Elevation 2 (sticky bars, navigation).
const List<BoxShadow> kMxShadow2 = [
  BoxShadow(color: Color(0x1A0D4151), blurRadius: 12, offset: Offset(0, -2)),
];

/// Elevation 3 (toast, floating).
const List<BoxShadow> kMxShadow3 = [
  BoxShadow(color: Color(0x290D4151), blurRadius: 24, offset: Offset(0, 8)),
];
