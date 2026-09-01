# חוזה · `enqueueNow` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/offline_order_queue.dart:229-237`
(‏`OfflineOrderQueue._enqueueNow`, ענף `claude/whats-happening-LyY9G` — האתר-החי).
הכרעת-קידום: **🔌 שקעים** (חוק-1/3) — כל קריאות-החוץ הוזרקו: `SharedPreferences.getInstance`
⇒ `getInstance` · `prefs.getString` ⇒ `getString` · `prefs.setString` ⇒ `setString` ·
`debugPrint` ⇒ `log` · השכנים-הפרטיים `_decode`/`_encode` (‏:313-336) ⇒ שקעי-קודק ·
המפתח `kOfflineOrdersKey` (‏:80, קונפיג-הצבה, חוק-6) ⇒ פרמטר `key`.
הטיפוס `OfflineOrderIntent` **לא הוטבע** — האטום לעולם לא מציץ פנימה, רק מוסיף לרשימה ⇒ גנרי `<T>`;
מזהה-הפריפס גנרי `<P>` (האטום רק משחיל אותו בין השקעים).

## חתימה
```dart
Future<void> enqueueNow<T, P>(
  T intent, {
  required Future<P> Function() getInstance,
  required String? Function(P prefs, String key) getString,
  required Future<void> Function(P prefs, String key, String value) setString,
  required List<T> Function(String? raw) decode,
  required String Function(List<T> pending) encode,
  required String key,
  required void Function(String message) log,
})
```
(‏`SharedPreferences.setString` מחזיר `Future<bool>` — נכנס לשקע `Future<void>` כרגיל בחיווט.)

## קלט
- `intent` — הפריט-להוספה (גנרי; במקור `OfflineOrderIntent`).
- `getInstance` — **שקע**: במקור `SharedPreferences.getInstance()` (‏:231).
- `getString` / `setString` — **שקעים**: קריאה/כתיבה במפתח (‏:232-233).
- `decode` / `encode` — **שקעי-קודק**: במקור `_decode` (סובלני, ‏:320-336) / `_encode` (‏:313-314).
- `key` — **קונפיג-הצבה** (במקור `kOfflineOrdersKey = 'bs.offline-orders.v1'`, ‏:80).
- `log` — **שקע**: במקור `debugPrint` (‏:235).

## פלט / התנהגות (עוגני-שורה)
- ‏`:231` — `prefs = await getInstance()`.
- ‏`:232` — `pending = decode(getString(prefs, key))..add(intent)` — הפענוח מקבל את
  הגולמי **כמות-שהוא** (כולל null), וה-intent מצורף **לסוף** (FIFO — enqueue order == replay order).
- ‏`:233` — `await setString(prefs, key, encode(pending))` — כתיבה אחת, באותו מפתח.
- ‏`:234-236` — **מוגן-מוחלט (rule #1 של המקור):** כל כשל (`on Object`) — ב-getInstance,
  ב-getString, ב-decode, ב-encode או ב-setString — ⇒ `log('OfflineOrderQueue: enqueue
  failed (ignored): $e')` **verbatim**, והפונקציה חוזרת בשקט. לעולם לא זורקת.
- כשל ⇒ **אין כתיבה** (או שהכתיבה עצמה היא שנכשלה) — אין כתיבה-חלקית אחרת.

## דוגמאות מספריות
| # | מצב | תוצאה |
|---|------|-------|
| 1 | store ריק (`getString`⇒null), decode(null)⇒`[]`, intent=`'a'` | נכתב `encode(['a'])`; ‏0 קריאות-log |
| 2 | store=`'RAW'`, decode('RAW')⇒`['a','b']`, intent=`'c'` | נכתב `encode(['a','b','c'])` — הסוף, סדר נשמר |
| 3 | `getInstance` זורק `boom` | ‏log אחד: `OfflineOrderQueue: enqueue failed (ignored): boom`; אפס כתיבות; לא זורק |
| 4 | `setString` נכשל אסינכרונית | ‏log אחד עם אותה קידומת; לא זורק |
| 5 | `decode` זורק | ‏log אחד; אפס כתיבות; לא זורק |
| 6 | `key='bs.offline-orders.v1'` | אותו key מגיע גם ל-getString וגם ל-setString |

## DoD (פקודה+פלט-צפוי — דיבר 12, נכתב לפני הקוד)
```
dart run --enable-asserts new/dart/enqueue_now_test.dart  ⇒ exit 0 + "OK enqueueNow: N asserts passed"
```
