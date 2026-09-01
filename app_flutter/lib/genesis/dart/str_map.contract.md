# חוזה · `strMap` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/config_op.dart:143-145`
(‏`_strMap`, פרטי-במקור — גולגל; גוף verbatim, הוסרה רק תחילית `_`).

## חתימה
```dart
Map<String, dynamic> strMap(Map<dynamic, dynamic> m)
```

## קלט
- `m` — מפה עם מפתחות מטיפוס-כלשהו (‏Map<dynamic, dynamic>), בד"כ מ-decode של JSON
  שהוחזר כ-`Map<dynamic, dynamic>`.

## פלט / התנהגות (עוגני-שורה)
- `config_op.dart:144-145` — `m.map((k, v) => MapEntry(k.toString(), v))`:
  - מפה **חדשה** שבה כל מפתח = `k.toString()`; הערכים מועברים כמות-שהם (ללא-שינוי).
  - סדר-האיטרציה נשמר כמו של `m` (‏`Map.map`).
  - **התנגשות:** שני מפתחות שונים ששווים אחרי `toString` ⇒ הערך של המאוחר-באיטרציה
    דורס (סמנטיקת `Map.map` / `MapEntry` באותו מפתח).

## דוגמאות מספריות
| # | m | ⇒ |
|---|---|---|
| 1 | `{}` | `{}` |
| 2 | `{'a': 1, 'b': 2}` | `{'a': 1, 'b': 2}` (מפתחות כבר מחרוזות) |
| 3 | `{1: 'x', 2: 'y'}` | `{'1': 'x', '2': 'y'}` |
| 4 | `{true: 'z'}` | `{'true': 'z'}` |
| 5 | `{1: 'a', '1': 'b'}` | `{'1': 'b'}` (‏int 1 ואז String '1' ⇒ המאוחר דורס) |
| 6 | `{'k': null}` | `{'k': null}` (ערך-null נשמר) |

## שקעים
- אין. `Map.map`, `MapEntry`, `Object.toString` — dart:core בלבד.

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/str_map_test.dart  ⇒ exit 0 + "OK strMap: N asserts passed"
```
