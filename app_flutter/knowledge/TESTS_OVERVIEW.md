# TESTS_OVERVIEW — what each `test/` file guards

A survey of the BuildSmart Flutter `test/` directory so the next agent (or
developer) can find the right test for a feature **without grepping**. Each
row points at the curated helper, ROADMAP step, or invariant a file enforces.

## Intro

- **Test files:** 102 `_test.dart` files at the top of `test/` (count via
  `ls test/ | grep -c "_test.dart"`), plus shared fixtures under `test/helpers/`.
- **Suite size:** 700+ tests passing — the suite is the **ground truth** before
  any checkpoint or push (PLAYBOOK §C, "comprehensive test cadence").
- **Guard protocol:** every wired helper must be referenced by at least one test
  (see `regression_gate_test`, SMARTPRODUCT_ROADMAP step 89). Adding a helper
  without a test goes red on the next run.
- **Naming rule:** files MUST end in `_test.dart` (**singular**). A plural
  `_tests.dart` is silently skipped by `flutter test` auto-discovery — see
  PLAYBOOK §C "test file must end in `_test.dart` (singular)".

## Grouping table

The 102 files split into ten domains. **Step** is the SMARTPRODUCT_ROADMAP entry
the test guards (where applicable; `—` = pre-roadmap or cross-cutting).

### 1. SmartProduct card data & rendering

| File | Step | One-line purpose |
|---|---|---|
| `smartproduct_contract_test.dart` | 5 | Every `SmartBrand.sku` resolves to a real `kCatalogProducts` SKU. |
| `smart_card_data_test.dart` | 81 | Per SmartProduct × brand: summary/standards/tools/guide/compat/why/variants/alt all coherent & non-throwing. |
| `product_journey_test.dart` | 81 | HARD end-to-end purchase journey driving all 935 product sheets through cart + checkout. |
| `card_score_test.dart` | 30 | `cardReadinessScore` returns 0..100 with a banded label for every product. |
| `card_detail_mode_test.dart` | 95 | Persisted expert/simple toggle (`cardDetailModeProvider`). |
| `smart_card_strings_test.dart` | 86 | i18n scaffold: 28 labels non-empty, unique, grounded in `catalog_screen.dart`. |
| `accessibility_test.dart` | 85 | Source-scan: 6 key card actions expose explicit `Semantics(button, label)`. |
| `widget_test.dart` | — | Boot smoke test for the root `MaterialApp`. |

### 2. Compat engine & coverage

| File | Step | One-line purpose |
|---|---|---|
| `compat_50_samples_test.dart` | — | Audits `compatibleProductsFor` on 50 diverse products via `_reallyMates`. |
| `compat_coverage_test.dart` | — | Reports verified-spec coverage by category (no failure, prints gaps). |
| `compat_explain_test.dart` | 21 | Every compat hit has a non-empty `connectionExplainHe` — match logic stays in sync with explanation. |
| `connection_joint_test.dart` | — | Joint-label invariants on `jointLabelHe` / `chainEdgeLabelHe`. |
| `chain_arrow_test.dart` | 23 | `chainArrowText` joins in order with the RTL arrow. |
| `adapter_suggestion_test.dart` | 27 | `adapterSuggestionFor` finds a bridging product when there's no direct mate. |
| `paired_warning_test.dart` | 29, 56 | `connectionWarningHe` + `frequentlyPairedTypesFor` shape & non-throw. |
| `line_fit_test.dart` | 28, 73 | `lineFitFor` + `connectionNeedsHe` against the smart cart. |
| `compat_brass_nipple_check.dart` | — | Targeted brass-nipple compat probe. |

### 3. Install / engine / studio

| File | Step | One-line purpose |
|---|---|---|
| `engine_harness_test.dart` | — | Engine smoke harness — `buildInstallation` over canned scenarios. |
| `install_builder_test.dart` | — | Layer 1+2 path-builder cases (10 named scenarios incl. the "2-inch faucet → toilet → pit" original bug). |
| `install_effort_test.dart` | 24, 34, 35 | `installEffortFor` + `installTipsFor` + `systemSafetyNoteHe`. |
| `install_kit_test.dart` | — | `installKitFor` returns valid kits per product. |
| `build_line_bom_test.dart` | 22 | `buildInstallation` anchor-call path the "build my line" button feeds. |
| `safety_kit_test.dart` | 25 | `safetyKitItems` diff of auto-compliance true vs false. |
| `acceptance_stage_test.dart` | 31, 38 | `acceptanceChecklistFor` non-empty/deduped + `stageProgressProvider` round-trip. |
| `pressure_drop_test.dart` (+ `_advanced` / `_offline`) | — | ΔP calc per chain; off-line-SKU exclusion (PLAYBOOK §D). |
| `hard_tests.dart` | — | Adversarial regression: pure fns + real catalog data + engine invariants, no UI. |

### 4. Card helpers (pure data)

