# חוזה · `tokens` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/equipment_stock_join.dart:42-51`
(‏`_tokens`, פרטי-במקור — גולגל; גוף verbatim, הוסרה רק תחילית `_`).

## חתימה
```dart
List<String> tokens(String normalized)
```

## קלט
- `normalized` — מחרוזת (בד"כ מנורמלת lower/trim במעלה-הזרם).

## פלט / התנהגות (עוגני-שורה)
- `equipment_stock_join.dart:42-51` — `normalized.isEmpty ? const [] : normalized.split(' ')`:
  - מחרוזת-ריקה (`''`) ⇒ `const []`.
  - אחרת ⇒ `normalized.split(' ')` — פיצול על **תו-רווח יחיד**.
  - `split(' ')` **אינו** מקפל אסימונים-ריקים: רווח-כפול ⇒ `''` באמצע; רווח מוביל/סוגר
    ⇒ `''` בקצה. (הקורא אחראי לנרמל רווחים — ראה הערת-המקור.)

## דוגמאות מספריות
| # | normalized | ⇒ |
|---|-----------|---|
| 1 | `''` | `[]` |
| 2 | `'a'` | `['a']` |
| 3 | `'a b c'` | `['a', 'b', 'c']` |
| 4 | `'a  b'` (רווח-כפול) | `['a', '', 'b']` (אסימון-ריק נשמר) |
| 5 | `' a'` (רווח מוביל) | `['', 'a']` |
| 6 | `'a '` (רווח סוגר) | `['a', '']` |
| 7 | `' '` (רווח יחיד, לא-ריק) | `['', '']` |

## שקעים
- אין. `String.isEmpty`, `String.split` — dart:core בלבד.

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/tokens_test.dart  ⇒ exit 0 + "OK tokens: N asserts passed"
```
