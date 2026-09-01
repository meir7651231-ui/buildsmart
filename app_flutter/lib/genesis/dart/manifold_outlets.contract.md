# חוזה · manifoldOutlets

**מוצא:** `buildsmart/app_flutter/lib/logic/install_engine.dart:1249-1258` (verbatim, חוק-4).

## חתימה
```dart
int manifoldOutlets<P>(P p, {
  required List<String>? Function(P) endSizesOf,
});
```

## קלט
- `p` — המוצר.
- `endSizesOf` — שקע: `p → List<String>?` — גדלי-הקצוות (`e.size` לכל קצה), מגלם `kVerifiedSpecs[p.sku]?.ends`; `null` כשאין spec.

## פלט
`int` — מספר-המוצאים הזהים של מחלק, או `0` כשאינו מחלק.

## התנהגות (מקור:1251-1257)
אין spec / פחות מ-3 קצוות ⇒ `0`. אחרת `maxc` = הריבוי-המרבי של גודל-קצה; `maxc ≥ 2 ? maxc : 0`.

## דוגמאות (עוגן install_engine.dart:1251-1257)
| # | endSizes | פלט | הערה |
|---|----------|-----|------|
| 1 | [1, ½, ½, ½] | 3 | מחלק 4-מוצאים |
| 2 | [32, 32] | 0 | <3 קצוות |
| 3 | [1, ½, ¾] | 0 | 3 שונים, maxc=1 |
| 4 | [1, ½, ½] | 2 | זוג ½" |
| 5 | [½, ½, ½, ½, 1] | 4 | ארבע ½" |
| 6 | null (אין spec) | 0 | |
