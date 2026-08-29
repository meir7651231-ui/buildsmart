// ⚛️ אטום-Dart (דרגת-חוזה) · assignmentRedeemed — האם רכיב מומש בשיוך-חנות.
// מוצא: maor/src/components/shop/lib.ts:180-199 (SHOP4) · המקור: new/atoms/assignment-redeemed.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). השכנים liveRedemptions + hebYearOf הוזרקו
//        כשקעים (חוק-1/חוק-3 — אטום לא מייבא אטום, קריאה-לשכן = פרמטר-פונקציה).
//
// תפקיד: בלי חג — מספיק מימוש-חי אחד של אותו רכיב. עם חג ({iso,name}) — מומש רק אם
//        קיים מימוש-חי לאותו שם-חג באותה שנה-עברית של מופע-החג (מתנה מחזורית).
// קלט:  a (שיוך) · componentId · holiday? ({iso,name}) · השקעים liveRedemptions(a)⇒מימושים
//        חיים · hebYearOf(iso)⇒שנה-עברית. פלט: bool.
//
// הערות-המרה (מקור→Dart):
//  • `live.some(pred)` → `live.any(pred)` — זהה סמנטית (מחזיר true על ההתאמה הראשונה).
//  • truthiness `!!r.date`: במקור-ה-JS date חסר/null/'' הוא falsy ⇒ בדארט `r['date'] != null
//    && r['date'] != ''` (שני התנאים לפני חישוב-השנה — קצר-מעגל זהה למקור).
//  • השוואות `===` על מחרוזות/מזהים → `==` בדארט (ערכי-מחרוזת). r['holiday']==holiday['name'].
//  • מוטביליות: `live`/`year` הם `final` (const `const` במקור); אין var מוקצה-מחדש.
//  • אין locale/פורמט/getMonth — hebYearOf הוא שקע, האטום עיוור לחשבון-הלוח (חוק-5).

/// Whether a component was redeemed in a shop-assignment.
/// No holiday → any one live redemption of the component suffices. With a holiday
/// ({iso,name}) → only if a live redemption exists for that same holiday name in the
/// same Hebrew year as the holiday instance (cyclic gift). Verbatim port of
/// new/atoms/assignment-redeemed.mjs. Neighbours liveRedemptions + hebYearOf are
/// injected as sockets (Law 1/3).
bool assignmentRedeemed<A>(
  A a,
  String componentId,
  Map<String, String>? holiday,
  List<Map<String, dynamic>> Function(A) liveRedemptions,
  int Function(String) hebYearOf,
) {
  final live = liveRedemptions(a);
  if (holiday == null) {
    return live.any((r) => r['componentId'] == componentId);
  }
  final year = hebYearOf(holiday['iso']!);
  return live.any((r) =>
      r['componentId'] == componentId &&
      r['holiday'] == holiday['name'] &&
      r['date'] != null &&
      r['date'] != '' &&
      hebYearOf(r['date'] as String) == year);
}
