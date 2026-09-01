# חוזה · `matchComponentTypeName` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/component_palette.dart:271-272`
(‏`matchComponentTypeName`). האח private `_matchClosed` (‏`registry_view.dart:237-260`) הוטבע verbatim inline (חוק-1).

## הכרעת-שקע (שקיפות)
המקור: `matchComponentTypeName(reply) => matchComponentType(_paletteTypeView, reply)`,
ולפי חוזה-`matchComponentType` = `_matchClosed(_paletteTypeView.componentTypes(), reply)`.
‏`_paletteTypeView` הוא מופע-RegistryView פרטי (היררכיה+state) — לכן
`_paletteTypeView.componentTypes()` הופך לשקע-נתון `componentTypes` (חוק-3).

## חתימה
```dart
String? matchComponentTypeName(String reply, {required Set<String> componentTypes})
```

## קלט
- `reply` — תשובת-המודל הגולמית.
- `componentTypes` — **שקע**: `_paletteTypeView.componentTypes()` verbatim (קבוצת טיפוסי-הרכיב בפלטה).

## פלט / התנהגות (עוגני-שורה)
- `:271-272` — `matchComponentType(_paletteTypeView, reply)` ⇒ `_matchClosed(componentTypes, reply)`.
- `_matchClosed`: מדויק גובר → מוכל-ארוך-ביותר → null; reply-ריק ⇒ null.

## דוגמאות מספריות (‏componentTypes: `{'button','card','iconButton'}`)
| # | reply | ⇒ |
|---|-------|---|
| 1 | `'card'` | `'card'` (מדויק) |
| 2 | `'iconButton'` | `'iconButton'` (מדויק גובר על התת-מחרוזת button) |
| 3 | `'הוסף iconButton'` | `'iconButton'` (מוכל-ארוך) |
| 4 | `'zzz'` | `null` |
| 5 | (componentTypes ריק) `'card'` | `null` (fail-closed) |

## שקעים
- `componentTypes` — הזרקת-קבוצה (חוק-3, בגלל מופע-View פרטי במקור).

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/match_component_type_name_test.dart  ⇒ exit 0 + "OK matchComponentTypeName: N asserts passed"
```
