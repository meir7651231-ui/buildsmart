// ⚛️ אטום-Dart (דרגת-חוזה) · normPhone — נרמול טלפון למפתח-דדופ.
// מוצא: maor/src/lib/dedup.ts:15-41 · תורגם TS→JS ל-new/atoms/norm-phone.mjs
//        (חוק-4 — התנהגות זהה-ביט למקור-ה-JS, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: מקבל מחרוזת חופשית ומחזיר רק את הספרות, מנורמלות לצורת-טלפון-ישראלית:
//        ספרה-חוזרת-בלבד (אפסים/placeholder) ⇒ ריק; ‏00 בינ"ל מוסר; 972 ⇒ 0;
//        אפסים-מובילים-כפולים מכווצים לאפס-יחיד.
// קלט:  s — מחרוזת חופשית (String?). null/undefined ⇒ נחשב כ-''.
// פלט:  מחרוזת-ספרות מנורמלת, String (יכולה להיות '').
//
// הערות-המרה (מקור→Dart), מול DART-PORTING-RULES:
//   • truthiness (כלל 7): ‏JS `(s || '')` מחזיר '' על null/undefined/''. ‏Dart: `s ?? ''`
//     שקול — הקלט הוא String, ולמחרוזת ריקה '' התוצאה זהה (רק null נבלע).
//   • \D/\d ‏(ASCII): גם ב-JS (בלי דגל u) וגם ב-Dart RegExp הם [0-9] ⇒ הסרת-לא-ספרות זהה.
//   • backreference `^(\d)\1+$`: ‏Dart תומך ב-\1 ⇒ זהה (ספרה בודדת חוזרת ≥2 פעמים).
//   • replace אנקורי `^00`/`^0{2,}`: מומש עם replaceFirst (העוגן ^ ⇒ פעם-אחת בלבד, כמו JS).
//   • slice(3) תחת startsWith('972'): האורך ≥3 מובטח ⇒ substring(3) בטוח (אין substring-שלילי).
//   • אין locale/getMonth/מודולו-שלילי/num.parse/מיון מעורבים.

/// Normalises a free-form string to an Israeli-phone dedup key. Verbatim behaviour
/// of the JS source new/atoms/norm-phone.mjs.
String normPhone(String? s) {
  var d = (s ?? '').replaceAll(RegExp(r'\D'), '');
  if (RegExp(r'^(\d)\1+$').hasMatch(d)) {
    return ''; // מציין-מקום (אפסים/ספרה-חוזרת) — לא טלפון אמיתי
  }
  d = d.replaceFirst(RegExp(r'^00'), ''); // צורה בינ"ל 00972…
  if (d.startsWith('972')) {
    d = '0' + d.substring(3);
  }
  return d.replaceFirst(RegExp(r'^0{2,}'), '0'); // כיווץ אפסים-מובילים-כפולים
}
