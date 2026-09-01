// ⚛️ אטום-Dart (דרגת-חוזה) · decode
// תפקיד: פענוח בטוח של מטען-JSON (תור-הזמנות-אופליין) לרשימת-ישויות — פריט-פגום מדולג,
//        מטען-פגום-כולו נזרק לרשימה-ריקה; לעולם לא זורק. משמש offline_order_queue.
// מוצא: buildsmart/app_flutter/lib/logic/offline_order_queue.dart:320-345 (‏_decode; חוק-4).
// טוהר: פונקציית top-level עצמאית; ייבוא dart:convert בלבד (שפה/סטנדרט, מותר). פרטי-במקור ⇒ public.
// אחים-שסוקטו: `OfflineOrderIntent.fromJson` ⇒ שקע `fromJson` · `debugPrint` ⇒ שקע `log`
//        (חוק-3: קריאה-לשכן ⇒ פרמטר-שקע; כך אין תלות ב-Flutter/foundation). גנרי על `T`.
//        אחים-שהוטבעו: — (‏_encode/הספק ושאר-הקובץ אינם חלק מהאטום).
//
// קלט:  raw      — מחרוזת-JSON או null (מ-SharedPreferences).
//       fromJson — שקע: בניית ישות ממפה (T Function(Map<String,dynamic>)); במקור `.fromJson`.
//       log      — שקע: לוג-אזהרה (void Function(String)); במקור `debugPrint`.
// פלט:  List<T> — הישויות התקינות (ריק על null/ריק/פגום).

import 'dart:convert';

/// Fault-tolerant JSON decode of a queue payload: a corrupt element is skipped
/// (logged), a corrupt whole payload yields `[]` (logged). NEVER throws. Verbatim
/// behaviour of offline_order_queue.dart:320-345 with `.fromJson`/`debugPrint` injected.
List<T> decode<T>(
  String? raw, {
  required T Function(Map<String, dynamic>) fromJson,
  required void Function(String) log,
}) {
  if (raw == null || raw.isEmpty) return <T>[];
  try {
    final out = <T>[];
    for (final e in jsonDecode(raw) as List<dynamic>) {
      try {
        out.add(fromJson(e as Map<String, dynamic>));
      } on Object catch (err) {
        log('OfflineOrderQueue: skipped corrupt intent: $err');
      }
    }
    return out;
  } on Object catch (e) {
    log('OfflineOrderQueue: corrupt queue payload (dropped): $e');
    return <T>[];
  }
}
