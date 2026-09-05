// ⚛️ אטום-Dart (דרגת-חוזה) · shekel — עיטוף סכום-שקלים לתצוגה (₪ + הפרדת-אלפים he-IL).
// מוצא: maor (חוט shekel) · המקור: new/atoms/shekel.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core בלבד).
// חוק-1: אטום לא-מייבא — העוזרים מוזרקים INLINE עם קידומת _ (מ-js-compat-reference).
// חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// המקור (JS):  return '₪' + Math.round(n).toLocaleString('he-IL');
//
// 🩹 תיקון-הסגר (FIXES.md · shekel): `toLocaleString('he-IL')` מזריק סימן-כיווניות
//    U+200E (LRM) לפני מינוס — `shekel(-1)='₪‎-1'`, וגם `-0` ⇒ `₪‎-0` (Math.round
//    של [-0.5,0) מפיק -0). הפורט-השבור עשה `.toString()` ⇒ איבד את הסימן ואת ה--0.
//    התיקון: `_jsHeIlInt` מחקה he-IL (סימן-RTL + מינוס לשלילי-וגם-אפס-שלילי)
//    ו-`_jsRound` משמר -0 (Math.round תקני).

/// עיטוף סכום לתצוגת-שקלים. Verbatim port של new/atoms/shekel.mjs (`shekel`):
/// `'₪' + Math.round(n).toLocaleString('he-IL')` — עם עיגון-Number נאמן-JS,
/// Math.round משמר-±0, וקיבוץ-אלפים he-IL (שלילי/‑0 ⇒ U+200E + '-', NaN ⇒ "₪NaN").
String shekel(Object? n) {
  return '₪' + _jsHeIlInt(_jsRound(_jsNum(n)));
}

// ── עיגון-JS: Math.round(x) = floor(x+0.5), משמר NaN/±∞ ו-±0 ─────────────────
/// אומת מול Node: Math.round(-0.5) === -0 (⇒ `₪‎-0`), Math.round(0.5)===1.
double _jsRound(double x) {
  if (x.isNaN || x.isInfinite) return x;
  if (x == 0) return x; // משמר ±0
  final double r = (x + 0.5).floorToDouble();
  if (r == 0 && x < 0) return -0.0; // JS: [-0.5,0) ⇒ -0
  return r;
}

// ── חוק-6 · jsHeIlInt — מחקה `Math.round(n).toLocaleString('he-IL')` לשלמים ───
/// אומת מול Node: חיובי מקובץ-פסיקים (1,234,567); שלילי **וגם -0** ⇒
/// U+200E (LRM) + '-' + מקובץ (‎-1,000 · ‎-0); אפס-חיובי ⇒ '0'; NaN ⇒ 'NaN'.
String _jsHeIlInt(double n) {
  if (n.isNaN) return 'NaN';
  if (n.isInfinite) return n.isNegative ? '‎-∞' : '∞';
  final bool neg = n < 0 || (n == 0 && n.isNegative);
  final String digits = _absIntDigits(n < 0 ? -n : n); // ספרות-abs מורחבות-מלא
  final StringBuffer buf = StringBuffer();
  final int len = digits.length;
  for (int i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  final String grouped = buf.toString();
  return neg ? '‎-' + grouped : grouped;
}

// ── ספרות-שלם מוחלטות מורחבות-מלא (toLocaleString מרחיב גם ≥1e21) ───────────
// **קריטי:** JS toLocaleString/String() משתמשים ב-shortest-round-trip
// (1.2345678901234568e20 ⇒ "123456789012345680000"), **לא** בפריסת-ה-double
// המדויקת (…683968) של toStringAsFixed. Dart.toString נותן את אותן ספרות
// (shortest), רק בצורת מעריכי/‎.0 — כאן מרחיבים לשלם מלא. אומת מול Node.
String _absIntDigits(double a) {
  final double d = a.abs();
  if (d == 0) return '0';
  if (d < _pow2_53) return d.toInt().toString();
  return _expandIntFromDart(d);
}

String _expandIntFromDart(double ad) {
  String s = ad.toString(); // ad>0, שלם-ערך: "D", "D.0", "D.DDDe+XX"
  int e = 0;
  final int ei = s.indexOf('e');
  if (ei >= 0) {
    e = int.parse(s.substring(ei + 1));
    s = s.substring(0, ei);
  }
  String intp, frac;
  final int di = s.indexOf('.');
  if (di >= 0) {
    intp = s.substring(0, di);
    frac = s.substring(di + 1);
  } else {
    intp = s;
    frac = '';
  }
  if (frac == '0') frac = '';
  final String digits = intp + frac;
  final int pointPos = intp.length + e;
  if (pointPos >= digits.length) return digits + '0' * (pointPos - digits.length);
  return digits.substring(0, pointPos);
}

const int _pow2_53 = 9007199254740992; // 2^53 — גבול השלם-הבטוח של JS

// ── חוק-10/17 · ToNumber כללי (Number(v)) במרחב-double של JS ─────────────────
double _jsNum(Object? v) {
  if (v == null) return 0.0; // Number(null)=0 (JSON null ≡ JS null; אין undefined ב-JSON)
  if (v is bool) return v ? 1.0 : 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return _jsStrToNum(v);
  return double.nan;
}

/// חוקים 10+18 · ToNumber של JS על מחרוזת, עם דקדוק-ES קפדני **לפני** פרסינג.
double _jsStrToNum(String raw) {
  final String s = _jsTrim(raw);
  if (s.isEmpty) return 0.0; // Number('') === 0
  if (s == 'Infinity' || s == '+Infinity') return double.infinity;
  if (s == '-Infinity') return double.negativeInfinity;
  if (RegExp(r'^0[xX][0-9a-fA-F]+$').hasMatch(s)) return _fromRadix(s.substring(2), 16);
  if (RegExp(r'^0[oO][0-7]+$').hasMatch(s)) return _fromRadix(s.substring(2), 8);
  if (RegExp(r'^0[bB][01]+$').hasMatch(s)) return _fromRadix(s.substring(2), 2);
  if (!RegExp(r'^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$').hasMatch(s)) return double.nan;
  return double.tryParse(s) ?? double.nan;
}

double _fromRadix(String digits, int radix) {
  try {
    return BigInt.parse(digits, radix: radix).toDouble();
  } catch (_) {
    return double.nan;
  }
}

// ── חוק-16 · trim נאמן-ES (בלי U+0085/U+180E) ───────────────────────────────
const Set<int> _esWs = {
  0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0xA0, 0x1680,
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007,
  0x2008, 0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000, 0xFEFF,
};

String _jsTrim(String s) {
  int start = 0, end = s.length;
  while (start < end && _esWs.contains(s.codeUnitAt(start))) start++;
  while (end > start && _esWs.contains(s.codeUnitAt(end - 1))) end--;
  return s.substring(start, end);
}
