// 🔌 מנוע-קטלוג-3D · פאזה C (שלב 41) — turtle-3D: דלתות-הפריסה פר-אביזר.
// היסוד הטהור של אלגוריתם-הפריסה (§3): לכל אביזר, כמה להתקדם קדימה (`ex`), כמה
// לצדדים על-הפנייה (`ey`), ובאיזו זווית-פנייה (`turn`). ה-turtle המלא (וקטורי-3D +
// מסגרות + Gram-Schmidt) נבנה מעל אלה בפרוסה נפרדת. מגודר (`features/fittings/`)
// ⇒ tree-shaken כשהדגל כבוי (keystone byte-identical · הכרטיס-החי לא-נגוע).
//
// כל דלתא = פונקציה של אותיות-המנוע (A/l/E/F/F2/d1/cap) — לכן זהה-golden
// טרנזיטיבית ל-`pure_engine.py`, ומקבילה ל-`elemMeshes` ב-`gen3d.html:280-319`
// (מימוש-הייחוס של ה-3D). ⚠️ **אפס גזירה חדשה של פיזיקה** — רק היטלי-פריסה.

import 'dart:math' as math;

import 'package:buildsmart/features/fittings/engine/fitting_dims.dart';
import 'package:flutter/foundation.dart' show immutable;

/// דלתת-פריסה של אביזר בודד ברצף ה-turtle: התקדמות-קדימה, התקדמות-על-הפנייה,
/// זווית-פנייה (רדיאנים · 0 = ישר), וסימון-קצה (פקק סוגר את הרצף).
@immutable
class LayoutDelta {
  const LayoutDelta({
    required this.ex,
    this.ey = 0,
    this.turn = 0,
    this.terminal = false,
  });

  /// התקדמות לאורך ציר-הזרימה הנוכחי (מ״מ).
  final double ex;

  /// התקדמות על ציר-הפנייה (מ״מ) — לא-אפס רק לברך.
  final double ey;

  /// זווית-הפנייה (רדיאנים) — 0 לאביזר-ישר, π/2 / π/4 לברך.
  final double turn;

  /// פקק — סוגר את הרצף (אין המשך-צנרת אחריו).
  final bool terminal;

  @override
  bool operator ==(Object other) =>
      other is LayoutDelta &&
      other.ex == ex &&
      other.ey == ey &&
      other.turn == turn &&
      other.terminal == terminal;

  @override
  int get hashCode => Object.hash(ex, ey, turn, terminal);
}

/// המשפחות שה-turtle יודע לפרוס (מקבילות ל-`elemMeshes`).
const Set<String> _kLayoutFamilies = {
  'מצמד', 'ברך 90°', 'ברך 45°', 'מסעף (טי)', 'מתאם תבריג',
  'ברז כדורי', 'מצרה', 'פקק', 'רוכב', 'צווארון',
};

/// דלתת-הפריסה של (family, od[, od2]) — נגזרת מאותיות-`generate`, מקבילה 1:1 ל-
/// `elemMeshes` ב-`gen3d.html`. משפחה-לא-מוכרת → `null` (M1 · fallback-לתמונה).
LayoutDelta? layoutDeltaFor(String family, int od, {int? od2}) {
  if (!_kLayoutFamilies.contains(family)) return null;
  final g = generate(family, od, od2: od2);
  switch (family) {
    case 'מצמד':
      return LayoutDelta(ex: g['A']!);
    case 'ברך 90°':
    case 'ברך 45°':
      final l = g['l']!;
      final t = (family.contains('45') ? 45 : 90) * math.pi / 180;
      return LayoutDelta(ex: l + l * math.cos(t), ey: l * math.sin(t), turn: t);
    case 'מסעף (טי)':
      return LayoutDelta(ex: g['E']!);
    case 'מתאם תבריג':
      return LayoutDelta(ex: g['l']!);
    case 'ברז כדורי':
      return LayoutDelta(ex: 2 * g['F']! + od * 1.6); // L = 2F + 1.6·OD (gen3d)
    case 'מצרה':
      return LayoutDelta(ex: g['F1']! + 4 + g['F2']!); // reducer: F1 + 4 + F2
    case 'פקק':
      return LayoutDelta(ex: g['F']! + g['cap']!, terminal: true);
    case 'רוכב':
      return LayoutDelta(ex: g['d1']! * 0.9);
    case 'צווארון':
      return LayoutDelta(ex: g['A']! + math.max(4, od * 0.18));
    default:
      return null;
  }
}
