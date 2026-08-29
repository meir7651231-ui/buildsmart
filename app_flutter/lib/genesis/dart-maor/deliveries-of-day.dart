// ⚛️ אטום-Dart (דרגת-חוזה) · deliveriesOfDay — מסירות של יום-חלוקה.
// מוצא: maor/src/components/shop7/lib.ts:25-27 · המקור: new/atoms/deliveries-of-day.mjs —
//        `export function deliveriesOfDay(db, dayId) { return db.deliveries.filter((d) => d.dayId === dayId); }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מסננת את db.deliveries ומחזירה רק את המסירות של יום-החלוקה dayId,
//        בסדר-המקור ובאותה רפרנס בדיוק (בלי העתקת-אובייקט). לוגיקת-בחירה = חיווט-קופסה עתידי.
// שקעים (חוק-1): db — מפת-הנתונים ובה מפתח 'deliveries' (רשימת מפות-מסירה, לכל אחת 'dayId');
//                dayId — מזהה יום-החלוקה לסינון.
// קלט: השקעים db,dayId. פלט: List<Map> חדשה (סדר-מקור), עם רפרנסים-מקוריים לאיברים.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  · JS `.filter` יוצר מערך-חדש שומר-סדר עם אותם רפרנסי-איברים ⇒ Dart `.where(...).toList()`
//    (העתק-רדוד: רשימה חדשה, איברים באותה זהות). מיושם eager (toList) כדי ש-length/index/identity
//    יעבדו בדיוק כמו מערך-JS, בלי lazy-iterable.
//  · JS `d.dayId === dayId` על מזהי-מחרוזת = השוואת-ערך ⇒ Dart `==` (זהה למחרוזות פרימיטיביות).
//  · אין locale/פורמט/getMonth/24:00/substring/truthiness — אטום-סינון טהור.

/// Returns the deliveries in [db] belonging to distribution-day [dayId], in source
/// order, each element the exact same reference (no object copy). New outer list.
/// Verbatim behaviour of the JS source `deliveriesOfDay` (an array `.filter`).
List<dynamic> deliveriesOfDay(Map<String, dynamic> db, dynamic dayId) {
  final deliveries = db['deliveries'] as List<dynamic>;
  return deliveries.where((d) => (d as Map)['dayId'] == dayId).toList();
}
