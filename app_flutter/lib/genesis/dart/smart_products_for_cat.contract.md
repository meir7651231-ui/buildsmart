# חוזה · `smartProductsForCat` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/data/smart_tree.dart:2549-2550`.

## תפקיד
מחזיר את כל המוצרים-החכמים ששדה-הקטגוריה שלהם שווה ל-[cat], מתוך הקטלוג-המוזרק.

## חתימה
```dart
List<SmartProduct> smartProductsForCat(String cat, {required List<SmartProduct> catalog})
```

## שקע
- `catalog` — **שקע-דאטה**: במקור `kSmartProducts` (const ~82 פריטים, data/smart_tree.dart). מוזרק כפרמטר ⇒ מתחלף פר-ורטיקל, המנוע טהור.

## טיפוס-מינימום
`SmartProduct { final String cat; const SmartProduct(...) }` — רק השדה `cat`.

## דוגמאות-מחייבות
| # | catalog(cats) | cat | ⇒ |
|---|---|---|---|
| 1 | ברזים,צנרת,ברזים | ברזים | 2 |
| 2 | ברזים,צנרת,ברזים | צנרת | 1 |
| 3 | ברזים,צנרת,ברזים | חשמל | [] |
| 4 | [] | ברזים | [] |

## DoD
```
dart run --enable-asserts new/dart/smart_products_for_cat_test.dart  ⇒ exit 0
```
