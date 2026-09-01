# חוזה · recommendedKitFor

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/logic/install_kit.dart:130-260`
**מתודות-שכן (verbatim):** `ConnectorEnd.directMatesWith`/`pipeSharedWith` — `lipskey_verified_connections.dart:38-53`
**אטום:** `new/dart/recommended_kit_for.dart` — `List<KitItem> recommendedKitFor(List<ChainProduct> chain, {verifiedSpecs})`

## קלט
- `chain` — `List<ChainProduct>` (רצף-ההתקנה המסודר). `ChainProduct` נושא **רק** `sku` (install_kit.dart:139).
- `verifiedSpecs` — שקע `Map<String, KitSpec>` (מייצג `kVerifiedSpecs`). `KitSpec` = `ends` (List&lt;KitEnd&gt;) · `material` (String); `KitEnd` = `type` (EndType) · `size` (String) + מתודות `directMatesWith`/`pipeSharedWith` (הוטבעו verbatim). חסר-מפתח ⇒ `null`. ברירת-מחדל `const {}`.

## פלט
`List<KitItem>` מנוקה-כפילויות (putIfAbsent לפי-מפתח, install_kit.dart:134-136).

## התנהגות (עוגני-שורה למקור)
1. `chain.length < 2` ⇒ `const []` (install_kit.dart:131).
2. לכל צמד-סמוך `(a,b)`: אם `sa`/`sb` (specs) חסר ⇒ `continue` (install_kit.dart:140-142).
3. איתור-מפרק — לולאה כפולה על הקצוות; `directMatesWith` גובר (isDirect, שובר), אחרת `pipeSharedWith` ראשון-שנמצא (install_kit.dart:145-161). אין-מפרק ⇒ `continue` (:162).
4. `jointA.type` ∈ {bspMale, bspFemale} ⇒ `wrench-bsp-<size>` ('לחיבור הברגה') + `ptfe` (install_kit.dart:165-179).
5. **שני** החומרים `startsWith('PPR')` ⇒ `ppr-welder` + `ppr-die-<size>` + `ppr-cutter`; **גובר** על ענף-החבישה (else-if) (install_kit.dart:182-201).
6. אחרת אם `jointA.type == hdpeCompression` ⇒ `wrench-comp-<material>-<size>` (install_kit.dart:203-211).
7. `jointA.type == pexPress` ⇒ `crimper-pex-<size>` (if נפרד, install_kit.dart:214-221).
8. `jointA.type == copperPress` ⇒ `press-cu-<size>` (if נפרד, install_kit.dart:224-231).
9. `ma != mb` ⇒ אם שני-הצדדים ב-{נחושת,פליז,פלדה,נירוסטה}: `dielectric` (safety); תמיד: `hemp` (sealant, recommended) (install_kit.dart:235-256).

## דוגמאות מספריות (מוכחות ב-recommended_kit_for_test.dart)
| # | chain / specs | אורך | בולטים | עוגן |
|---|---------------|------|--------|------|
| 1 | `[A]` (אורך 1) | 0 | `const []` | :131 |
| 2 | `[A,B]`, spec רק ל-A | 0 | sb==null ⇒ continue | :142 |
| 3 | bspMale '1/2"' (פליז) ↔ bspFemale '1/2"' (פליז) | 2 | 'מפתח שוודי מתכוונן לחיבור הברגה 1/2"' + 'סרט טפלון (PTFE)' | :165-179 |
| 4 | bspMale '3/4"' (נחושת) ↔ bspFemale '3/4"' (פלדה) | 4 | +'רקורד דיאלקטרי'(safety) +'חמצן (hemp)…'(recommended) | :235-256 |
| 5 | hdpeComp '40' (PPR) ↔ hdpeComp '40' (PPR) | 3 | 'מכונת ריתוך-שקע PPR (260°C)' · 'תבנית ריתוך ⌀40 מ"מ' · 'חותך צינור PPR' | :182-201 |
| 6 | hdpeComp '32' (HDPE) ↔ hdpeComp '32' (HDPE) | 1 | 'מפתח חבישה DN32 ל-HDPE' | :203-211 |
| 7 | pexPress '16' (PEX) ↔ pexPress '16' (PEX) | 1 | 'מכווץ PEX (Crimper) ל-16' | :214-221 |

## עדשה-עוינת (קלטי-קצה — CURRICULUM #6)
- ליבל-ה-BSP כאן ('לחיבור הברגה') שונה מ-recommendedKitForProduct ('להברגה') — verbatim, לא-מאוחד (#3, :169).
- PPR-both **גובר** על ענף-החבישה (else-if): מפרק hdpeCompression בין שני-PPR ⇒ ערכת-ריתוך, לא מפתח-חבישה (#5, :182).
- pexPress/copperPress הם `if` **נפרדים** (לא else) — יכולים להצטבר על-גבי ה-BSP/PPR/hdpe באותו מפרק (:214,:224).
- דיאלקטרי רק כששני-הצדדים מתכת-אספקה; hemp על **כל** מעבר-חומרים (גם פלסטיק↔מתכת) (#4, :240-255).
