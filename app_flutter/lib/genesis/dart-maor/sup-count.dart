// ⚛️ אטום-Dart (דרגת-חוזה) · supCount — מספר-תרומות כולל היסטוריה (הכרעת-בעלים 9.8 "לכולל", ‎#14).
// מוצא: maor/src/components/supporters/lib.ts:118-122 · המקור: new/atoms/sup-count.mjs.
// חוזה: new/atoms/sup-count.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). טהור, אפס שקעים (אין לוח-עברי/Intl).
// המקור (שורה אחת):
//   (sp.count || 0) + (sp.hist ?? []).filter((h) => (h.a || 0) > 0).length
//
// 🔧 תיקון-הסגר (חוק-17): ה-`+` של JS הוא תמיד float64. הטיוטה חיברה `num`
//    (int+int=int64 מדויק) ⇒ בטווח 2^53±ε ‏Dart מחזיר …995 (int64) בעוד V8
//    מעגל-double בכל צעד ⇒ …996. התיקון: `.toDouble()` בענף-המספרי של `_jsAdd`
//    (זהה ל-`jsAddNum`/`jsNum` בספריית-התאימות — שם התוצאה תמיד double).
//
// הערות-המרה (מקור→Dart):
//  • `sp.count || 0` ו-`h.a || 0` — `||` של JS נופל ל-0 על 0/NaN/''/false, לא רק
//    null/undefined ⇒ `_jsTruthy` (חוק-7).
//  • גישת-שדה: מפתח-חסר ⇒ undefined ⇒ סנטינל `_undef` דרך `_prop` (חוק-2).
//  • `(h.a || 0) > 0` — האגף-השמאלי עובר ToNumber (`_jsToNumber`); NaN > 0 ⇒ false.
//  • `count + positives` = ה-`+` של JS: count מחרוזת ⇒ שרשור — `_jsAdd`.
//  • `sp.hist ?? []` — `??` תופס null וגם undefined; hist שאינו מערך ⇒ זריקה כמו-JS.

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

/// אמת-JS (`||`): undefined/null=false · bool=עצמו · num=לא-0-ולא-NaN · String=לא-ריק · אחר=true.
bool _jsTruthy(Object? v) {
  if (identical(v, _undef) || v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// קבוצת-הרווחים של ECMAScript ל-trim של ToNumber (חוק-16: בלי U+0085/U+180E).
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
/// מחרוזת→trim-ES ואז: ריק→0, hex/octal/binary-ליטרל, Infinity, אחרת פרסור-עשרוני או NaN.
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
    return num.tryParse(t) ?? double.nan; // חוק-10: אף-פעם לא parse-שזורק
  }
  return double.nan; // אובייקט/מערך — מחוץ-לתחום-החוזה (ToPrimitive מלא לא-נדרש)
}

/// String(v) בהקשר-שרשור של JS (חוק-12: שלם-בטוח ⇒ עשרוני, לא פריסת-double).
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
      return d.toInt().toString(); // שלם-בטוח (|v|<2^53) ⇒ עשרוני בלי ".0"
    }
    return d.toString();
  }
  return v.toString();
}

/// ה-`+` של JS: אחד-האגפים מחרוזת ⇒ שרשור-מחרוזות; אחרת חיבור-float64 (חוק-17).
dynamic _jsAdd(Object? a, Object? b) {
  if (a is String || b is String) return _jsStr(a) + _jsStr(b);
  return _jsToNumber(a).toDouble() + _jsToNumber(b).toDouble();
}

/// מספר-התרומות הכולל של תורם — המונה-השמור count (קבלות) + מספר שורות-ה-hist
/// החיוביות בלבד (‎(h.a||0)>0‎ — זיכוי/אפס/שורה-בלי-a לא נספרים ולא מנפחים את
/// ציון-ה-RFM). פורט מילולי של new/atoms/sup-count.mjs (`supCount`) —
/// נגזרת טהורה, אפס שקעים.
dynamic supCount(dynamic sp) {
  final countRaw = _prop(sp, 'count');
  final Object? count = _jsTruthy(countRaw) ? countRaw : 0; // (sp.count || 0)
  final histRaw = _prop(sp, 'hist');
  final Object? hist =
      (identical(histRaw, _undef) || histRaw == null) ? const [] : histRaw; // ?? []
  if (hist is! List) {
    // ב-JS: .filter על לא-מערך ⇒ TypeError. מחוץ-לתחום-החוזה — משתקף כזריקה.
    throw ArgumentError('sp.hist is not an array');
  }
  var positives = 0;
  for (final h in hist) {
    final aRaw = _prop(h, 'a');
    final Object? a = _jsTruthy(aRaw) ? aRaw : 0; // (h.a || 0)
    if (_jsToNumber(a) > 0) positives++; // NaN > 0 ⇒ false, כמו-JS
  }
  return _jsAdd(count, positives); // (count||0) + filter(...).length
}
