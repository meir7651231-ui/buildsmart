# SmartProduct — 100-step roadmap (work plan)

Goal: turn `SmartProduct` (the smart-tree internal card, `_SmartProductSheet`)
into the unified "brain" of the app — knowing *what it is · what it suits · how
it connects · how to install · what it costs · who sells it*.

Status legend: ⬜ todo · 🟦 in progress · ✅ done

## 📌 Handoff — where we are (v5.38, ~73%: 55 ✅ + 13 🟦)

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

## 📌 Earlier handoff (v5.14, ~46%)
Saved for the next run. Pick up here:
- **Group A (still buildable locally, no deps) — do these next:**
  76 config-versioning · 25 auto safety-kit (engine-grounded) · 46 add-whole-line-to-cart ·
  74 full project BOM dialog (currently just a counter) · 89 regression-gate meta-test ·
  82 mutation tests on price/selection · 85 accessibility (Semantics) · 57 profession-aware depth.
- **Group B (finish the 🟦 partials):** 2,7,9,15,20,24,26,29,30,48,56,65,68 — see each step's note.
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
2. 🟦 `SmartProduct` linked to the **unified** catalog by SKU — bridge + contract
   now index `kCatalogProducts` (Lipskey + Polyroll), so any brand SKU resolves.
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
9. 🟦 Cleared safe analyze warnings in `catalog_screen.dart` (unused
   `lipskey_brand_screen` import + unused `cs` local). Remaining dead widgets
   (`_MiniSearchPill`/`_Chip`/`_CatalogDrillSection`/`_diameterSubGroups`) await
   a careful dedicated removal pass (file is large + shared with the other session).
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
15. 🟦 Durability rating (1-5 stars + reason) via `durabilityRatingFor`
   (material/temp/pressure heuristic). (Real lab ratings pending.)
   Guard: `durability_test`.
16. ✅ "When to pick which" decision table between brands via `brandDecisionGuide`
   (rec / price-extreme / hot-suitability → one-line advice; "מתי לבחור איזה מותג"
   block). Guard: `brand_guide_test`.
17. ⬜ Real availability (stock/ETA) per SKU from supplier.
18. ⬜ Price history + trend chart for the selected brand.
19. ✅ Auto compliance/warning labels via `complianceTriggersFor` ("תקינות נדרשת"
   block in the 📦 section).
20. 🟦 Manufacturer + mfr part-number via `manufacturerInfoFor` (יצרן + מק"ט יצרן
   = the SKU). (Warranty still ⬜ — no warranty data.) Guard: `manufacturer_info_test`.

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
48. 🟦 Share a quote — `quoteTextFor` builds a plain-text quote; "📋 הצעה" copies
   it to the clipboard. (WhatsApp/PDF export still ⬜ — needs url_launcher/PDF.)
   Guard: `quote_saved_test`.
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
56. 🟦 "Frequently paired" — `frequentlyPairedTypesFor` surfaces the product
   *types* that most often connect (data-driven from the compat engine).
   (Real co-purchase data pending a backend.) Guard: `paired_warning_test`.
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
62. 🟦 Forgiving multi-word catalog search — `fuzzySearchProducts(query)` (every
   word must appear; whole-phrase substring matches rank highest; proximity
   tiebreak; configurable products iterable + limit). Search-box UI still ⬜.
   Guard: `fuzzy_search_test`.
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
68. 🟦 Deep-link per product — `deepLinkFor` builds `…/p/<key>?brand=<name>`,
   embedded in the shared quote. (Actual route-handling to open the card from a
   link pending web routing.) Guard: `deep_link_test`.
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
85. 🟦 Accessibility — explicit `Semantics(button, label)` on **9** key card
   actions (save · BOM · add-to-project · cart+safety · save-version · mode-
   toggle · project-mode · profession-mode · temp-picker). Gated by
   `accessibility_test`. (Contrast + text-size adjustment still ⬜ — needs
   platform-level theme work.)
86. 🟦 i18n scaffold — `lib/l10n/smart_card_strings.dart` extracts 28 SmartProduct
   card labels as `static const` fields, ready for parallel En/Ar classes. No
   wiring yet. Guard: `smart_card_strings_test` (non-empty · no-dup · screen-
   containment). Full localization (RTL Arabic, language switch) still ⬜.
   Built by parallel sub-agent.
87. ✅ Reduced-motion — every `AnimationController` in the SmartProduct card
   path (`_DiagramFlow` stage cascade + `_ExplodeChips` accessory burst) gates
   on `catalogSettingsProvider.reducedMotion`: when on, the controller jumps
   straight to `value: 1` instead of running `forward()`. New SmartProduct
   additions added no extra animations. Locked by `reduced_motion_test`: a
   static count invariant that goes red if a new AnimationController is added
   to `catalog_screen.dart` without a matching reducedMotion check.
88. 🟦 Bundle-split strategy — `knowledge/BUNDLE_SPLIT.md` analysis of top files
   (catalog_screen 7668L · lipskey_catalog 6822L · install_studio 3184L) + a
   concrete plan (extract `_SmartProductSheet` to its own file; deferred-import
   `install_engine` behind BOM tap; lazy verified-spec; category-split catalog).
   Built by parallel sub-agent. Actual code-split refactor still ⬜.
89. ✅ Regression gate — `regression_gate_test` asserts every curated card
   helper (47 names) is referenced by at least one test file. It caught 3
   uncovered helpers on first run (engineeringSpecFor/priceFor/
   catalogProductForSmart) → backfilled by `core_helpers_test`. Going forward:
   adding a helper without a test goes red.
90. 🟦 In-app crash log — `crashLogProvider`: in-memory bounded `List<CrashEntry>`
   (newest-first, `maxEntries` trim), with `record(message, context:)`, `clear`,
   `countBy(contextFilter:)`. NOT persisted (error payloads may be sensitive).
   Guard: `crash_log_test` (5 tests). External telemetry (Sentry/Crashlytics)
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
