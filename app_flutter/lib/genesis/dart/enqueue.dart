// ⚛️ אטום-Dart · enqueue — צירוף-הסדרה: הרכבת פעולת-התור על שרשרת-ההסדרה (FIFO).
// מוצא: buildsmart/app_flutter/lib/logic/offline_order_queue.dart:226-227 (‏enqueue; חוק-4).
//   (הקובץ חי בקומיט 1677ef27 של buildsmart — ענפי claude/align-main ואחיו; אינו על main הנוכחי.)
// במקור: `Future<void> enqueue(OfflineOrderIntent intent) => _serialized(() => _enqueueNow(intent));`
// טוהר-מוחלט: פונקציית top-level, אפס import, אפס דאטה. שני השכנים הפכו שקעים (חוק-1/3):
//   • `serialized`  — שקע-המסדר: במקור `_serialized` (‏:178-184) — מריץ op אחרי כל
//     פעולת-תור שתוזמנה קודם (FIFO) ומחזיר את ה-future של הריצה עצמה.
//   • `enqueueNow`  — שקע-הפעולה: במקור `_enqueueNow` (‏:229-237) — ההוספה-בפועל לתור.
//   • `intent`      — גנרי `<T>` (במקור `OfflineOrderIntent`): האטום לא מציץ פנימה —
//     רק מעביר אותו כמות-שהוא לשקע (תקדים estimate_price: ריאדר-גנרי במקום הטבעת-טיפוס).
// התנהגות זהה-ביט למקור: האטום *לא* מריץ את enqueueNow בעצמו — הוא עוטף אותו
// ב-closure ומוסר למסדר; הפלט הוא בדיוק ה-future שהמסדר מחזיר (שגיאה מחלחלת דרכו).
//
// קלט:  intent · serialized · enqueueNow.
// פלט:  Future<void> — ה-future של ריצת-הפעולה כפי שהמסדר מחזיר אותו.

/// הוספה-לתור דרך שרשרת-ההסדרה: עוטף את [enqueueNow] עם [intent] ב-closure
/// ומוסר ל-[serialized] — סדר-קריאה == סדר-ריצה (FIFO), עצלן עד שהמסדר מריץ.
Future<void> enqueue<T>(
  T intent, {
  required Future<void> Function(Future<void> Function() op) serialized,
  required Future<void> Function(T intent) enqueueNow,
}) =>
    serialized(() => enqueueNow(intent));
