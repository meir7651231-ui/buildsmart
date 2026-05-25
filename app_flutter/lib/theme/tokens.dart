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

  // Dial dimensions (matches .dial__circle: 48px).
  static const double dialCircle = 48;
  static const double dialIconSize = 22;
  static const double dialEmojiSize = 20;
  static const double fabSize = 56;

  // Animation timing.
  static const Duration dialIn = Duration(milliseconds: 280);
  static const Duration ssubIn = Duration(milliseconds: 240);
  static const Curve dialCurve = Cubic(0.2, 0.9, 0.3, 1.2);

  // Brand color (ported from --brand in tokens.css — orange used in Preact).
  static const Color brand = Color(0xFFFF7A18);
  static const Color brandDark = Color(0xFFE85F00);

  // Light theme colors.
  static const Color bgLight = Color(0xFFFAFAFA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color inkLight = Color(0xFF1A1A1A);
  static const Color mutedLight = Color(0xFF666666);

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
