# חוזה · pipeConnectionDn

**מוצא:** `buildsmart/app_flutter/lib/logic/install_engine.dart:423-432` (verbatim, חוק-4).

## חתימה
```dart
enum EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale, drainOpening }
class ConnEnd { final EndType type; final String size; const ConnEnd(this.type, this.size); }
String? pipeConnectionDn<P>(P a, P b, {
  required List<ConnEnd>? Function(P) endsOf,
});
```

## קלט
- `a`, `b` — שני המוצרים.
- `endsOf` — שקע: `p → List<ConnEnd>?` — מגלם `kVerifiedSpecs[p.sku]?.ends`; `null` כשאין spec.

## פלט
`String?` — גודל-ה-DN של קטע-הצינור המשותף, או `null`.

## התנהגות (מקור:424-431)
צד ללא-spec ⇒ `null`. הזוג-הראשון (בסדר-הסריקה) של קצות `hdpeCompression` בעלי אותו גודל (`_pipeShared`, lvc.dart:50-53) ⇒ `eA.size`. אין ⇒ `null`.

## דוגמאות (עוגן install_engine.dart:426-431)
| # | a.ends | b.ends | פלט |
|---|--------|--------|-----|
| 1 | [hdpe 32] | [hdpe 32] | 32 |
| 2 | [hdpe 32] | [hdpe 25] | null |
| 3 | [bspMale 1/2"] | [bspFemale 1/2"] | null (תבריג, לא-צינור) |
| 4 | [hdpe 32] | (אין spec) | null |
| 5 | [hdpe 25, hdpe 32] | [hdpe 32] | 32 (הזוג-הראשון התואם) |
