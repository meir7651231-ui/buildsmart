import 'package:buildsmart/theme/config_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Theme factory. Renamed away from `BsTheme` because the settings
/// enum already owns that identifier.
class AppTheme {
  AppTheme._();

  static ThemeData dark({
    bool highContrast = false,
    CfgTheme cfg = CfgTheme.fallback,
  }) =>
      _build(Brightness.dark, highContrast: highContrast, cfg: cfg);
  static ThemeData light({
    bool highContrast = false,
    CfgTheme cfg = CfgTheme.fallback,
  }) =>
      _build(Brightness.light, highContrast: highContrast, cfg: cfg);

  static ThemeData _build(
    Brightness b, {
    bool highContrast = false,
    CfgTheme cfg = CfgTheme.fallback,
  }) {
    final isDark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: cfg.brand,
      brightness: b,
      primary: cfg.brand,
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
          isDark ? BsTokens.bgDark : BsTokens.bgLightAlt,
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
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cfg.brand,
        foregroundColor: highContrast ? BsTokens.inkLight : Colors.white,
        elevation: 6,
      ),
      // Contrast-sensitive foregrounds the rest of the theme can't reach (they
      // are widget-level literals). High-contrast darkens them; normal mode is
      // byte-identical to before — bsOnAccent/bsSuccess return white/#22C55E.
      extensions: <ThemeExtension<dynamic>>[
        BsSemanticColors(
          onAccent: highContrast ? BsTokens.inkLight : Colors.white,
          success: highContrast ? BsTokens.successDark : BsTokens.success,
        ),
        // Owner-overridable app theme — injected from configThemeProvider by
        // main.dart; defaults = BsTokens ⇒ inert when there is no override.
        cfg,
      ],
    );
  }
}

/// Foregrounds (text/icon colors) that the base [ThemeData] cannot reach because
/// call-sites hardcode them as literals. High-contrast mode darkens them to meet
/// WCAG AA; in normal mode they stay exactly as the brand palette defines them,
/// so the default look is unchanged. Read via [bsOnAccent] / [bsSuccess].
@immutable
class BsSemanticColors extends ThemeExtension<BsSemanticColors> {
  const BsSemanticColors({required this.onAccent, required this.success});

  /// Foreground to place ON a saturated accent FILL (brand orange / success-green
  /// fill / amber). White normally; dark ink in high-contrast — white-on-orange
  /// is only 2.61:1, which fails WCAG.
  final Color onAccent;

  /// Green used as the COLOR of TEXT/icons on a LIGHT background (prices, the
  /// online badge). #22C55E normally (matches the brand green used for fills and
  /// dots); a darker #15803D in high-contrast — #22C55E-on-white is only 2.28:1.
  final Color success;

  @override
  BsSemanticColors copyWith({Color? onAccent, Color? success}) =>
      BsSemanticColors(
        onAccent: onAccent ?? this.onAccent,
        success: success ?? this.success,
      );

  @override
  BsSemanticColors lerp(ThemeExtension<BsSemanticColors>? other, double t) {
    if (other is! BsSemanticColors) return this;
    return BsSemanticColors(
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

/// Legible foreground for a saturated accent fill — see [BsSemanticColors.onAccent].
/// Falls back to white if the extension is absent (e.g. a bare test harness).
Color bsOnAccent(BuildContext context) =>
    Theme.of(context).extension<BsSemanticColors>()?.onAccent ?? Colors.white;

/// Accessible green for text/icons on a light background — see [BsSemanticColors.success].
/// Falls back to the brand green if the extension is absent.
Color bsSuccess(BuildContext context) =>
    Theme.of(context).extension<BsSemanticColors>()?.success ??
    BsTokens.success;
