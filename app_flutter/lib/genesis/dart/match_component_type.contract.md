# חוזה · `matchComponentType` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/registry_view.dart:293-298`
(‏`matchComponentType`). האח private `_matchClosed` (‏`:237-260`) הוטבע verbatim inline (חוק-1).

## חתימה
```dart
String? matchComponentType(String reply, {required Set<String> Function() componentTypes})
```

## קלט
- `reply` — תשובת-המודל הגולמית.
- `componentTypes` — **שקע** (חוק-3): `RegistryView.componentTypes` verbatim — קבוצת טיפוסי-הרכיב בני-ההוספה.

## פלט / התנהגות (עוגני-שורה)
- `:293-298` — `_matchClosed(reg.componentTypes(), reply)`. עם השקע: `_matchClosed(componentTypes(), reply)`.
- `_matchClosed`: מדויק גובר → מוכל-ארוך-ביותר → null; reply-ריק ⇒ null.
- הערת-מקור: הקבוצה ריקה עד שהפלטה (step-73) נוחתת ⇒ קבוצה-ריקה ⇒ null לכל reply (fail-closed).

## דוגמאות מספריות (‏componentTypes: `{'button','card','iconButton'}`)
| # | reply | ⇒ |
|---|-------|---|
| 1 | `'card'` | `'card'` (מדויק) |
| 2 | `'iconButton'` | `'iconButton'` (מדויק גובר על התת-מחרוזת button) |
| 3 | `'הוסף iconButton'` | `'iconButton'` (מוכל-ארוך; 10>6) |
| 4 | `'zzz'` | `null` |
| 5 | (componentTypes ריק) `'card'` | `null` (טרם-פלטה, fail-closed) |

## שקעים
- `componentTypes` — הזרקת-פונקציה ללא-ארגומנט (חוק-3).

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/match_component_type_test.dart  ⇒ exit 0 + "OK matchComponentType: N asserts passed"
```
