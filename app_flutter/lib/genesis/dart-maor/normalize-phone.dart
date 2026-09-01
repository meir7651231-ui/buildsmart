// ⚛️ אטום-Dart (דרגת-חוזה) · normalizePhone — נירמול טלפון לזיהוי-כפילויות.
// מוצא: maor/src/lib/validate.ts:19-32 · המקור: new/atoms/normalize-phone.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core RegExp).
// חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). המנוע-האוטומטי לא הפיק טיוטה
//        לאטום זה (dart-from-maor ריק) — פורט ידנית מהמקור.
//
// תפקיד: מסיר רווחים/מקפים/סוגריים/נקודה, ממיר קידומת בינ"ל ישראלית ל-0 מקומי.
// קלט:  מחרוזת גולמית. פלט: מחרוזת מנורמלת.
//
// הערות-המרה (מקור→Dart):
//  • `String(raw || '')` → הפרמטר הוא String; raw ריק נשאר ריק ⇒ שקול ל-raw.
//    (כל קלטי-הזהב מחרוזות; אין null בחוזה-ה-Golden.)
//  • `.replace(/[\s\-().]/g, '')` → `.replaceAll(RegExp(r'[\s\-().]'), '')` —
//    אותה מחלקת-תווים, raw-string שומר את ה-backslash-ים למנוע-ה-RegExp.
//  • `.slice(3)`/`.slice(4)` → `.substring(3)`/`.substring(4)` (אותו אינדקס-התחלה).
//  • מוטביליות: `let s` → `var s` (מוקצה מחדש בשני הענפים).
//  אין locale/פורמט/getMonth מעורבים.

/// Israeli phone normalizer for duplicate-detection keys. Verbatim port of the
/// JS source new/atoms/normalize-phone.mjs (`normalizePhone`): strips
/// whitespace/hyphen/parens/dot, then maps 972 / +972 prefixes to a local 0.
String normalizePhone(String raw) {
  var s = raw.replaceAll(RegExp(r'[\s\-().]'), '');
  if (s.startsWith('972')) s = '0' + s.substring(3);
  if (raw.startsWith('+972')) {
    s = '0' + raw.replaceAll(RegExp(r'[\s\-().]'), '').substring(4);
  }
  return s;
}
