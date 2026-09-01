# חוזה · `isNavStructural` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:213-225`
(‏`_isNavStructural`). `d.area` קופל לשקע `area`; `d.kind == ElementKind.container`
קופל לשקע-bool `isContainer` (חוק-3; ElementKind/ElementDescriptor טיפוסי-שכן, לא-inline).

## חתימה
```dart
bool isNavStructural({required String area, required bool isContainer})
```

## פלט / התנהגות (עוגני-שורה)
- מקור: `d.area == 'nav' || d.kind == ElementKind.container`.
- קדימות `||`: אזור-nav מכריע `true` מיד; אחרת מוכרע ע"י isContainer.

## דוגמאות מספריות
| # | area | isContainer | ⇒ |
|---|------|-------------|---|
| 1 | `'nav'` | `false` | `true` |
| 2 | `'nav'` | `true` | `true` |
| 3 | `'body'` | `true` | `true` (container) |
| 4 | `'body'` | `false` | `false` |
| 5 | `''` | `false` | `false` |
| 6 | `'Nav'` | `false` | `false` (רגיש-רישיות, התאמה-מדויקת) |

## שקעים
- `area` · `isContainer` — הזרקה (חוק-3).
- `String ==`, `||` — שפה/סטנדרט.

## DoD
```
dart run --enable-asserts new/dart/is_nav_structural_test.dart  ⇒ exit 0 + "OK isNavStructural: N asserts passed"
```
