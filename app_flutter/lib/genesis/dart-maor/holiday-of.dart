// ⚛️ אטום-Dart (דרגת-חוזה) · holidayOf — שם החג/הצום בתאריך לועזי נתון, או null.
// מוצא: maor/src/lib/hebrew.ts (holidayOf) · המקור: new/atoms/holiday-of.mjs —
//   כולל תיקוני נחיל-עמוק 13.8 (דחיית-שבת) ודין-נדחה-מלא 19.8.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט ל-JS.
// שקעים (חוק-1): hebParts / scanHebYear / holidays הוזרקו כפרמטרים.
//
// הערות-המרה (מקור→Dart · מה שמנוע-ה-AST פספס / כללי DART-PORTING-RULES):
//   • `d.getDay()` של JS = 0=ראשון..6=שבת; ‏Dart `weekday` = 1=שני..7=ראשון.
//     ⇒ `d.weekday % 7` ממפה נכון (ראשון 7%7=0 · שבת 6 · שני 1 · חמישי 4).
//   • `p.month`/`p.day`/`p.year` — גישת-שדה ב-JS ⇒ ב-Dart גישת-מפתח `p['month']`
//     (השקע מחזיר Map, כמו בבדיקת-ה-JS `{ day, month, year }`).
//   • `scanHebYear(...).has30.has('Kislev')` ⇒ `['has30']` הוא Set, `.has`⇒`.contains`.
//   • `${p.month} ${p.day}` ⇒ `'$month $day'` (day int ⇒ 'Tevet 3', זהה).
//   • `HOLIDAYS[key] ?? null` ⇒ `holidays[key]` (מפתח-חסר ב-Dart Map = null, זהה).
//   • כל ההשוואות הן שוויון-מפורש (===/מספרי) — אין שקע-truthiness (כלל-7).

/// Returns the holiday/fast name on Gregorian date [d], or null.
/// Sockets: [hebParts] (d ⇒ {day,month,year}, month in English 'Tevet'/'Tamuz'/…),
/// [scanHebYear] (year ⇒ {has30: Set of 30-day month names}),
/// [holidays] (map "Month day" ⇒ holiday name).
/// Verbatim behaviour of the JS source `holidayOf`.
String? holidayOf(
  DateTime d,
  Map Function(DateTime d) hebParts,
  Map Function(dynamic year) scanHebYear,
  Map<String, String> holidays,
 {required String Function(String) term}) {
  final p = hebParts(d);
  final month = p['month'];
  final day = p['day'];

  // חנוכה יום ח' (ג' טבת): קיים רק בשנה שכסלו בה חסר (29). מלא ⇒ נגמרה בב' טבת.
  if (month == 'Tevet' && day == 3) {
    final has30 = scanHebYear(p['year'])['has30'] as Set;
    return has30.contains('Kislev') ? null : term('chnvkh');
  }

  final dow = d.weekday % 7; // JS getDay: 0=ראשון .. 6=שבת
  final key = '$month $day';

  // צום שחל בשבת ⇒ null (נדחה ליום ראשון).
  if (dow == 6 && (key == 'Tamuz 17' || key == 'Av 9')) return null;
  if (dow == 0 && month == 'Tamuz' && day == 18) return term('tsvm-yz-btmvz-ndchh');
  if (dow == 0 && month == 'Av' && day == 10) return term('tshah-bab-ndchh');
  // צום גדליה (ג' תשרי) שחל בשבת ⇒ נדחה לד' תשרי.
  if (dow == 6 && key == 'Tishri 3') return null;
  if (dow == 0 && month == 'Tishri' && day == 4) return term('tsvm-gdlyh-ndchh');
  // תענית אסתר (י"ג אדר/אדר-ב') שחלה בשבת ⇒ מוקדמת לחמישי י"א.
  if (dow == 6 && (key == 'Adar 13' || key == 'Adar II 13')) return null;
  if (dow == 4 && day == 11 && (month == 'Adar' || month == 'Adar II')) {
    return term('tanyt-astr-mvkdm');
  }

  return holidays[key];
}
