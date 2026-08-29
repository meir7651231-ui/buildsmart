// ⚛️ אטום-Dart (דרגת-חוזה) · ruleTypo — כלל-ניקוד: סובלנות שגיאות-כתיב
// מוצא: maor/src/lib/search.ts (scoreTerm; הכרעת-בעלים 'המשמעות בקופסה').
//        המקור: new/atoms/rule-typo.mjs · חוזה: new/atoms/rule-typo.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
// שקע: distance — פונקציית מרחק-עריכה מוזרקת (String,String)⇒num. האטום לא יודע
//        איזה אלגוריתם — זה חיווט-של-קופסה (טיפש-במכוון, כמו בחוזה).
//
// תפקיד: אם השאילתה המנורמלת nq באורך ≥3 ואינה כולה-ספרות, והמרחק d בין nq ל-nt
//        ≤ הסף (2 למונח באורך ≥6, אחרת 1) ⇒ ציון 52−4×d ‏(52/48/44); אחרת null.
// קלט:  nq, nt — שאילתה ומונח *מנורמלים* (String) + שקע distance.
// פלט:  int ‏(52/48/44) כשהכלל תופס, אחרת null.
//
// הערות-המרה (מקור→Dart, חוק-4 — התנהגות זהה-ביט):
// • `/^\d+$/.test(nq)` ⇒ `RegExp(r'^\d+$').hasMatch(nq)` — סמנטיקת ECMAScript זהה
//   ‏(\d=[0-9] בלבד; ^/$ עוגני-מחרוזת-שלמה, בלי multiline; אין דין-newline-סופי כי $
//   ‏ב-JS בלי m אינו תופס לפני \n — זהה ב-Dart). (טיוטת-ה-AST כתבה `.test` — לא קיים ב-Dart.)
// • `.length` — ספירת יחידות-UTF-16 גם ב-JS וגם ב-Dart ⇒ זהה (כולל עברית, BMP).
// • חשבון: d מגיע מהשקע; 52−d*4 על שלמים ⇒ int, ואם השקע יחזיר double —
//   האריתמטיקה הדינמית משמרת את ערך-ה-JS (double ב-JS ממילא).
// • אין מערכים/מיון/מודולו/תאריכים ⇒ כללי 1/3/4/9/10/11 לא-רלוונטיים; אין truthiness
//   ‏(כלל-7) — כל התנאים בוליאניים מפורשים במקור.

/// Typo-tolerance scoring rule. Verbatim behaviour of the JS source
/// new/atoms/rule-typo.mjs: queries shorter than 3 chars or all-digits never
/// match; threshold is 2 for terms of length >= 6, else 1; score is 52 - 4*d.
/// `distance` is the injected edit-distance socket.
dynamic ruleTypo(dynamic nq, dynamic nt, dynamic distance) {
  if (nq.length < 3 || RegExp(r'^\d+$').hasMatch(nq)) return null;
  final max = nt.length >= 6 ? 2 : 1;
  final d = distance(nq, nt);
  return d <= max ? 52 - d * 4 : null;
}
