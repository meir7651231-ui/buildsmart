import 'package:flutter/material.dart';

/// Design tokens ported from app/src/styles/tokens.css.
/// Single source of truth for spacing/color/typography across the Flutter app.
class BsTokens {
  BsTokens._();

  // Spacing scale (matches CSS --space-1..--space-6, 4-px base unit).
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;

  // Radii.
  static const double radiusPill = 999;
  static const double radiusCard = 16;
  static const double radiusCircle = 24; // FAB inner

  // Font sizes — bound from existing literals (token-equal · zero visual). P-3.
  static const double fontXs = 8; // chain_diagram caption
  static const double fontSm = 9; // chain_diagram label
  static const double fontMd = 14; // toast text
  static const double fontLg = 22; // chain_diagram glyph

  // Dial dimensions (matches .dial__circle: 48px).
  static const double dialCircle = 48;
  static const double dialIconSize = 22;
  static const double dialEmojiSize = 20;
  static const double fabSize = 56;

  // Animation timing.
  static const Duration dialIn = Duration(milliseconds: 280);
  static const Duration ssubIn = Duration(milliseconds: 240);
  static const Duration dialStaggerStep = Duration(milliseconds: 28); // per-row rise delay
  static const Duration toastDuration = Duration(seconds: 2);
  static const Curve dialCurve = Cubic(0.2, 0.9, 0.3, 1.2);

  // Brand color (ported from --brand in tokens.css — orange used in Preact).
  static const Color brand = Color(0xFFFF7A18);
  static const Color brandDark = Color(0xFFE85F00);

  // Light theme colors.
  static const Color bgLight = Color(0xFFFAFAFA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color inkLight = Color(0xFF1A1A1A);
  static const Color mutedLight = Color(0xFF666666);

  // Chat-specific text colors (light background, high-contrast).
  static const Color chatText = Color(0xFF111111);
  static const Color chatTimestamp = Color(0xFF777777);

  // Dark theme colors — still used by AppTheme.dark(), dial & toast. Restored
  // after the light-mode transition removed them while consumers still ref them.
  static const Color bgDark = Color(0xFF0E1116);
  static const Color cardDark = Color(0xFF181D26);
  static const Color inkDark = Color(0xFFF1F3F8);
  static const Color mutedDark = Color(0xFF9AA3B2);

  // Chain-diagram data-viz palette (material stripes + joint edges). Bound from
  // existing literals in chain_diagram.dart — token-equal · zero visual. P-1.
  static const Color chainCyan = Color(0xFF22D3EE); // HDPE / cold supply / hdpe-press / implicit bridge
  static const Color chainOrange = Color(0xFFFB923C); // PEX / pex-press
  static const Color chainCopper = Color(0xFFEA580C); // copper / copper-press
  static const Color chainBrass = Color(0xFFEAB308); // brass / bsp thread
  static const Color chainGray = Color(0xFF94A3B8); // PVC / drainage
  static const Color chainSlate = Color(0xFF64748B); // PP
  static const Color chainPurple = Color(0xFFA855F7); // multi-layer
  static const Color chainCeramic = Color(0xFFE2E8F0); // ceramic
  static const Color chainRubber = Color(0xFF334155); // rubber
  static const Color chainSteel = Color(0xFF475569); // steel
  static const Color chainStainless = Color(0xFFCBD5E1); // stainless
  static const Color chainDefault = Color(0xFF7C8AA5); // neutral fallback / SKU caption
  static const Color chainWarning = Color(0xFFEF4444); // bottleneck warning ring

  // Light theme scaffold background (ported from app_theme.dart literal). P-1.
  static const Color bgLightAlt = Color(0xFFF5F6FA);

  // Shadow used for dial circles + label pills.
  static const List<BoxShadow> circleShadow = [
    BoxShadow(
      color: Color(0x59000000), // 0 6px 18px -8px rgba(0,0,0,.35) — flattened
      blurRadius: 18,
      offset: Offset(0, 6),
      spreadRadius: -8,
    ),
  ];

  static const List<BoxShadow> labelShadow = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: -6,
    ),
  ];
}
