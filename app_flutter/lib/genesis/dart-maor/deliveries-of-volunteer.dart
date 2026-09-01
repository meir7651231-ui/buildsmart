// ⚛️ אטום-Dart (דרגת-חוזה) · deliveriesOfVolunteer — מסירות של מתנדב (אופציונלית: ביום נתון).
// מוצא: maor/src/components/shop7/lib.ts:29-31 · המקור-הטהור: new/atoms/deliveries-of-volunteer.mjs
//        (חוק-4 — התנהגות זהה-ביט למקור-ה-JS, לא-משופרת; המקור קדוש).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core).
//
// המקור: db.deliveries.filter(d => d.volunteerId === volId && (!dayId || d.dayId === dayId))
//
// תיקוני-המרה (המנוע פספס — תוקנו מול המקור):
//  • גישת-שדות: db/deliveries הם Map, לא record ⇒ `db['deliveries']`, `d['volunteerId']`
//    (הטיוטה השתמשה ב-`db.deliveries`/`d.volunteerId` — נכשל על Map).
//  • truthiness של `!dayId`: dayId מחרוזת/undefined ⇒ `_falsy` (null/''/false/0/NaN = כבוי),
//    כדי לשמר את דוגמה 3 (dayId='' מתנהג כמו בלי-dayId) ואת ההשמטה (undefined).
//  • dayId אופציונלי (JS: קריאה עם 2 ארגומנטים ⇒ undefined ⇒ falsy) ⇒ פרמטר-אופציונלי null.
//  • `.filter(...)` מחזיר מערך ⇒ `.where(...).toList()` (List עם length ואינדוקס, כמו JS).

/// JS truthiness: null/false/0/NaN/'' ⇒ false; אחרת ⇒ true.
bool _falsy(dynamic v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false;
}

/// Deliveries assigned to a volunteer, optionally narrowed to one distribution day.
/// Verbatim port of new/atoms/deliveries-of-volunteer.mjs (`deliveriesOfVolunteer`).
List<Map<String, dynamic>> deliveriesOfVolunteer(
    Map<String, dynamic> db, dynamic volId,
    [dynamic dayId]) {
  final List deliveries = db['deliveries'] as List;
  return deliveries
      .cast<Map<String, dynamic>>()
      .where((d) =>
          d['volunteerId'] == volId && (_falsy(dayId) || d['dayId'] == dayId))
      .toList();
}
