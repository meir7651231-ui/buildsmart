// ⚛️ אטום-Dart (דרגת-חוזה) · colRefToIndex — הפניית-תא xlsx לאינדקס-עמודה 0-בסיס
// מוצא: maor/src/lib/xlsx.ts:26-32 ("AB4" → 27). המקור-הנקי: new/atoms/col-ref-to-index.mjs
//        (חוק-4 — התנהגות זהה-לחלוטין למקור-ה-JS, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: אינדקס-עמודה 0-בסיס מבסיס-26 אלפביתי (A=0 … Z=25, AA=26 …) מתוך הפניית-תא.
//        הפנייה שאין בראשה אותיות-גדולות ⇒ 0 (נפילה-רכה).
// קלט:  ref — הפניית-תא כמו "AB4"; רק האותיות-הגדולות שבראשה נקראות (String).
// פלט:  מספר-שלם ≥ 0 (int).
//
// הערת-המרה (מקור→Dart):
//  • המנוע לא ייצר טיוטה — הומר ידנית מהמקור-הנקי.
//  • JS `/^([A-Z]+)/.exec(ref)` → Dart `RegExp(r'^([A-Z]+)').firstMatch(ref)`; null ⇒ 0.
//  • JS `charCodeAt(0)` → Dart `codeUnitAt(0)` (שניהם UTF-16 code unit; A=65 ⇒ 65−64=1).
//  • מוטביליות: n משתנה בלולאה ⇒ `var`. אין locale/פורמט/getMonth מעורבים.

/// 0-based column index from an xlsx cell ref (base-26 alphabetic: A=0 … Z=25,
/// AA=26 …). No leading uppercase letters ⇒ 0. Verbatim behaviour of the JS
/// source new/atoms/col-ref-to-index.mjs.
int colRefToIndex(String ref) {
  final m = RegExp(r'^([A-Z]+)').firstMatch(ref);
  if (m == null) return 0;
  var n = 0;
  for (final ch in m.group(1)!.codeUnits) {
    n = n * 26 + (ch - 64);
  }
  return n - 1;
}
