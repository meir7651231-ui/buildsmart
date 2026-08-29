// ⚛️ אטום-Dart (דרגת-חוזה) · phoneRegion — סיווג-אזור של מספר-טלפון (il/intl).
// מוצא: maor/src/components/supporters/lib.ts:261-283 (phoneRegion; חוק-4 — התנהגות
//        זהה למקור-ה-JS, לא-משופרת). המקור: new/atoms/phone-region.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). אין שכן ⇒
//        אין שקע (חוק-1). קלט מחרוזת ⇒ פלט 'il' | 'intl'.
//
// תפקיד: מספר שמתחיל 972/‏+972/‏00972 = ישראלי (il); ‏+... או 00... אחר = בינלאומי
//        (intl); ‏0+9/10 ספרות = ישראלי; ‏5+8 ספרות (נייד בלי-0-מוביל) = ישראלי; אחרת intl.
//        ריק/‏null = il (ברירת-מחדל מקומית).
// קלט:  raw — מחרוזת-קלט (String?; ‏null מותר, מחקה `raw || ''` של JS).
// פלט:  'il' או 'intl', String.
//
// הערות-המרה (מקור→Dart) — כללי DART-PORTING-RULES שהוחלו:
//  • `.replace(/…/g, '')` הוא **גלובלי** ⇒ `replaceAll` (לא replaceFirst! הטיוטה טעתה —
//    replaceFirst היה משאיר תווי-פורמט מרובים ומזייף את הסיווג).
//  • `.test(s)` של JS ⇒ `RegExp(…).hasMatch(s)` ב-Dart.
//  • `!s` (truthiness, כלל-7) — עבור מחרוזת, falsy רק כשהיא ריקה ⇒ `s.isEmpty`.
//  • `raw || ''` (כלל-7) — String falsy רק ל-''/null ⇒ `raw ?? ''` שקול (‏''→'' זהה).
//  • `\d`/`\D` ב-Dart-RegExp = ‏[0-9]/‏[^0-9] ללא-דגל-unicode, זהה ל-JS ללא-דגל-u.
//  • מוטביליות: `final` לערכים לא-מוקצים-מחדש.

/// Phone-region classifier: `'il'` for Israeli numbers (972 / +972 / 00972
/// prefixes, `0`+9/10 digits, or a `5`+8-digit bare mobile), `'intl'` for other
/// `+`/`00` international numbers, `'il'` for empty/null. Verbatim behaviour of
/// the JS source new/atoms/phone-region.mjs.
String phoneRegion(String? raw) {
  final s = (raw ?? '').replaceAll(RegExp(r'[^\d+]'), '');
  if (s.isEmpty) return 'il';
  if (RegExp(r'^(\+?972|00972)').hasMatch(s)) return 'il';
  if (RegExp(r'^\+').hasMatch(s)) return 'intl';
  if (RegExp(r'^00').hasMatch(s)) return 'intl';
  final d = s.replaceAll(RegExp(r'\D'), '');
  if (RegExp(r'^0\d{8,9}$').hasMatch(d)) return 'il'; // 0 + 9/10 ספרות
  if (RegExp(r'^5\d{8}$').hasMatch(d)) return 'il'; // נייד ישראלי בלי 0 מוביל
  return 'intl';
}
