# חוזה · `drainNow` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/offline_order_queue.dart:269-309`
(‏`OfflineOrderQueue._drainNow`; הקובץ חי בקומיט `1677ef27` של buildsmart — S9 offline).
הכרעה 1 (🔌): חמשת שכני-המקור הפכו שקעי-פרמטר (חוק-1/3); סוג-הכוונה הפך גנרי `T`
(המנוע לא נוגע בשדות-הכוונה — מיפוי `createdAt ← queuedAt` = חיווט-קופסה של שקע-ההשמה).

## חתימה
```dart
Future<int> drainNow<T>({
  required Future<List<T>> Function() loadPending,
  required bool Function() offlineSuspect,
  required void Function(T intent) placeOrder,
  required Future<void> Function(List<T> remainder) persistRemainder,
  required void Function(String message) log,
})
```

## שקעים (מקור כל אחד — עוגני-שורה)
- `loadPending` — ‏`:272-273` ‏(`SharedPreferences.getInstance()` + ‏`getString(kOfflineOrdersKey)` + ‏`_decode`).
- `offlineSuspect` — ‏`:275` (ה-getter ‏`:188` על `connectivityProbeProvider`).
- `placeOrder` — ‏`:276` + ‏`:283-292` ‏(`_ref.read(ordersRepositoryProvider).placeOrder(...)` — קריאה סינכרונית, לא-נאווטת).
- `persistRemainder` — ‏`:302` ‏(`prefs.setString(kOfflineOrdersKey, _encode(pending))`).
- `log` — ‏`:296` + ‏`:306` ‏(`debugPrint`).

## התנהגות (עוגני-שורה)
- ‏`:274` — תור ריק ⇒ מחזיר 0. **לפני** בדיקת-האופליין: הפרוב לא נקרא והריפו לא ננגע.
- ‏`:275` — ‏`offlineSuspect()` אמת ⇒ מחזיר 0, אפס-השמות, אפס-התמדות (התור נשמר; "נשלח בחזרת-רשת").
  הפרוב נבדק **פעם אחת** לריקון, לא פר-איטרציה.
- ‏`:277-292` — לולאת FIFO: תמיד `pending.first`; סדר-ההשמה = סדר-התור.
- ‏`:293-298` — כשל-השמה ⇒ ‏`log('OfflineOrderQueue: replay failed (kept queued): $e')` + ‏break —
  הכוונה-שנכשלה וכל הבאות נשארות בתור; מוחזר המונה שנצבר עד הכשל.
- ‏`:299-302` — אחרי כל השמה מוצלחת: `pending = pending.sublist(1)` · ‏`replayed++` ·
  התמדת-השארית **מיד** (crash-safety: קריסה בין השמות לא תשים-כפול). השארית האחרונה = `[]`.
- ‏`:305-308` — כל כשל אחר (טעינה/התמדה) ⇒ ‏`log('OfflineOrderQueue: drain failed (queue intact): $e')` +
  החזרת **המונה החלקי** שנצבר (לא זריקה — rule #1 של המקור: שום דבר לא זורק ל-UI).

## דוגמאות מספריות
| # | תור | פרוב | תרחיש | פלט | השמות | התמדות |
|---|------|------|--------|-----|-------|--------|
| 1 | `[]` | (לא-נקרא) | ריק | 0 | — | — |
| 2 | `[a,b]` | offline | תור-נשמר | 0 | — | — |
| 3 | `[a,b,c]` | online | הצלחה מלאה | 3 | a,b,c (FIFO) | `[b,c]`,`[c]`,`[]` |
| 4 | `[a,b,c]` | online | ‏b נכשל | 1 | a,b(זרק) | `[b,c]` בלבד |
| 5 | טעינה-זורקת | — | drain failed | 0 | — | — |
| 6 | `[a,b]` | online | התמדה-זורקת אחרי a | 1 (חלקי) | a | ניסיון-1 זרק |

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/drain_now_test.dart  ⇒ exit 0 + "OK drainNow: N asserts passed"
```
