# 🧬 DECOMP-DEPTH — פירוק-לעומק של השכבות שנשארו בשם-בלבד (100 שלבים)

> **הבעיה (מהבעלים):** הגרף מזכיר מנועים/דאטה/פרימיטיבים **בשם** — "קורא למנוע-החיבור" — אבל לא **פותח מה הם עושים בפנים**. מתכנת רואה שורת-קוד, לא איך זה עובד. **פירוק אמיתי = לראות את הפְּנים.**
> **העיקרון:** שם ≠ פירוק. אטום לא-מפורק-לעומק = חוב. כל מנוע/ישות/פרימיטיב חייב: **עצם · חיבורים · התנהגות(=האלגוריתם) · חוזה(קלט→פלט) · floor.**
> **North star:** מתכנת פותח אטום כלשהו ורואה את **הפְּנים** — האלגוריתם, החוזה, מבנה-הנתונים, המסע — לא רק שם.
> מקורות (`AGENT-SOURCES`): **קוד** מ-`whats-happening` (@98f74917 — כאן קורקע ב-3 סוקרים) · **מפרט/plan** מ-`nice-volta`.

---

## 🎯 מודל-הפירוק המורחב (מווידג'טים → ללוגיקה/דאטה/מסע)

המפרק הקיים (`tools/atom/decompose`) פותר **ווידג'טים**. השכבות שנשארו דורשות **ניתוח אחר**:

| שכבה | "עצם" | "חיבורים" | "התנהגות" | "floor" | "חוזה" |
|---|---|---|---|---|---|
| **לוגיקה** (פונקציה/מנוע) | שם·סיגנטורה·קבועים-מוטמעים | reads(state/params)·writes(mutations/IO/nav)·calls·called-by·gated-by | **האלגוריתם בצעדים** (precond→branch/formula/loop→effect) | פרימיטיב-שפה / קריאת-שדה / primitive-call | קלט→פלט·precond·postcond·invariants·null/throw·purity |
| **דאטה** (ישות/קטלוג) | שדות+טיפוסים+חובה+יחידות+ברירות | יחסים(FK/id)·נקרא-ע"י·נזרע-ע"י·persisted-where | מחזור-חיים(create/validate/mutate/delete)·invariants | טיפוס-שדה + חוק-ולידציה | הצורה שרשומה-תקינה מקיימת |
| **מסע** (navigation) | מסך(node)·`static route()` | קשתות: from→to·trigger·params | תנאי-מעבר·guards·provider-swaps | מסך-עלה | מסע-משתמש שלם(path) |

**Loop-until-floor:** צעד ברצפה = פרימיטיב-שפה, פרימיטיב-מתועד-בחוזה, או קריאה/כתיבה בודדת של שדה.

---

## 🗺️ מפת-הפאזות (ממופה 1:1 לפערי-הבעלים · לוגיקה-קודם)

| פאזה | פער | שלבים | תפוקה |
|---|---|---|---|
| **0 · שדרוג-הכלי** | *(מאפשר)* | 1–12 | מפרק-לוגיקה: analyzer element-model → call-graph + read/write של providers + חילוץ-אלגוריתם. |
| **L · לוגיקה/מנועים** ⭐ | #1 הכי חשוב | 13–45 | כל מנוע ב-`logic/`+`state/`+`domain/` מפורק 3-שכבות+חוזה. |
| **D · דאטה** | #2 | 46–62 | כל ישות/קטלוג/seed/schema ממופה. **הכרעת-מחיר.** |
| **P · חוזי-פרימיטיבים** | #3 | 63–70 | כל פרימיטיב-רצפה: קלט→פלט+ערובה+קצוות. |
| **N · מסעות** | #4 | 71–82 | גרף-מסע מלא + 3 המשטחים שעוקפים את ה-Navigator. |
| **async** | #5 | 83–86 | loading/error/empty כמצבי-התנהגות מפורשים. |
| **S · העמקת-רדודים** | #6 | 87–90 | 32 חד-אטום + 9 עזר → עומק מלא. |
| **W · מפרק-ווב** | #7 | 91–96 | כלי-שני (TS/TSX AST) → פירוק Preact החי. |
| **B · צד-שרת + capstone** | #8 | 97–100 | functions/scripts + לוח-כיסוי. |

