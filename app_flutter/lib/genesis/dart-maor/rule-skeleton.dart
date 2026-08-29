// ⚛️ אטום-Dart (דרגת-חוזה) · ruleSkeleton — כלל-שלד (הסרת אימות-קריאה י/ו)
// מוצא: maor/src/lib/search.ts (פורק מ-scoreTerm — הכרעת-בעלים 'המשמעות בקופסה').
//        המקור: new/atoms/rule-skeleton.mjs —
//        `if (nq.length < 3 || /^\d+$/.test(nq)) return null;
//         const sq = nq.replace(/[יו]/g, ''), st = nt.replace(/[יו]/g, '');
//         return sq.length >= 2 && sq === st ? 58 : null;`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: כלל-ניקוד בודד: שוויון אחרי הסרת אימות-הקריאה י/ו משני הצדדים
//        (שאילתה ≥3 תווים, לא כולה-ספרות, שלד ≥2). "טיפש במכוון" — הסדר
//        והמפעיל הם חיווט-של-קופסה.
// קלט:  nq — שאילתה מנורמלת (String) · nt — מונח מנורמל (String).
// פלט:  58 (int) אם הכלל תופס, אחרת null.
//
// הערות-המרה (מקור→Dart, חוק-4):
// • `/^\d+$/` ב-JS (בלי דגל-u) תופס רק ספרות-ASCII ‏[0-9]; RegExp של Dart —
//   אותה סמנטיקה (ECMAScript, בלי unicode) ⇒ שקול ביט-אחר-ביט.
// • `replace(/[יו]/g,'')` = החלפה-גלובלית ⇒ `replaceAll` (לא replaceFirst —
//   הבאג שבטיוטת-ה-AST).
// • `.length` בשתי השפות = יחידות-UTF-16 ⇒ שקול.
// • `===` על מחרוזות ⇒ `==` של Dart (השוואת-ערך) — שקול.
// אין locale/לוח-עברי/תאריכים ⇒ אין שקעים (חוק-11 לא נדרש).

final RegExp _allDigits = RegExp(r'^\d+$');
final RegExp _yudVav = RegExp(r'[יו]');

/// Single scoring rule: equality after stripping the matres lectionis י/ו from
/// both sides (query length >= 3, not all-digits, skeleton length >= 2).
/// Returns 58 when the rule fires, otherwise null. Verbatim behaviour of the
/// JS source new/atoms/rule-skeleton.mjs.
dynamic ruleSkeleton(dynamic nq, dynamic nt) {
  if ((nq.length as int) < 3 || _allDigits.hasMatch(nq as String)) return null;
  final sq = nq.replaceAll(_yudVav, '');
  final st = (nt as String).replaceAll(_yudVav, '');
  return sq.length >= 2 && sq == st ? 58 : null;
}
