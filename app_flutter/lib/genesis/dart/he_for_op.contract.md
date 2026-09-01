# חוזה · `heForOp` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/diff_preview.dart:165-178`
(‏`_heForOp`, פרטי-במקור — גולגל ל-top-level). קובץ-המקור חי בקומיט `81bda554`
(הקובץ נעדר מענף-העבודה הנוכחי של buildsmart — חולץ מ-git; הטיוטה תואמת-ביט למקור).

**אחים-שסוקטו (חוק-3):** `actionHe` (שכן מ-`action_catalog.dart:254`, קיים כאטום `action_he`)
ו-`_styleHe` (שכן פרטי, קיים כאטום `style_he`). ה-`registry` המקורי (‏:165) נצרך **אך ורק**
בתוך `_styleHe` (‏:174) ⇒ נבלע בשקע `styleHe` — האטום לא מכיר `RegistryView` כלל.

## חתימה
```dart
String heForOp(ConfigOp op, {
  required String? Function(String kind) actionHe,
  required String Function(String id, OpStyle? style) styleHe,
})
```

## שקעים (חוק-3)
- `actionHe` — במקום השכן `actionHe(action.kind)` (‏:177; מחזיר `null` לסוג-לא-בקטלוג).
- `styleHe` — במקום `_styleHe(op.id, style, registry)` (‏:174); ה-registry = עניין-החיווט
  של הקופסה (האטום `style_he` כבר סוקט אותו כ-`allowedValues`).

## טיפוסים-שהוטבעו (הכרעה ⚛️ — מינימום-verbatim מ-`config_store.dart:46-159` + `config_node.dart:61,157`)
- `ConfigOp` (sealed, `id`) + ‏6 הווריאנטים: `SetText` · `SetEmoji` · `SetHidden(hidden:bool?)`
  · `SetOrder(order:int?)` · `SetStyle(style:OpStyle?)` · `SetAction(action:OpAction?)`.
- `OpStyle{colorToken:String?}` = ‏`CfgStyle` מצומצם לשדה-הנקרא (תקדים `broadcast_row`).
- `OpAction{kind:String}` = ‏`CfgAction` מצומצם לשדה-הנקרא (‏:177 קורא רק `.kind`).

## פלט / התנהגות (עוגני-שורה — diff_preview.dart)
- `:166` — `SetText` ⇒ `'שינוי טקסט: $id'`.
- `:167` — `SetEmoji` ⇒ `'שינוי אמוג׳י: $id'`.
- `:168-170` — `SetHidden`: ‏`hidden==null` ⇒ `'שינוי נראות: $id'` · ‏`true` ⇒ `'הסתרה: $id'` · ‏`false` ⇒ `'הצגה: $id'`.
- `:171-173` — `SetOrder`: ‏`order==null` ⇒ `'שינוי סדר: $id'` · אחרת `'שינוי סדר: $id ← $order'` (before→after).
- `:174` — `SetStyle` ⇒ `styleHe(op.id, style)` (הפלט = פלט-השקע, כולל style=null).
- `:175-177` — `SetAction`: ‏`action==null` ⇒ `'ניקוי פעולה: $id'` · אחרת
  `'פעולה: ${actionHe(action.kind) ?? action.kind}'` — **בלי** ‏`$id` בשורה (verbatim!),
  וסוג-לא-בקטלוג מדרדר לסוג-עצמו (`?? action.kind`).

## דוגמאות מספריות
שקעים: `actionHe = {'nav.screen':'מעבר למסך','cart.add':'הוסף לסל'}[kind]` (אחרת `null`;
אוצר-מילים אמיתי מ-`action_catalog.dart:134,161`) ·
`styleHe(id, s)` = ‏`s?.colorToken==null ? 'שינוי עיצוב: $id' : 'שינוי צבע: $id ← ${s!.colorToken}'` (מייצג).

| # | op | ⇒ |
|---|----|---|
| 1 | `SetText('title')` | `'שינוי טקסט: title'` |
| 2 | `SetEmoji('logo')` | `'שינוי אמוג׳י: logo'` |
| 3 | `SetHidden('fab', null)` | `'שינוי נראות: fab'` |
| 4 | `SetHidden('fab', true)` | `'הסתרה: fab'` |
| 5 | `SetHidden('fab', false)` | `'הצגה: fab'` |
| 6 | `SetOrder('menu', null)` | `'שינוי סדר: menu'` |
| 7 | `SetOrder('menu', 3)` | `'שינוי סדר: menu ← 3'` |
| 8 | `SetStyle('btn', OpStyle(colorToken:'success'))` | `'שינוי צבע: btn ← success'` (פלט-השקע) |
| 9 | `SetStyle('btn', null)` | `'שינוי עיצוב: btn'` (null מושחל לשקע) |
| 10 | `SetAction('card', null)` | `'ניקוי פעולה: card'` |
| 11 | `SetAction('card', OpAction('nav.screen'))` | `'פעולה: מעבר למסך'` (בלי id) |
| 12 | `SetAction('card', OpAction('zzz'))` | `'פעולה: zzz'` (דרדור `?? kind`) |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/he_for_op_test.dart  ⇒ exit 0 + "OK heForOp: 12 asserts passed"
```
