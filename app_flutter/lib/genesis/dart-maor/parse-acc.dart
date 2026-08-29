// ⚛️ אטום-Dart (דרגת-חוזה) · parseAcc — פענוח JSON העדפות-נגישות.
// מוצא: maor/src/lib/a11y.ts:49-59 (parseAcc); המקור new/atoms/parse-acc.mjs.
//        חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש, לא-משופר).
// טוהר: פונקציית top-level עצמאית; ייבוא-סטנדרט בלבד (dart:convert ל-jsonDecode, שקול
//        JSON.parse). אין שכן/שקע-הקשר.
//
// תפקיד: פענוח מחרוזת-JSON של העדפות-נגישות ל-4 דגלים בוליאניים
//        {contrast, noanim, links, spacing}. קלט פגום/חלקי/ריק מתקבל בשקט
//        כברירות-מחדל (הכול false) — לעולם לא נזרקת שגיאה. ערכים לא-בוליאניים
//        נכפים ל-truthy (‏!! של JS).
// קלט:  raw — מחרוזת JSON או null/ריק (dynamic; String או null).
// פלט:  Map<String,bool> {contrast, noanim, links, spacing}, בסדר-המקור.
//
// הערות-המרה (מקור→Dart), לפי machtzev/emit/DART-PORTING-RULES.md:
//  • truthiness (כלל 7): `!raw` של JS ⇒ falsy למחרוזת = null או ''. Dart מפורש:
//    `raw == null || raw == ''`. `!!a?.field` ⇒ שקע-truthy `_truthy` (JS: false/0/
//    NaN/''/null/undefined ⇒ false, אחרת true) — לא `!x` של Dart.
//  • null מול undefined (כלל 2): `JSON.parse('null')` ⇒ null; `a?.field` על null ⇒
//    undefined ⇒ falsy. ב-Dart `_field(null,…)` מחזיר null ⇒ `_truthy(null)==false`.
//    גם קלט לא-אובייקט (jsonDecode('5')=5): `a?.field`⇒undefined ⇒ false — `_field`
//    מאנדקס רק כשהוא Map, אחרת null.
//  • JSON.parse זורק על JSON פגום ⇒ Dart `jsonDecode` זורק FormatException; ה-catch
//    בולע ומחזיר off — זהה למקור.
//  • מוטביליות: off נבנה-מחדש בכל קריאה (במסלול-ההצלחה מוחזר map חדש) ⇒ אין
//    שיתוף-הפניה בין קריאות.
//
// ייבוא: dart:convert בלבד (jsonDecode ≡ JSON.parse; כמו 12 אטומי-אחים הזקוקים
//        לפענוח-JSON) — סטנדרט-שפה, לא אטום-שכן.

import 'dart:convert';

/// JS-truthiness of a decoded JSON value (matches `!!v`): everything is truthy
/// except false, numeric 0, NaN, the empty string, and null/undefined.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// Optional-chained field read (`a?.field`): index only when `a` is a JSON
/// object, else undefined — mirrored here as null (which `_truthy` reads false).
dynamic _field(dynamic a, String k) => a is Map ? a[k] : null;

/// Parse a JSON string of accessibility preferences into four boolean flags.
/// Empty, null, or malformed input yields all-false silently — never throws.
/// Verbatim behaviour of the JS source new/atoms/parse-acc.mjs.
Map<String, bool> parseAcc(dynamic raw) {
  Map<String, bool> off() =>
      {'contrast': false, 'noanim': false, 'links': false, 'spacing': false};
  if (raw == null || raw == '') return off();
  try {
    final a = jsonDecode(raw as String);
    return {
      'contrast': _truthy(_field(a, 'contrast')),
      'noanim': _truthy(_field(a, 'noanim')),
      'links': _truthy(_field(a, 'links')),
      'spacing': _truthy(_field(a, 'spacing')),
    };
  } catch (_) {
    return off();
  }
}
