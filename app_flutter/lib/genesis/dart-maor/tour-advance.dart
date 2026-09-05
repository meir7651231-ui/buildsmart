// חוט · tour-advance — אינדקס-הצעד-הבא בסיור. חוזה: tour-advance.contract.md
// המרה מ-JS (new/atoms/tour-advance.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// המקור: const next = index + delta; next<0⇒0 · next>=length⇒null · אחרת next.
// אפס-import (רק dart-core). טהור.
//
// הערות-המרה (JS→Dart):
//  · **תיקון-הסגר (חוק-17 · float64):** הפורט-השבור עשה `index + delta` על
//    dynamic — כששניהם int, Dart מחבר במרחב-int64 המדויק, בעוד JS מחבר תמיד
//    ב-float64. מעל 2^53 הם מתפצלים: index=2^53, delta=1 ⇒ JS מעגל ל-2^53
//    אך Dart-int מחזיר 2^53+1. גם ההשוואה `next>=length` השתנתה בהתאם.
//    התיקון: חיבור ב-float64 דרך _jsNum (הועתק INLINE מ-
//    machtzev/emit/js-compat-reference.dart · חוק-1: אטום לא-מייבא).
//  · NaN מטופל טבעית: `NaN<0` ו-`NaN>=length` שניהם false ⇒ מחזיר NaN, כמו-JS.

num? tourAdvance(dynamic index, dynamic delta, dynamic length) {
  final double next = _jsNum(index) + _jsNum(delta); // ‏index+delta ב-float64
  if (next < 0) return 0;
  if (next >= _jsNum(length)) return null;
  return next;
}

// ── עוזרי js-compat (INLINE · חוק-1: אטום לא-מייבא) ──────────────────────────

/// חוק-16 · קבוצת-הרווחים של ECMAScript (trim). **בלי** U+0085/U+180E.
const Set<int> _esWs = {
  0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0xA0, 0x1680,
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007,
  0x2008, 0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000, 0xFEFF,
};

/// חוק-16 · trim נאמן-ES. גוזם רק את _esWs.
String _jsTrim(String s) {
  var start = 0, end = s.length;
  while (start < end && _esWs.contains(s.codeUnitAt(start))) start++;
  while (end > start && _esWs.contains(s.codeUnitAt(end - 1))) end--;
  return s.substring(start, end);
}

/// חוקים 10+18 · ToNumber של JS על מחרוזת, עם דקדוק-ES **לפני** הפרסינג.
double _jsStrToNum(String raw) {
  final s = _jsTrim(raw);
  if (s.isEmpty) return 0.0; // ‏Number('') === 0
  if (s == 'Infinity' || s == '+Infinity') return double.infinity;
  if (s == '-Infinity') return double.negativeInfinity;
  if (RegExp(r'^0[xX][0-9a-fA-F]+$').hasMatch(s)) {
    return _fromRadix(s.substring(2), 16);
  }
  if (RegExp(r'^0[oO][0-7]+$').hasMatch(s)) return _fromRadix(s.substring(2), 8);
  if (RegExp(r'^0[bB][01]+$').hasMatch(s)) return _fromRadix(s.substring(2), 2);
  if (!RegExp(r'^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$').hasMatch(s)) {
    return double.nan;
  }
  return double.tryParse(s) ?? double.nan;
}

double _fromRadix(String digits, int radix) {
  try {
    return BigInt.parse(digits, radix: radix).toDouble();
  } catch (_) {
    return double.nan;
  }
}

/// חוק-10/17 · ToNumber כללי (כל טיפוס), במרחב-double של JS.
double _jsNum(dynamic v) {
  if (v == null) return double.nan; // ‏Number(undefined)=NaN
  if (v is bool) return v ? 1.0 : 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return _jsStrToNum(v);
  return double.nan;
}
