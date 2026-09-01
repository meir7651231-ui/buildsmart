# חוזה · `matchAllElementIds` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/registry_view.dart:299-301`
(‏`matchAllElementIds`). האח private `_matchAllClosed` (‏`:261-271`) הוטבע verbatim inline (חוק-1).

## חתימה
```dart
Set<String> matchAllElementIds(String reply, {required Set<String> Function() elementIds})
```

## קלט
- `reply` — תשובת-המודל הגולמית.
- `elementIds` — **שקע** (חוק-3): `RegistryView.elementIds` verbatim — קבוצת כל ה-element-ids האמיתיים.

## פלט / התנהגות (עוגני-שורה)
- `:299-301` — `_matchAllClosed(reg.elementIds(), reply)`. עם השקע: `_matchAllClosed(elementIds(), reply)`.
- `_matchAllClosed` (‏:261-271): **כל** id ש-`k.isNotEmpty && reply.contains(k)` (לא-רק-הטוב);
  reply-ריק ⇒ קבוצה-ריקה. שום id לא נלקח מרשימת-מודל — Dart מונה מהרישום.

## דוגמאות מספריות (‏elementIds: `{'cart','cart.item','home'}`)
| # | reply | ⇒ |
|---|-------|---|
| 1 | `'cart.item ו-home'` | `{'cart','cart.item','home'}` (cart מוכל ב-cart.item!) |
| 2 | `'home'` | `{'home'}` |
| 3 | `'   '` | `{}` (ריק אחרי trim) |
| 4 | `'zzz'` | `{}` (אין-התאמה) |
| 5 | (elementIds ריק) `'home'` | `{}` (רישום-ריק) |

## שקעים
- `elementIds` — הזרקת-פונקציה ללא-ארגומנט (חוק-3).

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/match_all_element_ids_test.dart  ⇒ exit 0 + "OK matchAllElementIds: N asserts passed"
```
