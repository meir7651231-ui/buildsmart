// ⚛️ אטום-Dart (דרגת-חוזה) · supIls — סה"כ ₪ של תומכת כולל היסטוריה (הכרעת-בעלים 9.8 "לכולל").
// מוצא: maor/src/components/supporters/lib.ts:106-110 · המקור: new/atoms/sup-ils.mjs.
// חוזה: new/atoms/sup-ils.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (חוק-1: אטום לא-מייבא — העוזרים
//        מוזרקים INLINE עם קידומת _ מתוך machtzev/emit/js-compat-reference.dart).
// המקור (שורה אחת):
//   (sp.ils || 0) + (sp.hist ?? []).reduce((a, h) => a + (h.c === '$' ? 0 : h.a), 0)
//
// 🔧 תיקון-הסגר (חוק-17 · FIXES.md "sup-ils · sup-count — ה-+ של JS = תמיד float64"):
//   ה-`+` של JS מבוצע תמיד ב-float64. הטיוטה חיברה `num + num` — ב-Dart זה int64
//   מדויק כששני-האגפים int, ונבדל מ-JS ב-2^53±ε (JS מעגל-double בכל צעד …996;
//   Dart int64 מדויק …995). התיקון: `.toDouble()` בענף-המספרי של `_jsAdd`.
//
// הערות-המרה נוספות (נשמרו מהטיוטה — עדיין נכונות):
//  • `sp.ils || 0` = `||` של JS (נופל ל-0 גם על 0/NaN/''/false) ⇒ `_jsTruthy`.
//  • גישת-שדה `h.a`/`h.c`: מפתח-חסר ⇒ undefined (≠null) ⇒ סנטינל `_undef`.
//    `0 + undefined = NaN` אבל `0 + null = 0` — a:null נספר 0, a-חסר ⇒ NaN.
//  • `h.c === '$'` — שוויון-קפדני: רק המחרוזת '$' מחריגה.
//  • `sp.hist ?? []` — null וגם undefined ⇒ []; hist שאינו מערך ⇒ TypeError.

/// סנטינל ל-`undefined` של JS (נבדל מ-null; כלל-המרה 2).
const Object _undef = _Undef();

class _Undef {
  const _Undef();
}

/// גישת-שדה בסגנון JS: מפה עם המפתח ⇒ הערך; מפתח-חסר / לא-Map ⇒ `_undef`.
Object? _prop(Object? o, String k) {
  if (o is Map && o.containsKey(k)) return o[k];
  return _undef;
}

/// חוק-7 · אמת-JS (`||`): undefined/null=false · bool=עצמו · num=לא-0-ולא-NaN · String=לא-ריק.
bool _jsTruthy(Object? v) {
  if (identical(v, _undef) || v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// חוק-16 · קבוצת-הרווחים של ECMAScript ל-trim (בלי U+0085/U+180E).
bool _isEsWhitespace(int c) =>
    c == 0x09 || c == 0x0A || c == 0x0B || c == 0x0C || c == 0x0D ||
    c == 0x20 || c == 0xA0 || c == 0xFEFF ||
    c == 0x1680 || (c >= 0x2000 && c <= 0x200A) ||
    c == 0x2028 || c == 0x2029 || c == 0x202F || c == 0x205F || c == 0x3000;

String _esTrim(String s) {
  var start = 0;
  var end = s.length;
  while (start < end && _isEsWhitespace(s.codeUnitAt(start))) start++;
  while (end > start && _isEsWhitespace(s.codeUnitAt(end - 1))) end--;
  return s.substring(start, end);
}

/// ToNumber של JS: undefined→NaN · null→0 · bool→1/0 · num→עצמו ·
/// מחרוזת→trim-ES ואז: ריק→0, hex/octal/binary, Infinity, אחרת פרסור-עשרוני או NaN.
num _jsToNumber(Object? v) {
  if (identical(v, _undef)) return double.nan;
  if (v == null) return 0;
  if (v is bool) return v ? 1 : 0;
  if (v is num) return v;
  if (v is String) {
    final t = _esTrim(v);
    if (t.isEmpty) return 0;
    if (t == 'Infinity' || t == '+Infinity') return double.infinity;
    if (t == '-Infinity') return double.negativeInfinity;
    if (t.length > 2 && t.codeUnitAt(0) == 0x30) {
      final p = t[1];
      if (p == 'x' || p == 'X') return int.tryParse(t.substring(2), radix: 16) ?? double.nan;
      if (p == 'o' || p == 'O') return int.tryParse(t.substring(2), radix: 8) ?? double.nan;
      if (p == 'b' || p == 'B') return int.tryParse(t.substring(2), radix: 2) ?? double.nan;
    }
    return num.tryParse(t) ?? double.nan;
  }
  return double.nan;
}

/// חוק-12 · String(v) בהקשר-שרשור של JS (שלם-בטוח ⇒ עשרוני, לא פריסת-double).
String _jsStr(Object? v) {
  if (identical(v, _undef)) return 'undefined';
  if (v == null) return 'null';
  if (v is String) return v;
  if (v is bool) return v ? 'true' : 'false';
  if (v is num) {
    if (v is int) return v.toString();
    final d = v.toDouble();
    if (d.isNaN) return 'NaN';
    if (d.isInfinite) return d.isNegative ? '-Infinity' : 'Infinity';
    if (d == d.truncateToDouble() && d.abs() < 9007199254740992.0) {
      return d.toInt().toString();
    }
    return d.toString();
  }
  return v.toString();
}

/// חוק-17 · ה-`+` של JS: אחד-האגפים מחרוזת ⇒ שרשור; אחרת חיבור **float64**
/// (הזרקה מ-`jsAddNum` שבספריית-התאימות — `.toDouble()` מכריח מרחב-double).
dynamic _jsAdd(Object? a, Object? b) {
  if (a is String || b is String) return _jsStr(a) + _jsStr(b);
  return _jsToNumber(a).toDouble() + _jsToNumber(b).toDouble();
}

/// סה"כ ₪ של תומכת כולל היסטוריה — המונה-השמור ils (קבלות-בלבד) + סכימת שורות-hist
/// שאינן דולריות (רק c==='$' מוחרג; c חסר ⇒ נספר כשקלי). פורט מילולי של
/// new/atoms/sup-ils.mjs (`supIls`) — נגזרת טהורה, אפס שקעים.
dynamic supIls(dynamic sp) {
  final ilsRaw = _prop(sp, 'ils');
  final Object? ils = _jsTruthy(ilsRaw) ? ilsRaw : 0; // (sp.ils || 0)
  final histRaw = _prop(sp, 'hist');
  final Object? hist =
      (identical(histRaw, _undef) || histRaw == null) ? const [] : histRaw; // ?? []
  if (hist is! List) {
    // ב-JS: .reduce על לא-מערך ⇒ TypeError. מחוץ-לתחום-החוזה — משתקף כזריקה.
    throw ArgumentError('sp.hist is not an array');
  }
  Object? acc = 0;
  for (final h in hist) {
    final c = _prop(h, 'c');
    final Object? term = (c is String && c == '\$') ? 0 : _prop(h, 'a');
    acc = _jsAdd(acc, term); // a + (h.c === '$' ? 0 : h.a)
  }
  return _jsAdd(ils, acc);
}
