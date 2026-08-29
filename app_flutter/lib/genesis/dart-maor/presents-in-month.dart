// ⚛️ אטום-Dart (דרגת-חוזה) · presentsInMonth — מונה-נוכחות חודשי.
// מוצא: maor/src/components/courses/lib.ts:47-56 (באג #10) · המקור: new/atoms/presents-in-month.mjs —
//   `(presents ?? []).filter(d => typeof d === 'string' && d.slice(0,7) === todayIso.slice(0,7)).length`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מספר תאריכי-הנוכחות שנופלים בחודש הקלנדרי של todayIso (השוואת קידומת
//        YYYY-MM). ניקוב בלי-תאריך (ערך שאינו מחרוזת) מדולג; presents חסר ⇒ 0.
// קלט: presents (מערך ערכים מעורבים או null) · todayIso (מחרוזת ISO של היום).
// פלט: int ≥ 0.
//
// הערות-המרה (מקור→Dart), לפי DART-PORTING-RULES:
//  • כלל-5 (substring שלילי/גולש): JS `slice(0,7)` סלחן — לא זורק על מחרוזת קצרה
//    מ-7. ‏Dart `substring(0,7)` זורק. ⇒ שקע-slice בטוח `_slice7` שמדמה slice(0,7)
//    (חיתוך עד מינימום(7, אורך)). חל גם על todayIso וגם על כל איבר-מחרוזת.
//  • כלל-2/7 (null≠undefined / truthiness): `presents ?? []` של JS מטפל רק ב-
//    null/undefined; ב-Dart `presents ?? const []` שקול (null יחיד). איבר null
//    ברשימה נתפס ב-`d is String` (null אינו String) — מדולג, לא זורק.
//  • טיפוסים-מעורבים: `typeof d === 'string'` ⇒ `d is String` (מספר-זקיף כמו 7 נופל).

String _slice7(String s) => s.length >= 7 ? s.substring(0, 7) : s;

/// Monthly presence counter. Counts date-strings in `presents` whose YYYY-MM
/// prefix equals that of `todayIso`. Non-string entries are skipped; a null
/// `presents` yields 0. Verbatim behaviour of the JS source `presentsInMonth`.
int presentsInMonth(List<Object?>? presents, String todayIso) {
  final ym = _slice7(todayIso); // YYYY-MM
  var count = 0;
  for (final d in presents ?? const []) {
    if (d is String && _slice7(d) == ym) count++;
  }
  return count;
}
