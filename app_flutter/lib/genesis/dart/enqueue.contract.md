# חוזה · `enqueue` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/offline_order_queue.dart:226-227`
(‏`OfflineOrderQueue.enqueue`). הקובץ חי בקומיט `1677ef27` של buildsmart (ענפי
`claude/align-main` ואחיו — אינו על main הנוכחי; הטיוטה חוללה מ-app_flutter החי).
במקור: `Future<void> enqueue(OfflineOrderIntent intent) => _serialized(() => _enqueueNow(intent));`

**הכרעת-הקידום (טיוטה-קשה, אופציה 1 — מפנה-לשכן ⇒ שקע):** שני השכנים הפכו
שקעי-פרמטר — `_serialized` (‏:178-184) ⇒ `serialized`, ‏`_enqueueNow` (‏:229-237) ⇒
`enqueueNow`. הטיפוס `OfflineOrderIntent` **לא הוטבע**: האטום לא מציץ פנימה —
הכוונה עוברת אטומה דרך גנרי `<T>` (תקדים `estimate_price`: ריאדר-גנרי).

## חתימה
```dart
Future<void> enqueue<T>(
  T intent, {
  required Future<void> Function(Future<void> Function() op) serialized,
  required Future<void> Function(T intent) enqueueNow,
})
```

## קלט
- `intent` — הכוונה-לתור (במקור `OfflineOrderIntent`; כאן `<T>` אטום).
- `serialized` — **שקע-המסדר** (במקור `_serialized`): מריץ op אחרי כל פעולת-תור
  קודמת (FIFO) ומחזיר את ה-future של הריצה עצמה.
- `enqueueNow` — **שקע-הפעולה** (במקור `_enqueueNow`): ההוספה-בפועל לתור.

## פלט / התנהגות (עוגני-שורה)
- `offline_order_queue.dart:226-227` — האטום עוטף את `enqueueNow(intent)` ב-closure
  ומוסר ל-`serialized`; **מחזיר בדיוק את ה-future שהמסדר מחזיר**.
- ‏`:227` — עצלנות: `enqueueNow` אינו נקרא עד שהמסדר מריץ את ה-op (ה-closure דוחה).
- ‏`:177`,‏`:225` — רכיבה-על-השרשרת ⇒ סדר-קריאה == סדר-ריצה (enqueue order == replay order).
- ‏`:179`,‏`:183` — `catchError` חל רק על עותק-השרשרת, לא על `run` המוחזר ⇒ שגיאת-op
  מחלחלת ל-future המוחזר, והשרשרת נשארת חיה לפעולה הבאה.

## דוגמאות (מוכחות בבדיקה, עם רתמת `_serialized` נאמנת-מקור ‏:175-184)
| # | תרחיש | צפוי |
|---|-------|------|
| 1 | `enqueue(intent, …)` ⇒ await | ‏`enqueueNow` קיבל **את אותו אובייקט** (identical) |
| 2 | מסדר שלא מריץ את op | ‏`enqueueNow` לא נקרא (עצלנות) |
| 3 | ‏slow (20ms) ואז fast על שרשרת-המקור | סדר-ריצה `slow,fast` — FIFO |
| 4a | ‏op זורק `StateError` | השגיאה מחלחלת ל-future המוחזר |
| 4b | פעולה אחרי הזריקה | רצה — השרשרת שרדה |

## שקעים
- `serialized` · `enqueueNow` — הזרקת-שכנים (חוק-1/3). הקופסה תחווט את מסדר-השרשרת
  ואת `enqueue_now` (טיוטת-אח, מקודמת בנפרד) סביב האטום הזה.

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/enqueue_test.dart  ⇒ exit 0 + "OK enqueue: 5 asserts passed"
```
