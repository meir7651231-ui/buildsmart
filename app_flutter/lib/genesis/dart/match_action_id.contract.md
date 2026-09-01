# חוזה · `matchActionId` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/registry_view.dart:288-292`
(‏`matchActionId`). האח private `_matchClosed` (‏`:237-260`) הוטבע verbatim inline (חוק-1).

## חתימה
```dart
String? matchActionId(
  String id,
  String reply, {
  required Set<String> Function(String id) actionIdsFor,
})
```

## קלט
- `id` — מזהה-הרכיב שאת פעולותיו-המותרות מקרקעים אליו.
- `reply` — תשובת-המודל הגולמית.
- `actionIdsFor` — **שקע** (חוק-3): `RegistryView.actionIdsFor` verbatim — id ⇒ קבוצת-פעולות-מותרות.

## פלט / התנהגות (עוגני-שורה)
- `:288-292` — `_matchClosed(reg.actionIdsFor(id), reply)`. עם השקע: `_matchClosed(actionIdsFor(id), reply)`.
- `_matchClosed` (‏:237-260): התאמה-מדויקת גוברת, אחרת מוכל-ארוך-ביותר, אחרת null; reply-ריק ⇒ null.
- id שאין-לו-פעולות (קבוצה-ריקה) ⇒ כל reply מתדרדר ל-null (fail-closed).

## דוגמאות מספריות (‏actionIdsFor: `'btn'→{'nav.open','cart.add'}`, אחרת `{}`)
| # | id | reply | ⇒ |
|---|----|-------|---|
| 1 | `'btn'` | `'cart.add'` | `'cart.add'` (מדויק) |
| 2 | `'btn'` | `'לחץ nav.open עכשיו'` | `'nav.open'` (מוכל) |
| 3 | `'btn'` | `'zzz'` | `null` (אין-התאמה) |
| 4 | `'btn'` | `'   '` | `null` (ריק) |
| 5 | `'missing'` | `'cart.add'` | `null` (id ללא-פעולות ⇒ fail-closed) |

## שקעים
- `actionIdsFor` — הזרקת-פונקציה (חוק-3). הבדיקה מספקת stub דטרמיניסטי.

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/match_action_id_test.dart  ⇒ exit 0 + "OK matchActionId: N asserts passed"
```
