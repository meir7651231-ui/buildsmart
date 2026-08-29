// ⚛️ אטום-Dart (דרגת-חוזה) · dayProgress — מד-התקדמות ליום-חלוקה לפי סטטוס.
// מוצא: maor/src/components/shop7/lib.ts:43-51 · המקור: new/atoms/day-progress.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). השכן deliveriesOfDay הוזרק כשקע
//        (חוק-1/חוק-3 — אפס import פנימי).
//
// תפקיד: מקבל db + מזהה-יום + שקע-שכן שמחזיר את מסירות-היום, וסופר {total, pickup,
//        enroute, delivered} לפי שדה status של כל מסירה. יום ללא-מסירות ⇒ הכול 0.
// קלט:  db (Map) · dayId (String) · השקע deliveriesOfDay(db, dayId) ⇒ List<Map{status}>.
//        פלט: Map בסדר total → pickup → enroute → delivered (Map-literal = LinkedHashMap).
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נטה לפספס):
//  • הטיוטה כתבה `d.status` (גישת-property) — המסירות הן **Map** (אובייקטי-JS),
//    ⇒ הגישה הנכונה ב-Dart היא `d['status']`. (‏getMonth/locale/truthiness/מוטביליות —
//    לא מעורבים כאן; אין מיון ⇒ אין שאלת-יציבות; אין תאריכים.)
//  • `.filter(...).length` של JS → `.where(...).length` של Dart — סמנטיקה זהה (ספירה).
//  • כל המקומיים final; אין מוטציה.

/// Progress meter for a distribution day, by delivery status.
/// Returns {total, pickup, enroute, delivered} — counts over the day's deliveries
/// (each a Map with a 'status' field). Verbatim port of new/atoms/day-progress.mjs
/// (`dayProgress`); the neighbour `deliveriesOfDay` is injected as a socket (Law 1/3).
Map<String, int> dayProgress(
  Map<String, dynamic> db,
  String dayId,
  List Function(Map<String, dynamic>, String) deliveriesOfDay,
) {
  final list = deliveriesOfDay(db, dayId);
  return {
    'total': list.length,
    'pickup': list.where((d) => d['status'] == 'pickup').length,
    'enroute': list.where((d) => d['status'] == 'enroute').length,
    'delivered': list.where((d) => d['status'] == 'delivered').length,
  };
}
