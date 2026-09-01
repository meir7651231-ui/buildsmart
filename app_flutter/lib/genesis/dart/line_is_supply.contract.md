# חוזה · lineIsSupply

**מוצא:** `buildsmart/app_flutter/lib/logic/install_engine.dart:68-69` (verbatim, חוק-4).

## חתימה
```dart
enum WaterSystem { supply, drainage }
bool lineIsSupply<P>(List<P> items, {
  required Set<WaterSystem>? Function(P) endSystemsOf,
});
```

## קלט
- `items` — מוצרי-הקו.
- `endSystemsOf` — שקע: `p → Set<WaterSystem>?` — מגלם `kVerifiedSpecs[p.sku]?.endSystems` (מקור:69); `null` כשאין spec.

## פלט
`bool` — האם **לפחות מוצר אחד** נושא קצה-אספקה (`endSystems ∋ supply`).

## התנהגות
`items.any((p) => endSystemsOf(p)?.contains(supply) ?? false)`. קו-ניקוז-כובד טהור ⇒ `false`.

## דוגמאות (עוגן install_engine.dart:68-69)
| # | endSystems פר-פריט | פלט |
|---|---------------------|-----|
| 1 | [{supply}]          | true |
| 2 | [{drainage}]        | false |
| 3 | [{drainage},{supply}] | true |
| 4 | [null (אין spec)]   | false |
| 5 | [] (ריק)            | false |
