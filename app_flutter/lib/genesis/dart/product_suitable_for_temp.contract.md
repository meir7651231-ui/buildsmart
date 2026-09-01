# חוזה · productSuitableForTemp

**מוצא:** `buildsmart/app_flutter/lib/logic/install_engine.dart:58-61` (verbatim, חוק-4).

## חתימה
```dart
bool productSuitableForTemp<P>(P p, int tempC, {
  required double? Function(P) maxTempCOf,
});
```

## קלט
- `p` — המוצר (מועבר ל-`maxTempCOf`).
- `tempC` — טמפרטורת-הקו (int, °C).
- `maxTempCOf` — שקע: `p → double?` — מגלם `productMaxTempC(p)` (מקור:59); `null` = אין spec.

## פלט
`bool` — `t == null || tempC <= t`.

## התנהגות
לא-ידוע (`t==null`) ⇒ `true` (לא מסמנים 400+ פריטי-לגאסי ללא-spec). ידוע ⇒ `true` אך ורק כש-`tempC ≤ t`.

## דוגמאות (עוגן install_engine.dart:59-60)
| # | maxTempC | tempC | פלט | הערה |
|---|----------|-------|-----|------|
| 1 | 40       | 80    | false | HDPE ב-80°C — נחסם |
| 2 | 40       | 20    | true  | קר |
| 3 | 40       | 40    | true  | גבול `≤` |
| 4 | 95       | 96    | false | חורג ב-1° |
| 5 | null     | 80    | true  | לא-ידוע ⇒ מותר |
