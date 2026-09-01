// ⚛️ אטום-Dart (דרגת-חוזה) · supHasRegion — האם לתורם טלפון באזור המבוקש.
// מוצא: maor/src/components/supporters/lib.ts:295-297 · המקור: new/atoms/sup-has-region.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import. חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//        השכן allSupPhones הוזרק כשקע-פרמטר (חוק-1/חוק-3: אפס import של אטום-שכן).
//
// תפקיד: `allSupPhones(sp).some((r) => r.region === region)` — true אם לפחות
//        שורת-טלפון אחת עם region שווה למבוקש; אין טלפונים ⇒ false.
//
// הערות-המרה (מקור→Dart):
//  • שורת-טלפון מהשקע = Map ⇒ הגישה `r.region` של JS ממומשת כ-`r['region']`.
//    מפתח-חסר: JS ⇒ undefined, ‏Dart ⇒ null — בשני המקרים ההשוואה מול 'il'/'intl'
//    (תחום-החוזה של region) היא false, כך שאין צורך ב-containsKey (חוק-2 לא נדרש:
//    ההבחנה null↔undefined אינה נצפית כאן — undefined/null לעולם אינם שווים למחרוזת).
//  • `===` של JS על מחרוזות ≡ `==` של Dart (אין קוארציה בשניהם; NaN≠NaN בשניהם).
//  • `.some` ⇒ לולאה עם יציאה-מוקדמת (זהה-סדר, ללא תופעות-לוואי).

/// Does the supporter have at least one phone row in the requested region?
/// Verbatim port of new/atoms/sup-has-region.mjs (`supHasRegion`); the neighbour
/// call `allSupPhones` is injected as a socket: (sp) => List of rows with 'region'.
bool supHasRegion(dynamic sp, dynamic region, dynamic allSupPhones) {
  final rows = allSupPhones(sp) as List;
  for (final r in rows) {
    if ((r as Map)['region'] == region) return true;
  }
  return false;
}
