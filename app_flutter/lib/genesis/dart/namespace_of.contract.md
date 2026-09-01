# חוזה · `namespaceOf` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart:119-124`
(‏`_namespaceOf`, פרטי-במקור). מקודם ל-public (כלל-הגלגול). מפיק את מרחב-השם
(שם-המסך) ממזהה-אלמנט לצורך קבוצות-scope ב-Stage-A של עורך-הפרומפט.

## חתימה
```dart
String namespaceOf(String id)
```

## קלט
- `id` — מזהה-אלמנט (‏`String`; במקור מ-`elementIds()`).

## התנהגות (עוגני-שורה)
- `edit_prompt.dart:120` — `s = id.trim()`.
- `:121` — `dot = s.indexOf('.')` (הנקודה הראשונה).
- `:122` — `dot < 0 ? s : s.substring(0, dot)`.

## דוגמאות מספריות
| # | id | ⇒ |
|---|----|---|
| 1 | `'screen.home.btn'` | `'screen'` |
| 2 | `'screen'` | `'screen'` (אין נקודה) |
| 3 | `'  screen.x  '` | `'screen'` (trim לפני) |
| 4 | `'a.b.c'` | `'a'` (רק הראשונה) |
| 5 | `'.btn'` | `''` (נקודה במיקום 0 ⇒ substring(0,0)) |
| 6 | `''` | `''` |
| 7 | `'   '` | `''` (trim ⇒ ריק, אין נקודה) |

## שקעים
אין. `String.trim`/`indexOf`/`substring` — שפה בלבד.

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/namespace_of_test.dart  ⇒ exit 0 + "OK namespaceOf: N asserts passed"
```
