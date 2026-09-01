# חוזה · `swapMatesWithNeighbours`

**מוצא (קדוש, חוק-4):** `buildsmart/app_flutter/lib/logic/pressure_drop.dart:255-266`
(`_swapMatesWithNeighbours`). התנהגות זהה בדיוק, לא-משופרת.

## קלט
| שם | טיפוס | משמעות |
|----|-------|--------|
| `chain` | `List<P>` | שרשרת-המוצרים |
| `idx` | `int` | אינדקס המוצר-המוחלף (הערך ב-`chain[idx]` **אינו נקרא**) |
| `candidate` | `P` | המוצר-המועמד להחלפה |
| `skuOf` (שקע) | `String Function(P)` | ‏P → sku. מקור: `candidate.sku` / `chain[ni].sku` (‏:257,261) |
| `specExists` (שקע) | `bool Function(String)` | האם קיים spec-מאומת ל-sku. מקור: `kVerifiedSpecs[sku]==null` (‏:257,261) |
| `compatible` (שקע) | `bool Function(String,String)` | האם שני ה-spec-ים תואמים. מקור: `candSpec.compatibleWith(neighborSpec)` (‏:263) |

## פלט
`bool` — האם המועמד עדיין מתחבר לשני שכניו (‏idx-1 · idx+1) בשרשרת.

## התנהגות (עוגני-שורה למקור)
1. **מועמד ללא spec ⇒ `false` מיידי** — `if (candSpec == null) return false;` (:257-258).
2. לולאה על `[idx-1, idx+1]` (:259). אינדקס מחוץ-לטווח ⇒ `continue` (:260).
3. **שכן ללא spec ⇒ `continue`** (מדולג, לא-מכשיל) — `if (neighborSpec == null) continue;` (:261-262).
4. **שכן בעל-spec בלתי-תואם ⇒ `false`** — `if (!candSpec.compatibleWith(neighborSpec)) return false;` (:263).
5. עברו כל השכנים ⇒ `true` (:265).

> **שקע (חוק-3):** `kVerifiedSpecs`, `.compatibleWith`, ושדה `.sku` הוזרקו כפרמטרים —
> האטום אינו מייבא את המפה-הגלובלית ולא את `LipskeyCatalogProduct`.

## דוגמאות מספריות (מגלמות `_withSpec={'CAND','L','R','BAD'}` · `compatible=לא-מעורב-'BAD'`)
| # | chain | idx | candidate | ⇒ | עוגן |
|---|-------|-----|-----------|----|------|
| 1 | `['L','MID','R']` | 1 | `'NOSPEC'` | `false` | :257-258 (מועמד ללא spec) |
| 2 | `['L','MID','R']` | 1 | `'CAND'` | `true` | :263,265 (שני שכנים תואמים) |
| 3 | `['NOSPEC','MID','R']` | 1 | `'CAND'` | `true` | :262 (שכן-null מדולג) |
| 4 | `['BAD','MID','R']` | 1 | `'CAND'` | `false` | :263 (שכן בלתי-תואם) |
| 5 | `['SLOT','R']` | 0 | `'CAND'` | `true` | :260 (idx-1=-1 מדולג) |
| 6 | `['BAD','SLOT']` | 1 | `'CAND'` | `false` | :260,263 (idx+1 מחוץ, שמאל בלתי-תואם) |
| 7 | `['SLOT']` | 0 | `'CAND'` | `true` | :259-265 (אין שכנים בטווח) |

## DoD
`dart run --enable-asserts new/dart/swap_mates_with_neighbours_test.dart` ⇒ exit 0
(`OK swapMatesWithNeighbours: 7 asserts passed`).
`dart analyze new/dart/swap_mates_with_neighbours.dart` ⇒ אפס errors.
