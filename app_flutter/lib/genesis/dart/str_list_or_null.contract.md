# חוזה · `strListOrNull` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/connection_schema.dart:35`
(‏`_strListOrNull`, פרטי-במקור — גולגל; גוף verbatim, הוסרה רק תחילית `_`).

**אחים-שסוקטו:** הטיוטה כוללת גם `_numMap` ו-`_sizeTable` (‏:36-45) — אטומים נפרדים, לא הועתקו.

## חתימה
```dart
List<String>? strListOrNull(Object? v)
```

## קלט
- `v` — ערך גולמי כלשהו (‏Object?), בד"כ תוצאת decode של JSON.

## פלט / התנהגות (עוגני-שורה)
- `connection_schema.dart:35` — `v is List ? v.whereType<String>().toList() : null`:
  - `v` הוא `List` ⇒ **רק** האיברים שהם `String`, בסדר-הופעה, כ-`List<String>` חדשה.
  - `v` אינו `List` (‏null, מחרוזת, מספר, Map, …) ⇒ **`null`**.
- ההבדל מ-`strList`: מפתח-חסר/לא-List מחזיר `null` (מפתח נעדר) ולא `[]` (מפתח קיים-וריק).

## דוגמאות מספריות
| # | v | ⇒ |
|---|---|---|
| 1 | `null` | `null` |
| 2 | `'abc'` (מחרוזת, לא-List) | `null` |
| 3 | `42` | `null` |
| 4 | `{'k': 'v'}` (Map) | `null` |
| 5 | `['x', 'y']` | `['x', 'y']` |
| 6 | `[1, 'a', true, 'b', null]` | `['a', 'b']` (רק המחרוזות) |
| 7 | `[]` (List ריקה קיימת) | `[]` (‏**לא** null!) |

## שקעים
- אין. `is List`, `Iterable.whereType`, `.toList()` — dart:core בלבד.

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/str_list_or_null_test.dart  ⇒ exit 0 + "OK strListOrNull: N asserts passed"
```
