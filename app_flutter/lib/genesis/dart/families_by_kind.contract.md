# חוזה · `familiesByKind` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/data/variant_families.dart:143-147`.

## תפקיד
מחזיר את משפחות-הווריאנטים התואמות לסוג-התכונה [kind]; kind==null ⇒ כל המשפחות.

## חתימה
```dart
List<VariantFamily> familiesByKind(AttrKind? kind, {required List<VariantFamily> families})
```

## שקע
- `families` — **שקע-דאטה**: במקור `allVariantFamilies()` (רשימה נגזרת + ממוטמנת מ-`resolvedCatalogProducts`/`kLipskeyCatalog`). הוזרקה ⇒ אפס מטמון-גלובלי/IO, המנוע טהור, מתחלף פר-ורטיקל.

## טיפוס-מינימום
`VariantFamily { final AttrKind kind; ... }` — רק `kind`.
`enum AttrKind { size, color, model, subtype }`.

## דוגמאות-מחייבות
| # | kind | families(kinds) | ⇒ |
|---|---|---|---|
| 1 | null | size,color,size | 3 (הכול) |
| 2 | size | size,color,size | 2 |
| 3 | color | size,color,size | 1 |
| 4 | model | size,color,size | [] |

## DoD
```
dart run --enable-asserts new/dart/families_by_kind_test.dart  ⇒ exit 0
```
