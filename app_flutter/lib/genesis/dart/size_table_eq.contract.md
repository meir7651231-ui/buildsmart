# חוזה · `sizeTableEq`

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/domain/connection_schema.dart:51-59`
(`_sizeTableEq` — עוזר value-`==` של טבלת-מידה ב-`SizeConstraint`; פרטי במקור, קודם ל-top-level).

## חתימה
```dart
bool sizeTableEq(
  List<List<String>>? a,
  List<List<String>>? b, {
  bool Function(List<String> x, List<String> y) rowEq = _listEq,
})
```

## קלט
- `a`, `b` — טבלאות-מידה `List<List<String>>?` (nullable). כל טבלה = רשימת-שורות, כל שורה = רשימת-מחרוזות.
- `rowEq` — **שקע** (חוק-3): משווה שתי שורות איבר-לאיבר. במקור זה `listEquals`
  (‏`package:flutter/foundation.dart`, נקרא ב-connection_schema.dart:56). ברירת-המחדל `_listEq`
  משכפלת את `listEquals` אחד-לאחד (אורך-שונה⇒false · identical⇒true · אחרת השוואת-איברים).

## פלט
`bool` — האם שתי הטבלאות שקולות.

## התנהגות (עוגני-שורה למקור)
1. `:52` — `a == null || b == null` ⇒ מחזיר `a == b`. משמעו: שניהם-null ⇒ `true`; אחד-null בלבד ⇒ `false`.
2. `:53` — אורך-חיצוני שונה ⇒ `false`.
3. `:54-56` — לולאה: אם שורה כלשהי אינה שקולה דרך `rowEq` ⇒ `false`.
4. `:57` — עברו כל השורות ⇒ `true` (כולל טבלה ריקה `[]`, שהלולאה מדלגת עליה).

## דוגמאות מספריות (מקריאת-הקוד)
| # | a | b | פלט | עוגן |
|---|---|---|-----|------|
| 1 | `null` | `null` | `true` | :52 (a==b, שניהם null) |
| 2 | `null` | `[["1"]]` | `false` | :52 (a==b, אחד null) |
| 3 | `[["1"]]` | `null` | `false` | :52 |
| 4 | `[]` | `[]` | `true` | :53+:57 (אורך 0==0, לולאה מדלגת) |
| 5 | `[["1"]]` | `[]` | `false` | :53 (1 != 0) |
| 6 | `[["a","b"],["c"]]` | `[["a","b"],["c"]]` | `true` | :54-57 |
| 7 | `[["a"]]` | `[["b"]]` | `false` | :56 (שורה שונה) |
| 8 | `[["a","b"]]` | `[["a"]]` | `false` | :56 (אורך-שורה שונה⇒rowEq false) |

## עדשה-עוינת (קלט-קצה — CURRICULUM #6)
- שורות-ריקות: `[[]]` מול `[[]]` ⇒ `true` (rowEq של שתי רשימות-ריקות = true).
- שורות שונות-סדר: `[["a","b"]]` מול `[["b","a"]]` ⇒ `false` (rowEq תלוי-סדר).
- אותה-הפניה: `sizeTableEq(t, t)` עם `t=[["x"]]` ⇒ `true` (identical-fast-path ב-rowEq, גם ללא זה השוויון מתקיים).

## DoD (דיבר 12)
`dart run --enable-asserts new/dart/size_table_eq_test.dart` ⇒ exit 0 + הדפסת `OK sizeTableEq: N asserts passed`.