**סדר:** `0 → L → D → P → N → async → S → W → B`.

---

## פאזה 0 · שדרוג-הכלי (1–12) — צוואר-הבקבוק האמיתי

**האמת:** אי-אפשר "להריץ את המפרק הקיים" על לוגיקה — הוא ל-widget-tree. פירוק-לוגיקה = ניתוח call-graph + data-flow. נבנה קודם.

- **1 · element-model** — הרחב `tools/atom/decompose` מ-widget-AST ל-`analyzer` element-model (functions·methods·top-level·providers·notifiers).
- **2 · call-graph** — לכל פונקציה: מי-היא-קוראת (invocations) + מי-קורא-לה (reverse). פלט = קשתות-calls.
- **3 · data-flow reads** — `ref.watch/read`·provider·params·globals·שדות-`this`·מפות-קבועות (`kVerifiedSpecs`, category-sets).
- **4 · data-flow writes** — `state=`·`.update()`·`notifyListeners`·IO(prefs/firestore)·nav(`Navigator.*`)·toast · **mutation-in-place** (`items.insert`).
- **5 · gated-by** — `if(kFlag)`·`if(role==)`·`if(tradeId!='plumbing')`·guards-מוקדמים·try/on-Object kill-switch.
- **6 · algorithm-extract** — גוף-הפונקציה כ-IR קריא (precond→branch/formula/loop→effect). **הלב.**
- **7 · contract-infer** — סיגנטורה→חוזה: קלט/פלט·nullability·`throw`-sites·`return`-early → precond/postcond·invariants.
- **8 · purity-tag** — טהור/דטרמיניסטי/side-effecting (מ-writes בשלב 4). זהה `DateTime.now`/`Random`/IO.
- **9 · floor-detect** — צעד ברצפה = primitive-call/field-access; אחרת המשך-פירוק.
- **10 · data-vs-engine split** — "עצם" שהוא טבלת-`const` (registry/schema) → **דאטה-אטום** (פאזה D), לא לוגיקה-אטום. רק `findDescriptor`/`fromJson` = לוגיקה.
- **11 · golden** — הרץ על **מנוע-הזהב `findShortestPath`** (שלב 13) → חייב לשחזר את הפירוק-הידני 1:1. `golden_test`.
- **12 · CI-gate** — `Atom Tools` NON-blocking נשאר · הכלי עם טסטים ירוקים · אפס-שינוי בקוד-האפליקציה (מפרק=קורא-בלבד).

---

## פאזה L · לוגיקה (13–45) — *הפרס · מקורקע ב-3 הסוקרים*

> **המפה:** `logic/`≈30 מנועים · `domain/` (resolver+schema) · `state/` (cart+notifiers). הליבה = `install_engine.dart` (1629 שורות, ~30 פונקציות, caches משותפים, מוטרים-in-place).

### הגולדן (13) — נקודת-העוגן לכל השאר
- **13 · ⭐ golden-engine: `findShortestPath`** (`logic/install_engine.dart:733`) — פרק ידנית 3-שכבות+חוזה, כיעד-שחזור לכלי (שלב 11). **למה זה:** Dijkstra אמיתי · reads(`chainUniverse`,`kVerifiedSpecs`) · writes(`_compatCache`) · calls-6 (`productSystems`,`canConnect`,`flowRole`,`compatibleWith`,`_usableConnector`,`_edgeCost`) · called-by-3 · נוסחת-עלות (`10·parts + material-transitions + bore`) · חוזה null-on-no-path, total. התנהגות: precond(fixture×fixture→null · sysFrom∩sysTo=∅→null · canConnect→[a,b]) → Dijkstra על `SplayTreeMap` buckets → invariant(הקו נשאר במערכת-אחת · חיתוך-מערכות מונוטוני-מצטמצם).

