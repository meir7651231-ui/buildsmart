// ⚛️ אטום-Dart (דרגת-חוזה) · deliveryNoteTitle
// מוצא: buildsmart/app_flutter/lib/logic/delivery_note.dart:41
//        (‏deliveryNoteTitle; חוק-4 — התנהגות verbatim, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק dart:core).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-1/3, דיבר-3):
//   • הטיפוס Order מהמקור (state/orders_engine.dart) ⇒ מוחזק ב-`NoteOrder` —
//     מחזיק-קלט טהור עם השדה היחיד שהכותרת קוראת (order.id). אפס תלות.
//
// קלט:  order — NoteOrder (id — מזהה-ההזמנה, מחרוזת).
// פלט:  String — כותרת-המסמך לתעודת-משלוח.

/// מחזיק-קלט טהור: רק השדה ש-deliveryNoteTitle קורא (delivery_note.dart:41).
class NoteOrder {
  final String id;
  const NoteOrder({required this.id});
}

/// כותרת-המסמך לתעודת-משלוח — verbatim של delivery_note.dart:41.
String deliveryNoteTitle(NoteOrder order, {required String Function(String) term}) => '${term('tavdt-mshlvch')}${order.id}';
