# SmartProduct — 100-step roadmap (work plan)

Goal: turn `SmartProduct` (the smart-tree internal card, `_SmartProductSheet`)
into the unified "brain" of the app — knowing *what it is · what it suits · how
it connects · how to install · what it costs · who sells it*.

Status legend: ⬜ todo · 🟦 in progress · ✅ done

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
7. ⬜ Unified state (single provider for brand/acc/qty selection) with persist.
8. ⬜ Golden tests for the unified card across every category.
9. ⬜ Remove dead code left from the duplication + clean analyze warnings.
10. ⬜ Feature-flag infra to swap old/new card safely (A/B).

## Phase 2 · Data enrichment (11–20)
11. ✅ Engineering spec (material/pressure/temp/system/ends/bore) rendered in the
   smart card via `engineeringSpecFor` (in the 📦 section).
12. ✅ Israeli standards embedded (ת"י 1205/5452/1519/1385) — relevant-standard tag
   per product via `israeliStandardsFor` ("תקן ישראלי רלוונטי" in the 📦 section).
   Guard: `standards_tools_test`.
13. ⬜ Real image gallery per brand (zoom, 360°).
14. ⬜ Precise dimensions + small engineering sketch (DN/length/thread) per variant.
15. ⬜ Quality/durability rating per brand (stars + reason).
16. ✅ "When to pick which" decision table between brands via `brandDecisionGuide`
   (rec / price-extreme / hot-suitability → one-line advice; "מתי לבחור איזה מותג"
   block). Guard: `brand_guide_test`.
17. ⬜ Real availability (stock/ETA) per SKU from supplier.
18. ⬜ Price history + trend chart for the selected brand.
19. ✅ Auto compliance/warning labels via `complianceTriggersFor` ("תקינות נדרשת"
   block in the 📦 section).
20. ⬜ Warranty + manufacturer + mfr part-number per brand.

## Phase 3 · Compatibility-engine integration (21–30)
21. ✅ "🔗 מתחבר ל-N מוצרים" in the smart card (`compatibleProductsFor` +
   `connectionExplainHe` labels, in the 📦 section).
22. ⬜ "Build my line" button → `buildInstallation` → full BOM.
23. ⬜ Materialized chain diagram inline (explicit pipes/couplings).
24. ⬜ System (supply/drainage) warning + min-bore + ΔP inline.
25. ⬜ Auto install-kit — card offers all required safety items (correct-by-construction).
26. ⬜ Temperature picker → filters heat-unsuitable brands in real time.
27. ⬜ Smart adapter recommendation when a brand doesn't directly mate the cart.
28. ⬜ "Your line so far" — what's in cart + how this product fits.
29. ⬜ Physical validation: warn on impossible connections.
30. ⬜ Line score (safety/pressure/cost) that updates with each choice.

## Phase 4 · Installation guidance (31–40)
31. ⬜ Interactive stages with "mark done" checklist.
32. ⬜ Short install video per stage.
33. ✅ Required-tools list (derived from spec ends → wrench/teflon, press tool,
   saw/solvent) via `installToolsFor` ("כלי עבודה" row). Guard: `standards_tools_test`.
34. ⬜ Time estimate + difficulty (DIY/pro) per install.
35. ⬜ Common mistakes + tips per stage.
36. ⬜ AR mode — place the product in space/on a wall via camera.
37. ⬜ Exploded view of the parts.
38. ⬜ "Test kit" — pressure/leak check at the end, with a compliance checklist.
39. ⬜ Export a tailored install-guide PDF.
40. ⬜ Voice / read-aloud of the stages for hands-busy work.

## Phase 5 · Price, suppliers & commerce (41–50)
41. ⬜ Real multi-supplier price (not "by supplier") with comparison.
42. ⬜ "Total cost for the line" — product + accessories + pipes + est. labour.
43. ⬜ Quantity discounts + auto promotions.
44. ⬜ Supplier choice by distance/rating/availability from settings.
45. ✅ "Cheaper alternative" — strictly-cheapest sibling brand via
   `cheaperAlternativeBrand` ("💰 חלופה זולה יותר"). Guard: `summary_alt_test`.
46. ⬜ Smart add-to-cart: the whole line in one tap (incl. safety).
47. ⬜ Save config as favorite / project template.
48. ⬜ Share a quote (WhatsApp/PDF) straight from the card.
49. ⬜ Price tracking: alert when a selected brand drops in price.
50. ⬜ Direct order/payment from the card (when backend exists).

## Phase 6 · Personalization & AI (51–60)
51. ⬜ Smart default brand from the user's order history.
52. ⬜ Filter by the active project (cold/hot/commercial) — hide irrelevant.
53. ⬜ In-card AI assistant: "what suits me?" in free text.
54. ⬜ Learning: more lines built → sharper recommendations.
55. ⬜ Product recognition from camera (barcode/image) → opens the card.
56. ⬜ "People who bought X also added Y" (data-driven accessories).
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
65. ⬜ Quick in-brand filter (type/size/material/price) — extend existing.
66. ✅ "Recently viewed" history — persisted `recentlyViewedProvider`
   (move-to-front + dedupe + cap-20), recorded on card open, shown as
   "נצפו לאחרונה". Guard: `recently_viewed_test`.
67. ⬜ Discovery tags ("new", "best-seller", "pro-recommended").
68. ⬜ Deep-link per product (share a link that opens the card).
69. ⬜ QR on the physical product → opens the card.
70. ⬜ Voice search that lands on the card.

## Phase 8 · Contractor & projects (71–80)
71. ⬜ Add product to a specific project (floor/apartment/room).
72. ⬜ Duplicate-to-many-points ("need 6 of these in 3 rooms").
73. ⬜ Material dependencies: the card knows what else the line needs before/after.
74. ⬜ Cumulative project BOM from all chosen cards.
75. ⬜ Customer quote straight from the choices.
76. ⬜ Config versioning (compare alternatives for the project).
77. ⬜ Team sharing: chat/notes on a chosen product.
78. ⬜ Sync with the Gantt/tasks.
79. ⬜ Unified procurement report (PDF) for the whole project.
80. ⬜ Ready project templates ("standard bathroom" = a product set).

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
