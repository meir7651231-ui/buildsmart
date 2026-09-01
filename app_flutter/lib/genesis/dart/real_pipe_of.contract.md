# חוזה · realPipeOf

**מוצא:** `buildsmart/app_flutter/lib/logic/install_engine.dart:996-1010` (‏`_realPipeOf`, verbatim, חוק-4).
(הטיוטה ציינה `chainUniverse`; במקור-החי הלולאה על `kCompatCatalog`:997 — שניהם קרסו לשקע `catalog`.)

## חתימה
```dart
enum EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale, drainOpening }
class ConnEnd { final EndType type; final String size; const ConnEnd(this.type, this.size); }
class PipeSpecView { final String material; final List<ConnEnd> ends; const PipeSpecView(this.material, this.ends); }
P? realPipeOf<P>(String dn, Set<String> mats, {
  required Iterable<P> catalog,
  required bool Function(P) isPipe,
  required PipeSpecView? Function(P) specOf,
  required Set<String> drainageFamily,
});
```

## קלט
- `dn` — גודל-ה-DN המבוקש (למשל `'32'`).
- `mats` — חומרי-הקצוות המשתתפים בחיבור.
- `catalog` — שקע: מגלם את `kCompatCatalog` (‏:997), סדר-הסריקה = סדר-הרשימה.
- `isPipe` — שקע: מגלם את `_isPipeProductE(p)` (‏:998; האטום-השכן is_pipe_product_e — הקופסה מחווטת).
- `specOf` — שקע: `p → PipeSpecView?` — מגלם `kVerifiedSpecs[p.sku]` (‏:999); `null` כשאין spec.
- `drainageFamily` — שקע-דאטה: מגלם את `_kDrainageFamily` (‏:991) — במקור `{'PVC','PP','רב-שכבתי','ceramic'}`; לא-צרוב במנוע.

## פלט
`P?` — מוצר-הצינור הקטלוגי **הראשון** (בסדר-הסריקה) שתואם, או `null`.

## התנהגות (מקור:996-1010)
1. לא-צינור (`!isPipe`) ⇒ דילוג (‏:998).
2. אין spec ⇒ דילוג (‏:1000).
3. תאימות-חומר (‏:1002-1003): `mats.contains(m)` **או** (`m ∈ drainageFamily` וגם `mats` מכיל חבר-כלשהו של `drainageFamily`). לא-תואם ⇒ דילוג.
4. קיים קצה `hdpeCompression` עם `size == dn` (‏:1005) ⇒ החזרת המוצר.
5. סוף-הקטלוג ⇒ `null` (‏:1009).

## דוגמאות (עוגן install_engine.dart:996-1010; drainageFamily={'PVC','PP','רב-שכבתי','ceramic'})
| # | מוצר-בקטלוג (material · ends) | dn | mats | פלט |
|---|---|---|---|---|
| 1 | PVC · [hdpe 110] | 110 | {PVC} | המוצר (התאמה-ישירה) |
| 2 | PVC · [hdpe 110] אך `isPipe=false` | 110 | {PVC} | null (לא-צינור) |
| 3 | ‏spec חסר (`specOf⇒null`) | 110 | {PVC} | null |
| 4 | PVC · [hdpe 110] | 110 | {PP} | המוצר (צלב-משפחת-ניקוז) |
| 5 | PVC · [hdpe 110] | 110 | {HDPE} | null (אין חבר-ניקוז ב-mats) |
| 6 | HDPE · [hdpe 32] | 32 | {HDPE} | המוצר (ישיר, לא-ניקוז) |
| 7 | PVC · [hdpe 110] | 50 | {PVC} | null (גודל-לא-תואם) |
| 8 | PVC · [bspMale 110] | 110 | {PVC} | null (סוג-קצה-לא-hdpe) |
| 9 | שני-תואמים בקטלוג | — | — | הראשון-בסדר-הסריקה |
| 10 | קטלוג-ריק | 110 | {PVC} | null |

## DoD
`dart run --enable-asserts new/dart/real_pipe_of_test.dart` ⇒ exit 0.
