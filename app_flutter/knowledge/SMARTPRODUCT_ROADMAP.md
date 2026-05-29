# SmartProduct — 100-step roadmap (work plan)

Goal: turn `SmartProduct` (the smart-tree internal card, `_SmartProductSheet`)
into the unified "brain" of the app — knowing *what it is · what it suits · how
it connects · how to install · what it costs · who sells it*.

Status legend: ⬜ todo · 🟦 in progress · ✅ done

## 📌 Handoff — where we are (v5.14, ~46%: 32 ✅ + 14 🟦)
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
4. ⬜ One documented data schema replacing the duplication.
5. ✅ Contract tests: every `SmartBrand.sku` is a real catalog SKU; every product
   has a resolvable recommended brand. Baseline: 81 products · 365 brands ·
   307 with SKU · 252 of those with a verified spec. Guard: `smartproduct_contract_test`.
6. ✅ "📦 נתוני קטלוג" section in the smart card injects the catalog's spec /
   compat / price for the selected brand's SKU (via the bridge).
7. 🟦 Persisted selection — `cardSelectionProvider` remembers the last brand per
   product (`productKey→brandName`); restored in `initState`, saved on tap.
   (acc/qty persistence still ⬜.) Guard: `card_selection_test`.
8. ⬜ Golden tests for the unified card across every category.
9. 🟦 Cleared safe analyze warnings in `catalog_screen.dart` (unused
   `lipskey_brand_screen` import + unused `cs` local). Remaining dead widgets
   (`_MiniSearchPill`/`_Chip`/`_CatalogDrillSection`/`_diameterSubGroups`) await
   a careful dedicated removal pass (file is large + shared with the other session).
10. ⬜ Feature-flag infra to swap old/new card safely (A/B).

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
24. 🟦 System (supply/drainage) safety note + min-bore inline via
   `systemSafetyNoteHe` (gravity-drainage / upstream-shutoff) + the bore row.
   (Line-level ΔP still ⬜ — needs a built line.) Guard: `install_effort_test`.
25. ⬜ Auto install-kit — card offers all required safety items (correct-by-construction).
26. 🟦 Hot-water suitability across brands via `hotWaterSuitabilityFor`
   ("🌡 מים חמים: X/Y מותגים מתאימים", cross-checked vs engine
   `productSuitableForTemp`). (Interactive temp picker still ⬜.)
   Guard: `hot_water_suitability_test`.
27. ✅ Smart adapter recommendation — `adapterSuggestionFor` finds a bridging
   catalog product that mates BOTH this product and a cart item, when there's no
   direct connection ("🔌 מתאם מומלץ"). Guard: `adapter_suggestion_test`.
28. ✅ "Your line so far" — `lineFitFor` reads the smart cart and reports how
   many cart items this product connects to ("🧩 בקו שלך"). Guard: `line_fit_test`.
29. 🟦 Physical-connection warning — `connectionWarningHe` flags a spec'd product
   with zero direct catalog mates ("ייתכן שנדרש מתאם"). (Full per-pair impossible-
   connection validation lives in the engine gaps.) Guard: `paired_warning_test`.
30. 🟦 Card data-readiness score (0-100 + label) via `cardReadinessScore`
   (spec/connectivity/finder/price/variants) shown as a badge in the 📦 header.
   (Line-level safety/pressure/cost scoring still ⬜.) Guard: `card_score_test`.

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
46. ⬜ Smart add-to-cart: the whole line in one tap (incl. safety).
47. ✅ Save config as favourite — persisted `savedConfigsProvider`
   (`productKey#brandName`); "☆ שמור / ★ נשמר" toggle in the 📦 header.
   Guard: `quote_saved_test`.
48. 🟦 Share a quote — `quoteTextFor` builds a plain-text quote; "📋 הצעה" copies
   it to the clipboard. (WhatsApp/PDF export still ⬜ — needs url_launcher/PDF.)
   Guard: `quote_saved_test`.
49. ⬜ Price tracking: alert when a selected brand drops in price.
50. ⬜ Direct order/payment from the card (when backend exists).