| File | Step | One-line purpose |
|---|---|---|
| `core_helpers_test.dart` | 89 | Backfill for 3 helpers the regression gate caught uncovered (`engineeringSpecFor`, `priceFor`, `catalogProductForSmart`). |
| `brand_guide_test.dart` | 16 | `brandDecisionGuide` returns one stable entry per brand. |
| `brand_hot_filter_test.dart` | 65 | `brandSuitableForHot` matches the engine's hot-water rule. |
| `hot_water_suitability_test.dart` | 26 | `hotWaterSuitabilityFor` cross-checked against `productSuitableForTemp`. |
| `durability_test.dart` | 15 | `durabilityRatingFor` stars 1..5 + reason; null on spec-less. |
| `manufacturer_info_test.dart` | 20 | `manufacturerInfoFor` returns 'יצרן + מק"ט יצרן'. |
| `standards_tools_test.dart` | 12, 33 | `israeliStandardsFor` + `installToolsFor` per product. |
| `discovery_tags_test.dart` | 67 | `discoveryTagsFor` unique-per-(sp,brand) and never throws. |
| `compliance_why_test.dart` | 58 | Every distinct compliance-trigger label has a non-null `complianceWhyHe`. |
| `summary_alt_test.dart` | 45, 59 | `smartCardSummaryHe` + `cheaperAlternativeBrand`. |
| `line_cost_test.dart` | 42 | `lineCostEstimateFor` breakdown (product + acc + labour). |

### 5. Persisted state (SharedPreferences)

All use `SharedPreferences.setMockInitialValues({})` + fresh-notifier reload to
simulate a restart (pattern from PLAYBOOK §F).

| File | Step | One-line purpose |
|---|---|---|
| `card_selection_test.dart` | 7 | Per-product brand selection persists. |
| `brand_history_test.dart` | 51 | Brand-pick counts + `favouriteFor`. |
| `card_versions_test.dart` | 76 | Named config snapshots per product. |
| `card_projects_test.dart` | 71, 72, 74, 75, 80 | Project assignment / dup-to-locations / project BOM / project quote / templates. |
| `recently_viewed_test.dart` | 66 | Pure move-to-front-dedupe-cap + persisted round-trip. |
| `recent_searches_test.dart` | 62 | Same shape for in-card searches. |
| `feature_flags_test.dart` | 10 | Persisted `Set<String>` of enabled flag names. |
| `ab_experiments_test.dart` | 92 | Deterministic `ensure(experiment, variants)` + override/clear. |
| `quote_saved_test.dart` | 47, 48 | `savedConfigsProvider` toggle + `quoteTextFor`. |
| `offline_cache_test.dart` | 83 | TTL'd JSON-backed `OfflineCacheNotifier`. |
| `persistence_roundtrip_test.dart` | — | Every store moved to prefs writes key on change + loads into a fresh container. |
| `crash_log_test.dart` | 90 | In-memory bounded crash log (NOT persisted, payloads may be sensitive). |
| `analytics_log_test.dart` | 91 | In-memory bounded analytics event log (NOT persisted by design). |

### 6. Cart, projects & commerce

| File | Step | One-line purpose |
|---|---|---|
| `cart_safety_test.dart` | 46 | `buildSafetyAccessories` converts engine SKUs to `SmartCartAcc`. |
| `cart_bulk_order_test.dart` | — | 20 products × qty 1..20 through real cart math (subtotal/VAT/delivery/order). |
| `cart_stress_test.dart` | — | 50 randomised-but-deterministic cart scenarios vs hand-computed math. |
| `draft_quote_test.dart` | — | Draft-quote lifecycle. |
| `store_notif_widget_test.dart` | — | Store-screen notification widget. |
| `deep_link_test.dart` | 68 | `deepLinkFor` builds `/p/<key>?brand=<name>`. |

### 7. Mutation / regression gates (invariants)

| File | Step | One-line purpose |
|---|---|---|
| `regression_gate_test.dart` | 89 | **Meta-gate:** every curated card helper (47 names) is referenced by ≥1 test file. |
| `mutation_test.dart` | 82 | 6 strong invariants on price/selection helpers (sum identity, strict-cheaper, score-band fences, effort threshold, kit disjoint, tag exclusivity). |
| `catalog_regression_test.dart` | — | Catalog structural invariants. |
| `knowledge_protocol_test.dart` | — | Version label in `home_shell.dart` and `STATUS.md` stay in sync (PLAYBOOK §B "version label drift"). |
| `dedup_test.dart` | — | No SKU duplicates across the unified catalog. |
| `no_duplicate_specs_test.dart` | — | `kVerifiedSpecs` has no duplicate registrations. |
| `external_card_score_test.dart` | — | External / mirror card scoring stays consistent. |
| `enrichment_score_test.dart` | — | Enrichment scoring invariants. |

### 8. Audits, scans & catalog health

