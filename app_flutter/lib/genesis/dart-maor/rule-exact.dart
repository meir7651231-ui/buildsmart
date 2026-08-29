// ⚛️ אטום-Dart (דרגת-חוזה) · ruleExact — כלל-ניקוד: התאמה מוחלטת
// מוצא: maor/src/lib/search.ts (scoreTerm; פורק — הכרעת-בעלים 'המשמעות בקופסה').
//        המקור: new/atoms/rule-exact.mjs —
//        `export const ruleExact = (nq, nt) => (nt === nq ? 100 : null);`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: כלל-ניקוד בודד וטיפש-במכוון — התאמה מוחלטת בין שאילתה למונח *מנורמלים*.
//        לא יודע מתי מפעילים אותו ולא מה קודם למה — הסדר הוא חיווט-של-קופסה.
// קלט:  nq — שאילתה מנורמלת · nt — מונח מנורמל (במקור: מחרוזות).
// פלט:  100 (int) אם הכלל תופס (nt שווה ל-nq), אחרת null.
//
// הערת-המרה (מקור→Dart): ה-JS משווה עם `===` (זהות-ערך על מחרוזות, בלי-כפייה-של-טיפוס);
// ב-Dart `==` על String הוא השוואת-ערך ⇒ שקול ביט-אחר-ביט על תחום-הקלט של החוזה.
// אין locale/לוח-עברי/truthiness/מוטציה — אין צורך בשקעים (חוק-11 לא-רלוונטי).

/// Single scoring rule: exact match. Returns 100 when the normalised term
/// equals the normalised query, otherwise null. Verbatim behaviour of the
/// JS source new/atoms/rule-exact.mjs.
dynamic ruleExact(dynamic nq, dynamic nt) => (nt == nq ? 100 : null);
