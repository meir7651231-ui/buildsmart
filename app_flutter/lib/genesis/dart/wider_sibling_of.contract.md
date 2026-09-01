# חוזה · `widerSiblingOf`

**מוצא (קדוש, חוק-4):** `buildsmart/app_flutter/lib/logic/pressure_drop.dart:271-311`
(`widerSiblingOf`). התנהגות זהה בדיוק, לא-משופרת.

## קלט
| שם | טיפוס | משמעות |
|----|-------|--------|
| `p` | `P` | המוצר שמחפשים לו "אח רחב-יותר" |
| `catalog` (שקע) | `List<P>` | רשימת-המוצרים לסריקה. מקור: `kCatalogProducts` (:288) |
| `skuOf` (שקע) | `String Function(P)` | ‏P → sku (:289) |
| `productTypeOf` (שקע) | `String? Function(P)` | ‏P → סוג-מוצר (:290) |
| `brandOf` (שקע) | `String Function(P)` | ‏P → מותג (:291) |
| `categoryHeOf` (שקע) | `String Function(P)` | ‏P → קטגוריה (:292) |
| `minBoreOf` (שקע) | `double? Function(P)` | הקוטר-הפנימי-המינימלי (m). מקור: `kVerifiedSpecs[sku]?.ends`+`_boreMeters` (:272-281 עבור p · :293-302 עבור q) |

## פלט
`P?` — האח ה**רחב-הקטן-ביותר-שעדיין-עוזר** (אותו productType+brand+categoryHe, קוטר גדול-יותר),
או `null` כשאין ל-p קוטר-ניתן-לפענוח / אין מועמד רחב-יותר.

## התנהגות (עוגני-שורה למקור)
1. `myMin = minBoreOf(p)`; `null ⇒ return null` — ממזג `spec==null` (:272) + `myMin==null` (:281).
2. לכל `q` בקטלוג, דלג כאשר: `sku==p.sku` (:289) · `productType!=` (:290) · `brand!=` (:291) · `categoryHe!=` (:292) · `minBoreOf(q)==null` (ממזג :293+:303) · `qMin<=myMin` (:303, לא-רחב).
3. **בחירת המינימום-שבשדרוגים:** `if (bestBore==null || qMin<bestBore){best=q;bestBore=qMin;}` (:304-307) — "הקטן שעדיין עוזר, לא הענק". בלתי-תלוי בסדר-ההופעה.
4. `return best;` (:310).

> **שקע (חוק-3):** `kCatalogProducts`, מפת-ה-specs, `_boreMeters`, ושדות `LipskeyCatalogProduct`
> הוזרקו — האטום גנרי `<P>` ואינו מייבא דבר.

## דוגמאות מספריות (בסיס `p`: type=ברך · brand=X · cat=C · bore=0.020m)
| # | catalog (sku:bore/סטייה) | ⇒ | עוגן |
|---|--------------------------|----|------|
| 1 | `P:0.050(=sku)`, `q2(type≠)`, `q3(brand≠)`, `q4(cat≠)`, `q5(bore=null)`, `q6:0.015`, `q7:0.020`, `q8:0.025`, `q9:0.032` | `q8` | :289-307 (הקטן-שבשדרוגים 25mm) |
| 2 | p-בסיס עם `bore=null`, קטלוג-מלא | `null` | :281 (אין myMin) |
| 3 | `a:0.010`, `b:0.020` (כולם ≤20) | `null` | :303 (אף-אחד לא רחב) |
| 4 | `w:0.050` אך brand=Z | `null` | :291 (מסונן-מותג) |
| 5 | `P:0.099` (אותו sku, רחב) | `null` | :289 (לא-מציע-את-עצמו) |
| 6 | `big:0.032` לפני `small:0.025` | `small` | :304-307 (הקטן, בלתי-תלוי-סדר) |

## DoD
`dart run --enable-asserts new/dart/wider_sibling_of_test.dart` ⇒ exit 0
(`OK widerSiblingOf: 6 asserts passed`).
`dart analyze new/dart/wider_sibling_of.dart` ⇒ אפס errors.
