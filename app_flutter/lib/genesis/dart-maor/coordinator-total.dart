// ⚛️ אטום-Dart (דרגת-חוזה) · coordinatorTotal — סך-הריקונים של רכז.
// מוצא: maor/src/components/tzedaka/lib.ts:60-63 · המקור: new/atoms/coordinator-total.mjs —
//   `return coordinatorBoxes(boxes, coordId).reduce((a, b) => a + boxTotal(b), 0);`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: בורר את קופות-הרכז דרך השקע coordinatorBoxes ומסכם את סך-כל-קופה דרך
//        השקע boxTotal. reduce מ-0 ⇒ רכז בלי קופות / מערך ריק ⇒ 0.
// שקעים (חוק-1 · חוק-3 — קריאות-לשכנים הוזרקו כפרמטרים, אפס import פנימי):
//  • coordinatorBoxes(boxes, coordId) ⇒ Iterable — סינון קופות-הרכז (במחסן: חוט coordinator-boxes).
//  • boxTotal(box) ⇒ num — סך-הריקונים של קופה בודדת (במחסן: חוט box-total).
// קלט: boxes · coordId · שני השקעים. פלט: num (הסכום; 0 כשאין קופות).
//
// הערות-המרה (מקור→Dart), מה שהמנוע פספס:
//  • טיוטת-המנוע השתמשה ב-`.fold(0, ...)` על ערך dynamic — עובד בזמן-ריצה אך ה-accumulator
//    dynamic. כאן: לולאה עם accumulator מוטבע `num sum = 0` — reduce-מ-0 של המקור ביט-זהה,
//    בלי להישען על טיפוס-dynamic של ה-fold.
//  • השקעים הוזרקו כטיפוסי-פונקציה מפורשים (Iterable Function(...) / num Function(...))
//    במקום dynamic — משקף את החוזה ומאפשר ל-Dart לוודא את חתימת-השקע.
//  • מוטביליות: sum משתנה ⇒ נשאר mutable (num); b בלולאה = final. אין locale/getMonth/truthiness.

/// Total collections of a coordinator: selects the coordinator's boxes via the
/// [coordinatorBoxes] socket and sums each box via the [boxTotal] socket, reducing
/// from 0 (an unknown coordinator or an empty list yields 0). Verbatim behaviour
/// of the JS source `coordinatorTotal`.
num coordinatorTotal(
  dynamic boxes,
  Object? coordId,
  Iterable Function(dynamic boxes, Object? coordId) coordinatorBoxes,
  num Function(dynamic box) boxTotal,
) {
  num sum = 0;
  for (final b in coordinatorBoxes(boxes, coordId)) {
    sum += boxTotal(b);
  }
  return sum;
}
