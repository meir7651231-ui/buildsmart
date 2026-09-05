// ⚛️ אטום-Dart (דרגת-חוזה) · rulePrefix — כלל-ניקוד: קידומת
// מוצא: maor/src/lib/search.ts (פורק מ-scoreTerm — הכרעת-בעלים 'המשמעות בקופסה').
//        המקור: new/atoms/rule-prefix.mjs —
//        `const rulePrefix = (nq, nt) => (nt.startsWith(nq) ? 80 : null);`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: כלל-ניקוד בודד: המונח מתחיל בשאילתה ⇒ 80, אחרת null.
//        טיפש במכוון — לא יודע מתי מפעילים אותו ולא מה קודם למה (הסדר = חיווט-של-קופסה).
// קלט:  nq — שאילתה מנורמלת (String) · nt — מונח מנורמל (String).
// פלט:  80 (int) אם הכלל תופס, אחרת null.
//
// הערת-המרה (מקור→Dart): `String.startsWith` ב-Dart שקול ל-`String.prototype.startsWith`
// של JS על מחרוזות רגילות, כולל הקצה של שאילתה-ריקה (''.startsWith ⇒ true בשתי השפות)
// ומחרוזת-זהה (nt==nq ⇒ true). השוואה על יחידות-UTF-16 בשתיהן — זהה-ביט גם לעברית.
// אין locale/truthiness/מספרים מעורבים — ללא שקעים.

/// Single scoring rule: the term starts with the query. Returns 80 when the
/// rule fires, null otherwise. Verbatim behaviour of the JS source
/// new/atoms/rule-prefix.mjs.
int? rulePrefix(String nq, String nt) => nt.startsWith(nq) ? 80 : null;
