# חוזה · configOpsToJson

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/logic/studio/config_op.dart:109-111`
**אטום:** `new/dart/config_ops_to_json.dart` — `List<Map<String,dynamic>> configOpsToJson<T>(List<T> ops, {required Map<String,dynamic> Function(T) toJson})`

## קלט
- `ops` — `List<T>`: רשימת-האטומים לסריאליזציה. במקור `List<ConfigOp>` (טיוטת op-list). לא-nullable — אין דילוג/סינון.
- `toJson` — `required Map<String,dynamic> Function(T op)`: שקע-הסריאליזציה הפר-איבר. מייצג את קריאת-השכן `configOpToJson(op)` (config_op.dart:67-72,111). הרכבת המעטפת (schemaVersion + `op.toJson()`) חיה בתוך-השקע — האטום אינו יודע על מבנה ה-Map.

## פלט
`List<Map<String,dynamic>>` — כל איבר של `ops` עבר את `toJson`, **באותו סדר, 1:1** (config_op.dart:110-111). **TOTAL — לעולם לא זורק, לעולם לא מדלג** (הקלט לא-nullable; זו מיפוי-רשימה טהור).

## התנהגות (עוגני-שורה למקור)
1. `[for (final op in ops) toJson(op)]` (config_op.dart:111) — list-comprehension: לכל `op` ב-`ops`, לפי הסדר, מוסיף את `toJson(op)`.
2. אורך-הפלט ≡ אורך-הקלט (1:1, אין drop) — עוגן ההערה `1:1, order preserved` (:109).
3. סדר-הפלט ≡ סדר-הקלט (יציב) (:111).
4. `ops` ריקה ⇒ פלט ריק (list-comprehension ריק).

## דוגמאות מספריות (מוכחות ב-config_ops_to_json_test.dart)
הרתמה מדמה את השכן `configOpToJson` בשקע פשוט: `toJson: (op) => {'v': op}` (זהות עטופה), כדי לבודד את חוזה-האצווה (מיפוי + סדר + 1:1) מחוזה הפר-איבר.

| # | קלט ops (עם toJson=`{'v':op}`) | פלט | עוגן |
|---|--------|-----|------|
| 1 | `[]` | `[]` | :111 (רשימה-ריקה) |
| 2 | `[10]` | `[{'v':10}]` | :111 (איבר-יחיד עובר toJson) |
| 3 | `[1,2,3]` | `[{'v':1},{'v':2},{'v':3}]` | :110-111 (סדר-נשמר, 1:1) |
| 4 | `[3,1,2]` | `[{'v':3},{'v':1},{'v':2}]` | :111 (הסדר הוא סדר-הקלט, לא ממויין) |
| 5 | `[7,7]` | `[{'v':7},{'v':7}]` | :111 (כפילים נשמרים — אין dedup) |

**דוגמת-נאמנות-סוקט (‏#6):** עם שקע המדמה את המקור המלא —
`toJson: (op) => {'schemaVersion':1, 'op':op}` — קלט `['x','y']` ⇒
`[{'schemaVersion':1,'op':'x'}, {'schemaVersion':1,'op':'y'}]` (המעטפת חיה-בשקע, config_op.dart:67-72).

## עדשה-עוינת (קלטי-קצה — CURRICULUM #6)
- **רשימה-ריקה** ⇒ פלט-ריק (‏#1) — לא null, לא זריקה.
- **איבר-יחיד** ⇒ רשימת-יחיד (#2).
- **סדר לא-ממויין** (`[3,1,2]`) ⇒ הפלט שומר את סדר-הקלט המדויק, לא ממיין (#4, :111) — המקור מיפוי-רשימה, לא מיון.
- **כפילים** (`[7,7]`) ⇒ שני איברים בפלט (#5) — 1:1 מדויק, אפס-הסרת-כפילים.
- **אין null/דילוג:** בניגוד לאח `configOpsFromJson` (שמדלג לא-מזוהים), כאן הקלט לא-nullable והמיפוי מלא — אורך-הפלט תמיד ≡ אורך-הקלט (:110-111).
