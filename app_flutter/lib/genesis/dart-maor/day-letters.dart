// ⚛️ אטום-Dart (דרגת-חוזה) · dayLetters — אותיות ימי-הפעילות בעברית (0=ראשון … 5=שישי).
// מוצא: maor/src/components/courses/lib.ts:81 (DAY_LETTERS) · המקור: new/atoms/day-letters.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: קבוע = ערך בלבד (חוק-5): המערך לא יודע איפה/מתי משתמשים בו. שש אותיות
//        עבריות, כל אחת אות + גרש-עברי U+05F3 (׳), אינדקס 0=ראשון … 5=שישי.
//        אין אות לשבת (אין פעילות בשבת) — המערך בן 6 בדיוק.
// קלט: אין (קבוע). פלט: List<String> בן 6 מחרוזות.
//
// הערת-המרה (מקור→Dart): המקור הוא literal-מערך טהור — אין locale/פורמט/getMonth/
// truthiness/מוטביליות. המרה ישירה של ה-literal ל-List<String>. התו השני בכל איבר
// הוא גרש-עברי U+05F3 (׳) — לא apostrophe U+0027 — נשמר ביט-אחר-ביט מהמקור.

/// The activity-day letters in Hebrew (index 0=Sunday … 5=Friday; no Saturday).
/// Verbatim port of new/atoms/day-letters.mjs (`DAY_LETTERS`). Value only, no
/// context knowledge (חוק-5). Each item is a Hebrew letter + geresh U+05F3 (׳).
List<String> dayLetters({required String Function(String) term}) {
  return [term('a'), term('b'), term('g'), term('d'), term('h'), term('v')];
}
