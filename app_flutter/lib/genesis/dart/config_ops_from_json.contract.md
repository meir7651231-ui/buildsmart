# חוזה · configOpsFromJson

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/logic/studio/config_op.dart:116-124`
**אטום:** `new/dart/config_ops_from_json.dart` — `List<T> configOpsFromJson<T>(Object? raw, {required T? Function(Object?) fromJson})`

## קלט
- `raw` — `Object?`: ה-JSON הגולמי (במקור רשימת-op-ים שהוחזרה מ-`configOpsToJson`). כל דבר שאינו `List` ⇒ רשימה-ריקה.
- `fromJson` — `required T? Function(Object?)`: שקע-פענוח-האיבר. מייצג את קריאת-השכן `configOpFromJson(e)` (config_op.dart:120). מחזיר `null` כשהאיבר אינו op-מוכר — אז האיבר נופל. סוג-ההחזרה `ConfigOp?` במקור ⇒ גנרי `T?`.

## פלט
`List<T>` — הפריטים שפוענחו בהצלחה (‏fromJson ≠ null), **בסדר-המקור**, ללא ה-null-ים. **TOTAL — לעולם לא זורק** (config_op.dart:116-124).

## התנהגות (עוגני-שורה למקור)
1. `raw is! List` ⇒ `const []` (config_op.dart:117) — כולל `null`, String, Map, num.
2. אתחול `out = <T>[]` (config_op.dart:118).
3. לכל איבר `e` בסדר-הרשימה (config_op.dart:119): `op = fromJson(e)` (‏:120).
4. `if (op != null) out.add(op)` (config_op.dart:121) — `null` נופל; אחרת נוסף בסוף. אין דדופ, אין מיון, אין קיצור (1:1 על האיברים-המוכרים).
5. `return out` (config_op.dart:123) — הסדר משתמר, כולל כפילים.

## דוגמאות מספריות (מוכחות ב-config_ops_from_json_test.dart)
הרתמה מדמה את שקע-השכן: `fromJson(e)` = `e is String ? 'op:$e' : null` (String ⇒ מוכר, אחר ⇒ נופל).

| # | קלט raw | פלט | עוגן |
|---|--------|-----|------|
| 1 | `null` | `[]` | :117 (אינו List) |
| 2 | `'hi'` (String) | `[]` | :117 (אינו List) |
| 3 | `{'a':1}` (Map) | `[]` | :117 (Map אינו List) |
| 4 | `42` (num) | `[]` | :117 (אינו List) |
| 5 | `[]` (רשימה ריקה) | `[]` | :118,123 (אין איברים) |
| 6 | `['x','y']` | `['op:x','op:y']` | :119-121 (סדר משתמר) |
| 7 | `['x', null, 'z']` | `['op:x','op:z']` | :121 (null נופל) |
| 8 | `[1,2,3]` | `[]` | :121 (כולם non-String ⇒ null) |
| 9 | `['x', 5, 'z']` | `['op:x','op:z']` | :121 (5 נופל, השאר נשמרים) |
| 10 | `['a','a']` | `['op:a','op:a']` | :121 (כפיל נשמר — אין דדופ) |
| 11 | `[null, null]` | `[]` | :121 (כולם נופלים) |

## עדשה-עוינת (קלטי-קצה — CURRICULUM #6)
- **קלט-שאינו-רשימה** (null / String / Map / num) גובר על הכל ⇒ `[]` בטרם הלולאה (#1-4, :117) — לעולם לא זריקה, לעולם לא ניסיון-איטרציה על לא-איטרבל.
- **רשימה-ריקה** ⇒ `[]` (#5) — נבדל מ-const-[] של #1 רק במופע, זהה בערך.
- **איבר-null / איבר-לא-מוכר** (‏fromJson⇒null) נופל בשקט, לא מקצר את שאר-הרשימה (#7,9) — טיוטה עם op זר מאבדת רק אותו איבר.
- **כולם-נופלים** ⇒ `[]` (#8,11) — לא null, אלא רשימה-ריקה.
- **כפילים** נשמרים כפי-שהם (#10) — אין דדופ/מיון; הסדר והריבוי הם 1:1 על האיברים-המוכרים.
