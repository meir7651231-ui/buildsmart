// חוט · gem-year — שנה עברית⇒גימטריה מקוצרת (mod 1000). חוזה: gem-year.contract.md
// המרה מ-JS (new/atoms/gem-year.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// השכן gem (חוט gematria) מוזרק כשקע (חוק-1 — אפס import פנימי, dart-core בלבד).
//
// תיקון-הסגר (אימות-עוין, FIXES.md):
//  • JS `+y` = ToNumber → מומש כ-_jsNum המוזרק (num.parse זורק על ''/'עברית';
//    JS מחזיר 0/NaN — אין זריקה).
//  • JS `%` = remainder (סימן-המונה): `-5 % 1000 === -5` ב-JS, מול 995 ב-modulo של Dart.

String gemYear(Object? y, String Function(num) gem) {
  // JS: gem(+y % 1000) — unary-plus מקדים ל-%: ((ToNumber y) remainder 1000).
  final num n = _jsNum(y).remainder(1000);
  return gem(n);
}

// ── שקע-תאימות מוזרק INLINE (העתק מ-machtzev/emit/js-compat-reference.dart, קידומת _) ──

/// חוק-10/17 · ToNumber כללי (כל טיפוס), במרחב-double של JS.
double _jsNum(dynamic v) {
  if (v == null) return double.nan; // Number(undefined)=NaN — null≡undefined בהקשר-מספר
  if (v is bool) return v ? 1.0 : 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return _jsStrToNum(v);
  return double.nan;
}

/// חוקים 10+18 · ToNumber של JS על מחרוזת (Number(str)); NaN על קלט-רע — לא זריקה.
double _jsStrToNum(String raw) {
  final s = _jsTrim(raw);
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

/// חוק-16 · קבוצת-הרווחים של ECMAScript (trim).
const Set<int> _esWs = {
  0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0xA0, 0x1680,
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007,
  0x2008, 0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000, 0xFEFF,
};

String _jsTrim(String s) {
  var start = 0, end = s.length;
  while (start < end && _esWs.contains(s.codeUnitAt(start))) start++;
  while (end > start && _esWs.contains(s.codeUnitAt(end - 1))) end--;
  return s.substring(start, end);
}