| File | Step | One-line purpose |
|---|---|---|
| `audit40_test.dart` · `deep_audit_test.dart` · `full_compliance_audit_test.dart` · `ten_scenarios_audit_test.dart` | — | Broad audit sweeps (40 cases / deep / compliance / 10 named scenarios). |
| `catalog_bfs_test.dart` · `bfs_demo_test.dart` · `pathfinder_test.dart` · `long_chain_test.dart` · `loop_test.dart` | — | Pathfinder & BFS coverage over the engine graph. |
| `catalog_health_test.dart` · `category_scan_test.dart` · `coverage_scan_test.dart` · `gaps_test.dart` · `gap_advice_test.dart` · `dn_pipe_gaps_test.dart` · `find_all_four_test.dart` · `alt_paths_test.dart` | — | Coverage scans + gap reports across the catalog. |
| `auto_compliance_test.dart` · `drainage_no_supply_test.dart` · `temp_suitability_test.dart` · `zone_tmtv_test.dart` · `manifold_test.dart` · `materialize_test.dart` · `hidden_sections_test.dart` · `connection_joint_test.dart` · `ppr_infra_test.dart` · `wiring_test.dart` · `system_examples_test.dart` · `comparison_set_test.dart` · `chip_structure_test.dart` · `line_structure_test.dart` · `layer3_quality_test.dart` · `twenty_products_test.dart` · `spec_assets_test.dart` | — | Engine + system domain invariants (drainage ≠ supply, T/M/TV zones, manifold, materialize, etc.). |

### 9. Cards: interactions, robustness & edge cases

| File | Step | One-line purpose |
|---|---|---|
| `card_interactions_test.dart` | — | Card tap/toggle interaction surface. |
| `robustness_test.dart` · `edge_cases_test.dart` · `state_deep_test.dart` · `product_sheet_strips_test.dart` | — | Robustness sweeps + sheet strip rendering. |
| `brand_history_test.dart` (also §5) | 51 | Cross-listed: drives history. |

### 10. Misc helpers (`test/helpers/`)

| File | Purpose |
|---|---|
| `dial_test_helper.dart` · `wiring_contract_helper.dart` · `state_machine_fixture.dart` | Shared fixtures used by other tests. |
| `feature_isolation_test_base.dart` · `isolation_validator.dart` | Base classes / validators for isolated feature runs. |
| `infra_extreme_test.dart` · `infra_gap_test.dart` · `infra_hard_test.dart` · `infra_stress_test.dart` | Infra-level stress probes consumed by the audits. |

## Notable patterns

- **Singular suffix:** `_test.dart`, never `_tests.dart` (silently skipped by
  `flutter test` auto-discovery — see PLAYBOOK §C).
- **Persistence pattern:** every persisted-state test opens with
  `SharedPreferences.setMockInitialValues({})`, creates a notifier, mutates,
  then creates a **fresh** notifier of the same type and re-asserts — that
  second instantiation is the "restart" (PLAYBOOK §F).
- **Regression gate is meta:** `regression_gate_test` scans `test/` for the
  curated helper names; if a wired helper has zero references, it goes red.
  That's how step 89 caught `engineeringSpecFor` / `priceFor` /
  `catalogProductForSmart` and forced `core_helpers_test`.
- **HARD journey rendering:** `product_journey_test` (step 81) is the only test
  that actually pumps the `_SmartProductSheet` widget end-to-end across all 935
  sheets — the rest of the card-data invariants live in non-pumping data tests
  (`smart_card_data_test`) which run far faster.
- **Mutation tests don't gate on `count > 0`:** invariants must be vacuously
  true on empty data, never a "must find samples" assertion (PLAYBOOK §C).
- **Synthetic specs stay out:** `HW-*` / `PIPE-*` SKUs registered into
  `kVerifiedSpecs` at runtime never leak into `compatibleProductsFor` because
  it filters on `kLipskeyCatalog` (PLAYBOOK §D, §H).

## For future agents — where does my new helper's test go?

When you add a curated card helper `myHelperFor(...)`:

1. **Focused unit test** — create `test/<my_helper>_test.dart` (singular!) that
   exercises the helper directly: empty input, happy path, boundary values, any
   invariants from the SMARTPRODUCT_ROADMAP step you're closing. Follow the
   shape of `adapter_suggestion_test.dart` / `discovery_tags_test.dart`.
2. **Regression-gate registration** — if the helper is **publicly used by the
   card** (i.e. imported from `lib/screens/catalog_screen.dart` or
   `lib/screens/lipskey_product_sheet.dart`), add its name to the
   `_kRequiredHelpers` list in `regression_gate_test.dart`. The gate will
   confirm at least one test file mentions the name. Private (`_foo`) helpers
   and trivial getters are excluded by design.
3. **Persisted state?** Mirror `card_selection_test.dart`: mock prefs, mutate,
   reload with a fresh notifier, assert the value survived.
4. **Touches `_SmartProductSheet` rendering?** The widget itself is huge and
   private; rely on the existing `product_journey_test` + `smart_card_data_test`
   coverage rather than pumping it yourself — see PLAYBOOK §G on the unreliable
   canvas-tap surface for why pure-data tests are preferred.
5. **Verify the count rose** — after `flutter test` the total must increase.
   If it doesn't, you probably named the file `_tests.dart` (plural). Rename.
