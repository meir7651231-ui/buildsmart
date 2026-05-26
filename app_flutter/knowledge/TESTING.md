# Testing protocol — app_flutter

Three layers verify the app. Run all before every commit.

## 1. `flutter test` (the regression suite)
`test/` holds ~127 checks across 16 files. Key files:
- `gaps_test.dart` — pure-logic contract checks (cart math, checkout gates,
  notif predicate/grouping/importance, index tokenizer, chat presence,
  catalog defaults). Mirrors `../WIRING.md`.
- `wiring_test.dart` — the wiring contract (cart stepper, store→cart defaults,
  notif filter, chat mute/archive).
- `edge_cases_test.dart` — 30 adversarial edge cases.
- `catalog_regression_test.dart` — runs the in-app `testCatalog()` harness.
- `widget_test.dart` — shell boot, dial drills, overview/categories.
- `product_journey_test.dart` — **end-to-end purchase journey** for **10 real
  products** across categories: catalog search → product sheet → add-to-cart →
  cart FAB → store cart (stepper + summary) → checkout → confirmation, asserting
  UI **and** providers at every stage. (This suite caught a real `_RelatedCard`
  overflow for long product names — now fixed via a `Flexible` name.) It also
  includes a **catalog-wide sweep**: one product per distinct category (all 69),
  the product sheet fully scrolled, asserting no overflow/render error for any
  category's layout. Plus a **HARD sweep** over all **935** products at the
  app's largest text scale (1.15) on a narrow 340×680 phone — which exposed 92
  horizontal Row overflows (accessory name, section title, category header,
  size badge), all fixed with `Flexible`/ellipsis.
- domain: `pathfinder_test`, `catalog_bfs_test`, `bfs_demo_test`,
  `install_builder_test`, `manifold_test`, `deep_audit_test`, etc.

## 2. In-app regression harness (`lib/test_harness/`)
`runRegression(ref)` runs modules: dsync · tabs · buttons · products ·
behavior · dupes · sections · settings · catalog. Surfaced in
`regression_panel_screen.dart` (reachable from the BS dial). All counts are
computed **dynamically** from `kLipskeyCatalog` — no hard-coded totals.

## 3. Mutation testing (the teeth check)
Inject a deliberate bug into logic, run `flutter test`, confirm a test goes
red (CAUGHT), then `git checkout --` to revert. Scripts used live in `/tmp`
(not committed). History:
- 30 obvious bugs → 30/30 caught.
- 50 subtle bugs → 32/50 (18 gaps in embedded/uncovered logic).
- Closed the 18 by extracting pure helpers + tests.
- A 2nd subtler round found 9 more gaps → closed.
- Final 50-mutation sweep → **49/50**, last one an *equivalent mutant*
  (`minOrderAmount > 0` vs `>= 0`), pinned with a negative-subtotal case → **50/50**.

**Rule:** domain logic must be 100% mutation-caught. To make logic catchable,
extract it from widgets into pure top-level functions (see ARCHITECTURE).
Genuinely-equivalent mutants are pinned with adversarial inputs, not ignored.

### Quick mutation-test recipe
```python
# for each (file, old, new): replace → flutter test → returncode!=0 == CAUGHT → git checkout -- file
```
UI-only effects (theme/grid/VAT display/image size) are covered through their
providers/helpers, not pixel rendering — a known, accepted boundary.
