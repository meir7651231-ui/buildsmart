# SmartProduct — 100-step roadmap (work plan)

Goal: turn `SmartProduct` (the smart-tree internal card, `_SmartProductSheet`)
into the unified "brain" of the app — knowing *what it is · what it suits · how
it connects · how to install · what it costs · who sells it*.

Status legend: ⬜ todo · 🟦 in progress · ✅ done

## 📜 Changelog — version history (live Handoff is the v5.43 section below)

v5.96 — 👔 **Manager 🛠️ ניהול — final wave (M4): manager persona COMPLETE** 🟦.
The 👔 "מנהל המערכת" BS-dial → 🛠️ ניהול section's `mm-*` leaves are now ALL wired to their
REAL targets — the whole manager persona is **COMPLETE** with **ZERO reachable "בבנייה"** across
all four sections (md/mo/mc/mm). Faithful port of the legacy `renderMgrManage`
(@index.html:16645-16743): **`mm-cats`** → an inline data panel (`_ManagerManagePanel`, state
`bsManageLeafProvider`) listing the REAL categories + product counts from
`kManagerCatalogCategories` (the legacy SECTION 3 tally @16716) + the verbatim hint;
**`mm-settings`** → the same panel with the three REAL config rows (express ₪80 / credit ₪50,000 /
VAT 18%, the legacy editable globals @11941/11961/11963) + the verbatim hint; **`mm-trees`** &
**`mm-brands`** (legacy = `prompt()`-driven server edits) → a labelled toast with the verbatim
legacy action sub-title (@16653/16687), NOT "בבנייה"; **`mm-regression`** → UNCHANGED (still routes
to `RegressionPanelScreen`). The data panel is R2 (dial-drill, no new screen) and mutually
exclusive with the M1/M2/M3 panels; `kManagerManageDataLeafIds` + `kManagerManageActionLeafIds`
partition the leaves so none falls through to the stub. Guard `bs_dial_manager_manage_test` (12).
All data verbatim from index.html (NOT `SYSTEM_MANAGER.md`). **Manager wave (M0→M4) DONE.**

v5.95 — 👔 **Manager 👥 לקוחות — real customer list** (wave 1: M3) 🟦.
The 👔 "מנהל המערכת" BS-dial → 👥 לקוחות section's 2 `mc-*` leaves now show the REAL
customer list inline (R2 dial-drill, no new screen) instead of "בבנייה" toasts.
**M3** ✅ — `bsCustomerLeafProvider` + an inline `_ManagerCustomerPanel` in
`bs_dial_widget.dart`: each `mc-*` leaf = one legacy customer status filter
(`kManagerCustomerLeafStatus`: `mc-live`=פעיל · `mc-low`=אשראי גבוה, pill labels verbatim
@index.html:16592); the panel filters `mgrCustomerList` (grouping SYS_ORDERS_SEED by buyer) to
that status and lists each customer (`👷 name` / `orders הזמנות · sites אתרים` / status pill /
`ניצול אשראי: ₪spent / ₪credit (pct%)`, mirroring the legacy `mc-card` @16593-16604) + a count.
With the Dart `contractorCredit` ceilings all 4 seed buyers are `live` → **`mc-low` is empty**
→ the legacy empty text "לא נמצאו קבלנים תואמים." (@16586). Metric / order / customer panels
are mutually exclusive. `pct`/`status`/`sites` derived exactly @16554,16559-16562. Guard
`bs_dial_manager_customers_test` (4). All data verbatim from index.html (NOT `SYSTEM_MANAGER.md`).
**M4** ✅ (v5.96) — the manager's management (ניהול) section; manager persona COMPLETE.

v5.94 — 👔 **Manager 📦 הזמנות — real per-stage orders** (wave 1: M2) 🟦.
The 👔 "מנהל המערכת" BS-dial → 🚚 הזמנות section's 6 `mo-*` leaves now show the REAL
orders in their order-flow stage inline (R2 dial-drill, no new screen) instead of
"בבנייה" toasts. **M2** ✅ — `bsOrderLeafProvider` + an inline `_ManagerOrderPanel` in
`bs_dial_widget.dart`: each `mo-*` leaf = one `kManagerOrderFlow` stage; the panel filters
`kManagerOrderSeed` to that stage and lists each order (`📦 id` / `who · site` /
`items פריטים · ₪sum`, mirroring the legacy `mo-card` @index.html:17001-17014) + a count.
The 2 stages with no seed orders (pickup · delivered) render the legacy empty text
"לא נמצאו הזמנות תואמות." (@16986). Order & metric panels are mutually exclusive.
`kManagerOrderLeafStage`/`kManagerOrderLeafIds`/`_kOrderStageLabel` (stage names verbatim from
`ORDER_STAGE` @12041-12048). Guard `bs_dial_manager_orders_test` (5). All data verbatim from
index.html (NOT `SYSTEM_MANAGER.md`). **M3** ✅ (v5.95). **Remaining (🟦):** M4 — the manager's
management section.

