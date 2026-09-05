// ⚛️ אטום-Dart (דרגת-חוזה) · encode
// מוצא: buildsmart/app_flutter/lib/logic/offline_order_queue.dart:313-319 (‏_encode; חוק-4).
// טוהר: פונקציית top-level עצמאית. יבוא-סטנדרט בלבד — `dart:convert` (‏jsonEncode).
//        הקלט `List<OfflineOrderIntent>` הפך גנרי `List<T>`, והקריאה-לשכן `i.toJson()`
//        הפכה לשקע-פרמטר `toJson` (חוק-3/6: טיפוס-שכן לא נגרר). שם: `_encode`⇒`encode`.
//
// קלט:  intents — רשימת ישויות (גנרית T).
//       toJson  — שקע: T ⇒ Map<String,dynamic> (במקור i.toJson()).
// פלט:  String — ‏JSON-array של המפות, בסדר-הרשימה (jsonEncode).

import 'dart:convert';

/// Encode a list of intents to a JSON array via each intent's `toJson`.
/// Verbatim behaviour of offline_order_queue.dart:313-319 with `toJson` injected.
String encode<T>(
  List<T> intents, {
  required Map<String, dynamic> Function(T) toJson,
}) =>
    jsonEncode(intents.map((i) => toJson(i)).toList());
