// ⚛️ אטום-Dart (דרגת-חוזה) · deliveriesOfFamily — מסירות של משפחה.
// מוצא: maor/src/components/shop7/lib.ts:64-66 · המקור: new/atoms/deliveries-of-family.mjs —
//        `return db.deliveries.filter((d) => d.familyId === famId);`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: כל המסירות ששייכות למשפחה נתונה — סינון db.deliveries לפי familyId,
//        בסדר-המקור, כשהאיברים המוחזרים הם אותן הרפרנסות בדיוק (בלי העתקה/שינוי).
// קלט:  db — מפה בעלת מפתח 'deliveries' (רשימת מסירות, כל מסירה מפה עם 'familyId').
//        famId — מזהה-המשפחה. פלט: List של המסירות התואמות (רשימה חדשה, אותם איברים).
//
// הערות-המרה (מקור→Dart):
//  • `Array.filter` → `Iterable.where(...).toList()` — שומר סדר-מקור (יציב) וזהות-רפרנס
//    של כל איבר-מסירה (Map הוא טיפוס-רפרנס ⇒ identical(a[1], db.deliveries[2]) מתקיים,
//    מקביל ל-a[1] === db.deliveries[2] של הבדיקה). `.toList()` = רשימה-חדשה כמו filter.
//  • השוואת-זהות-שדה: JS `d.familyId === famId` על מחרוזות → `d['familyId'] == famId`
//    (השוואת-ערך על String ב-Dart זהה ל-=== של JS על פרימיטיב-מחרוזת).
//  • מוטביליות: אין var מוקצה-מחדש; אין locale/פורמט/getMonth/truthiness/substring.
//  • שקע-הקריאה-לשכן: אין (אטום עצמאי לגמרי, אפס import — חוק-1).

/// Deliveries belonging to a family — filters `db.deliveries` by `familyId`, in
/// source order, returning the exact same delivery references (no copy, no mutation).
/// Verbatim port of new/atoms/deliveries-of-family.mjs (`deliveriesOfFamily`).
List<Map<String, dynamic>> deliveriesOfFamily(
  Map<String, dynamic> db,
  String famId,
) {
  final deliveries = (db['deliveries'] as List).cast<Map<String, dynamic>>();
  return deliveries.where((d) => d['familyId'] == famId).toList();
}
