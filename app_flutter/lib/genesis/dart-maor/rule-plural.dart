// ⚛️ אטום-Dart (דרגת-חוזה) · rulePlural — כלל-ניקוד: הסרת סיומת-ריבוי
// מוצא: maor/src/lib/search.ts (scoreTerm; הכרעת-בעלים 'המשמעות בקופסה').
//        המקור: new/atoms/rule-plural.mjs —
//        `if (nq.length >= 5 && (nq.endsWith('ימ') || nq.endsWith('ות'))) {`
//        `  const stem = nq.slice(0, -2);`
//        `  if (nt === stem || nt.startsWith(stem)) return 70; } return null;`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: כלל-ניקוד בודד — שאילתה באורך ≥5 שמסתיימת בסיומת-ריבוי (ימ/ות, אחרי
//        נורמליזציה של ם→מ) ⇒ מסירים את הסיומת ומשווים לגזע: המונח שווה-לגזע או
//        מתחיל-בגזע ⇒ 70; אחרת null.
//        טיפש-במכוון: לא יודע מתי מפעילים אותו ולא מה קודם למה — הסדר הוא חיווט-של-קופסה.
// קלט:  nq — שאילתה *מנורמלת* (String) · nt — מונח *מנורמל* (String).
// פלט:  70 (int) אם הכלל תופס, אחרת null.
//
// הערת-המרה (מקור→Dart): ‏`String.length`/`endsWith`/`startsWith` בשתי-השפות פועלים על
// יחידות-UTF-16 — שקולים ביט-אחר-ביט. ‏`slice(0, -2)` הסלחן של JS (כלל-5) מתורגם
// ל-`substring(0, nq.length - 2)` — בטוח כי השער `length >= 5` מבטיח אורך מספיק.
// ‏`nt === stem` מול `==` של Dart על String = השוואת-ערך שקולה; ההשוואה-הכפולה
// (שוויון + startsWith) נשמרת verbatim אף ש-startsWith מכסה שוויון — נאמנות-למקור.
// אין locale / truthiness / מערכים / לוח-עברי — אפס-שקעים.

/// Single scoring rule: plural-suffix stripping — a normalised query of length
/// >= 5 ending in 'ימ' or 'ות' has the suffix removed; if the normalised term
/// equals the stem or starts with it => 70, otherwise null. Verbatim behaviour
/// of the JS source new/atoms/rule-plural.mjs.
int? rulePlural(String nq, String nt, {required String Function(String) term}) {
  if (nq.length >= 5 && (nq.endsWith(term('ym')) || nq.endsWith(term('vt')))) {
    final stem = nq.substring(0, nq.length - 2);
    if (nt == stem || nt.startsWith(stem)) return 70;
  }
  return null;
}
