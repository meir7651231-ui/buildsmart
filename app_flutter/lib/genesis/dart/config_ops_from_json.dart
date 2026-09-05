// ⚛️ אטום-Dart (דרגת-חוזה) · configOpsFromJson
// מוצא: buildsmart/app_flutter/lib/logic/studio/config_op.dart:116-124
//        (‏configOpsFromJson; חוק-4 — התנהגות זהה בדיוק, לא-משופרת, Dart נשאר Dart).
// טוהר: פונקציית top-level עצמאית + גנרית, אפס import פנימי (רק שפה/סטנדרט —
//        ‏List/for). דיסטילציית-אצווה: מפענח כל איבר דרך שקע, מפיל null, שומר סדר.
//
// שקע שהוזרק (קריאה-לשכן ⇒ פרמטר-שקע · חוק-1/3, דיבר-3):
//   • fromJson(element) — הופכי-האיבר `configOpFromJson(e)` (:120). במקור מחזיר
//     `ConfigOp?`; כאן `T?` גנרי. null ⇒ האיבר נופל (לא נכנס לפלט), אחרת מתווסף.
//   סוג-ההחזרה `List<ConfigOp>` ⇒ `List<T>`.
//
// קלט:  raw — Object? : ה-JSON הגולמי (במקור רשימת-op-ים משוחזרת). כל דבר שאינו
//       `List` ⇒ רשימה-ריקה (‏const []).
//       fromJson — required T? Function(Object?) : שקע-פענוח-האיבר.
// פלט:  List<T> — הפריטים שפוענחו בהצלחה, בסדר-המקור, ללא ה-null-ים.
//       ‏TOTAL — לעולם לא זריקה; קלט-שאינו-רשימה ⇒ [].

/// §69 — פענוח-אצווה (config_op.dart:116-124): הופכי-הרשימה של `configOpsToJson`.
/// מפיל כל איבר לא-מוכר (‏fromJson ⇒ null) במקום לזרוק/לבנות-חצי — טיוטה-שמורה עם
/// op עתידי/זר פשוט מאבדת את אותו איבר בטעינה. `raw` שאינו `List` ⇒ רשימה-ריקה.
List<T> configOpsFromJson<T>(
  Object? raw, {
  required T? Function(Object? element) fromJson,
}) {
  if (raw is! List) return const [];
  final out = <T>[];
  for (final e in raw) {
    final op = fromJson(e);
    if (op != null) out.add(op);
  }
  return out;
}
