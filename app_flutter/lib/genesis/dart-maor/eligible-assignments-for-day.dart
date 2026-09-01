// ⚛️ אטום-Dart (דרגת-חוזה) · eligibleAssignmentsForDay — שיוכים פעילים שטרם נמסרו ביום.
// מוצא: maor/src/components/shop7/lib.ts:38-41 · המקור: new/atoms/eligible-assignments-for-day.mjs —
//   const taken = new Set(db.deliveries.filter(d=>d.dayId===dayId).map(d=>d.assignmentId));
//   return db.shopAssignments.filter(a => a.status==='active' && !taken.has(a.id));
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: הקלט לבורר-השיוך במודול-החלוקה (SHOP7) — שיוכי-חנות פעילים שטרם הפכו
//        למסירה ביום-החלוקה הזה. מסירה ביום אחר אינה חוסמת. הפלט מצביע לאובייקטי-המקור.
// שקע (חוק-1): db {deliveries:[{dayId,assignmentId}], shopAssignments:[{id,status}]} · dayId.
// קלט: db (Map) · dayId. פלט: List של אובייקטי-המקור עצמם (זהות-רפרנס נשמרת).
//
// הערת-המרה (מקור→Dart): המנוע פספס — .has של Set-JS ⇒ .contains ב-Dart · גישת-שדה
// db.deliveries על dynamic ⇒ אינדוקס-מפתח db['deliveries'] (הדאטה = Maps) · where עצל
// ⇒ .toList() לרשימה קונקרטית. === של JS על מחרוזות ⇒ == ב-Dart. אין
// locale/פורמט/getMonth/truthiness/מוטביליות — הפילטר משמר את רפרנסי-המקור.

/// Active shop-assignments not yet delivered on the given distribution day.
/// Verbatim behaviour of the JS source `eligibleAssignmentsForDay`: builds the
/// set of assignmentIds delivered on `dayId`, returns active assignments whose id
/// is not in that set. Returned elements are the exact source objects (no copy).
List eligibleAssignmentsForDay(Map db, dynamic dayId) {
  final deliveries = (db['deliveries'] as List);
  final taken = deliveries
      .where((d) => d['dayId'] == dayId)
      .map((d) => d['assignmentId'])
      .toSet();
  final shopAssignments = (db['shopAssignments'] as List);
  return shopAssignments
      .where((a) => a['status'] == 'active' && !taken.contains(a['id']))
      .toList();
}
