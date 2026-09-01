# חוזה · `catalogProductForBrand` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/data/related_info.dart:98-99`.

## תפקיד
מחזיר את מוצר-הקטלוג שאליו מצביע מק"ט-המותג; null כשאין מק"ט או שהמק"ט לא באינדקס.

## חתימה
```dart
LipskeyCatalogProduct? catalogProductForBrand(SmartBrand brand,
    {required Map<String, LipskeyCatalogProduct> skuIndex})
```

## שקע
- `skuIndex` — **שקע-דאטה**: במקור `_skuIndex` (מטמון-גלובלי הנבנה פעם מ-`resolvedCatalogProducts`/`kLipskeyCatalog` — מק"ט→מוצר). הוזרק כמפה ⇒ המנוע טהור, אפס IO/מטמון, מתחלף פר-ורטיקל.

## טיפוסי-מינימום
- `SmartBrand { final String? sku; ... }` — רק `sku`.
- `LipskeyCatalogProduct { const ... }` — ערך-האינדקס בלבד.

## דוגמאות-מחייבות
| # | brand.sku | ⇒ |
|---|---|---|
| 1 | SKU-A (באינדקס) | המוצר pA (זהות) |
| 2 | null | null |
| 3 | SKU-Z (לא באינדקס) | null |
| 4 | SKU-A, אינדקס-ריק | null |

## DoD
```
dart run --enable-asserts new/dart/catalog_product_for_brand_test.dart  ⇒ exit 0
```
