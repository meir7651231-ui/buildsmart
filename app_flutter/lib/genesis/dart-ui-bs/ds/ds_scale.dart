// ✨ מאגר-העיצוב · סקאלות-טוקנים (Design Tokens) — **מחולל ע"י machtzev/ds-tokens.mjs מ-design-seed.json.**
// אל תערוך ידנית: שנה את הזרע והרץ את המנוע. הכרעה 17 (מראה-רצוי) + 19 (טוקן=דאטה). material בלבד.
import 'package:flutter/material.dart';
import 'ds.dart';

// ── טיפוגרפיה · סולם בסיס×יחס (display→label) ──
class DsType {
  static const display = TextStyle(fontSize: 31.5, fontWeight: FontWeight.w800, height: 1.12, letterSpacing: -0.5, color: DsTokens.ink);
  static const title = TextStyle(fontSize: 24.5, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.3, color: DsTokens.ink);
  static const subtitle = TextStyle(fontSize: 19, fontWeight: FontWeight.w600, height: 1.3, color: DsTokens.ink);
  static const body = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.45, color: DsTokens.ink);
  static const bodyMuted = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.45, color: DsTokens.muted);
  static const caption = TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, height: 1.35, color: DsTokens.muted);
  static const label = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: 0.4, color: DsTokens.faint);
  static const numeric = TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.1, fontFeatures: [FontFeature.tabularFigures()], color: DsTokens.ink);
}

// ── מרווחים · רשת 4 נקודות ──
class DsSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const huge = 48.0;
}

// ── רדיוסים · דרגות ──
class DsRadii {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 22.0;
  static const pill = 999.0;
}

// ── הגבהות · ראמפת-צל e0→e4 ──
class DsElev {
  static const List<BoxShadow> e0 = [];
  static const List<BoxShadow> e1 = [
    BoxShadow(color: Color(0x0F101828), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0B101828), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> e2 = [
    BoxShadow(color: Color(0x14101828), blurRadius: 8, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0E101828), blurRadius: 3, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> e3 = [
    BoxShadow(color: Color(0x19101828), blurRadius: 18, offset: Offset(0, 9)),
    BoxShadow(color: Color(0x11101828), blurRadius: 4, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> e4 = [
    BoxShadow(color: Color(0x1E101828), blurRadius: 32, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x14101828), blurRadius: 5, offset: Offset(0, 3)),
  ];
}

// ── גרדיאנטים · ספרייה נקובה ──
class DsGradient {
  static const accent = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF97316), Color(0xFFD66313)]);
  static const sunset = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFB923C), Color(0xFFF43F5E)]);
  static const ocean = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF38BDF8), Color(0xFF4F46E5)]);
  static const aurora = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF34E0C8), Color(0xFF6366F1), Color(0xFFA855F7)]);
  static const forest = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF34D399), Color(0xFF059669)]);
  static const dusk = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF6366F1), Color(0xFFEC4899)]);
}

// ── מוֹשֶׁן · משכים + עקומות ──
class DsMotion {
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration base = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration ambient = Duration(milliseconds: 6000);
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve decelerate = Curves.easeOut;
  static const Curve spring = Cubic(0.34, 1.56, 0.64, 1.0);
}

// ── מצב-כהה · פלטה-מקבילה (טרנספורם-מהבהיר) ──
class DsDark {
  static const bg = Color(0xFF0A0C14);
  static const card = Color(0xFF141829);
  static const ink = Color(0xFFEEF0FB);
  static const muted = Color(0xFF8B97A8);
  static const faint = Color(0xFF646E7F);
  static const line = Color(0xFF232A3D);
  static const accent = Color(0xFFFA8839);
  static const accentDark = Color(0xFFF97316);
  static const success = Color(0xFF45B56E);
  static const List<BoxShadow> shadow = [
    BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
  ];
}
