# Word Finder — Architecture

The "מאתר חכם" (smart finder): a predictive, keyboard-style way to reach a plumbing
product the way a veteran counter-salesperson would — by simple words, by material,
or by the job — instead of typing a search query. Self-gated behind the
`kWordFinder` feature flag (renders `SizedBox.shrink()` when off); shipped ON to the
buildsmart-il.com web demo via `--dart-define=ENABLE_WORD_FINDER=true` (see
`feature_flags.dart`).

## Three entry axes (all at the "opening", flag-gated)
1. **Word cascade** (the default) — the top words by frequency, then "עוד…" reveals
   all ~107. Tapping a word seeds a dive.
2. **Material row** (`_buildMaterialRow`) — chips for the materials present in the
   pool; tapping scopes the whole dive to that material. See *Material axis* below.
3. **Jobs-first** (`_buildJobsEntry` → "לפי עבודה") — lists the ~82 work-recipes;
   tapping one opens its kit. The discoverable way into engine #6.

## The dive engine (`word_finder_engine.dart` → `offerQuestion`)
Given the current `pool` + answered `stack`, returns the next `NewbieQuestion`:
1. empty stack → `AskWords` (top `kFirstWordCount` words),
2. pool collapses to one distinct card → `Resolve`,
3. ≤ `kShowProductsThreshold` cards → `ShowProducts`,
4. else the **most-decisive unanswered axis** (`bestUnansweredAxis`, info-gain /
   expected-remaining-cards scored — "the easy path: ask what splits most first"),
5. else the curated-facet axis (`offerAxis` → `narrowAxis`, honours a subtype),
6. else `ShowProducts` (convergence floor).
`narrow_axis.dart` is the shared axis picker: curated facets → sizes → angles →
colours → characterizing words; returns a Hebrew label + chip labels, empty when
nothing splits. Distinct-card collapsing + per-key disambiguation live in
`distinct_label.dart` (`distinctSelectionLabels`).

## The seven engines (the "hidden ladder")
1. **Vocabulary** — `word_lexicon.dart` (`buildWordLexicon`): product → its
   characterizing word (first meaningful token, brand-prefixes stripped, synonyms
   canonicalized; else a category-fallback word).
2. **Dive shim** — the word→size→colour cascade over the union pool.
3. **Easy-path ladder** — the info-gain axis scorer (engine step 4 above).
4. **Recipe kit** — `recipe_kit.dart`: a job (`SmartProduct` in `smart_tree.dart`,
   ~82 recipes) → its accessories → ranked catalog SKUs. See *Recipe kit* below.
5. **Connections** — `connectionsFor(anchor)` ("מה מתחבר לזה?"): compatible parts
   for a reached product.
6. **(= recipe kit, surfaced via jobs-first + the 'בנה לי את הערכה' affordance.)**
7. **Quick-pad** — `quick_pad_*.dart`: punch product + quantity fast.

## Data flow
`lipskey_catalog.dart` (the raw catalog) → `dive_pool.dart` (`kDivePool`, the deduped
union of catalog + polyroll + huliot + hotwater corpora, ~1948 products) →
`word_lexicon`/`narrow_axis`/`material_lexicon`/`recipe_kit` derive their views from
that pool. `word_finder_screen.dart` is the only widget layer; every other file is
pure logic over the pool + product fields (no Flutter widgets), unit-testable.

## Material axis (`material_lexicon.dart`)
`materialOf(p)` = the first `kMaterials` key whose any term substrings
`'<nameHe> <categoryHe>'`, **else** the whole-category override
`kCategoryMaterial[categoryHe]`, else null. 7 materials (נחושת [copper+brass], PPR,
HDPE, רב-שכבתי, פקס, נירוסטה, פלדה); ~58% of the pool classified. The screen
memoizes the scoped pool + lexicon at pick time (`_materialPool`/`_materialLexicon`)
so the O(pool × terms) scan stays off the per-build path.

## Recipe kit (`recipe_kit.dart` + `recipe_acc_overrides.dart`)
`assembleKit(recipe)` resolves each `SmartAcc` to a catalog product by confidence:
owner-set sku → `kAccRankedSkus` swarm-ranked list (recommended first + alternatives)
→ relevance scorer → ambiguous/none. ~49% accessory coverage; the rest are
catalog-scope gaps (tools/tiling/sanitaryware not stocked) — an owner data decision.

## Feature flag & demo gating
`kWordFinderFlag = 'kWordFinder'`. `feature_flags.dart` force-enables it for the web
demo via the top-level const `kEnableWordFinderDemo = bool.fromEnvironment(
'ENABLE_WORD_FINDER')` (a NAMED const — a `bool.fromEnvironment` used directly in a
const collection-`if` is NOT reliably folded). Two CI workflows build with the define:
`firebase-hosting.yml` + `web-deploy.yml`.

## Test strategy (`test/features/word_finder/`)
- **Pure engines: 100% line coverage** (narrow_axis, word_finder_engine, dive_pool,
  word_lexicon, quick_pad_engine) — example + branch tests.
- **Screen: ~90%** — widget tests via `pumpScreen` + `@visibleForTesting` hooks
  (`openJobsForTest`, `showKitForTest`, `pickMaterialForTest`, `submitQueryForTest`,
  `restartForTest`, `connectionsViewOpen`, …) AND real-key-tap dispatch tests.
- **Cross-state regression** (`word_finder_screen_test.dart`): material→jobs→kit
  survival, `_resetSubViews` symmetry, single-back invariant, header/tooltip a11y.
- Gotchas (enforced): exactly one `WordKeyboard` at the opening (icon-free `BsKey`
  rows via `_iconFreeKeyRows` are NOT keyboards); `ensureVisible` not
  `scrollUntilVisible`; widget-level Semantics assertions (no `ensureSemantics`,
  which leaks a `SemanticsHandle`); `flutter test --dart-define` does NOT forward
  defines to library consts, so the flag-ON path is verified by `flutter build web`.

## File map
`word_finder_screen.dart` (UI + dive state) · `word_finder_engine.dart` (offerQuestion)
· `narrow_axis.dart` (axis picker) · `word_lexicon.dart` (vocab) · `material_lexicon.dart`
(material axis) · `recipe_kit.dart` + `recipe_acc_overrides.dart` (kit) · `dive_pool.dart`
(union pool) · `distinct_label.dart` (per-key disambiguation) · `quick_pad_*.dart`
(quantity pad) · `word_finder_home.dart` (mode toggle) · `word_keyboard.dart` / `bs_key`
(key widgets).

## OWNER-REVIEW knobs (reversible defaults, marked `// OWNER-REVIEW` in code)
Copy strings (axis questions, "מצא לי", "עוד…", "לפי עבודה", "לפי חומר"), the material
labels + terms + `kCategoryMaterial`, the ranked `kAccRankedSkus`, the distinct-label
axis order/separator, and `kFirstWordCount`. Phase-4 (auto mode-switching) and
voice/barcode are deferred owner-design decisions.
