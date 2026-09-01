# חוזה · `matchPropKey` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/registry_view.dart:277-282`
(‏`matchPropKey`). האח private `_matchClosed` (‏`:237-260`) הוטבע verbatim inline (חוק-1).

## חתימה
```dart
String? matchPropKey(
  String id,
  String reply, {
  required Set<String> Function(String id) propKeysFor,
})
```

## קלט
- `id` — מזהה-הרכיב שאת מפתחות-המאפיין-הברי-עריכה שלו מקרקעים.
- `reply` — תשובת-המודל הגולמית.
- `propKeysFor` — **שקע** (חוק-3): `RegistryView.propKeysFor` verbatim — id ⇒ קבוצת prop-keys.

## פלט / התנהגות (עוגני-שורה)
- `:277-282` — `_matchClosed(reg.propKeysFor(id), reply)`. עם השקע: `_matchClosed(propKeysFor(id), reply)`.
- `_matchClosed`: מדויק גובר → מוכל-ארוך-ביותר → null; reply-ריק ⇒ null.
- id לא-מוכר ⇒ קבוצת-props ריקה ⇒ כל reply מתדרדר ל-null (fail-closed).

## דוגמאות מספריות (‏propKeysFor: `'card'→{'color','bgColor','label'}`, אחרת `{}`)
| # | id | reply | ⇒ |
|---|----|-------|---|
| 1 | `'card'` | `'color'` | `'color'` (מדויק) |
| 2 | `'card'` | `'bgColor'` | `'bgColor'` (מדויק גובר על התת-מחרוזת color) |
| 3 | `'card'` | `'שנה את bgColor'` | `'bgColor'` (מוכל-ארוך; 7>5) |
| 4 | `'card'` | `'zzz'` | `null` |
| 5 | `'missing'` | `'color'` | `null` (id לא-מוכר ⇒ fail-closed) |

## שקעים
- `propKeysFor` — הזרקת-פונקציה (חוק-3). הבדיקה מספקת stub דטרמיניסטי.

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/match_prop_key_test.dart  ⇒ exit 0 + "OK matchPropKey: N asserts passed"
```
