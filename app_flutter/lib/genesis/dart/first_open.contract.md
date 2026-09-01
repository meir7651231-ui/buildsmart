# חוזה · `firstOpen` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:314-322`
(‏`_firstOpen`). אין שכנים, אין const-אחות; רק שוני-שם `_firstOpen`⇒`firstOpen` (גוף verbatim).

## חתימה
```dart
int firstOpen(String s)
```

## קלט
- `s` — מחרוזת כלשהי.

## פלט / התנהגות (עוגני-שורה)
- `edit_intent.dart:315` — `brace = s.indexOf('{')`.
- `edit_intent.dart:316` — `bracket = s.indexOf('[')`.
- `edit_intent.dart:317` — `if (brace < 0) return bracket;` (אין '{' ⇒ מחזיר את מיקום '[' — או -1).
- `edit_intent.dart:318` — `if (bracket < 0) return brace;` (אין '[' ⇒ מחזיר את מיקום '{').
- `edit_intent.dart:319` — `return brace < bracket ? brace : bracket;` (המוקדם מבין השניים).
- דין-קצה: שניהם חסרים ⇒ שניהם -1 ⇒ `brace<0` אמת ⇒ מחזיר `bracket` = -1.

## דוגמאות מספריות
| # | s | ⇒ | נימוק |
|---|---|---|-------|
| 1 | `'{"a":1}'` | 0 | '{' ב-0, '[' חסר |
| 2 | `'[1,2]'` | 0 | '[' ב-0, '{' חסר |
| 3 | `'xx{y'` | 2 | '{' ב-2, '[' חסר |
| 4 | `'no json here'` | -1 | שניהם חסרים |
| 5 | `'a[b{c'` | 1 | '[' ב-1 מוקדם מ-'{' ב-3 |
| 6 | `'a{b[c'` | 1 | '{' ב-1 מוקדם מ-'[' ב-3 |
| 7 | `'{['` | 0 | '{' ב-0 מוקדם מ-'[' ב-1 |
| 8 | `'[{'` | 0 | '[' ב-0 מוקדם מ-'{' ב-1 |
| 9 | `''` | -1 | ריק |

## שקעים
- אין. הכל שפה/סטנדרט (`String.indexOf`).

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/first_open_test.dart  ⇒ exit 0 + "OK firstOpen: N asserts passed"
```
