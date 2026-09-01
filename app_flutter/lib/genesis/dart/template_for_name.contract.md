# חוזה · `templateForName` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/component_palette.dart:254-270`.
קובץ-המקור נעדר מהריפו הנוכחי ⇒ הטיוטה היא מקור-האמת.

**אחים-שסוקטו:** הטיוטה כוללת גם `componentHe` ותיעוד `matchComponentType` — לא הועתקו.

## חתימה
```dart
T? templateForName<T>(String name, {required List<T> palette, required String Function(T) typeName})
```

## שקעים (חוק-3)
- `palette` — שקע במקום `kComponentPalette` (‏:257).
- `typeName` — שקע במקום `t.type.name` (‏:258 — שם-ה-enum).
- `ComponentTemplate` ⇒ גנרי `T` (מקור נעדר).

## פלט / התנהגות (עוגני-שורה)
- `component_palette.dart:255` — `final n = name.trim()`.
- `:256` — `if (n.isEmpty) return null` (‏שם ריק/רווחים-בלבד ⇒ null, לפני כל סריקה).
- `:257-259` — לולאה: מוחזר **הראשון** ש-`typeName(t) == n`.
- `:269` (fallthrough) — אין תאום ⇒ `null` (fail-closed, לא זריקה).
- ההשוואה על ה-**trimmed** `n`, אך על `typeName(t)` **כמו-שהוא** (בלי trim לפלטה).

## דוגמאות מספריות
שקע: `palette` = `[(typeName:'button', he:'כפתור'), (typeName:'text', he:'טקסט')]`,
`typeName = (t) => t.typeName`:

| # | name | ⇒ |
|---|------|---|
| 1 | `'button'` | `(typeName:'button', he:'כפתור')` |
| 2 | `'  button  '` | `(...'button'...)` (‏trim לפני השוואה) |
| 3 | `''` | `null` (ריק) |
| 4 | `'   '` (רווחים) | `null` (‏trim⇒ריק) |
| 5 | `'zzz'` (לא-קיים) | `null` |
| 6 | `'text'` עם `palette = []` | `null` |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/template_for_name_test.dart  ⇒ exit 0 + "OK templateForName: N asserts passed"
```
