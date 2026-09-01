// ⚛️ אטום-Dart (דרגת-חוזה) · holidayAllowed — האם חג רלוונטי לפריט מתנת-חג.
// מוצא: maor/src/components/shop/lib.ts:79-86 · המקור: new/atoms/holiday-allowed.mjs —
//   `return !ri.holidays?.length || ri.holidays.includes(holidayName);`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט ל-JS.
//
// תפקיד: פריט-קטלוג מותר לחג אם אין לו רשימת-חגים (חסרה או ריקה) — כללי לכל חג —
//        או שהחג המבוקש נמצא ברשימה. השוואה מדויקת (רווח-נגרר ⇒ אי-התאמה).
// שקע (חוק-1): ri — אובייקט-הפריט (Map); holidayName — שם-החג (Object?, השוואת-שוויון).
//
// הערת-המרה (מקור→Dart · מה שמנוע-ה-AST פספס):
//   • `ri.holidays` ב-JS = גישת-מפתח ⇒ ב-Dart `ri['holidays']` (לא שדה-אובייקט).
//   • optional-chaining `?.length` — חסר/null ⇒ undefined; `!undefined`===true.
//     ⇒ מדגם רק List-לא-ריקה כ"אמת"; חסר/null/ריק ⇒ !hasList===true (מותר).
//   • `!length` (truthiness של JS, כלל-7) ⇒ תנאי-מפורש `!(is List && isNotEmpty)`.
//   • `.includes` ⇒ `.contains` (זהות-שוויון, כמו === של תוכן-מחרוזת).

/// Returns whether [holidayName] is allowed for catalog item [ri].
/// Allowed when the item has no holidays list (missing or empty — applies to
/// every holiday) OR the list contains the exact [holidayName].
/// Verbatim behaviour of the JS source `holidayAllowed`.
bool holidayAllowed(Map ri, Object? holidayName) {
  final holidays = ri['holidays'];
  final hasList = holidays is List && holidays.isNotEmpty;
  return !hasList || holidays.contains(holidayName);
}