## Phase 6 · Personalization & AI (51–60)
51. ⬜ Smart default brand from the user's order history.
52. ⬜ Filter by the active project (cold/hot/commercial) — hide irrelevant.
53. ⬜ In-card AI assistant: "what suits me?" in free text.
54. ⬜ Learning: more lines built → sharper recommendations.
55. ⬜ Product recognition from camera (barcode/image) → opens the card.
56. 🟦 "Frequently paired" — `frequentlyPairedTypesFor` surfaces the product
   *types* that most often connect (data-driven from the compat engine).
   (Real co-purchase data pending a backend.) Guard: `paired_warning_test`.
57. ⬜ Profession-aware (plumber/contractor/DIY) — different detail level.
58. ✅ "Why it matters" explanation under each compliance warning via
   `complianceWhyHe` (↳ line). Coverage-gated: every trigger label has a why.
   Guard: `compliance_why_test`.
59. ✅ One-line text summary via `smartCardSummaryHe` (name·material·system·temp·
   price) at the top of the 📦 section. Guard: `summary_alt_test`.
   (Voice read-aloud still ⬜.)
60. ⬜ Timing recommendation (when to order per project schedule).

## Phase 7 · Search & discovery (61–70)
61. ⬜ Index SmartProduct in the main search (not just the tree).
62. ⬜ Forgiving search (layman word → product) in the smart card too.
63. ✅ "Similar" — variant-family list ("גרסאות נוספות במשפחה") in the 📦 section
   via `variantSiblingsOf`. (Upgrade/cheaper-alternative still ⬜.)
64. ⬜ Health navigation: from the card straight to the relevant finder/category.
65. 🟦 Quick in-brand filter — extended the brand selector (סוג/מידה) with a
   "🌡 מים חמים בלבד" toggle via `brandSuitableForHot`. (material/price quick
   filters still ⬜.) Guard: `brand_hot_filter_test`.
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
74. 🟦 Cumulative project view — running "📋 בפרויקט: N יחידות · M מיקומים" from
   `cardProjectsProvider`. (Full materialized project BOM dialog pending.)
   Guard: `card_projects_test`.
75. ✅ Customer quote for the whole project — `projectQuoteText` aggregates each
   assigned item (location/brand/qty + est. price) into a copyable quote
   ("📋 הצעת מחיר לפרויקט"). Guard: `card_projects_test`.
76. ⬜ Config versioning (compare alternatives for the project).
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
82. ⬜ Golden + mutation tests on the price/selection logic.
83. ⬜ Offline-first: caching of data + images.
84. ⬜ Lazy-load images + smart prefetch.
85. ⬜ Full accessibility (screen reader, contrast, text size) across the card.
86. ⬜ Perfect RTL + Arabic/English support (i18n).
87. ⬜ Reduced-motion / sun mode per settings.
88. ⬜ Bundle size: split & code-split the card.
89. ⬜ Regression gate: every card choice covered by a test.
90. ⬜ Crash monitoring + telemetry for render errors.

## Phase 10 · Platform, analytics & moonshots (91–100)
91. ⬜ Analytics: what's chosen/abandoned in the card → product improvement.
92. ⬜ Built-in A/B experiments on the card layout.
93. ⬜ User ratings + real user photos ("here's how it looks at my place").
94. ⬜ Manufacturer integration (official datasheets) via API.
95. ✅ Expert vs simple mode — persisted `cardDetailModeProvider`; "מצב מורחב/פשוט"
   chip in the 📦 header gates standards/tools/bore/kit/variants/brand-guide/
   recently-viewed/compliance-why. Guard: `card_detail_mode_test`.
96. ⬜ Home-screen widget ("reorder my last line").
97. ⬜ Contractor inventory integration ("I have 3 in stock").
98. ⬜ Export the chosen config to CAD/BIM.
99. ⬜ "Coach mode" — the app teaches a junior plumber as they go.
100. ⬜ It all converges: one unified product card that knows *what · why · how it
    connects · how to install · cost · supplier* — the knowledge brain of plumbing.

---
_Created during the SmartProduct deep-dive. Execution starts at Phase 1, Step 5
(data contract) as the safe foundation for the merge._
