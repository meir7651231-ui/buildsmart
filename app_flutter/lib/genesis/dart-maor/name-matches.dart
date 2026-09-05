// ⚛️ אטום-Dart (דרגת-חוזה) · nameMatches — האם שני שמות "אותו-אדם".
// מוצא: maor/src/lib/plannedMatch.ts:54-70 (nameMatches) · המקור: new/atoms/name-matches.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). השכן normName (נרמול-שם) הוזרק כשקע (חוק-1/חוק-3).
//        ⚠️ המנוע לא הפיק טיוטה (dart-from-maor/ ריק) — פורט ידנית מהמקור.
//
// תפקיד: מנרמל את שני השמות דרך השקע; שווים-בדיוק ⇒ אמת; אחרת חפיפת-מילים (מילים
//        באורך ≥2). דרוש 2-מילים-חופפות (פרטי+משפחה), אלא אם לשני-הצדדים מילה-יחידה
//        ⇒ די באחת. צד ריק (אחרי נרמול) ⇒ שקר.
// קלט:  a, b (מחרוזות-שם) · השקע normName(s) ⇒ מחרוזת. פלט: bool.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • truthiness: `if (!na || !nb)` הוא בדיקת-אמת של JS — מחרוזת-ריקה=falsy. השקע normName
//    מחזיר תמיד String ⇒ הבדיקה היחידה היא ריקוּת ⇒ `na.isEmpty || nb.isEmpty` (לא `== null`;
//    לקח-המרה #7 truthiness / #2 null≠undefined — כאן אין null, רק ריק).
//  • `na === nb` → `na == nb` (השוואת-ערך של מחרוזות; ב-Dart == על String הוא ערכי).
//  • `.split(' ').filter((w)=>w.length>=2)` → `.split(' ').where((w)=>w.length>=2)`. שני-הצדדים
//    כבר לא-ריקים ⇒ split מחזיר לפחות איבר-אחד לא-ריק; אין מקרה-`['']` (נחסם קודם).
//  • `new Set(...)` → `<String>{...}` (Set ליטרלי מה-where). `wa.size===0` → `wa.isEmpty`;
//    `wb.has(w)` → `wb.contains(w)`.
//  • אין locale/פורמט/getMonth/מודולו/תאריך — לוגיקת-מחרוזות טהורה; מקומיים final (מוטביליות).

/// Whether two names denote the same person (for payment matching). Normalises both via the
/// injected `normName` socket, then: exact-equal ⇒ true; else word-overlap (words of length ≥2)
/// needing 2 shared words (given+family) unless both sides are single-word ⇒ 1 suffices.
/// Verbatim port of new/atoms/name-matches.mjs (`nameMatches`); the neighbour `normName` is
/// injected as a socket (Law 1/3).
bool nameMatches(String a, String b, String Function(String) normName) {
  final na = normName(a);
  final nb = normName(b);
  if (na.isEmpty || nb.isEmpty) return false;
  if (na == nb) return true;
  final wa = <String>{...na.split(' ').where((w) => w.length >= 2)};
  final wb = <String>{...nb.split(' ').where((w) => w.length >= 2)};
  if (wa.isEmpty || wb.isEmpty) return false;
  var overlap = 0;
  for (final w in wa) {
    if (wb.contains(w)) overlap++;
  }
  // דורש 2-חופפות (שם-פרטי+משפחה); רק כשלשני-הצדדים שם-יחיד ⇒ די באחת (תואם-מלא).
  final need = wa.length == 1 && wb.length == 1 ? 1 : 2;
  return overlap >= need;
}
