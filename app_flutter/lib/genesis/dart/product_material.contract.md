# חוזה · productMaterial

**מוצא:** `buildsmart/app_flutter/lib/logic/install_engine.dart:54` (verbatim, חוק-4).

## חתימה
```dart
String? productMaterial<P, S>(P p, {
  required S? Function(P) specOf,
  required String Function(S) materialOf,
});
```

## קלט
- `p` — המוצר (במקור בעל `.sku` לחיפוש ב-`kVerifiedSpecs`).
- `specOf` — שקע: `p → S?` — ה-spec המאומת, או `null` (מקור:54, `?.`).
- `materialOf` — שקע: `S → String` — תווית-החומר.

## פלט
`String?` — `material` של ה-spec, או `null` כשאין spec מאומת.

## התנהגות
`kVerifiedSpecs[p.sku]?.material` — אין spec ⇒ `null`.

## דוגמאות (עוגן install_engine.dart:54)
| # | p.sku | spec.material | פלט |
|---|-------|---------------|-----|
| 1 | A     | HDPE          | HDPE |
| 2 | B     | PEX           | PEX  |
| 3 | C     | נחושת         | נחושת |
| 4 | D     | פליז          | פליז |
| 5 | RAW (אין spec) | —    | null |
