// ⚛️ אטום-Dart (דרגת-חוזה) · ruleContains — כלל-ניקוד: מכיל
// מוצא: maor/src/lib/search.ts (scoreTerm; הכרעת-בעלים 'המשמעות בקופסה').
//        המקור: new/atoms/rule-contains.mjs —
//        `export const ruleContains = (nq, nt) => (nq.length >= 2 && nt.includes(nq) ? 62 : null);`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: כלל-ניקוד בודד — המונח מכיל את השאילתה (ושאילתה באורך ≥2) ⇒ 62; אחרת null.
//        טיפש-במכוון: לא יודע מתי מפעילים אותו ולא מה קודם למה — הסדר הוא חיווט-של-קופסה.
// קלט:  nq — שאילתה *מנורמלת* (String) · nt — מונח *מנורמל* (String).
// פלט:  62 (int) אם הכלל תופס, אחרת null.
//
// הערת-המרה (מקור→Dart): JS `String.prototype.includes` ו-Dart `String.contains` שניהם
// חיפוש-תת-מחרוזת על יחידות-UTF-16 — שקולים ביט-אחר-ביט. שאילתה-ריקה מסוננת ממילא
// ע"י `length >= 2`, כך שגם קצה-המחרוזת-הריקה (includes('') === true) לא רלוונטי.
// אין locale / truthiness / מערכים / לוח-עברי — אפס-שקעים.

/// Single scoring rule: the normalised term contains the normalised query
/// (query length >= 2) => 62, otherwise null. Verbatim behaviour of the JS
/// source new/atoms/rule-contains.mjs.
int? ruleContains(String nq, String nt) =>
    nq.length >= 2 && nt.contains(nq) ? 62 : null;
