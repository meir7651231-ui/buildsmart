// ⚛️ אטום-Dart (דרגת-חוזה) · modelMeta — תווית + צבעי מסלול-התמחור של חוג.
// מוצא: maor/src/components/courses/lib.ts:200-206 · המקור: new/atoms/model-meta.mjs.
// טוהר: פונקציה top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-1 —
//        אטום לא-מייבא; העוזרים מוזרקים INLINE עם קידומת _ מ-js-compat-reference.
//        חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: לפי c.model מחזיר {label, bg, c} — תווית עברית + צבע-רקע + צבע-טקסט (hex).
//        punch משבץ את c.size בתווית; כל מודל לא-מוכר/חסר ⇒ ברירת-המחדל 'מנוי חודשי'.
// קלט:  c — Map של חוג (model, ול-punch גם size). פלט: Map {label, bg, c}.
//
// אבחון-ההסגר (FIXES.md · model-meta · כלל-12): העוזר הישן `_jsNum` השתמש ב-
//   `truncate()` ⇒ רוויית-int64 לדאבל שלם ≥2^63. size=1e21 ⇒ JS "1e+21" מול
//   Dart "9223372036854775807"; 1e19 נרווה גם הוא. התיקון: החלפת שרשור-המספר
//   ב-`_jsStr` הנאמן-ל-JS (shortest-round-trip): שלם-בטוח בלי ".0"; טווח
//   [2^53,1e21) עשרוני-מלא בלי truncate; ≥1e21 כתיב-מעריכי; שבר = toString הקצר.
//
// הערות-המרה (מקור→Dart):
//  • גישת-שדה `c.model` ⇒ `c['model']` (הקלט מיוצג כ-Map, כמו אובייקט-JS).
//  • `=== 'punch'` ⇒ `== 'punch'` — רק מחרוזת-זהה עוברת; כל טיפוס אחר נופל
//    לענף-ברירת-המחדל, כמו ב-JS.
//  • חוק-2 (null מול undefined): מפתח `size` חסר ⇒ 'undefined'; null מפורש ⇒
//    'null'. ההבחנה דרך `containsKey`, לא דרך `== null`.

/// Label + pricing-track colors for a course, verbatim port of
/// new/atoms/model-meta.mjs (`modelMeta`). Unknown model ⇒ 'מנוי חודשי'.
Map<String, dynamic> modelMeta(dynamic c) {
  if (c['model'] == 'punch') {
    return {
      'label': 'כרטיסייה · ' + _jsStrField(c, 'size') + ' ניקובים',
      'bg': '#fdf1d4',
      'c': '#9a6414',
    };
  }
  if (c['model'] == 'half_year') {
    return {'label': 'מנוי חצי-שנתי', 'bg': '#e7edf5', 'c': '#3a5a86'};
  }
  if (c['model'] == 'year') {
    return {'label': 'מנוי שנתי', 'bg': '#efe7f3', 'c': '#7c3aed'};
  }
  return {'label': 'מנוי חודשי', 'bg': '#e4f5ea', 'c': '#12803c'};
}

/// JS-style string coercion of `'' + c.<key>` — מבחין חסר (⇒'undefined') מ-null
/// מפורש (⇒'null', חוק-2); מספרים דרך `_jsStr` (חוק-12); bool/מחרוזת כלשונם.
String _jsStrField(dynamic c, String key) {
  final bool present = c is Map ? c.containsKey(key) : false;
  if (!present) return 'undefined';
  final dynamic v = c[key];
  if (v == null) return 'null';
  if (v is num) return _jsStr(v);
  if (v is bool) return v ? 'true' : 'false';
  return v.toString();
}

// ── inlined מ-js-compat-reference.dart (jsStr · חוק-12) — אטום לא-מייבא ──
const double _pow2_53 = 9007199254740992.0;

/// חוק-12 · String(num) של JS = shortest-round-trip. שלם-בטוח ⇒ בלי ".0";
/// טווח [2^53,1e21) ⇒ עשרוני-מלא מרופד-אפסים; ≥1e21 ⇒ מעריכי; שבר ⇒ toString
/// הקצר של Dart (זהה-ביט ל-V8). -0 ⇒ '0'. NaN/∞ כמו-JS.
String _jsStr(num n) {
  if (n is int) return n.toString();
  final d = n as double;
  if (d.isNaN) return 'NaN';
  if (d == double.infinity) return 'Infinity';
  if (d == double.negativeInfinity) return '-Infinity';
  if (d == 0) return '0'; // כולל -0.0
  final neg = d < 0;
  final ad = neg ? -d : d;
  String body;
  if (ad == ad.truncateToDouble() && ad < 1e21) {
    if (ad < _pow2_53) {
      body = ad.toInt().toString();
    } else {
      body = ad.toStringAsFixed(0);
    }
  } else {
    body = ad.toString();
  }
  return neg ? '-' + body : body;
}
