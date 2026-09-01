// ⚛️ אטום-Dart (דרגת-חוזה) · couponExpiry
// מוצא: maor · new/atoms/coupon-expiry.mjs (חוק-4 — התנהגות זהה-לחלוטין למקור-ה-JS, לא-משופרת).
//        המקור: maor/src/components/shop/lib.ts:221-227 (תוקף קופונים, SHOP2).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). השכן isoOf מוזרק כשקע
//        (חוק-3 — חוט לא מייבא שכן; קריאה-לשכן ⇒ פרמטר-שקע).
//
// תיקוני-פורט מול טיוטת-המנוע (התנהגות משומרת ביט-אחר-ביט):
//   • גישת-שדות — המנוע פלט `a.since`/`comp.validDays` על `dynamic`; ב-Dart על אובייקט-JS
//                 (Map) זו גישת-מפתח ⇒ `a['since']`/`comp['validDays']`. הטיפוסים הופכים מפורשים.
//   • truthiness — המנוע פלט `_falsy(...)` (לא-מוגדר). JS `!comp.validDays || !a.since`:
//                 validDays falsy = null/חסר או 0 ; since falsy = null/חסר או ''.
//                 ⇒ תנאי-מפורש (כלל-פורט 7). validDays=0 ⇒ '' (אפס=אין-תוקף, לא "פוקע היום").
//   • מוטביליות  — המנוע פלט `d.setDate(d.day + validDays)`; DateTime של Dart בלתי-משתנה
//                 ⇒ `d.add(Duration(days: validDays))`. בכלל-הצהריים (T12:00:00) הזזת-24ש׳
//                 פר-יום לא חוצה גבול-יום גם בקיפולי-DST ⇒ אותו תאריך-קלנדרי כמו setDate.
//   • הפרסור    — `DateTime.parse('...T12:00:00')` (בלי אזור) = זמן-מקומי, כמו `new Date` ב-JS.
//
// קלט:  a ({since?}) · comp ({validDays?}) · isoOf — שקע חובה: DateTime ⇒ "YYYY-MM-DD" מקומי.
// פלט:  מחרוזת ISO של יום-הפקיעה, או '' כשאין נתונים.

/// תאריך פקיעת קופון: since + validDays ימים (בכלל-הצהריים, חסין אזורי-זמן).
/// '' כשאין validDays (או 0) או שאין לשיוך since.
String couponExpiry(Map a, Map comp, String Function(DateTime) isoOf) {
  final validDays = comp['validDays'];
  final since = a['since'];
  if (validDays == null || validDays == 0 || since == null || since == '') {
    return '';
  }
  var d = DateTime.parse('${since}T12:00:00');
  d = d.add(Duration(days: validDays as int));
  return isoOf(d);
}
