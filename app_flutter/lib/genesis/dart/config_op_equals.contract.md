# חוזה · configOpEquals

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/logic/studio/config_op.dart:129-142`
**אטום:** `new/dart/config_op_equals.dart` — `bool configOpEquals<T>(T a, T b, {kindOf, idOf, payloadOf})`

## קלט
- `a`, `b` — `T`: שני ה-ops להשוואה (במקור `ConfigOp` — sealed: SetText·SetEmoji·SetHidden·SetOrder·SetStyle·SetAction, config_store.dart:49-150).
- `kindOf` — שקע `Object? Function(T)`: מזהה-הווריאנט. מזקק את הבחנת-ה-`switch` על צמד-הטיפוסים (config_op.dart:129-141). שני ops מאותו וריאנט ⇒ אותו `kind`; וריאנטים שונים ⇒ `kind` שונה (⇔ ה-`_ => false`, config_op.dart:141).
- `idOf` — שקע `Object? Function(T)`: `op.id` (המשותף לכל 6 הענפים — `ConfigOp.id`, config_store.dart:51; נבדק בכל ענף כ-`x.id == y.id`).
- `payloadOf` — שקע `Object? Function(T)`: השדה-הנשווה-פר-וריאנט — `text`/`emoji`/`hidden`/`order`/`style`/`action` (config_op.dart:130,131,133,134,135,137). `nullable` מותר (‏text/emoji הם `String?`, hidden `bool?`, order `int?`). ההשוואה `payloadOf(a) == payloadOf(b)` מאצילה לשוויון-הערך של הטיפוס: ‏CfgStyle/CfgAction מגדירים value-`==` (config_node.dart:139-149,181-184).

## פלט
`bool` — `true` רק כאשר `a` ו-`b` הם אותו וריאנט **וגם** אותו `id` **וגם** אותו `payload`. אחרת `false`.

## התנהגות (עוגני-שורה למקור)
1. וריאנטים שונים ⇒ `false` — במקור ה-`_ => false // mismatched variants` (config_op.dart:141). כאן `kindOf(a) != kindOf(b) ⇒ false`, **לפני** בדיקת id/payload (זהה: המקור לא משווה שדות בין וריאנטים שונים).
2. אותו וריאנט ⇒ `x.id == y.id && x.<field> == y.<field>` (config_op.dart:130-140). כאן `idOf(a) == idOf(b) && payloadOf(a) == payloadOf(b)`.
3. `SetStyle`/`SetAction`: ה-payload הוא `CfgStyle?`/`CfgAction?`; ההשוואה `==` היא value-equality (config_node.dart:139-149 ל-CfgStyle, :181-184 ל-CfgAction) — לא identity.

## דוגמאות מספריות (מוכחות ב-config_op_equals_test.dart)
הרתמה מדמה את `ConfigOp`: 6 וריאנטים; `_Style`/`_Action` עם value-`==` (כמו CfgStyle/CfgAction).

| # | a | b | פלט | עוגן |
|---|---|---|-----|------|
| 1 | SetText('a','hi') | SetText('a','hi') | `true` | :130 (id∧text) |
| 2 | SetText('a','hi') | SetText('a','bye') | `false` | :130 (text שונה) |
| 3 | SetText('a','hi') | SetText('b','hi') | `false` | :130 (id שונה) |
| 4 | SetText('a','x') | SetEmoji('a','x') | `false` | :141 (וריאנט שונה) |
| 5 | SetOrder('m',3) | SetOrder('m',3) | `true` | :134 (id∧order) |
| 6 | SetOrder('m',3) | SetOrder('m',5) | `false` | :134 (order שונה) |
| 7 | SetHidden('h',true) | SetHidden('h',true) | `true` | :133 (id∧hidden) |
| 8 | SetHidden('h',true) | SetHidden('h',false) | `false` | :133 (hidden שונה) |
| 9 | SetEmoji('e','🔧') | SetEmoji('e','🔧') | `true` | :131 (id∧emoji) |
| 10 | SetStyle('s',Style(brand)) | SetStyle('s',Style(brand)) | `true` | :135 (value-== של CfgStyle) |
| 11 | SetStyle('s',Style(brand)) | SetStyle('s',Style(ink)) | `false` | :135 (colorToken שונה) |
| 12 | SetAction('c',Action(noop)) | SetAction('c',Action(noop)) | `true` | :137-138 (value-== של CfgAction) |
| 13 | SetText('a',null) | SetText('a',null) | `true` | :130 (null==null) |
| 14 | SetText('a',null) | SetText('a','x') | `false` | :130 (null≠'x') |
| 15 | SetOrder('m',3) | SetStyle('m',Style(brand)) | `false` | :141 (וריאנט שונה גובר) |

## עדשה-עוינת (קלטי-קצה — CURRICULUM #6)
- **payload = null** (text/emoji/hidden/order nullable במקור): `null == null ⇒ true` (#13), `null == value ⇒ false` (#14) — זהה למקור `x.text == y.text` על `String?`.
- **וריאנט-שונה גובר על id/payload זהים** (#15): גם כש-id זהה, `kindOf` שונה ⇒ `false` מיד, לעולם לא נכנס להשוואת-שדות — זהה ל-`_ => false` שבמקור קודם לכל השוואת-שדה בין-וריאנטית.
- **payload מקונן** (SetStyle/SetAction): ההשוואה `==` מאצילה ל-value-`==` של הטיפוס, לא identity — שני מופעים נפרדים שווי-שדות ⇒ `true` (#10,#12), עקבי עם config_op.dart:135,137 שנשען על CfgStyle/CfgAction `==`.