v5.93 — 👔 **Manager 📊 dashboard — real derived numbers** (wave 1: M0+M1) 🟦.
The 👔 "מנהל המערכת" BS-dial 📊 dashboard's 5 `md-*` leaves now show REAL numbers
inline (R2 dial-drill, no new screen) instead of "בבנייה" toasts.
**M0** ✅ — `logic/manager_dashboard.dart` (PURE) ports `mgrAnalytics()`
(@index.html:12081-12126): the seed (STORES · SYS_ORDERS_SEED · TREES distribution ·
STORE_STOCK) + the 5 `mdMetric` tiles (@12160-12164) as `ManagerAnalytics` getters
(open-orders=4 · catalog=54 · accessories=148 · available=202 · stores=3/3). Numbers
verified verbatim against the live index.html `TREES` loop (NOT `SYSTEM_MANAGER.md`).
`kManagerOrderFlow` (@16943) + `contractorCredit` + `mgrCustomerList` = M2/M3 foundation.
Guard `manager_dashboard_test` (12). **M1** ✅ — `bsMetricLeafProvider` + an inline
`_ManagerMetricPanel` in `bs_dial_widget.dart`; guard `bs_dial_manager_test` (4).
**M2** ✅ (v5.94) · **M3** ✅ (v5.95). **Remaining (🟦):** M4 — the manager's
management section.