### install_engine.dart — פירוק הגוד-מודול (14–20)
- **14 · מפת-המודול** — ~30 פונקציות + 3 caches (`_skuCache`·`_compatCache`·`_syntheticPipeCache`) + **מוטציית-runtime של `kVerifiedSpecs`** (`_syntheticPipe` רושם specs). תעד את הגרף-הפנימי + החוב: caches-גלובליים = state-נסתר.
- **15 · פרדיקטי-תאימות** — `canConnect:498` (**2 מסלולים:** verified→`compatibleWith` · fallback name-inference: size-overlap∧gender∧method) · `connectionFailReason:524` · `compatibleWith:611` (memoized).
- **16 · מנועי-ניתוב** — `findShortestPath:733`(Dijkstra) · `_findShortestPathExcluding:681` · `findAlternativePaths:624`(Yen k-paths) · `_edgeCost:875`(נוסחת-עלות) · `_usableConnector`. פרק כל נוסחה בצעדים.
- **17 · מנועי-סיווג** — `productSystems:447` · `flowRole:479`. ⚠️ **hard-case #1:** מסווגים לפי **מחרוזות-`categoryHe`** (`_supplyCats`/`_drainCats`/`_fixtureCats`/`_terminalCats`). התפוקה: החצן את הטבלאות-בקוד כ-"דאטה welded לזרימה" — סמן להעברה ל-schema.
- **18 · אורקסטרטורי-BOM** — `buildInstallation:1339` · `buildTreeInstallation:1492` · `materializeChain:1319`(מכניס צינור בין fitting↔fitting) · `manifoldOutlets:1471` · `_findBridge:1158`.
- **19 · מנועי-בטיחות (⚠️ אחריות)** — `lineComplianceChecklist:194` + `_autoAddCompliance:997`. **hard-case #2:** מוטר-in-place רגיש-לסדר (`insertAt` closure · `clamp(1,len-1)` · הזרקת PRV/vessel/TMTV/dielectric). פרק את **סדר-ההזרקה** כהתנהגות — לא רק "מוסיף בטיחות". **caveat-בטיחות = ערך-ייחוס בלבד (M5).**
- **20 · תפר-ההאצלה s41** — `connectionMethodLabel:111` + `lineComplianceChecklist` ענף מגודר → `ConnectionResolver`. **hard-case #3:** GATED-BY `tradeId!='plumbing'` + try/on-Object **kill-switch** ("plumbing לעולם לא מאציל"). תעד כ-חיבור-מותנה, לא "node אחד".

