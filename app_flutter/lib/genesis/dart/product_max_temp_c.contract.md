# חוזה · productMaxTempC

**מוצא:** `buildsmart/app_flutter/lib/logic/install_engine.dart:51` (verbatim, חוק-4).

## חתימה
```dart
double? productMaxTempC<P, S>(P p, {
  required S? Function(P) specOf,
  required double Function(S) maxTempCOf,
});
```

## קלט
- `p` — המוצר (במקור בעל `.sku` לחיפוש ב-`kVerifiedSpecs`).
- `specOf` — שקע: `p → S?` — ה-spec המאומת של המוצר, או `null` כשאין (מקור:51, `?.`).
- `maxTempCOf` — שקע: `S → double` — טמפרטורת-השירות-המרבית של החומר (°C).

## פלט
`double?` — `maxTempC` של ה-spec, או `null` כשאין spec מאומת.

## התנהגות
`kVerifiedSpecs[p.sku]?.maxTempC` — ה-`?.` חי באטום: אין spec ⇒ `null`.

## דוגמאות (עוגן install_engine.dart:51)
| # | p.sku | spec.maxTempC | פלט |
|---|-------|---------------|-----|
| 1 | HDPE  | 40            | 40  |
| 2 | PEX   | 95            | 95  |
| 3 | CU    | 110           | 110 |
| 4 | RAW (אין spec) | —    | null |
