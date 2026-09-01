# חוזה · recommendedKitForProduct

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/logic/install_kit.dart:42-149`
**אטום:** `new/dart/recommended_kit_for_product.dart` — `List<KitItem> recommendedKitForProduct(KitProduct p, {verifiedSpecs})`

## קלט
- `p` — `KitProduct`: `sku` (String) · `brand` (String) · `dims` (Map&lt;String,dynamic&gt;? — נקרא ב-`dims['dn נומינלי']` בשער-PPR, ‏`dims['DN']` בשער-חוליות) · `categoryHe` (String — נקרא בשער-חוליות). אלה השדות היחידים ש-recommendedKitForProduct קורא (install_kit.dart:43,48,50,92,93).
- `verifiedSpecs` — שקע `Map<String, KitSpec>` (מייצג `kVerifiedSpecs`, install_kit.dart:43). `KitSpec` = `material` (String) · `ends` (List&lt;KitEnd&gt;); `KitEnd` = `type` (EndType) · `size` (String). חסר-מפתח ⇒ `null`. ברירת-מחדל `const {}`.

## פלט
`List<KitItem>` — `KitItem` = `kind` (KitKind: tool/sealant/safety) · `label` (String) · `reason` (String) · `severity` (Severity: required[ברירת-מחדל]/recommended/optional).

## התנהגות (עוגני-שורה למקור)
1. **שער-PPR** — `brand=='פולירול'` **או** `spec?.material.startsWith('PPR')`: מחזיר ערכת-ריתוך קבועה בת **6 פריטים** (install_kit.dart:48-86). `dn = dims['dn נומינלי']?.toString() ?? ''`; ריק ⇒ הליבל ללא-קוטר, אחרת מוסיף ` $dn` / ` ⌀$dn מ"מ`. פריטים 0-3 = `required`, פריטים 4-5 = `recommended`.
2. **שער-חוליות (SmartLock)** — `brand=='חוליות'` (install_kit.dart:91-111): `dn = double.tryParse(dims['DN']?.toString() ?? '') ?? 0`; `isPipe = categoryHe.contains('צינור')`; `wrenchLabel = dn<=40 ? 'מפתח לאום SmartLock 32-40 (מק"ט 61040360)' : 'מפתח לאום SmartLock 50-63 (מק"ט 61060560)'`. מחזיר: פריט-חותך `required` **רק כש-isPipe** (`'חותך צינורות SmartLock'`), ואז תמיד פריט-מפתח `recommended` (`wrenchLabel`). ⇒ אורך 2 כשצינור, 1 אחרת.
3. `spec == null` (ולא-PPR, ולא-חוליות) ⇒ `const []` (install_kit.dart:112).
4. אחרת — לכל `e` ב-`spec.ends`, `putIfAbsent` לפי-מפתח (מנקה-כפילויות, install_kit.dart:116-147):
   - `bspMale`/`bspFemale` ⇒ `wrench-bsp-<size>` (מפתח-שוודי) + `ptfe` (סרט-טפלון sealant) (install_kit.dart:117-127).
   - `hdpeCompression` ⇒ `wrench-comp-<material>-<size>` (install_kit.dart:128-133).
   - `pexPress` ⇒ `crimper-pex-<size>` (install_kit.dart:134-139).
   - `copperPress` ⇒ `press-cu-<size>` (install_kit.dart:140-146).

## דוגמאות מספריות (מוכחות ב-recommended_kit_for_product_test.dart)
| # | קלט | אורך | בולטים | עוגן |
|---|-----|------|--------|------|
| 1 | brand='פולירול', dims=null | 6 | [0]='מצמד PPR (אביזר חיבור)' · [2]='תבנית/ראש ריתוך' · [4].severity=recommended | :48-86 |
| 2 | brand='פולירול', dims={'dn נומינלי':40} | 6 | [0]='מצמד PPR 40 (אביזר חיבור)' · [2]='תבנית/ראש ריתוך ⌀40 מ"מ' | :52-66 |
| 3 | brand='x', spec.material='PPR-100' | 6 | זהה ל-#1 (שער דרך material) | :48 |
| 4 | brand='x', sku ללא-spec | 0 | `const []` | :112 |
| 5 | ends=[bspMale '1/2"', bspFemale '1/2"'], material='פליז' | 2 | 'מפתח שוודי מתכוונן להברגה 1/2"' + 'סרט טפלון (PTFE)' (ptfe מנוקה-כפילות) | :117-127 |
| 6 | ends=[hdpeCompression '32'], material='HDPE' | 1 | 'מפתח חבישה DN32 ל-HDPE' | :128-133 |
| 7 | ends=[pexPress '16'], material='PEX' | 1 | 'מכווץ PEX (Crimper) ל-16' | :134-139 |
| 8 | brand='חוליות', dims={'DN':40}, categoryHe='צינור ביוב' | 2 | [0]='חותך צינורות SmartLock' (required) · [1]='מפתח לאום SmartLock 32-40 (מק"ט 61040360)' (recommended) | :91-111 |
| 9 | brand='חוליות', dims={'DN':63}, categoryHe='אביזר' | 1 | [0]='מפתח לאום SmartLock 50-63 (מק"ט 61060560)' (recommended; אין חותך — לא-צינור) | :91-111 |

## עדשה-עוינת (קלטי-קצה — CURRICULUM #6)
- שער-PPR גובר על ה-spec: גם spec==null עם brand='פולירול' ⇒ 6 פריטים (#1, :48).
- שער-PPR קופץ דרך **שני** מסלולים (brand או material) — `??false` מגן על spec==null (#3, :48).
- שער-חוליות אחרי שער-PPR ולפני `spec==null`: brand='חוליות' ⇒ ערכת-SmartLock גם ללא-spec (#8/#9, :91).
- חוליות: `dn<=40` הוא סף-כולל — DN=40 ⇒ מפתח 32-40 (#8); DN=63 ⇒ 50-63 (#9). `dims` חסר ⇒ dn=0 ⇒ מפתח 32-40.
- חוליות: החותך מותנה `categoryHe.contains('צינור')` בלבד — קטגוריה ללא-'צינור' ⇒ פריט-מפתח יחיד (#9, :98).
- `ptfe` בעל-מפתח-קבוע ⇒ מופיע פעם-אחת גם על שני קצוות-BSP (putIfAbsent, #5, :123).
- קצה שאינו אחד מ-4 הסוגים המזוהים ⇒ נדלג בשקט (חסר ב-out); spec ריק-קצוות ⇒ `[]` (:116-147).
