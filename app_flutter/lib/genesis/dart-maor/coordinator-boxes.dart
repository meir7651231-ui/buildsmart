// ⚛️ אטום-Dart (דרגת-חוזה) · coordinatorBoxes — הקופות של רכז (סינון לפי מזהה).
// מוצא: maor/src/components/tzedaka/lib.ts:56-59 · המקור: new/atoms/coordinator-boxes.mjs —
//        `return boxes.filter((b) => b.coordinatorId === coordId);`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מחזיר את תת-הקבוצה של הקופות ששדה coordinatorId שלהן שווה ל-coordId,
//        בסדר-המקור, כמערך חדש (filter של JS לא נוגע במערך-המקור).
// שקע (חוק-1): boxes — רשימת קופות (מפות עם 'coordinatorId'); coordId — מזהה-הרכז.
// קלט: boxes, coordId. פלט: List חדשה עם הקופות התואמות, בסדר-המקור.
//
// הערת-המרה (מקור→Dart): טיוטת-המנוע החזירה `.where(...)` — Iterable עצל, לא List;
// JS filter מחזיר מערך ממומש. ⇒ הוספת `.toList()` כדי לשקף מערך-חדש-ממומש.
// השוואה `=== ` של JS ⇒ `==` על ערכי-מחרוזת (זהה לתוצאה). אין locale/getMonth/
// truthiness/מוטביליות — הקלט אינו משתנה (filter טהור, וכן toList מייצר מכולה חדשה).

/// Returns the boxes whose `coordinatorId` equals [coordId], in source order,
/// as a new list. Verbatim behaviour of the JS source `coordinatorBoxes`
/// (a pure filter that never mutates the input list).
List<Map<String, dynamic>> coordinatorBoxes(
    List<Map<String, dynamic>> boxes, Object? coordId) {
  return boxes.where((b) => b['coordinatorId'] == coordId).toList();
}
