// ⚛️ אטום-Dart (דרגת-חוזה) · reenrollListText — טקסט-תדפיס קריא לרשימת-הרישום-מחדש.
// מוצא: maor/src/components/courses/reenroll-lib.ts:338-344 · המקור: new/atoms/reenroll-list-text.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). טהור-מלא, בלי שקעים.
//
// תפקיד: שורה-לתלמיד/ה — 'שם · חוג — נוכחות P, חיסורים A · <החלטה>[ ✓נרשם]',
//        המקטעים מחוברים ב-'\n'. rows=[] ⇒ מחרוזת ריקה (join של אפס-איברים).
// קלט:  rows=[{memberName, courseName, summary:{presents, absences}, decision?, renewed?}].
//        פלט: String.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נטה לפספס):
//  • גישת-שדה: המנוע פלט `r.memberName` (גישת-property של JS על object) — לא-חוקי על Map ב-Dart.
//    ⇒ תוקן ל-`r['memberName']`, וה-summary המקונן ל-`(r['summary'] as Map)['presents']`.
//  • truthiness של renewed (כלל-המרה 7): JS `r.renewed ? ...` — undefined/false = falsy.
//    ‏renewed בוליאני/חסר בלבד ⇒ `r['renewed'] == true` מכסה בדיוק: true⇒✓ · false/null(=undefined)⇒''.
//  • decision חסר: Map מחזיר null (=undefined ב-JS) ⇒ אף אחד מהתנאים לא נתפס ⇒ 'טרם הוחלט'. זהה.
//  • join('\n') — `.map(...).join('\n')` של JS; ב-Dart `.map(...).join('\n')` על Iterable, ללא toList
//    (join של Iterable תקין). מספרים ב-interpolation: int 12 ⇒ "12" בדיוק כמו JS.
//  • טהור: אין locale/פורמט/getMonth/מודולו — רק שרשור-מחרוזת ותנאים.

/// A printable reenrollment list — one line per student, joined by '\n'.
/// Verbatim port of new/atoms/reenroll-list-text.mjs (`reenrollListText`).
String reenrollListText(List<Map<String, dynamic>> rows, {required String Function(String) term}) {
  String decWord(dynamic d) => d == 'yes'
      ? term('mmshyk')
      : d == 'no'
          ? term('la-mmshyk')
          : d == 'hold'
              ? term('bhmtnh')
              : term('trm-hvchlt');
  return rows.map((r) {
    final summary = r['summary'] as Map;
    final suffix = r['renewed'] == true ? term('nrshm') : '';
    return '${r['memberName']} · ${r['courseName']}${term('xi_nvkchvt')}${summary['presents']}, '
            '${term('xi_chysvrym')}${summary['absences']} · ${decWord(r['decision'])}' +
        suffix;
  }).join('\n');
}
