# חוזה · `matchElementId` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/registry_view.dart:272-276`
(‏`matchElementId`). האח private `_matchClosed` (‏`:237-260`) הוטבע verbatim inline (חוק-1).

## חתימה
```dart
String? matchElementId(String reply, {required Set<String> Function() elementIds})
```

## קלט
- `reply` — תשובת-המודל הגולמית.
- `elementIds` — **שקע** (חוק-3): `RegistryView.elementIds` verbatim — קבוצת כל ה-element-ids האמיתיים.

## פלט / התנהגות (עוגני-שורה)
- `:272-276` — `_matchClosed(reg.elementIds(), reply)`. עם השקע: `_matchClosed(elementIds(), reply)`.
- `_matchClosed`: מדויק גובר → מוכל-ארוך-ביותר → null; reply-ריק ⇒ null; רישום-ריק ⇒ null (fail-closed).

## דוגמאות מספריות (‏elementIds: `{'cart','cart.item','home'}`)
| # | reply | ⇒ |
|---|-------|---|
| 1 | `'home'` | `'home'` (מדויק) |
| 2 | `'cart.item'` | `'cart.item'` (מדויק גובר על התת-מחרוזת cart) |
| 3 | `'פתח את cart.item'` | `'cart.item'` (מוכל-ארוך; 9>4) |
| 4 | `'zzz'` | `null` |
| 5 | `'   '` | `null` (ריק) |
| 6 | (elementIds ריק) `'home'` | `null` (fail-closed) |

## שקעים
- `elementIds` — הזרקת-פונקציה ללא-ארגומנט (חוק-3).

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/match_element_id_test.dart  ⇒ exit 0 + "OK matchElementId: N asserts passed"
```
