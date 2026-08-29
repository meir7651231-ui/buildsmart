// ⚛️ אטום-Dart (דרגת-חוזה) · phoneKey — נירמול מספר-טלפון למפתח-זיהוי
// מוצא: maor/src/lib/... (phoneKey; חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/phone-key.mjs —
//          let d = (raw || '').replace(/\D/g, '');
//          if (!d) return '';
//          if (d.startsWith('00')) d = d.slice(2);
//          if (d.startsWith('972')) d = d.slice(3);
//          d = d.replace(/^0+/, '');
//          return d;
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: מסלק כל תו שאינו-ספרה, מפשיט קידומת-חיוג-בינ״ל (00), קידומת-ישראל (972),
//        ואפסים מובילים — ומחזיר מחרוזת-ספרות קנונית לזיהוי המתקשר. ריק/חסר ⇒ ''.
// קלט:  raw — מחרוזת גולמית (טלפון/טקסט חופשי), String? (חסר/null ⇒ '').
// פלט:  מפתח-ספרות מנורמל, String.
//
// הערות-המרה (מקור→Dart — סטיות-מנוע שתוקנו מול הטיוטה):
//   • `/\D/g` הוא global ⇒ replaceAll (הטיוטה השתמשה ב-replaceFirst — הסירה תו-אחד בלבד).
//   • `slice(n)` על String ⇒ substring(n) (הטיוטה השתמשה ב-sublist שהוא של List וזורק).
//   • JS `if (!d)` על מחרוזת ⇒ d.isEmpty (הטיוטה קראה ל-_falsy לא-מוגדר).
//   • `^0+` עוגן-תחילה ⇒ replaceFirst מספיק (מתאים פעם-אחת), שווה-ערך ל-replace הלא-global.
//   מוטביליות: `var d` משתנה כמו `let d`. אין locale/getMonth מעורבים.

/// Canonicalises a raw phone string to a digit key. Strips non-digits, then the
/// international prefix `00`, then the Israel country code `972`, then leading
/// zeros. Empty/null input yields `''`. Verbatim behaviour of the JS source
/// new/atoms/phone-key.mjs.
String phoneKey(String? raw) {
  var d = (raw ?? '').replaceAll(RegExp(r'\D'), '');
  if (d.isEmpty) return '';
  if (d.startsWith('00')) d = d.substring(2);
  if (d.startsWith('972')) d = d.substring(3);
  d = d.replaceFirst(RegExp(r'^0+'), '');
  return d;
}
