// ⚛️ אטום-Dart (דרגת-חוזה) · sheetSummary — סיכום-נוכחות ליום בגיליון.
// מוצא: maor/src/components/courses/lib.ts:396-400 · המקור: new/atoms/sheet-summary.mjs.
// טוהר: פונקציה top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: כמה מרשימת-הגיליון מסומנים-נוכחים בתאריך הנתון (presents כולל את ה-ISO)
//        מול סך-הרשימה. שיבוץ בלי presents נספר לא-נוכח (?? []).
// קלט:  roster — רשימת שיבוצי-הגיליון ({presents?: string[], …}) · dateIso — ISO לועזי.
// פלט:  Map חדש {'present': int, 'total': int} — total = אורך-הרשימה כולה.
//
// הערות-המרה (מקור→Dart):
//  • JS `e.presents ?? []` — גם undefined (מפתח-חסר) וגם null-מפורש נופלים ל-[];
//    ב-Dart `e['presents']` מחזיר null בשני המקרים ⇒ `?? []` שקול-ביט (חוק-2 לא
//    רלוונטי כאן — שני הענפים מתלכדים לאותה תוצאה).
//  • JS `includes` על מחרוזות = השוואה מדויקת (SameValueZero) ⇒ Dart `contains`
//    (השוואת == של String) שקול. אין נירמול-פורמט — '2026-08-4' ≠ '2026-08-04'.
//  • JS `filter(...).length` ⇒ Dart `where(...).length` (ספירה בלבד, אין מערך-ביניים
//    נצפה). `roster.length` — אורך-הרשימה כמות-שהיא.
//  • אין locale/תאריך-מפורסר/truthiness/מודולו — השוואת-מחרוזת וספירה בלבד.

/// Attendance summary for one day: how many roster entries have [dateIso]
/// in their `presents` list, versus the whole roster length.
/// Verbatim port of new/atoms/sheet-summary.mjs (`sheetSummary`).
dynamic sheetSummary(dynamic roster, dynamic dateIso) {
  return {
    'present': (roster as List)
        .where((e) => ((e['presents'] ?? []) as List).contains(dateIso))
        .length,
    'total': roster.length,
  };
}
