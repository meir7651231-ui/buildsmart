// ✨ מאגר-העיצוב · שפת-Pure (Layer B · הטמעה) — **מחולל ע"י machtzev/ds-pure.mjs מ-new/atoms/pure-look.mjs.**
// אל תערוך ידנית: שנה את הזרע (pure-look) והרץ את המנוע. נייטרל+סמנטי **קבועים**; אקצנט **מורף**
// פר-ערכה (t-indigo / t-teal / t-amber). דורמנטי לצד DsScale/DsDark — הזהות מוזרקת בחיווט (חוק-6). material בלבד.
import 'package:flutter/material.dart';

/// ערכת-אקצנט אחת — מורפת יחד בהחלפת-ערכה (חוק-5: האטום לא יודע איזו ערכה).
@immutable
class DsPureTheme {
  final Color aHi;
  final Color a;
  final Color a800;
  final Color gl;
  final Color c2;
  final Color c3;
  const DsPureTheme({
    required this.aHi,
    required this.a,
    required this.a800,
    required this.gl,
    required this.c2,
    required this.c3,
  });
}

/// חבילת-פונט — **פרמטר הפיך, לא קבוע**: ברירת-המחדל היא פונטי-Pure, אך ניתנת להזרקה דרך
/// PureScope (חוק-6: הזהות בחיווט; חוק-7: היעדר-הזרקה ⇒ ברירת-המחדל ⇒ פלט ביט-זהה). material בלבד.
@immutable
class DsPureFonts {
  final String serif;
  final String serifHe;
  final String grotesk;
  final String he;
  const DsPureFonts({
    this.serif,
    this.serifHe,
    this.grotesk,
    this.he,
  });
}

/// שפת-Pure כטוקני-Dart. נייטרל+סמנטי קבועים; 3 ערכות-אקצנט; themeOf() = resolver.
class DsPure {
  // ── נייטרל · סולם-רקע/דיו/קו — לא מורף בהחלפת-ערכה ──
  static const canvas = Color(0xFF0C0C0E);
  static const sunken = Color(0xFF0A0A0C);
  static const surface = Color(0xFF151517);
  static const raised = Color(0xFF1B1B1E);
  static const raised2 = Color(0xFF212126);
  static const ink = Color(0xFFECE9E2);
  static const mut = Color(0xFF9B968C);
  static const faint = Color(0xFF6E6A62);
  static const hair = Color(0x17ECE9E2);
  static const hair2 = Color(0x0DECE9E2);

  // ── סמנטי · ok/warn/err/gold — קבוע (error נשאר אדום, gold נשאר זהב) ──
  static const ok = Color(0xFF43D08C);
  static const warn = Color(0xFFE6B84F);
  static const err = Color(0xFFE0574E);
  static const gold = Color(0xFFE6C766);

  // ── ערכות-אקצנט · מורפות יחד ──
  static const indigo = DsPureTheme(aHi: Color(0xFFB0A4FF), a: Color(0xFF7A6BF0), a800: Color(0xFF4B3ECB), gl: Color(0x6B7A6BF0), c2: Color(0xFF4CC6E6), c3: Color(0xFFB57BE6));
  static const teal = DsPureTheme(aHi: Color(0xFF6FE6D5), a: Color(0xFF1FB8A6), a800: Color(0xFF0C7E72), gl: Color(0x6B1FB8A6), c2: Color(0xFF4FB6E6), c3: Color(0xFF43D08C));
  static const amber = DsPureTheme(aHi: Color(0xFFF2C87E), a: Color(0xFFD99A3C), a800: Color(0xFF9E6B1E), gl: Color(0x6BD99A3C), c2: Color(0xFFE8863C), c3: Color(0xFFE67BA6));

  // ── קיצורי-אקצנט לברירת-המחדל (Color ישיר — לטוקנים דורמנטיים כמו BsPure) ──
  static const accentHi = Color(0xFFB0A4FF);
  static const accent = Color(0xFF7A6BF0);
  static const accentDark = Color(0xFF4B3ECB);

  // ── חבילת-פונט · ברירת-מחדל (פרמטר הפיך — ניתנת להחלפה דרך PureScope, אינה מורפת פר-ערכה) ──
  static const DsPureFonts fonts = DsPureFonts(serif: "Fraunces", serifHe: "Frank Ruhl Libre", grotesk: "Space Grotesk", he: "Heebo");

  static const String defaultTheme = 't-indigo';
  static const Map<String, DsPureTheme> themes = {'t-indigo': indigo, 't-teal': teal, 't-amber': amber};

  /// resolver-הערכה (מקביל ל-pure-resolve בצד-ה-JS): id→ערכה, נפילה לברירת-המחדל.
  static DsPureTheme themeOf(String id) => themes[id] ?? themes[defaultTheme]!;
}
