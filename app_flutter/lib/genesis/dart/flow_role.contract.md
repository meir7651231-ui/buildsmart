# חוזה · flowRole

**מוצא:** `buildsmart/app_flutter/lib/logic/install_engine.dart:310-317` (verbatim, חוק-4).
עוגן enum: `:295` `enum FlowRole { connector, fixture, accessory }`.

## חתימה
```dart
enum FlowRole { connector, fixture, accessory }
FlowRole flowRole(String sku, String categoryHe, {
  Set<String> hotWaterAccessorySkus = const {},
});
```

## קלט
- `sku` — SKU המוצר (`p.sku`).
- `categoryHe` — קטגוריית-המוצר (`p.categoryHe`).
- `hotWaterAccessorySkus` — שקע: מגלם `kHotWaterAccessorySkus` (מקור:312); ברירת-מחדל `{}`.

## פלט
`FlowRole` — קסקדה (מקור:311-316): SKU-אביזר / מבני ⇒ `accessory`; קבוע ⇒ `fixture`; אחרת ⇒ `connector`.

## התנהגות
`_accessorySkus`(:301-308) ∪ שקע ⇒ accessory · `_structuralCats`(:268-271) ⇒ accessory · `_fixtureCats`(:263-267) ⇒ fixture · else connector.

## דוגמאות (עוגן install_engine.dart:310-317)
| # | sku | categoryHe | hwAcc | פלט |
|---|-----|------------|-------|-----|
| 1 | HW-INSUL | צינורות | {} | accessory (sku) |
| 2 | 77701185 | ברזי מעבר | {} | accessory (מתלה) |
| 3 | HW-PUMP-25 | צינורות | {HW-PUMP-25} | accessory (שקע) |
| 4 | X | חבקי תליה | {} | accessory (מבני) |
| 5 | X | אסלות וכיורים | {} | fixture |
| 6 | X | אביזרי נחושת | {} | connector |
