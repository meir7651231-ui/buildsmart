// חוט · block-reason — סיבת חסימת-יום לתזמון חוגים. חוזה: new/atoms/block-reason.contract.md
// המרה מ-JS (new/atoms/block-reason.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4, המקור קדוש).
// מוצא: maor/src/components/diary/lib.ts:80-112. השכנים hebParts (לוח עברי) ו-holidays
// (מפת-חגים) הוזרקו כשקעים (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
//
// הערות-המרה (מקור→Dart), תיקוני-זנב שהמנוע פספס:
//  • getDay() ב-JS: 0=ראשון … 6=שבת. Dart weekday: 1=שני … 7=ראשון. `weekday % 7`
//    ממפה בדיוק: שני=1 … שבת=6, ראשון=7%7=0 ≡ getDay של JS.
//  • truthiness: ב-JS `if (hol && …)` — hol עשוי להיות undefined; ב-Dart מפורש `hol != null`.
//  • blockingOn: ב-JS ברירת-מחדל true בפרמטר-שני; ב-Dart אופציונלי-חובה-אחרון
//    (`[bool blockingOn = true]`) כדי לשמר את ברירת-המחדל — התנהגות זהה בקריאה מלאה.
//  • השקע hebParts מחזיר record ({day, month, year}) — hp.month/hp.day verbatim מהמקור.

/// חגים שבהם אין פעילות כלל (מוטבע מלוח-החגים המשותף — מקור: diary/lib.ts).

/// Day-block reason for course scheduling. Verbatim behaviour of the JS source
/// new/atoms/block-reason.mjs. Sockets injected (law-1): [hebParts] returns the
/// Hebrew-calendar parts (month as English name), [holidays] maps
/// `'<EnglishMonth> <day>'` to a holiday name. Returns the reason string or null.
String? blockReason(
  DateTime d,
  ({int day, String month, int year}) Function(DateTime d) hebParts,
  Map<String, String> holidays, List<String> FULL_HOLIDAYS, Map<String, dynamic> T, [
  bool blockingOn = true,
]) {
  if (!blockingOn) return null;
  final dow = d.weekday % 7;
  if (dow == 6) return (T['k1'] as String);
  if (dow == 5) return (T['k2'] as String);
  final hp = hebParts(d);
  final hol = holidays['${hp.month} ${hp.day}'];
  if (hol != null && FULL_HOLIDAYS.contains(hol)) return hol;
  // צום תשעה באב נדחה: כשט' באב חל בשבת, הצום נצפה בי' באב (ראשון). ט' באב עצמו
  // נחסם כ'שבת', אך י' באב — הצום בפועל — נחסם כאן כדין הלוח.
  if (dow == 0 && hp.month == 'Av' && hp.day == 10) return (T['k3'] as String);
  if ((hp.month == 'Tishri' && hp.day >= 16 && hp.day <= 21) ||
      (hp.month == 'Nisan' && hp.day >= 16 && hp.day <= 20)) {
    return (T['k6'] as String);
  }
  return null;
}
