// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 23 — CfgTheme (owner-overridable app theme).
//
// A [ThemeExtension] for the app-wide design the owner can override: brand /
// surface / ink / radius / fontScale. Added to [AppTheme]'s extensions; its
// DEFAULTS equal the current [BsTokens], so with no override the look is
// byte-identical (answer-equivalent / golden-render). Read via the `cfg*`
// accessors, each falling back to BsTokens when the extension is absent.
//
// (Placed in lib/theme/ — not state/studio — to keep the theme self-contained and
// avoid a theme→state import; it is a pure theme object. The config→CfgTheme wiring
// + the live editor are step 24.)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:flutter/material.dart';

@immutable
class CfgTheme extends ThemeExtension<CfgTheme> {
  const CfgTheme({
    this.brand = BsTokens.brand,
    this.surface = BsTokens.cardLight,
    this.ink = BsTokens.inkLight,
    this.radius = BsTokens.radiusCard,
    this.fontScale = 1.0,
  });

  final Color brand;
  final Color surface;
  final Color ink;
  final double radius;
  final double fontScale;

  /// The inert default — exactly the current palette.
  static const CfgTheme fallback = CfgTheme();

  @override
  CfgTheme copyWith({
    Color? brand,
    Color? surface,
    Color? ink,
    double? radius,
    double? fontScale,
  }) =>
      CfgTheme(
        brand: brand ?? this.brand,
        surface: surface ?? this.surface,
        ink: ink ?? this.ink,
        radius: radius ?? this.radius,
        fontScale: fontScale ?? this.fontScale,
      );

  @override
  CfgTheme lerp(ThemeExtension<CfgTheme>? other, double t) {
    if (other is! CfgTheme) return this;
    return CfgTheme(
      brand: Color.lerp(brand, other.brand, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      radius: radius + (other.radius - radius) * t,
      fontScale: fontScale + (other.fontScale - fontScale) * t,
    );
  }
}

/// Brand color — owner override, else [BsTokens.brand].
Color cfgBrand(BuildContext context) =>
    Theme.of(context).extension<CfgTheme>()?.brand ?? BsTokens.brand;

/// Card/surface color — owner override, else [BsTokens.cardLight].
Color cfgSurface(BuildContext context) =>
    Theme.of(context).extension<CfgTheme>()?.surface ?? BsTokens.cardLight;

/// Ink/text color — owner override, else [BsTokens.inkLight].
Color cfgInk(BuildContext context) =>
    Theme.of(context).extension<CfgTheme>()?.ink ?? BsTokens.inkLight;

/// Corner radius — owner override, else [BsTokens.radiusCard].
double cfgRadius(BuildContext context) =>
    Theme.of(context).extension<CfgTheme>()?.radius ?? BsTokens.radiusCard;

/// Global font scale — owner override, else 1.0.
double cfgFontScale(BuildContext context) =>
    Theme.of(context).extension<CfgTheme>()?.fontScale ?? 1.0;
