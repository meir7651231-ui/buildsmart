// ⚛️ אטום-Dart (דרגת-חוזה) · ayinActive — האם תיק-העין (מעקב-טיפול) "פעיל".
// מוצא: המקור new/atoms/ayin-active.mjs (`export function ayinActive(a)`), חולץ
//        אוטומטית באפיון-Golden. חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). אין locale/פורמט/getMonth.
//
// תפקיד: תיק פעיל אם השלב אינו 'new', או שכבר יש שם, מגע-אחרון, תשובה, או שורת-לוג.
// שקע (חוק-1): אין — עצמאי מוחלט.
// קלט: a — אובייקט התיק {stage, names[], lastTouch, answers[], log[]}; פלט: bool.
//
// הערת-המרה (מקור→Dart):
//  • `if (!a) return false` — `!` של JS = truthiness לתחום; מומש ב-`_truthy` (null/
//    undefined/''/0/NaN/false ⇒ false). מחרוזת-ריקה נופלת ל-false בדיוק כמו במקור.
//  • `a.stage !== 'new'` — השוואת-זהות; קריאת-שדה על ערך-שאינו-Map (למשל String
//    שנזרק בגולדן) ⇒ undefined ב-JS = null ב-Dart, ו-`null != 'new'` ⇒ true, בדיוק
//    כמו `undefined !== 'new'`. מקוצר-הערכה (||) שומר שהזנב לא נקרא — כמו במקור.
//  • `!!a.lastTouch` → `_truthy(...)`; `a.X.length > 0` → `_len(...) > 0`.
//  • מפתח-חסר ב-Map ⇒ null (מקביל ל-undefined); `_len(null)` = 0 (השרשרת מקוצרת
//    לפני-כן בכל הקלטות-הגולדן, כך שאין נגיעה בהתנהגות הנבדקת).

bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  return true;
}

dynamic _prop(dynamic a, String key) => a is Map ? a[key] : null;

int _len(dynamic v) {
  if (v is List) return v.length;
  if (v is String) return v.length;
  return 0;
}

/// Returns whether the care-tracking ("eye") case is active. Verbatim behaviour of
/// the JS source `ayinActive`: falsy input ⇒ false; otherwise true when the stage
/// is not 'new', or any of names / lastTouch / answers / log carry content.
bool ayinActive(dynamic a) {
  if (!_truthy(a)) return false;
  return (_prop(a, 'stage') != 'new') ||
      (_len(_prop(a, 'names')) > 0) ||
      _truthy(_prop(a, 'lastTouch')) ||
      (_len(_prop(a, 'answers')) > 0) ||
      (_len(_prop(a, 'log')) > 0);
}