### pressure_drop.dart — פיזיקה (21–24)
- **21 · `estimatePressureDrop:354`** — **Darcy-Weisbach** בצעדים: ΣK (דלג `_kOffLineSkus`) → צוואר-בקבוק(bore-מינ') → `A=πD²/4`·`v=Q/A`·`Re=ρvD/µ`·ƒ(laminar `64/Re` / Blasius `0.316/Re^0.25`)·`ΔP=(K+ƒL/D)·½ρv² + ρgh` → `bar=Pa/1e5`. total, pure.
- **22 · כללי-ההצעה** — bore<13∧flow≥0.3→sibling רחב · v>2→הרחב · ΔP>1bar→booster · rise≥10→booster · Re<2300→narrow. פרק כ-branching מסופר.
- **23 · `autoFlowFix:198` · `widerSiblingOf:272` · `_frictionFactor:319`** (Newton `_pow025`/`_sqrt` hand-rolled).
- **24 · `checkDrainageSlope:491`** (ת"י 1205 · 2%) · `_kForType:29` (טבלת-K לפי מחרוזת → hard-case #1, החצן).

### שאר logic/ (25–42)
- **25 · `price_estimate.dart:90`** — `estimatePrice` (מפת-קטגוריה→ILS · fallback ₪25 · `lowConfidence`). ⛓️ קשור **הכרעת-המחיר** (שלב 54).
- **26 · `fuzzy_match.dart`** — `damerauLevenshtein:16` + `fuzzyMatch/NameMatch/Score`. ⛓️ קשור פרימיטיבים (שלב 66).
- **27 · `install_kit.dart`** — `recommendedKitForProduct:42` (מגודר brand/EndType) · `recommendedKitFor:155` (dedup לאורך-שרשרת).
- **28 · `workflow_engine.dart`** — מכונת-מצבים טהורה 5-שלבים: `planWfAdvance:192`(patch+event+toast) · `wfActionVisible:149` · `planAddName:247` · `wfDailyRows:266` · `wfRevertPatch:236`.
- **29–31 · `domain/connection_resolver.dart` (🎯 האסטרטגי)** — מעריך-כללים trade-agnostic (s39, דורמנטי). `canConnect:211`(end-pairs memoized) · `_endPair:239`(כלל-ראשון-מנצח fwd/rev) · `_sizeOk:277`(exactSame/anyToAny/tableLookup) · `completion:320`(גלווני+type-required) · `systemCoherence:391`. **זה היעד שאליו אמורה לעבור הפיזיקה מהמחרוזות (hard-case #1).** ⛓️ קשור מטריצת-החיבורים (51) + גשר-הזריעה (53).
- **32–34 · `state/` cart** — `SmartCartNotifier.add` (`smart_cart.dart:131`). **hard-case #6:** ה-add שורה-אחת, אבל ה-**invariant אמיתי ב-setter** (`_persist()` async + `_loaded` race-guard). פרק את מחזור-החיים של ה-setter. + `CartListsNotifier.saveCart:119` · `buildSafetyAccessories` (`cart_safety.dart:8`, טהור).
- **35–37 · `logic/studio/` (AI co-editor · טהור · דורמנטי · ⚠️ בטיחות)** — `action_catalog`(7 אפקטים סגורים כולל `cart.add`) · `edit_intent.parseConfigEdit`(פרסר anti-hallucination, לעולם-לא-throw) · `edit_safety.validateSafe`(nav/auth immutable · רצפת-price/order · WCAG) · `diff_preview` · `component_palette` · `co_editor_gate`(3-צירים) · `rules_model`. פרק חוזים בקפידה — הם **שולטים מה AI מותר לעשות לאפליקציה**.
- **38–39 · `logic/intel/` (analytics · טהור)** — `funnels.computeFunnel`+detectors(stuck/abandon/dead-end) · `segments`(cohorts לפי uid יציב) · `intel_config`(כל-הספים במקום-אחד).
- **40–42 · ספרינט שאר-המנועים** — `manager_dashboard`·`customer_score`·`attention_engine`·`assistant_intent`(פרסר-המקור)·`equipment_stock_join`·`tasks_gantt`·`calendar_days`·doc-gen(`invoice`/`delivery_note`/`printable_docs`/`finance_report_pdf`)·`category/system_division`·`data_quality`·`offline_order_queue`·`manager_copilot`·`ai_hub_logic`. כל אחד 3-שכבות.

### הגבולות (43–45)
- **43 · `features/fittings/engine/`** — `generate:184`(switch-משפחות · **throws** על-לא-מוכר) · `base:58` · `r1:27`(round half-even bit-exact). **hard-case #5:** חוזה = "זהה ל-`pure_engine.py`" · golden-linked · **אל תפשט/תשנה.** תעד `fitting_flags` (דורמנטי, default-OFF).
- **44 · data-vs-engine split (hard-case #4)** — `state/studio/element_registry.dart` (2393 שורות ~99% `const`) + 6 מחלקות `connection_schema.dart` = **דאטה** (→פאזה D), לא מנועים. רק `findDescriptor`/`fromJson` = לוגיקה. אכוף את חוק-שלב-10.
- **45 · `spec_logic_test` + mutation** — הכלי משחזר את golden-13 · כל אלגוריתם → assertions מהצעדים (⛓️ kli-B testgen). מוטציה-L3 לכל נוסחה.

---

## פאזה D · דאטה (46–62) — *מקורקע במפה החיה*

> **מבנה-על:** (1) עמוד-שדרה-חי: `LipskeyCatalogProduct` const (+company-overlay) · (2) פיזיקה-חיה: `VerifiedSpec`+`ConnectorEnd` (enum-`EndType` סגור) · (3) מודל-מחבר-חדש: `connection_schema.dart` (`ConnectorType`+מטריצת-`CompatibilityRule`) + `trade_schema.dart`, ב-`TradesDoc`→SharedPreferences, **נזרע מ-891 VerifiedSpec (שלב-37), לא מחווט למסך-חי** ⇒ אפס-רגרסיה.

- **46 · מודל-המוצר (spine)** — `LipskeyCatalogProduct` (`data/lipskey_catalog.dart:4`) שדה-שדה: `sku`(PK·String) · `nameHe/En` · `categoryHe`(join-key) · `page` · `dims:Map?` · תמונות · `brand:String='ליפסקי'`. auto-gen מ-`scripts/extract_lipskey.py`, const, לא-מוטבל.
- **47 · getters-נגזרים = לא-שדות** — `connectionSizes:131`·`connectionGender:148`·`connectionMethod:160`·`imageAsset` **נגזרים בזמן-קריאה** (regex על `nameHe`). חיבור(name→נתון), לא אחסון. **hard-case #2.**
- **48 · seam-הצריכה** — `resolvedCatalogProducts` (`catalog_source.dart:98`): company-overlay → empty-shell(profile) → v1/v2. נקודת-כניסה יחידה.
- **49 · ⭐ golden-ישות `VerifiedSpec`** (`data/lipskey_verified_connections.dart:77`) — `sku`(FK)·`ends`·`material`·`maxTempC:double=40`(°C·ברירת-HDPE)·`systemOverride?`. התנהגות: `compatibleWith`(any-end mates + `_materialsCompatible`)·`suitableForTemp`(≤maxTempC)·`endSystems`.
- **50 · `ConnectorEnd`/`EndType`/`WaterSystem`** (:43/:24/:41) — enum-קצה סגור(6) + `directMatesWith`(BSP m⟺f·pex·copper·drain·same-size) + `pipeSharedWith`.
- **51 · מטריצת-החיבורים (highest-value)** — `connection_schema.dart` שדה-שדה: `ConnectorType:64`·`SystemDef:110`·`ProductEnd:146`·`ProductConnectorSpec:171`(`envelope:Map<String,num>`)·**`CompatibilityRule:240`**(`aTypeId`/`bTypeId`·`sizeMatch`·`sizeTable`·`incompatibleMaterialGroups` גלווני)·`CompletionRule:323`.
- **52 · חוזה-decoders** — כל fromJson **סובלני** (חסר/שגוי→ברירה, לא throw). **hard-case #7: אין שכבת-ולידציה — רשומה-פגומה מפוענחת בשקט.** סמן כחוב.
- **53 · גשר-הזריעה** — `buildPlumbingSeed()` (`domain/seeds/plumbing_trade_seed.dart`): 891 `VerifiedSpec` → `ConnectorType`+`CompatibilityRule`. נקודת-איחוד tier-2↔tier-3. **hard-case #8: שני מודלים מקבילים.**
- **54 · ⚠️ הכרעת-המחיר** — **`price` אינו שדה על המוצר.** 3 ייצוגים מנותקים: (א) `price_estimate` קטגוריה→ILS · (ב) `SmartBrand.price:int?`(null="לפי ספק") · (ג) **היחיד-האמיתי:** `InventoryItem.price:num` Firestore-פר-חנות (`store_inventory.dart:78`). **תפוקה: מסמך-הכרעה → החלטת-בעלים.**
- **55 · שדות-עמידים** — `dims` חופשי(#1) · size מחרוזת-מעורבת(mm/inch/½¼¾/×)+`kBspInchToMm`(#3) · `EndType.hdpeCompression` עמוס(HDPE-לחץ+PVC/PP-ניקוז→צריך `material`+`systemOverride`)(#4) · `envelope` מפתחות-פתוחים(#5).
- **56 · טבלת-הישויות** — CatalogNode·Brand·Section·VariantFamily·SmartProduct/Brand/Acc·Trade-superset·InventoryItem/Store·phaseb/contractor/supplier-seeds·Persona/Project/Chat/BsUser: שם·file:line·שדות·חובה·יחסים·נזרע·נקרא.
- **57 · repositories-דפוס** — ~45 קבצים, ~11 interfaces: `abstract interface`+`_local`(prefs)+`_firebase`(Firestore)+תמיכה(`firestore_cached_repo`·`catalog_sync`·`paged_query`·`*_seed` gated). פרק interface-אחד כ-golden.
- **58–60 · ספרינט-כיסוי** — כל שאר data/ פר-tier (קטלוגים·seeds-פר-persona·supplier/courier·finance/site).
- **61 · seeds profile-gated** — רבים `empty` על shell-נקי (personas/projects/chat/phaseb) → מסך-ריק מכוון, לא באג.
- **62 · דוח-כיסוי-דאטה** — `מכוסה N/M · hard-cases לפי סוג`.

**שומר-דאטה:** מפרק **קורא-בלבד** · לא "מתקן" מודל-כפול/מחיר (מתעד+מביא הכרעה) · tolerant-decoder מסומן כחוב-ולידציה.

---

## פאזה P · חוזי-פרימיטיבים (63–70) — *כל אחד ממופה בסוקר*

לכל פרימיטיב-רצפה: **קלט→פלט + ערובה + קצוות + purity.** (ה-floor הופך מ"שם" ל-חוזה.)

- **63 · money** — `groupThousands` (`logic/money_format.dart:19`, `(int)→String`, שלילי→abs) · `formatNis:31` (`"₪3,150"`, סימן-לפני-₪).
- **64 · text-norm** — `normSearch` (`text_normalize.dart:24`, lowercase+ניקוד+אותיות-סופיות+פיסוק) · `normName:36` (+הסרת-רווחים · מפתח-dedup).
- **65 · validators** (`input_validators.dart`) — `validIsraeliMobile:11`·`validEmail:17`·`validBusinessId:29`(checksum 1-2-1-2)·`normalizePhone:48`(אין-ספרות→`""`)·`validBoardCode:59`·`waMeDigits:74`·`validPositiveAmount:91`(null→false)·`validDateRange:95`. כל אחד קלט→פלט+קצה.
- **66 · fuzzy** — `damerauLevenshtein:16`·`fuzzyTolerance:54`(`len~/3+1`)·`fuzzyMatch:58`·`fuzzyNameMatch:68`·`fuzzyScore:78`(−1=no-match). ⛓️ שלב 26.
- **67 · sanitize** — `promptSafeText` (`prompt_sanitize.dart:19`, cap `maxLen=600`, collapse-whitespace).
- **68 · toast** — `showToast` (`widgets/toast.dart:19` — **לא state/**) · `showGlobalToast:34` (`bsMessengerKey`, not-mounted→no-op). side-effect (❌ pure).
- **69 · טבלת-פרימיטיבים** — שם·file:line·signature·returns·edge·pure? (מלא מהסוקר).
- **70 · `primitive_contract_test`** — כל קצה-מתועד → assertion (abs·null→false·empty→""·checksum). ⛓️ kli-B.

---

## פאזה N · מסעות (71–82) — *Navigator 1.0 · 3 משטחים עוקפים*

- **71 · מנגנון-הניתוב** — Flutter **Navigator 1.0 imperative**: אין router/named-table. `MaterialApp.home=OnboardingGate` (`main.dart:555`); כל מעבר = `MaterialPageRoute` לא-שמי דרך `Navigator.push`; קונבנציה `static Route route([params])`. חזרה `Navigator.pop(ctx,value)`. ~200 pushes מפוזרים.
- **72 · טבלת-הקשתות** — from→to · trigger · params (מהסוקר: Suppliers→Brand→Section→Products→Sheet→cart · role_picker→dashboards · scanner/camera **מחזירים** ערך ב-pop).
- **73 · ⚠️ 3 המשטחים שעוקפים את ה-Navigator** — (א) `HomeShell` 4 טאבים = `IndexedStack`+`mainTabProvider` · (ב) `StoreScreen` all/cart/orders/services = `storeSectionProvider` enum · (ג) opening-flow = `startupStepProvider`+`PopScope`. **נושאים קשתות-מסע מרכזיות אך בלתי-נראים לכלי-route.** פרק אותם כמסע.
- **74–77 · מסעות-משתמש (paths)** — first-run(`OnboardingGate→Welcome→Profession→Onboarding→HomeShell`) · **browse→cart→order**(`Suppliers→Brand→Section→Products→Sheet→add→StoreSection.cart→checkout→orders` — 3 הקפיצות האחרונות = provider-swaps) · persona-work · updates/chat(+push `pendingPushThreadProvider`).
- **78 · gaps** — אין route-registry (grep פר-מסך) · `IntelRouteObserver` **מת** (routes לא-שמיים → screen-view לא-נורה ל-pushes) · מסכים בלי `route()` (`InstallStudio`/`Audit` raw-push) · `StudioScreen` כפול · הרבה edges מגודרי-דגל (דורמנטיים).
- **79–81 · כלי-חילוץ-מסע** — הרחב את המפרק: grep `Navigator.push`+`.route(`+3 provider-swaps → גרף-מסע JSON (node=מסך·edge=trigger+params). golden = מסע browse→order.
- **82 · דוח-מסע** — כל מסך מגיע-מ/מוביל-ל? מסעות-יתומים? edges-דורמנטיים מסומנים?

---

## פאזה async (83–86)

- **83 · דפוס** — Riverpod `AsyncValue`+`.when(loading/error/data)`; **error מקופל ל-empty** ("HARD RULE #3", לעולם-לא-crash); empty=`isEmpty` בתוך `data:`. repos→try/catch→חריגות-**typed**.
- **84 · דוגמאות** — `role_requests_inbox:115` · `home_shell:1459`(`_emptyHint`) · `order_functions:149`(`OrderFunctionsException`). פרק כמצבי-התנהגות.
- **85 · ⚠️ פיצול local/remote** — קטלוג/עגלה **סינכרוני** (const) → **אין `AsyncValue`**, loading לא-ממודל, empty ad-hoc(`showToast`). רק Firestore/Functions משתמשים `.when`. **אל תניח חוזה-async אחיד.**
- **86 · חוזה-מצבים** — לכל provider: יש loading/error/empty? מסמן חוסר כפער (מקומי=אין-error-path כי לא-יכול-להיכשל).

---

## פאזה S · העמקת-רדודים (87–90)
- **87–89 · 32 חד-אטום + 9 עזר** — הרץ מפרק-לוגיקה המשודרג עליהם → עומק מלא (לא רדוד).
- **90 · דוח** — כל מסך/עזר בעומק-מלא? רשימת-שאריות.

## פאזה W · מפרק-ווב (91–96) — *הרמה הנפרדת הגדולה*
- **91–93 · כלי-שני** — מפרק TS/TSX (typescript compiler-API / ts-morph) · אותו מודל 3-שכבות · על `app/src/`.
- **94–95 · golden-ווב** — שחזר מסך-Preact-אחד ידנית → הכלי מתאים. (⚠️ `app/` = החי-בפרודקשן — קורא-בלבד.)
- **96 · דוח-כיסוי-ווב.**

## פאזה B · צד-שרת + capstone (97–100)
- **97–98 · functions/scripts** — פרק צד-שרת (Cloud Functions · `scripts/`) · אותו מודל.
- **99 · לוח-כיסוי-על** — Flutter+Preact+backend: כמה-מפורק, hard-cases פתוחים, הכרעות-בעלים ממתינות.
- **100 · 🔑 capstone** — מתכנת-חדש פותח **כל** אטום ורואה את הפְּנים (אלגוריתם·חוזה·דאטה·מסע). אפס "שם-בלבד".

---

## 🛡️ שומרים קבועים
- **מפרק = קורא-בלבד.** אפס-שינוי בקוד-אפליקציה. תפוקה = ידע (JSON+MD) בלבד.
- **לא "מתקן" — מתעד.** גוד-מודול · מודל-כפול · מחיר-חסר-בית · tolerant-decoder · caches-גלובליים → **פערים מתועדים + הכרעות-בעלים**, לא refactor.
- **golden-reproduction gate:** הכלי משחזר את הגולדנים הידניים (findShortestPath · VerifiedSpec) לפני ריצה-רחבה.
- **byte-identical/דורמנטי לא-נגעים** (fittings golden-port · ענפים מגודרי-דגל).
- **בטיחות = ערך-ייחוס + caveat (M5)** — לעולם לא מחייב (compliance/pressure/weld).
- **pass=מאומת/מתועד · gap=מדווח** (משמעת kli-B). CI: `Atom Tools` NON-blocking ירוק.

## 🔁 פרוטוקול-לולאה
פאזה → פרוסה → מפרק-קורא-בלבד → golden-מתאים → `Atom Tools` ירוק → **ירוק? הבאה בלי אישור** → חזור.
**עצור-ושאל:** חסם · **החלטת-בעלים** (הכרעת-מחיר-54 · תיקון-מודל-כפול · refactor-גוד-מודול · כל שינוי-קוד-חי) · כשל-שורש-פעמיים.
**דווח:** אבן-דרך פר-פאזה (L→D→P→N…) — שם אאמת ואביא לבעלים.

---

## ✂️ בלוק להעתקה לנחיל
━━━━━━━━━━━━━━━━━━
משימה: **DECOMP-DEPTH — פירוק-לעומק של לוגיקה/דאטה/פרימיטיבים/מסעות** (השכבות שנשארו בשם-בלבד), לפי `DECOMP-DEPTH-100-STEPS.md` (על nice-volta), מצב-לולאה. בונה על `whats-happening` (@98f74917).

**סדר:** `0(שדרוג-כלי) → L(לוגיקה·הכי-חשוב) → D(דאטה) → P(פרימיטיבים) → N(מסעות) → async → S → W(Preact) → B(backend)`.

**שלב-0 חובה-ראשון:** הרחב `tools/atom/decompose` מ-widget-AST ל-analyzer element-model (call-graph + read/write + algorithm-extract). בלי זה פירוק-לוגיקה = ידני.

**גולדנים (יעד-שחזור):** מנוע = `findShortestPath` (`install_engine.dart:733`, Dijkstra) · ישות = `VerifiedSpec` (`lipskey_verified_connections.dart:77`). הכלי חייב לשחזר את הפירוק-הידני 1:1.

**🛡️ מפרק = קורא-בלבד.** לא מתקן — מתעד. גוד-מודול(1629ש')·מודל-כפול(VerifiedSpec מול ConnectorType)·מחיר-חסר-בית·tolerant-decoder = **פערים מתועדים + הכרעות-בעלים**, לא refactor. בטיחות=ערך-ייחוס+caveat(M5). byte-identical/דורמנטי לא-נגעים.

לולאה: פרוסה → golden-מתאים → `Atom Tools` NON-blocking ירוק → הבאה בלי אישור.
עצור-ושאל: חסם · החלטת-בעלים (הכרעת-מחיר · תיקון-מודל-כפול · refactor-גוד-מודול · שינוי-קוד-חי) · כשל-פעמיים.
דווח אבן-דרך פר-פאזה — שם אאמת ב-CI ואביא לבעלים.
━━━━━━━━━━━━━━━━━━

*מקורקע ב-3 סוקרים על הקוד החי @98f74917: engines-map · data-map · nav/primitives/async-map. גולדנים אמיתיים, hard-cases 1-8 מתועדים.*
