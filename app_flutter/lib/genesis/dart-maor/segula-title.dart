// חוט · segula-title — כותרת-תצוגה לתזכורת-סגולה. חוזה: segula-title.contract.md
// המרה מ-JS (new/atoms/segula-title.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// אפס-import (dart-core בלבד; חוק-1 — העוזרים מוזרקים INLINE עם קידומת _).
// מוצא: maor/src/components/supporters/lib.ts:338-342.
//
// סמנטיקת-JS משומרת:
//   r.final ?  ⇒ truthiness של JS (חוק-7): false/0/NaN/''/null-או-undefined ⇒ שקר.
//   name || '' ⇒ אותה truthiness — ריק/undefined ⇒ מחרוזת ריקה (דוגמאות-החוזה 3–4).
//   שרשור + על מספר ⇒ ToString של JS (חוק-12): 1 ⇒ '1' (לא '1.0' של double-Dart);
//     שלם-double בטווח [2^53,1e21) ⇒ עשרוני-מלא בלי ".0" (התיקון — FIXES.md).
//   r = אובייקט {day, final} ⇒ ‏Map ב-Dart; מפתח-חסר = undefined של JS ⇒ 'undefined' (חוק-2).

String segulaTitle(dynamic name, dynamic r, dynamic target, {required String Function(String) term}) {
  final dynamic rFinal = (r is Map && r.containsKey('final')) ? r['final'] : null;
  final dynamic rDay =
      (r is Map) ? (r.containsKey('day') ? r['day'] : _undef) : null;
  return (_truthy(rFinal) ? term('syvm-sgvlh') : term('sgvlh')) +
      ' — ' +
      (_truthy(name) ? _jsStr(name) : '') +
      term('yvm') +
      _jsStr(rDay) +
      '/' +
      _jsStr(target);
}

/// סמן-undefined מקומי (חוק-2): מפתח-חסר ב-Map ≠ null-מפורש.
const Object _undef = #_undefined;

/// עוזר מקומי: truthiness של JS (חוק-7) — false על null/undefined/false/0/NaN/''.
bool _truthy(dynamic v) {
  if (v == null || identical(v, _undef)) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true; // אובייקט/מערך/פונקציה — תמיד אמת ב-JS
}

const double _pow2_53 = 9007199254740992.0; // 2^53

/// עוזר מקומי: ToString של JS לשרשור-+ (חוק-12, טווח-האטום).
/// מפתח-חסר⇒'undefined'; null⇒'null'; מספר⇒shortest-round-trip של V8:
/// שלם-בטוח בלי ".0"; ‏[2^53,1e21) עשרוני-מלא מרופד-אפסים; ‏≥1e21 מעריכי;
/// שבר ⇒ toString הקצר של Dart (זהה-ביט); ‏-0⇒'0'; NaN/±∞ כמו-JS.
String _jsStr(dynamic v) {
  if (identical(v, _undef)) return 'undefined';
  if (v == null) return 'null';
  if (v is num) {
    if (v is int) return v.toString();
    final d = v as double;
    if (d.isNaN) return 'NaN';
    if (d == double.infinity) return 'Infinity';
    if (d == double.negativeInfinity) return '-Infinity';
    if (d == 0) return '0'; // כולל -0.0
    final neg = d < 0;
    final ad = neg ? -d : d;
    String body;
    if (ad == ad.truncateToDouble() && ad < 1e21) {
      // שלם-ערך בטווח [1,1e21): עשרוני-מלא בלי ".0". ל-<2^53 ייצוג-int מדויק;
      // מעל — toStringAsFixed(0) (פריסה-מדויקת, מרופד-אפסים כמו V8).
      body = ad < _pow2_53 ? ad.toInt().toString() : ad.toStringAsFixed(0);
    } else {
      // שבר או ≥1e21 — ה-toString של Dart כבר shortest-round-trip (זהה-V8),
      // כולל כתיב-מדעי ל-≥1e21; ל-שבר אין ".0" מיותר.
      body = ad.toString();
    }
    return neg ? '-' + body : body;
  }
  return '$v';
}
