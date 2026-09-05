// ⚛️ אטום-Dart (דרגת-חוזה) · fieldValue
// מוצא: buildsmart/app_flutter/lib/logic/studio/rules_model.dart:420-435 (‏_fieldValue; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import. הקלט `Order order` צומצם לשלושת
//        השדות בהם נגע הגוף — `createdAt` (DateTime?), `sum` (num), `items` (num) —
//        כשקעי-ריאדר גנריים (חוק-3/6: טיפוס-שכן-גדול לא נגרר). שלוש קבועי-המפתח
//        (`kFieldAgeDays`/`kFieldSum`/`kFieldItems`) הופכו לשקעי-פרמטר (חוק-3) —
//        ערכיהם אינם נגישים במקור-הנוכחי (studio/ חסר) ⇒ שקע, לא ניחוש (חוק-9).
//        ה-`switch` תורגם לשרשרת-if שקולה (case⇒==) לשימור-סמנטיקה עם מפתחות-שקע.
//
// קלט:  field, order, now — המזהה, הישות, ותאריך-ההשוואה.
//       createdAt/sum/items — שקעי-ריאדר על הישות.
//       ageDaysField/sumField/itemsField — שקעי-מפתח (במקור const-ים).
// פלט:  num — גיל-בימים / סכום / מספר-פריטים; מפתח לא-מוכר ⇒ 0.

/// Numeric value of one rule field over an order. Verbatim behaviour of
/// rules_model.dart:420-435 with the Order fields and field-key consts injected.
num fieldValue<T>(
  String field,
  T order,
  DateTime now, {
  required DateTime? Function(T) createdAt,
  required num Function(T) sum,
  required num Function(T) items,
  required String ageDaysField,
  required String sumField,
  required String itemsField,
}) {
  if (field == ageDaysField) {
    final created = createdAt(order);
    return created == null ? 0 : now.difference(created).inDays;
  }
  if (field == sumField) return sum(order);
  if (field == itemsField) return items(order);
  return 0;
}
