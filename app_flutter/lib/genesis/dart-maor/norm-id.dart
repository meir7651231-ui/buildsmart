// ⚛️ אטום-Dart (דרגת-חוזה) · normId — נרמול מזהה/מפתח-שיוך
// מוצא: maor/src/lib/dedup.ts:272-285 → new/atoms/norm-id.mjs
//        (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: מנרמל מחרוזת לספרות-בלבד ומחזיר אותה רק אם היא מפתח-שיוך אמין
//        (ת"ז / מזהה-חיצוני): ≥5 ספרות, לא-הכול-אפסים, ו-≥4 ספרות-משמעותיות
//        אחרי הסרת אפסים-מובילים (חוסם מציין-מקום מרופד כמו "000000020").
// קלט:  s — מחרוזת כלשהי (String?, ליישור עם `s || ''` של המקור).
// פלט:  String — המחרוזת-הספרתית או '' אם אינה מפתח.
//
// הערות-המרה (מקור→Dart), לפי DART-PORTING-RULES.md:
//   • `(s || '')` — truthiness של JS על String: '' ו-null שניהם falsy ⇒ ''. ב-Dart
//     `s ?? ''` נותן '' ל-null, ומחרוזת-ריקה נשארת ריקה ⇒ שקול-בדיוק (כלל 7).
//   • `!d` (falsy של '') ⇒ `d.isEmpty`.
//   • `.replace(/\D/g,'')` ⇒ `replaceAll` (כל ההתאמות); \D ב-Dart = [^0-9] כמו JS.
//   • `.replace(/^0+/,'')` (בלי g, עוגן-תחילה) ⇒ `replaceFirst`.
//   אין locale/פורמט/getMonth/מודולו/תאריך/substring-שלילי — אטום ספרתי טהור.

/// Normalises `s` to digits-only and returns it only when it is a trustworthy
/// association key (≥5 digits, not all-zeros, ≥4 significant digits after
/// stripping leading zeros); otherwise `''`. Verbatim behaviour of the JS
/// source new/atoms/norm-id.mjs.
String normId(String? s) {
  final d = (s ?? '').replaceAll(RegExp(r'\D'), '');
  if (d.isEmpty || RegExp(r'^0+$').hasMatch(d)) return '';
  if (d.replaceFirst(RegExp(r'^0+'), '').length < 4) return '';
  return d.length >= 5 ? d : '';
}
