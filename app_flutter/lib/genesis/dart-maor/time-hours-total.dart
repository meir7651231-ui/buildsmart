// חוט · time-hours-total — סה"כ שעות בשעתון: סכום `hours` על רשומות `a.time`.
// חוזה: new/atoms/time-hours-total.contract.md · מוצא: maor/src/lib/ayin.ts:104-106.
// המרה מ-JS (new/atoms/time-hours-total.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// אפס-import (רק dart-core; חוק-1: העוזר מוזרק INLINE עם קידומת _). טהור, לא משנה קלט.
//
// תיקון-הסגר (חוק-18 · FIXES.md): הפורט הקודם השתמש ב-`num.tryParse` שגוזם רווחי-
// יוניקוד (למשל NEL U+0085) לפני הפרסינג — כך `'4'` היה מוחזר 4, אך JS
// ‏`+'4'` = NaN ⇒ `||0` ⇒ 0. התיקון: שקע-מספר נאמן-ES (_jsStrToNum) שבודק
// דקדוק-ES קפדני לפני tryParse, מ-js-compat-reference.dart המאומת.
//
// המקור: `(a.time || []).reduce((t, e) => t + (+e.hours || 0), 0)`.
//  · `a.time || []` — time חסר/null/לא-List ⇒ 0 (אין מה לסכם).
//  · `+e.hours || 0` — כפיית-מספר של JS, ואז `||0` הופך falsy (NaN/0/-0) ל-0.
num timeHoursTotal(Map a) {
  final time = a['time'];
  if (time is! List) return 0;
  num total = 0;
  for (final e in time) {
    final row = e is Map ? e : const {};
    total += _num(row['hours']);
  }
  return total;
}

// שקע-כפיית-מספר: מחקה את `+v || 0` של JS. כל falsy (NaN/0/-0) ⇒ 0.
num _num(Object? v) {
  final d = _coerce(v);
  if (d == 0 || d.isNaN) return 0;
  return d;
}

// חוק-10/17 · ToNumber כללי במרחב-double של JS.
double _coerce(Object? v) {
  if (v == null) return double.nan; // +undefined/מפתח-חסר ⇒ NaN (ואז ||0 ⇒ 0)
  if (v is bool) return v ? 1.0 : 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return _jsStrToNum(v);
  return double.nan;
}

// חוקים 10+18 · ToNumber של JS על מחרוזת, עם דקדוק-ES קפדני לפני הפרסינג
// (‏Dart tryParse גוזם רווחי-יוניקוד בעצמו — עוקף כל trim; לכן בודקים דקדוק).
double _jsStrToNum(String raw) {
  final s = _jsTrim(raw);
  if (s.isEmpty) return 0.0; // Number('') === 0
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

// חוק-16 · קבוצת-הרווחים של ECMAScript ל-trim (בלי U+0085/U+180E).
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
