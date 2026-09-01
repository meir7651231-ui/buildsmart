// ⚛️ אטום-Dart (דרגת-חוזה) · duplicateCourse — שכפול-חוג לסמסטר-חדש
// מוצא: maor/src/components/courses/lib.ts:340-343 (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/duplicate-course.mjs · החוזה: duplicate-course.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). אין שכנים ⇒ אין שקעים.
//
// תפקיד: עותק של כל שדות-החוג עם id-חדש ותאריכים-חדשים, והשם מסומן " (עותק)".
//        טהור — לא נוגע במקור (spread ⇒ מפה חדשה); שיבוצים נפרדים מהחוג ⇒ המשוכפל
//        נולד ריק מעצם-המבנה.
//
// הערות-המרה (מקור→Dart):
//  • `{ ...c, id, name, start, end }` — spread ואז דריסת-מפתחות-קיימים: ב-Dart
//    (LinkedHashMap) השמה למפתח-קיים שומרת את מיקומו המקורי, בדיוק כמו object של JS,
//    ולכן id/name/start/end שכבר קיימים ב-c שומרים על מקומם המקורי בסדר-המפתחות.
//  • `c.name + ' (עותק)'` — שרשור-מחרוזת של JS מומר לאינטרפולציה, ששומרת את סמנטיקת
//    ה-`+` (coercion של הצד השני למחרוזת) — string→verbatim, וגם null/מספר יומרו כמו ב-JS.
//  • `dates.start`/`dates.end` ⇒ `dates['start']`/`dates['end']`.
//  • אין locale/פורמט/getMonth/מיון/substring/truthiness מעורבים.

/// Duplicate a course for a new semester: copy every field, assign a new id and
/// new dates, and mark the name with " (עותק)". Pure — the source map is never
/// mutated (verbatim of the JS source new/atoms/duplicate-course.mjs).
Map<String, dynamic> duplicateCourse(
  Map<String, dynamic> c,
  String newId,
  Map<String, dynamic> dates,
 {required String Function(String) term}) {
  return {
    ...c,
    'id': newId,
    'name': '${c['name']}${term('avtk')}',
    'start': dates['start'],
    'end': dates['end'],
  };
}
