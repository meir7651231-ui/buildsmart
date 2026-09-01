# חוזה · `estimatePressureDrop`

**מוצא (קדוש, חוק-4):** `buildsmart/app_flutter/lib/logic/pressure_drop.dart:352-483`
(`estimatePressureDrop`). ההידראוליקה זהה בדיוק, לא-משופרת.

## קלט
| שם | טיפוס | ברירת-מחדל | משמעות |
|----|-------|-----------|--------|
| `chain` | `List<P>` | — | שרשרת-המוצרים |
| `pipeLengthMeters` | `double` | `5.0` | אורך-הצינור הישר (m) |
| `flowRateLPS` | `double` | `0.3` | ספיקה (L/s) |
| `verticalRiseMeters` | `double` | `0.0` | עלייה אנכית (m); שלילי מוסיף לחץ |
| `skuOf` (שקע) | `String Function(P)` | — | ‏P → sku (:362,373) |
| `nameHeOf` (שקע) | `String Function(P)` | — | ‏P → שם-עברי (:413,424,459) |
| `kOf` (שקע) | `double Function(P)` | — | מקדם-K. מקור `_kForType(p.productType)` (:363) |
| `minBoreOf` (שקע) | `double? Function(P)` | — | קוטר-מינימלי (m). מקור `_minBoreOf(p)` (:375) |
| `widerSiblingOf` (שקע) | `P? Function(P)` | — | אח-רחב. מקור `widerSiblingOf(bottleneck)` (:406) |
| `frictionFactor` (שקע) | `double Function(double)` | — | מקדם-חיכוך. מקור `_frictionFactor(reynolds)` (:392) |
| `offLineSkus` (שקע) | `Set<String>` | `_defaultOffLineSkus` | SKU-ים חוצי-קו. verbatim מ-:99-103 |

## פלט — `PressureDropResult<P>`
`dropBar` · `totalK` · `frictionMetres`(=pipeLengthMeters) · `minBoreMm` · `bottleneck`(P?) ·
`bottleneckSku`(תווית ל-toString) · `suggestions`(List<FlowSuggestion<P>>). נגזרות: `warnings`
(בעיות שאינן `ok`) · `exceedsBudget`(`dropBar>1.0`).

## הנוסחה (עוגני-שורה — :384-398)
```
area = 3.14159265·D²/4      q = flowLPS/1000      v = q/area
Re   = ρ·v·D/μ              (ρ=1000, μ=0.001, g=9.81)
f    = frictionFactor(Re)   frictionTerm = f·L/D
dynamicPa = (ΣK + frictionTerm)·(ρ·v²/2)   staticPa = ρ·g·rise
dropBar   = (dynamicPa + staticPa)/1e5
```
- **ΣK ומינימום-הקוטר מדלגים על `offLineSkus`** (:362,373) — ברז-דגימה 4mm אינו בקבוק ואינו נספר.
- קוטר-מינימלי נשמר עם המוצר-הבעלים כ-`bottleneck` (:376-379); חסר-כל-קוטר ⇒ `minBore=0.020` (:382).

## הצעות-פעולה (סדר-חומרה, :403-473)
1. **צוואר-בקבוק** (`minBore·1000<13 && flow≥0.3`, :407) ⇒ `swap`. עם אח-רחב: `'החלף את "<שם>" ב-"<שם-רחב>"'` (:413).
2. אחרת **מהירות-גבוהה** (`v>2.0 && bottleneck≠null`, :418) ⇒ `swap`.
3. **חריגת-תקציב** (`dropBar>1.0`, :432) ⇒ `add`, `addProductSku='HW-PUMP-40'`.
4. **עלייה-אנכית** (`rise≥10`, :443) ⇒ `add`, בעיה `'עלייה אנכית <N> מ׳ — <N·0.098> בר אובדים על הגובה'`.
5. **זרימה-לאמינרית** (`Re<2300 && flow≥0.2 && bottleneck≠null`, :455) ⇒ `swap`, בעיה `'זרימה לאמינרית (Re=<N>) …'`.
6. ריק ⇒ `'הקו תקין'` / `ok` (:467-473).

> **התאמת-גנריקה (חוק-3):** `PressureDropResult`/`FlowSuggestion` מוגנרקים `<P>`; `bottleneck?.sku`
> ב-`toString` נשמר דרך שדה `bottleneckSku` (הגנריקה אינה יכולה לגשת לשדה) — הפלט ביט-זהה למקור.
> ה-`const FlowSuggestion` של מקרה-ה-ok הפך ל-`FlowSuggestion<P>` (אסור const עם משתנה-טיפוס; אפס שינוי-התנהגות).

## דוגמאות מספריות (frictionFactor = _frictionFactor+_pow025 Newton verbatim, :317-339)
| # | chain (sku:k:bore_m) | flow · rise | ⇒ totalK · minBoreMm · dropBar | הצעות | עוגן |
|---|----------------------|-------------|-------------------------------|-------|------|
| S1 | `A:0.9:.020`, `B:0.05:.025` | 0.3 · 0 | `0.95` · `20.0` · `0.024454720795368902` | 1× `ok` | :360-398,467 |
| S2 | `A:0.9:.010`, `B:0.1:.032` | 0.3 · 0 | `1.0` · `10.0` · `0.5313159905807183` | 1× `swap` `'צוואר-בקבוק — קוטר 10mm צר מדי לזרימה 0.3 L/s'` → `'החלף את "ברך צרה" ב-"ברך רחבה"'` | :407-417 |
| S3 | `HW-SAMPLE:0.9:.004`, `B:0.1:.020` | 0.3 · 0 | `0.1` · `20.0` · `0.020579185512192594` | 1× `ok` | :362,373 (חוצה-קו מודר); bottleneck=`B` |
| S4 | `A:0.9:.020` | 0.3 · 12 | dropBar `1.2014267481316527` | `add`(HW-PUMP-40) + `add` `'עלייה אנכית 12 מ׳ — 1.2 בר אובדים על הגובה'` | :396,432,443 |
| S5 | `A:0.9:.160` | 0.2 · 0 | minBoreMm `160.0`, Re≈`1591.55` | 1× `swap` `'זרימה לאמינרית (Re=1592) — הקוטר גדול מהנדרש, מבזבז חומר'` | :455-462 |

בנוסף: `S1.toString() == 'ΔP = 0.02 bar  (K=0.95, L=5.0m, minBore=20.0mm, bottleneck=A)'` (:185-190).

## DoD
`dart run --enable-asserts new/dart/estimate_pressure_drop_test.dart` ⇒ exit 0
(`OK estimatePressureDrop: 34 asserts passed`).
`dart analyze new/dart/estimate_pressure_drop.dart` ⇒ אפס errors.
