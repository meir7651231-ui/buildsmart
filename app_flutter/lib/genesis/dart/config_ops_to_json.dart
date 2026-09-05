// ⚛️ אטום-Dart (דרגת-חוזה) · configOpsToJson
// מוצא: buildsmart/app_flutter/lib/logic/studio/config_op.dart:109-111
//        (‏configOpsToJson; חוק-4 — התנהגות זהה בדיוק, לא-משופרת, Dart נשאר Dart).
// טוהר: פונקציית top-level עצמאית + גנרית, אפס import פנימי (רק שפה/סטנדרט —
//        list-comprehension `[for ...]`). ה-1:1 ושימור-הסדר נשמרים verbatim.
//
// שקע שהוזרק (קריאה-לשכן ⇒ פרמטר-שקע · חוק-1/3, דיבר-3):
//   המקור קורא לשכן `configOpToJson(op)` (config_op.dart:67-72 · מוסיף מעטפת-
//   schemaVersion ומפזר את `op.toJson()`) פר-איבר ⇒ הפך לשקע `toJson`. סוג-
//   האיבר `ConfigOp` במקור ⇒ גנרי T (כמו באטום-האח configOpFromJson). האטום
//   עצמו אינו יודע דבר על מבנה ה-Map — רק ממפה 1:1 בשימור-סדר.
//
// קלט:  ops — List<T> : רשימת-האטומים (במקור List<ConfigOp> — טיוטת op-list).
//       toJson — required Map<String,dynamic> Function(T op) : שקע-הסריאליזציה
//                הפר-איבר (במקור configOpToJson).
// פלט:  List<Map<String,dynamic>> — כל איבר עבר את toJson, באותו סדר, 1:1.
//        TOTAL — לעולם לא זורק, לעולם לא מדלג (הקלט לא-nullable במקור).

/// §69 — סריאליזציה של אצווה (‏op-list של טיוטה): 1:1, סדר-נשמר
/// (config_op.dart:109-111). כל איבר עובר את שקע-[toJson]; רשימה-ריקה ⇒ רשימה-ריקה.
List<Map<String, dynamic>> configOpsToJson<T>(
  List<T> ops, {
  required Map<String, dynamic> Function(T op) toJson,
}) =>
    [for (final op in ops) toJson(op)];
