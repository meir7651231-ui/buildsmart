# חוזה · `smartProductByKey` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/data/smart_tree.dart:2553-2558`.

## תפקיד
מציאת המוצר-החכם הראשון ששדה-המפתח שלו שווה ל-[key] בקטלוג-המוזרק; null אם אין.

## חתימה
```dart
SmartProduct? smartProductByKey(String key, {required List<SmartProduct> catalog})
```

## שקע
- `catalog` — **שקע-דאטה**: במקור `kSmartProducts` (const, data/smart_tree.dart). מוזרק ⇒ מנוע טהור, מתחלף פר-ורטיקל.

## טיפוס-מינימום
`SmartProduct { final String key; const SmartProduct(...) }` — רק `key`.

## דוגמאות-מחייבות
| # | key | ⇒ |
|---|---|---|
| 1 | pipe-b | הפריט pipe-b |
| 2 | faucet-a (כפיל) | הפריט הראשון (זהות) |
| 3 | nope | null |
| 4 | קטלוג ריק | null |

## DoD
```
dart run --enable-asserts new/dart/smart_product_by_key_test.dart  ⇒ exit 0
```