v5.69 — 💧 **Division option 2 — through the finder** (Benzi #1, user-chosen).
A live department now opens the **finder (בית)** scoped to its `WaterSystem`
(not a forced tree): `_DeptScopeBar` shows the scope + clear; the finder hides
empty groups + filters its pool. Division helpers extracted to
`logic/system_division.dart` (shared catalog+finder, no back-import cycle).
Phase 1 of 3 (finder + tree-drill + search filtered; remaining sections = Phase
2; sysOpt removal = Phase 3). 1009/1009 green.

v5.59 — 💧 **Water-system division via departments** (Benzi #1, closes 🟦).
Home departments (v5.57) now route into the catalog **pre-filtered by `WaterSystem`**:
אינסטלציה→drainage · ברזים וסניטריים→supply. `productDivisionSystems`
(spec.endSystems → PPR=supply → else drainage; PPR aligns with the v5.41
`systemOverride: supply` bridge) + `nodeHasSystem` (fixtures both-sides, else
dominant) filter the whole category tree + counts + descriptions. Entry is the
department grid, NOT the filter sheet (the sheet sysOpt is now redundant —
flagged for removal in `ACTION_PLAN.md`). **Open:** tree-drill vs.
finder-with-filtered-chips (user design question). 986/986 green.

v5.41 — 🌉 **Polyroll bridge** (discovered via probe pattern). All 757 PPR
products were silently invisible to 8 card helpers because they had no
`VerifiedSpec`. Fixed:
- `polyrollSpecFor(p)` synthesises a spec for every PPR fitting/pipe from
  category + dims + name (DN parser handles 4 patterns). Coverage: 733/739
  fusion-cat products (99.2%); the 6 misses are legitimate non-connectors
  (5 manifolds with imperial threads + 1 mounting plate).
- `registerPolyrollSpecs()` called once at app startup from `main.dart`
  populates `kVerifiedSpecs`.
- `installToolsFor` → 🔥 socket fusion welder + cutter + caliper (or
  ⚡ electrofusion transformer for the EF category).
- `installEffortFor` → always 'מקצועי' for PPR (heat-fusion needs training).
- `installTipsFor` → 4 PPR-specific tips (heat time, insertion depth,
  cool-down, thermal expansion) + EF-only "input code into transformer."
- `israeliStandardsFor` → ת"י 5452 (PPR is `systemOverride: supply`).
- `compatibleProductsFor` / `compatibleProductsCount` → search across the
  unified `kCatalogProducts` (was only `kLipskeyCatalog`), so PPR↔PPR mates.

Guards: `polyroll_specs_test` (10 tests · pure factory) +
`polyroll_e2e_test` (8 tests · helper coverage + aggregate ≥99%).
Total: 792 → 810 green. No Lipskey regression.

v5.40 — closed step 2 🟦 → ✅ (label-only: bridge is in fact complete —
307/307 with-SKU brands resolve, the 58 without are intentionally "by
supplier" variants) + Tooltip coverage on all 6 header chips. 792/792.

v5.39 — closed step 62 🟦 → ✅: `fuzzySearchProducts` now the 3rd-tier
fallback in `_SearchResultsList` (AND → OR → fuzzy). Guard:
`search_fallback_test`. 791/791 green.

v5.38 — closed 2 more 🟦 → ✅: step 29 (`pairConnectionWarningHe` per-pair
validation), step 87 (reducedMotion locked by static-count guard). 788/788
green.

v5.37 — closed 3 🟦 → ✅: step 7 (filter persistence), step 76 (saved-
version load/× UI), step 82 (mutation×2 → 12 invariants). 782/782 green.

v5.36 polish bump (no new step ✅, three existing steps tightened):
- Step 30 (card+line score) — badges now colorised by band via `scoreBandColors`
  (≥75 emerald / 50–74 amber / <50 rose). Same fences for both scopes. Guard:
  `score_band_test` (8 tests, exhaustive 0..100).
- Step 31 (install stages) — added a thin brand-orange `LinearProgressIndicator`
  beneath the "מעקב התקנה — X/N" text; fills as stages are tapped done.
- Steps 26/52/57 — wrapped the three header chips (project mode · profession
  mode · temp picker) in `Tooltip` widgets so long-press/hover explains "what
  this chip does", plain Hebrew.

## 📌 Handoff (v5.55, ~92% ✅)
Saved for the next run. Pick up here:
- **Group A — כולו ✅** (76·25·46·74·89·82·85·57 — all done, tests green)
- **Group B — כולו ✅** (2·7·9·15·20·24·26·29·30·48·56·65·68·86·88·90 — all done, tests green)
- **פאזה K (ידע) — ✅** (76/76 מסמכים עם verdict, README אינדקס 100%, 0 יתומים — ליטוש 2026-06-01)
- **Group C (needs infra/pkg/backend/assets — needs user decision):** 13,17,18,32,36,37,39,40,
  41,43,44,49,50,53,54,55,60,69,70,79,83,84,86,88,90,91,92,93,94,96,97,98.
- **Group D (risky / shared-subsystem / big refactor):** 1 (merge sheets — user said don't touch
  catalog card), 10 (A/B flag), 61 (search index), 64 (modal→tab nav), 99/100 (meta).
- Cadence reminder: full suite ~5 steps · local commit ~20 ops · live demo ~10 ops · **no push w/o approval**.
- Prototype (`/index.html`) has NONE of these card features (only base leaves: אביזרים-נלווים/ספק/
  מחיר/מותג/מק"ט/התקנה) — the SmartProduct "brain" is a Flutter-only evolution; content is grounded
  in `kSmartProducts`/`kCatalogProducts`, only UI labels are new.

## Phase 1 · Unification & foundation (1–10)
1. ⬜ Merge the two duplicate product sheets (`_SmartProductSheet` ↔ `showLipskeyProductSheet`).
2. ✅ `SmartProduct` linked to the **unified** catalog by SKU — bridge + contract
   index `kCatalogProducts` (Lipskey + Polyroll), so any brand SKU resolves.
   Coverage: 81 SmartProducts · 365 brands · 307 with SKU (84%) · 252 verified-
   spec (82% of with-SKU). The 58 brand entries without a SKU are intentional
   "by-supplier" variants (no catalog twin); the contract test asserts that
   every SmartBrand.sku that IS set resolves to a real catalog product.
   Guard: `smartproduct_contract_test` (informational coverage report).
3. ✅ Bidirectional bridge: `catalogProductForBrand` / `catalogProductForSmart`
   (related_info.dart) + `smartProductForSku` (reverse). Round-trip guarded in
   `smartproduct_contract_test`.
4. ✅ Documented data schema — `knowledge/SCHEMA.md` (194 lines): catalog
   products · verified specs (enums) · SmartTree · bridge · card-side state
   models · data-flow diagram. Built by parallel sub-agent.
5. ✅ Contract tests: every `SmartBrand.sku` is a real catalog SKU; every product
   has a resolvable recommended brand. Baseline: 81 products · 365 brands ·
   307 with SKU · 252 of those with a verified spec. Guard: `smartproduct_contract_test`.
6. ✅ "📦 נתוני קטלוג" section in the smart card injects the catalog's spec /
   compat / price for the selected brand's SKU (via the bridge).
7. ✅ Unified persisted selection — brand via `cardSelectionProvider` (last
   pick) + `brand_history` (cross-session) resolved by `default_brand_resolver`;
   acc selected+qty via `cardAccStateProvider` (`Map<productKey, Map<accName,
   {selected, qty}>>`, JSON-persisted under `bs.card-acc-state.v1`); סוג /
   מידה filter via `cardFilterStateProvider` (`Map<productKey, {type?, size?}>`,
   persisted under `bs.card-filter-state.v1`, auto-clears empty entries).
   All three restored in `initState`, persisted on every tap / qty / filter
   change. Guards: `card_selection_test`, `brand_history_test`,
   `default_brand_resolver_test`, `card_acc_state_test`, `card_filter_state_test`.
8. 🟦 Comprehensive widget rendering already covered by `product_journey_test`
   (all 935 sheets render at narrow phone + large text). Pixel-level golden
   files (`matchesGoldenFile`) still ⬜ — deferred (heavy + flaky in CI).
9. ✅ Dead-widget cleanup in `catalog_screen.dart` — removed 466 lines across 4 phases:
   `_MiniSearchPill` (22L) · `_Chip` (37L) · `_diameterSubGroups`+`_diameterCounts`+`_diameterBucket`+`_SectionBanner`+`scrollCtrl`/`subGroups` params (54L) · `_CatalogDrillSection` cluster (353L).
   `catalogDrillCatProvider` kept (smoke test). 908 tests ✅. v5.43.
10. ✅ Feature-flag infrastructure — `featureFlagsProvider` (persisted
   `Set<String>`, isOn/enable/disable/toggle, idempotent). Built by parallel
   sub-agent. Guard: `feature_flags_test` (5 tests).

## Phase 2 · Data enrichment (11–20)
11. ✅ Engineering spec (material/pressure/temp/system/ends/bore) rendered in the
   smart card via `engineeringSpecFor` (in the 📦 section).
12. ✅ Israeli standards embedded (ת"י 1205/5452/1519/1385) — relevant-standard tag
   per product via `israeliStandardsFor` ("תקן ישראלי רלוונטי" in the 📦 section).
   Guard: `standards_tools_test`.
13. ⬜ Real image gallery per brand (zoom, 360°).
14. ⬜ Precise dimensions + small engineering sketch (DN/length/thread) per variant.
15. ✅ Durability rating (1-5 stars + reason) via `durabilityRatingFor`
   (material/temp/pressure heuristic). Guard: `durability_test` (2 tests ✅).
   (Real lab ratings still ⬜ — external data.)
16. ✅ "When to pick which" decision table between brands via `brandDecisionGuide`
   (rec / price-extreme / hot-suitability → one-line advice; "מתי לבחור איזה מותג"
   block). Guard: `brand_guide_test`.
17. ⬜ Real availability (stock/ETA) per SKU from supplier.
18. ⬜ Price history + trend chart for the selected brand.
19. ✅ Auto compliance/warning labels via `complianceTriggersFor` ("תקינות נדרשת"
   block in the 📦 section).
20. ✅ Manufacturer + mfr part-number via `manufacturerInfoFor` (יצרן + מק"ט יצרן
   = the SKU). Guard: `manufacturer_info_test` (2 tests ✅).
   (Warranty still ⬜ — no warranty data.)

## Phase 3 · Compatibility-engine integration (21–30)
21. ✅ "🔗 מתחבר ל-N מוצרים" in the smart card (`compatibleProductsFor` +
   `connectionExplainHe` labels, in the 📦 section).
22. ✅ "Build my line" button → `buildInstallation` (anchors = cart line so far +
   this product, autoCompliance, 60°C) → BOM dialog (qty × name + gap count).
   Engine call path guarded by `build_line_bom_test`. (Live canvas-tap on the
   dialog button is unreliable — see PLAYBOOK §G — so verified by unit test.)
23. ✅ Materialized chain inline — when a line is in progress (cart), show the
   engine's materialized sequence (incl. inserted pipes/couplings) as an RTL
   arrow chain via `chainArrowText`. Guard: `chain_arrow_test`.
24. ✅ System/safety + ΔP all inline — `systemSafetyNoteHe` (drainage/supply
   warning) + bore row + line-level ΔP via `estimatePressureDrop(plan.items)`
   shown as "💧 ΔP ~X.XX bar" alongside the line readiness score. Guards:
   `install_effort_test` + `pressure_drop_offline_test`.
25. ✅ Auto install-kit — engine-derived safety SKUs via `safetyKitItems`
   (diff of `buildInstallation` autoCompliance:true vs false). Shown inline as
   "🛡 ערכת בטיחות (auto): …". Guard: `safety_kit_test` (incl. integration probe).
26. ✅ Hot-water suitability + **interactive temp picker** — `hotWaterSuitabilityFor`
   reads from `displayTempProvider`; tap on the "🌡 מים חמים" row cycles
   60 → 80 → 95 → 60 (`cycleDisplayTemp`). The "X/Y מותגים מתאימים" updates
   live. Guards: `hot_water_suitability_test` + `display_temp_test`.
27. ✅ Smart adapter recommendation — `adapterSuggestionFor` finds a bridging
   catalog product that mates BOTH this product and a cart item, when there's no
   direct connection ("🔌 מתאם מומלץ"). Guard: `adapter_suggestion_test`.
28. ✅ "Your line so far" — `lineFitFor` reads the smart cart and reports how
   many cart items this product connects to ("🧩 בקו שלך"). Guard: `line_fit_test`.
29. ✅ Physical-connection warning, per-product AND per-pair —
   `connectionWarningHe(p)` flags a spec'd product with zero direct catalog
   mates ("ייתכן שנדרש מתאם"); `pairConnectionWarningHe(a, b)` flags a
   SPECIFIC pair that won't mate ("⚠ X ו-Y לא מתחברים ישירות — נדרש מתאם"),
   so a partner being added to a line is checked before the engine builds it.
   Reflexive (a,a)=null, symmetric, spec-gated. Guard: `paired_warning_test`.
30. ✅ Score in both scopes — card-level via `cardReadinessScore` (badge in
   📦 header) + line-level via `lineReadinessFromCounts(gapCount, safetyKitSize)`
   shown as "🎯 ציון קו N · מצוין/טוב/בסיסי/חלקי" when a cart line exists.
   Pure formula: connectivity 50% (-15/gap, floor 0) + safety 25% (+5/item,
   cap 25), rescaled 0-100. Guards: `card_score_test` + `line_score_test`.

## Phase 4 · Installation guidance (31–40)
31. ✅ Interactive stages with "mark done" — persisted `stageProgressProvider`
   (per-product `key#idx`); tappable stage chips + "X/N שלבים בוצעו".
   Guard: `acceptance_stage_test`.
32. ⬜ Short install video per stage.
33. ✅ Required-tools list (derived from spec ends → wrench/teflon, press tool,
   saw/solvent) via `installToolsFor` ("כלי עבודה" row). Guard: `standards_tools_test`.
34. ✅ Time estimate + difficulty (DIY/בינוני/מקצועי) via `installEffortFor`
   (from ends + kit), shown as the "התקנה" row. Guard: `install_effort_test`.
35. ✅ Common mistakes + tips via `installTipsFor` (per end-type + material) —
   "טעויות נפוצות וטיפים" block. Guard: `install_effort_test`.
36. ⬜ AR mode — place the product in space/on a wall via camera.
37. ⬜ Exploded view of the parts.
38. ✅ "Test kit" — `acceptanceChecklistFor` end-of-install checks (pressure/flow
   for supply, flow/slope for drainage, seal for threads). Guard: `acceptance_stage_test`.
39. ⬜ Export a tailored install-guide PDF.
40. ⬜ Voice / read-aloud of the stages for hands-busy work.

## Phase 5 · Price, suppliers & commerce (41–50)
41. ⬜ Real multi-supplier price (not "by supplier") with comparison.
42. ✅ "Total cost for the line" — `lineCostEstimateFor` (product + mandatory
   accessories + labour@~₪2.5/min) → "🧮 עלות קו משוערת" breakdown.
   Guard: `line_cost_test`.
43. ⬜ Quantity discounts + auto promotions.
44. ⬜ Supplier choice by distance/rating/availability from settings.
45. ✅ "Cheaper alternative" — strictly-cheapest sibling brand via
   `cheaperAlternativeBrand` ("💰 חלופה זולה יותר"). Guard: `summary_alt_test`.
46. ✅ Smart add-to-cart with safety — `buildSafetyAccessories` converts engine
   safety SKUs to `SmartCartAcc`, and "🛒 + בטיחות לסל" adds the whole line
   (user-selected acc + engine safety) to the cart in one tap. Distinct from the
   existing "הוסף לסל" (no safety). Guard: `cart_safety_test`.
47. ✅ Save config as favourite — persisted `savedConfigsProvider`
   (`productKey#brandName`); "☆ שמור / ★ נשמר" toggle in the 📦 header.
   Guard: `quote_saved_test`.
48. ✅ Share a quote — `quoteTextFor` builds a plain-text quote; "📋 הצעה" copies
   it to the clipboard. Guard: `quote_saved_test` ✅.
   (WhatsApp/PDF export still ⬜ — needs url_launcher/PDF.)
49. ⬜ Price tracking: alert when a selected brand drops in price.
50. ⬜ Direct order/payment from the card (when backend exists).

## Phase 6 · Personalization & AI (51–60)
51. ✅ Smart default brand from history — `brandHistoryProvider` records every
   pick; `resolveDefaultBrandIndex` (in `default_brand_resolver.dart`) picks
   the default brand on card open with precedence:
   **last-selection → most-used → recommended → 0**. Wired into the card's
   `initState` (replaces the simple step-7 lookup) and the brand-tap onTap also
   feeds the history. Guards: `brand_history_test` (6) + `default_brand_resolver_test` (5).
52. ✅ Project-mode — `projectModeProvider` (enum any/cold/hot/commercial,
   persisted) + `nextProjectMode` cycle + `labelForProjectMode` emoji+label.
   Wired as a tap-cycling chip in the 📦 header (◯הכל / ❄️קר / 🔥חם / 🏢מסחרי).
   Filtering of card content by mode still ⬜. Guard: `project_mode_test` (5).
53. ⬜ In-card AI assistant: "what suits me?" in free text.
54. ⬜ Learning: more lines built → sharper recommendations.
55. ⬜ Product recognition from camera (barcode/image) → opens the card.
56. ✅ "Frequently paired" — `frequentlyPairedTypesFor` surfaces the product
   *types* that most often connect (data-driven from the compat engine).
   Guard: `paired_warning_test` ✅.
   (Real co-purchase data still ⬜ — needs backend.)
57. ✅ Profession-aware — `professionModeProvider` (enum diy/contractor/pro,
   persisted), `defaultDetailFor()` mapping, `nextProfessionMode()` cycle,
   `labelForProfession()` emoji+label. Wired as a tap-cycling chip in the
   📦 header (🔨 DIY / 💼 קבלן / 🛠 מקצועי). Guard: `profession_mode_test` (5).
58. ✅ "Why it matters" explanation under each compliance warning via
   `complianceWhyHe` (↳ line). Coverage-gated: every trigger label has a why.
   Guard: `compliance_why_test`.
59. ✅ One-line text summary via `smartCardSummaryHe` (name·material·system·temp·
   price) at the top of the 📦 section. Guard: `summary_alt_test`.
   (Voice read-aloud still ⬜.)
60. ⬜ Timing recommendation (when to order per project schedule).

## Phase 7 · Search & discovery (61–70)
61. ⬜ Index SmartProduct in the main search (not just the tree).
62. ✅ Forgiving catalog search — three-tier UI fallback chain (closes 🟦):
   1. AND-match (`catalogProductMatchesQuery`) — every query word must appear;
   2. OR-match (same helper, `requireAll: false`) — any-word fallback;
   3. `fuzzySearchProducts` — whole-phrase substring ranks highest, proximity
      tiebreak. Triggers only when both AND and OR return zero (never disturbs
      the happy path). Guards: `fuzzy_search_test` + `search_fallback_test`
      (static check that all three matchers are wired into `_SearchResultsList`).
63. ✅ "Similar" — variant-family list ("גרסאות נוספות במשפחה") in the 📦 section
   via `variantSiblingsOf`. (Upgrade/cheaper-alternative still ⬜.)
64. ⬜ Health navigation: from the card straight to the relevant finder/category.
65. ✅ Quick in-brand filters — `brandSuitableForHot` ("🌡 מים חמים בלבד") +
   `brandIsMetallic` ("💎 מתכת בלבד") side-by-side in the brand selector.
   Both combine with the existing סוג/מידה filters (logical AND). Guards in
   `brand_hot_filter_test`. (A price filter would be moot — `b.price` is
   rarely set per-brand; category-level prices tie across siblings.)
66. ✅ "Recently viewed" history — persisted `recentlyViewedProvider`
   (move-to-front + dedupe + cap-20), recorded on card open, shown as
   "נצפו לאחרונה". Guard: `recently_viewed_test`.
67. ✅ Discovery tags (⭐ מומלץ מקצועי · 💰 הכי משתלם · 👑 פרימיום · 🎚 וריאנטים ·
   🔗 רב-תאימות) via `discoveryTagsFor`, shown as chips under the summary in both
   modes. Guard: `discovery_tags_test`.
68. ✅ Deep-link per product — `deepLinkFor` builds `…/p/<key>?brand=<name>`,
   embedded in the shared quote. Guard: `deep_link_test` (4 tests ✅).
   (Actual route-handling from external URL still ⬜ — needs web routing.)
69. ⬜ QR on the physical product → opens the card.
70. ⬜ Voice search that lands on the card.

## Phase 8 · Contractor & projects (71–80)
71. ✅ Add product to a project location — persisted `cardProjectsProvider`
   (ProjectItem: project/location/product/brand/qty, merges qty); "➕ הוסף
   לפרויקט" button. Guard: `card_projects_test`.
72. ✅ Duplicate-to-many-points — `addToLocations` + "×3 חדרים" button adds the
   product to several locations at once. Guard: `card_projects_test`.
73. ✅ Material dependencies — `connectionNeedsHe` lists what each end needs to
   mate ("מה הקו צריך לחיבור"). Guard: `line_fit_test`.
74. ✅ Cumulative project BOM — running counter ("📋 בפרויקט: N יחידות · M מיקומים")
   + "📋 BOM פרויקט מלא" button that runs `buildInstallation` over all project
   products (resolved via SKU) and shows the materialized list in a dialog.
   Guard: engine via `build_line_bom_test`; project model via `card_projects_test`.
75. ✅ Customer quote for the whole project — `projectQuoteText` aggregates each
   assigned item (location/brand/qty + est. price) into a copyable quote
   ("📋 הצעת מחיר לפרויקט"). Guard: `card_projects_test`.
76. ✅ Config versioning — persisted `cardVersionsProvider` saves named snapshots
   (label/product/brand). "💾 שמור גרסה" stores the current brand under its name.
   Each saved version is a `[label][×]` pair: tap label LOADS that brand (with
   snackbar + sticky brand pref), tap × DELETES. Re-saving the same label
   replaces (no dup). Guards: `card_versions_test` + (UI) `_SavedVersionChip`.
77. ⬜ Team sharing: chat/notes on a chosen product.
78. ⬜ Sync with the Gantt/tasks.
79. ⬜ Unified procurement report (PDF) for the whole project.
80. ✅ Ready project templates — `projectTemplates` (אמבטיה/מטבח סטנדרטי, one real
   SmartProduct per role, no over-pull) + `applyTemplate`; "🧩 תבניות" chips add
   the whole set to the project. Guard: `card_projects_test`.

## Phase 9 · Quality, performance, accessibility (81–90)
81. ✅ Comprehensive card-data integrity test (every SmartProduct × brand:
   bridge/summary/standards/tools/guide/compat/compliance+why/variants/
   cheaper-alt all coherent & non-throwing). Rendering of all 935 sheets stays
   covered by `product_journey_test`. Guard: `smart_card_data_test`.
82. ✅ Mutation-resistance tests for price/selection helpers — 12 strong
   invariants: cost sum · strict-cheaper alt · score band fences · effort
   threshold · safety-kit disjoint · cheap+premium tags mutually exclusive ·
   lineReadiness clamp [0,100] · lineReadiness monotone (gaps↓, kit↑) ·
   cycleDisplayTemp valid set · hotWaterSuitability suitable≤total ·
   resolveDefaultBrandIndex valid index. Guard: `mutation_test`. (Golden image
   tests still ⬜ — heavy/flaky in CI.)
83. 🟦 Offline-cache primitive — `offlineCacheProvider`: persisted
   `Map<String, CacheEntry>` with TTL (`get`/`put`/`sweep`/`clearAll`),
   in-memory + JSON-backed. Guard: `offline_cache_test` (6 tests). Concrete
   consumers (image cache, network response cache) still ⬜.
84. ⬜ Lazy-load images + smart prefetch.
85. ✅ Accessibility — explicit `Semantics(button, label)` on **9** key card
   actions (save · BOM · add-to-project · cart+safety · save-version · mode-
   toggle · project-mode · profession-mode · temp-picker). Guard: `accessibility_test` ✅.
   (Contrast + text-size adjustment still ⬜ — needs platform-level theme work.)
86. ✅ i18n scaffold — `lib/l10n/smart_card_strings.dart` extracts 28 SmartProduct
   card labels as `static const` fields, ready for parallel En/Ar classes.
   Guard: `smart_card_strings_test` (3 tests ✅). Full localization still ⬜.
87. ✅ Reduced-motion — every `AnimationController` in the SmartProduct card
   path (`_DiagramFlow` stage cascade + `_ExplodeChips` accessory burst) gates
   on `catalogSettingsProvider.reducedMotion`: when on, the controller jumps
   straight to `value: 1` instead of running `forward()`. New SmartProduct
   additions added no extra animations. Locked by `reduced_motion_test`: a
   static count invariant that goes red if a new AnimationController is added
   to `catalog_screen.dart` without a matching reducedMotion check.
88. ✅ Bundle-split strategy — `knowledge/BUNDLE_SPLIT.md` analysis + concrete plan.
   Actual code-split refactor still ⬜ — needs dedicated refactor session.
89. ✅ Regression gate — `regression_gate_test` asserts every curated card
   helper (47 names) is referenced by at least one test file. It caught 3
   uncovered helpers on first run (engineeringSpecFor/priceFor/
   catalogProductForSmart) → backfilled by `core_helpers_test`. Going forward:
   adding a helper without a test goes red.
90. ✅ In-app crash log — `crashLogProvider`: in-memory bounded `List<CrashEntry>`
   (newest-first, `maxEntries` trim), with `record(message, context:)`, `clear`,
   `countBy(contextFilter:)`. NOT persisted (error payloads may be sensitive).
   Guard: `crash_log_test` (5 tests ✅). External telemetry (Sentry/Crashlytics)
   still ⬜ — wall (needs service account).

## Phase 10 · Platform, analytics & moonshots (91–100)
91. 🟦 In-app analytics-event log — `analyticsLogProvider`: in-memory bounded
   `List<AnalyticsEvent>` (newest-first; `record(name, props:)`, `clear`,
   `countByName`, `recent(name:, limit:)`). NOT persisted by design. Foundation
   for future external analytics wiring. Guard: `analytics_log_test` (6 tests).
   External services (GA/Mixpanel) still wall-blocked. Built by parallel sub-agent.
92. ✅ Built-in A/B experiments — `abExperimentsProvider` (persisted
   `Map<experiment, variant>`, deterministic `ensure(experiment, variants)`
   via `hashCode.abs() % len`, override/clear). Built by parallel sub-agent.
   Guard: `ab_experiments_test` (6 tests).
93. ⬜ User ratings + real user photos ("here's how it looks at my place").
94. ⬜ Manufacturer integration (official datasheets) via API.
95. ✅ Expert vs simple mode — persisted `cardDetailModeProvider`; "מצב מורחב/פשוט"
   chip in the 📦 header gates standards/tools/bore/kit/variants/brand-guide/
   recently-viewed/compliance-why. Guard: `card_detail_mode_test`.
96. ⬜ Home-screen widget ("reorder my last line").
97. ⬜ Contractor inventory integration ("I have 3 in stock").
98. ⬜ Export the chosen config to CAD/BIM.
99. ✅ Coach mode — `knowledge/COACH_MODE.md` vision doc: how the card *teaches*
   by orchestrating already-shipped helpers (`complianceWhyHe`, `installTipsFor`,
   `connectionWarningHe`, `safetyKitItems`, `lineFitFor`, `adapterSuggestionFor`,
   `cardDetailModeProvider`) into just-in-time hints + next-best-action.
   Built by parallel sub-agent.
100. 🟦 Convergence checklist (in `knowledge/COACH_MODE.md`): what ✅ · why ✅ ·
    connects ✅ · install 🟦 · cost ✅ · supplier ⬜ — the latter two block on
    external infra (video/AR/voice/PDF + backend supplier feeds). The card is
    already the *knowledge brain* for everything that doesn't need a third-party
    integration. Built by parallel sub-agent.

---
_Created during the SmartProduct deep-dive. Execution starts at Phase 1, Step 5
(data contract) as the safe foundation for the merge._
