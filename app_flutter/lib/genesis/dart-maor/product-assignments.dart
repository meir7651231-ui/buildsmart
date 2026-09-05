// ⚛️ אטום-Dart (דרגת-חוזה) · productAssignments — שיוכי-חנות של מוצר נתון.
// מוצא: maor/src/components/shop/lib.ts:452-465 · המקור: new/atoms/product-assignments.mjs —
//        `export function productAssignments(assignments, productId) {
//            return assignments.filter((a) => a.productId === productId); }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקע (חוק-1): assignments — רשימת-שיוכים (כל שיוך = Map עם 'productId'); productId — המזהה למסנן.
// קלט: assignments, productId. פלט: רשימה חדשה של השיוכים ש-productId שלהם שווה-קפדנית ל-productId,
//      בסדר-המקור, כשכל איבר הוא אותה רפרנס בדיוק (filter של JS לא משכפל איברים).
//
// הערות-המרה (מקור→Dart), הכללים שהמנוע פספס:
//   · המנוע פלט `a.productId` (גישת-שדה) ו-`.where(...)` (Iterable עצל). תוקן:
//     - איבר-Map ⇒ גישה דרך `a['productId']` (לא property-access).
//     - `.where(...).toList()` ⇒ List קונקרטית (חוזה-JS מחזיר Array, לא איטרטור עצל);
//       בלי toList הבדיקה `[a1,a3]` נכשלת (Iterable ≠ List, וההערכה עצלה).
//   · === קפדני של JS: '1' === 1 ⇒ false. ב-Dart `==` בין String ל-int מחזיר false גם כן —
//     לכן `a['productId'] == productId` משמר את הסמנטיקה הקפדנית ('1' לא תופס 1). אין
//     שקעי-locale/פורמט/getMonth/truthiness/מוטביליות באטום זה.

/// Returns the assignments whose `productId` strictly equals [productId],
/// in source order, each the exact same reference. Verbatim behaviour of the
/// JS source `productAssignments` (`assignments.filter(a => a.productId === productId)`).
List<Map<String, dynamic>> productAssignments(
    List<Map<String, dynamic>> assignments, Object? productId) {
  return assignments.where((a) => a['productId'] == productId).toList();
}
