# חוזה · productSystems

**מוצא:** `buildsmart/app_flutter/lib/logic/install_engine.dart:278-286` (verbatim, חוק-4).

## חתימה
```dart
enum WaterSystem { supply, drainage }
Set<WaterSystem> productSystems(String categoryHe, {
  required Set<WaterSystem>? Function() endSystemsOf,
});
```

## קלט
- `categoryHe` — קטגוריית-המוצר (`p.categoryHe`).
- `endSystemsOf` — שקע-thunk עצל: מגלם `kVerifiedSpecs[p.sku]?.endSystems` (מקור:284); נקרא **רק** בענף-הנפילה.

## פלט
`Set<WaterSystem>` — מערכות-המים של המוצר.

## התנהגות (מקור:280-285)
`_supplyCats`(:240-247) ⇒ `{supply}` · `_drainCats`(:257-262) ⇒ `{drainage}` · `_fixtureCats`/`_structuralCats` ⇒ `{supply,drainage}` · קטגוריה-עמומה ⇒ קצות-המוצר; ריק/null ⇒ `{supply,drainage}`.

## דוגמאות (עוגן install_engine.dart:280-285)
| # | categoryHe | endSystemsOf() | פלט |
|---|------------|----------------|-----|
| 1 | אביזרי נחושת | (לא-נקרא) | {supply} |
| 2 | סיפונים | (לא-נקרא) | {drainage} |
| 3 | אסלות וכיורים | (לא-נקרא) | {supply,drainage} |
| 4 | אביזרי תבריג (עמום) | {supply} | {supply} |
| 5 | אביזרי תבריג (עמום) | null | {supply,drainage} |
| 6 | אביזרי תבריג (עמום) | {} (ריק) | {supply,drainage} |
