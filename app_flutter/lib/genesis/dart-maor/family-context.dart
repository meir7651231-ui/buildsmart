// ⚛️ אטום-Dart (דרגת-חוזה) · familyContext — מוני "פתוחים" של משפחה לכרטיס-השיחה (screen-pop).
// מוצא: maor/src/lib/callerId.ts:113-117 · המקור: new/atoms/family-context.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: openDeliveries = מסירות המשפחה בסטטוס≠'delivered' (shop7) ·
//        activeAssignments = שיוכי-חבילות בסטטוס==='active' (shop). טהור, תצוגה-בלבד.
// שים לב לשמות-השדה השונים כלשון-המקור: במסירות המשפחה היא familyId, בשיוכים היא famId.
//
// הערת-המרה (מקור→Dart, DART-PORTING-RULES):
//  - המנוע פלט גישת-property (db.deliveries / d.familyId) — לא-חוקי על Map ב-Dart;
//    תוקן לגישת-מפתח (db['deliveries'] / d['familyId']).
//  - כלל-2 (null≠undefined): במקור `d.status !== 'delivered'` — status חסר=undefined⇒נספר;
//    ב-Dart d['status'] חסר=null, ו-`null != 'delivered'`⇒true — התנהגות זהה. אין שקר-null נוסף.
//  - כלל-7 (truthiness): `db.deliveries || []` — רק undefined/null נופל לברירת-מחדל
//    (מערך-ריק truthy ב-JS); `db['deliveries'] ?? []` תואם (רק null נופל).
//  - אין locale/getMonth/מיון/תאריך/substring — אין שקעים.

/// Family-context counters for the caller card (screen-pop). Pure, view-only.
/// Verbatim behaviour of the JS source `familyContext`.
Map<String, int> familyContext(Map db, Object? famId) {
  final deliveries = (db['deliveries'] ?? const []) as List;
  final assignments = (db['shopAssignments'] ?? const []) as List;
  final openDeliveries = deliveries
      .where((d) => d['familyId'] == famId && d['status'] != 'delivered')
      .length;
  final activeAssignments = assignments
      .where((a) => a['famId'] == famId && a['status'] == 'active')
      .length;
  return {'openDeliveries': openDeliveries, 'activeAssignments': activeAssignments};
}
