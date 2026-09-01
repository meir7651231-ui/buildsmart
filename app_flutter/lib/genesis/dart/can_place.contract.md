# חוזה · canPlace

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/logic/studio/component_palette.dart:277-280`
**אטום:** `new/dart/can_place.dart` — `bool canPlace<TType, TKind>(TType type, TKind container, {allowedContainersFor})`

## קלט
- `type` — `TType`: הסוג לבדיקה (במקור `ComponentType` — button/textBlock/badge/divider/infoCard/linkRow).
- `container` — `TKind`: מין-המיכל היעד (במקור `ElementKind` — container/list/action/text/theme).
- `allowedContainersFor` — שקע `Set<TKind>? Function(TType type)`. מייצג את `templateFor(type)?.allowedContainers` (component_palette.dart:278-279): מחזיר `null` כשאין תבנית לסוג (fail-closed, `t==null`), אחרת את קבוצת-המיכלים-המותרים של התבנית. במקור כל תבנית = `{container, list}` (component_palette.dart:167,175,182,189,196,203).

## פלט
`bool` — האם רכיב מסוג `type` מותר לשחרור לתוך מיכל מסוג `container`.

## התנהגות (עוגני-שורה למקור)
1. `t = templateFor(type)` — כאן `allowed = allowedContainersFor(type)` (component_palette.dart:278).
2. `t == null` ⇒ `false` (סוג-לא-מוכר, fail-closed) — כאן `allowed == null` ⇒ `false` (component_palette.dart:279).
3. אחרת ⇒ `allowed.contains(container)` — `true` רק אם המיכל בקבוצת-המותרים; אחרת `false` (component_palette.dart:279).

## דוגמאות מספריות (מוכחות ב-can_place_test.dart)
המפה מדמה את `kComponentPalette`: button/divider ⇒ `{container, list}`; סוג `missing` ⇒ אין תבנית (null).

| # | קלט | פלט | עוגן |
|---|-----|-----|------|
| 1 | button · container | `true` | :279 (‏{container,list}.contains) |
| 2 | button · list | `true` | :279 |
| 3 | button · action | `false` | :279 (action לא בקבוצה — §4) |
| 4 | button · text | `false` | :279 (text לא בקבוצה — §4) |
| 5 | button · theme | `false` | :279 (theme לא בקבוצה — §4) |
| 6 | divider · container | `true` | :279 |
| 7 | missing · container | `false` | :279 (‏allowed==null, fail-closed) |

## עדשה-עוינת (קלטי-קצה — CURRICULUM #6)
- **סוג-לא-מוכר** (השקע מחזיר null) גובר על הכול ⇒ `false`, לעולם לא זריקה (#7) — זהה למקור `t != null &&` (component_palette.dart:279).
- **מיני-בקרה** (action/text/theme) לעולם אינם בקבוצת-המותרים ⇒ `false` — זו-היא הגנת-§4 "אין רכיב לתוך מיכל-בקרה/auth" (component_palette.dart:26-30,382).
- קבוצת-מותרים ריקה `{}` (תיאורטית) ⇒ `contains` מחזיר `false` ⇒ `false` (עקבי עם המקור, אין ענף מיוחד).
