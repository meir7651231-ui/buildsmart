// חוט · time-cost-total — עלות-העבודה: סכום (שעות × תעריף) של רשומות-השעתון.
// חוזה: new/atoms/time-cost-total.contract.md · מוצא: maor/src/lib/ayin.ts:109-113.
// המרה מ-JS (new/atoms/time-cost-total.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// אפס-import (רק dart-core). טהור, לא משנה קלט.
//
// הערות-המרה (JS→Dart):
//  · המקור: `(a.time || []).reduce((t, e) => t + (+e.hours || 0) * (e.rate || 0), 0)`.
//  · `+e.hours || 0` — ToNumber-של-JS ואז falsy⇒0 (מחרוזת-מספרית נכפית, זבל⇒0).
//  · `e.rate || 0` — **בלי** unary-plus: falsy⇒0, אחרת הכפל עושה ToNumber
//    (מחרוזת-מספרית⇒ערך · מחרוזת-זבל-truthy⇒NaN המדביק את הסכום — נאמן ל-JS).
//  · **תיקון-הסגר (חוק-18):** הפורט-השבור השתמש ב-num.tryParse(v.trim()) —
//    ‏Dart.trim גוזם רווחי-יוניקוד ש-JS אינו גוזם (NEL U+0085, MVS U+180E) וגם
//    tryProcessing סלחני מ-Number(). התוצאה: '3' פורש ל-3 ב-Dart אך NaN
//    ב-JS. התיקון: שקע ToNumber נאמן-ES — jsTrim (בלי NEL) + דקדוק-ES קפדני
//    **לפני** הפרסינג (הועתק INLINE מ-machtzev/emit/js-compat-reference.dart).

num timeCostTotal(Map a) {
  final time = a['time'];
  if (time is! List) return 0; // ‏time חסר/null/לא-List ⇒ 0 (אין מה לסכם)
  double total = 0;
  for (final e in time) {
    final row = e is Map ? e : const {};
    total += _hoursNum(row['hours']) * _rateNum(row['rate']);
  }
  return total;
}

// שקע `+v || 0` של JS: ToNumber ואז falsy(0/NaN)⇒0.
double _hoursNum(Object? v) {
  final n = _jsNum(v);
  return (n == 0 || n.isNaN) ? 0 : n;
}

// שקע `v || 0` + ‏ToNumber-של-הכפל: falsy ⇒ 0; truthy ⇒ ToNumber (זבל⇒NaN).
double _rateNum(Object? v) => _jsTruthy(v) ? _jsNum(v) : 0;

// ── עוזרי js-compat (INLINE · חוק-1: אטום לא-מייבא) ──────────────────────────

/// חוק-7 · truthiness של JS: ''/0/-0/NaN/null/false כוזבים; השאר אמת.
bool _jsTruthy(dynamic v) {
  if (v == null || v == false) return false;
  if (v == true) return true;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true; // אובייקט/מערך — תמיד אמת
}

/// חוק-16 · קבוצת-הרווחים של ECMAScript. **בלי** U+0085/U+180E.
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
