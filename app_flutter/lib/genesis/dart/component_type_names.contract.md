# חוזה · componentTypeNames

**מוצא (עוגן-שורה · דיבר-11):** `buildsmart/app_flutter/lib/logic/studio/component_palette.dart:232-233`

חולץ verbatim (חוק-4). המקור:

```dart
Set<String> componentTypeNames() =>
    {for (final t in kComponentPalette) t.type.name};   // :232-233
```

## שקע שהוזרק (חוק-1/3 · דיבר-3)
- `kComponentPalette` (השכן הגלובלי, `List<ComponentTemplate>`, component_palette.dart:163-208)
  — קורס ל-`palette`, `Iterable<PaletteEntry>`. המקור קורא מכל פריט ערך-אחד בלבד:
  `t.type.name` (:233). לכן `PaletteEntry` = מחזיק-קלט טהור `{ typeName }` — אפס תלות
  ב-`ComponentTemplate`, ב-enum `ComponentType`, או בשדות
  `he/allowedContainers/requiredProps/optionalProps/optionalAction/maxPerContainer`.

## קלט
| שם | טיפוס | משמעות |
|----|-------|--------|
| `palette` | `Iterable<PaletteEntry>` | הפלטה-הסגורה; כל פריט נושא `typeName` (= `t.type.name` במקור). |

## פלט
`Set<String>` — שמות סוגי-הרכיבים המובחנים. Set-literal של Dart שומר סדר-הכנסה
(LinkedHashSet) ומסיר כפילויות — זהה לסמנטיקת ה-Set-comprehension במקור.

## התנהגות (verbatim)
1. סורק את `palette` בסדר, אוסף `t.typeName` מכל פריט לתוך Set (:232-233).
2. כפילות-שם ⇒ מופיעה פעם-אחת (סמנטיקת-Set) — כמו במקור.
3. פלטה ריקה ⇒ `<String>{}` ריק.
4. אין קלט אחר, אין fail-closed, לעולם לא זורק (מראה מדויק של המקור — לא "משפרים", חוק-4).

## דוגמאות מספריות (מקריאת-הקוד · kComponentPalette, component_palette.dart:163-208)
הפלטה-החיה: 6 תבניות בסדר — `button` (:165), `textBlock` (:173), `badge` (:180),
`divider` (:187), `infoCard` (:194), `linkRow` (:201). כל השמות מובחנים.

| # | palette | פלט |
|---|---------|-----|
| 1 | 6 החי (button…linkRow) | `{button, textBlock, badge, divider, infoCard, linkRow}` (length 6) |
| 2 | ריק | `{}` (length 0) |
| 3 | `[button]` בלבד | `{button}` (length 1) |
| 4 | `[badge, badge]` (שם כפול) | `{badge}` (length 1 — Set מדדף) |
| 5 | `[divider, button, divider]` | `{divider, button}` (length 2, סדר-הכנסה) |

## עדשה-עוינת (CURRICULUM #6)
- פלטה ריקה ⇒ Set ריק (לא זריקה) — כמו המקור על `kComponentPalette` ריקה.
- שם כפול בפלטה ⇒ מופיע פעם-אחת (סמנטיקת-Set), זהה למקור.
- שם ריק `''` כ-typeName ⇒ נאסף כמות-שהוא (המקור אינו מסנן/trim; `''` הוא name חוקי-תיאורטית) — מראה מדויק.
- סדר-ההכנסה נשמר (LinkedHashSet) — הבדיקה מאמתת סדר-איטרציה, לא רק חברות.

## DoD (דיבר-12)
```
dart run --enable-asserts new/dart/component_type_names_test.dart  ⇒ exit 0
פלט צפוי: "componentTypeNames OK — 5/5 contract examples proven"
```
