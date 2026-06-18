// WordFinderScreen — the flag-gated NEWBIE product-finder surface (בית/מאתר).
//
// STEP 5 of the word-finder swarm: the thin UI seam that wires the PURE
// conversation engine (STEP 3, word_finder_engine.dart) to the approved
// word-key keyboard (word_keyboard.dart) into the smallest FULL newbie path:
//
//     pick a plain WORD  →  narrow by an axis chip (repeat)  →  reach ONE
//     product card  →  open the product sheet (showLipskeyProductSheet).
//
// This file is the ONLY Flutter-aware layer of the finder dive. It holds the
// answered-step `stack` as widget state, derives the live pool from the base
// pool by ANDing every step's pure predicate, and on every tap asks the engine
// `offerQuestion` what to render next. When the engine RESOLVEs (pool collapses
// to one distinct card) it opens the existing reach-product sheet — the flow
// ENDS there, adding NO new cart path.
//
// SELF-GATING: like `SmartSuggestionStrip`, the screen renders nothing (a
// zero-height `SizedBox.shrink`) unless `kWordFinderFlag` is enabled. Wiring it
// into a real navigation seam is a SEPARATE later step — this widget is safe to
// land dark.
//
// EMERGENCY TYPING: the keyboard's `הקלדה` key reveals the real [BsKeyboard]
// over a [TextField]; on submit the stack is cleared and the pool is re-seeded
// by a catalog text query (`catalogProductMatchesQuery`). Typing is the escape
// hatch only — the happy path is word → chip taps.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/smart_tree.dart'
    show SmartProduct, smartProductForSku;
import 'package:buildsmart/features/word_finder/distinct_label.dart'
    show distinctSelectionLabels;
import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/quick_pad_engine.dart'
    show quickLabel;
import 'package:buildsmart/features/word_finder/recipe_kit.dart'
    show KitLine, KitMatch, assembleKit;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:buildsmart/features/word_finder/word_finder_flag.dart';
import 'package:buildsmart/features/word_finder/word_keyboard.dart';
import 'package:buildsmart/features/word_finder/word_keys_model.dart';
import 'package:buildsmart/features/word_finder/word_lexicon.dart';
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogProductMatchesQuery, searchRelevance;
import 'package:buildsmart/screens/lipskey_product_sheet.dart' show showLipskeyProductSheet;
import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The finder's word lexicon, built ONCE over the union dive-pool. Top-level so
/// the (potentially large) build runs a single time per isolate rather than on
/// every screen mount — the engine's `resolveWord`/`offerQuestion` read it.
final WordLexicon wordFinderLexicon = buildWordLexicon(kDivePool);

// ── 6th engine (work-recipe / "מתכון העבודה") view-only copy ────────────────
//
// These three strings are the ONLY display copy the kit view adds. They live
// here (not in the engine) because they are pure VIEW text — the same place
// `_buildEmptyState` keeps its copy. All three are OWNER-REVIEW: reword freely;
// the kit LOGIC (assembleKit / KitMatch) is untouched by a copy change.

/// OWNER-REVIEW: the icon-free key that, on a reached WORK-product, builds and
/// shows its recommended kit. Rendered via the same BsKey letter idiom as every
/// other word/chip key (no icon).
const String kBuildKitKey = 'בנה לי את הערכה';

/// OWNER-REVIEW: the expandable "more options" row label shown under a kit line
/// that has alternatives. The count of alternatives is appended in
/// [_WordFinderScreenState._buildKitLine] (e.g. 'עוד אפשרויות (3)').
const String kKitMoreOptions = 'עוד אפשרויות';

/// OWNER-REVIEW: the prefix for an accessory the catalog has no product for
/// (a [KitMatch.none] line) — shown as plain text, never a tappable key, so the
/// recipe still LISTS the part honestly ("you also need X — not in the
/// catalog") instead of hiding it.
const String kKitNotInCatalog = 'אין בקטלוג';

/// The flag-gated newbie product-finder screen.
///
/// Holds the answered-step [_WordFinderScreenState.stack] and the optional
/// emergency typing surface; everything else (what to ask, what a tap means) is
/// delegated to the pure `word_finder_engine` functions.
class WordFinderScreen extends ConsumerStatefulWidget {
  const WordFinderScreen({super.key, this.subtype});

  /// Optional curated sub-type, passed straight through to `offerQuestion` →
  /// `offerAxis`/`narrowAxis` for curated-facet narrowing. Usually null (the
  /// generic dive).
  final String? subtype;

  @override
  ConsumerState<WordFinderScreen> createState() => _WordFinderScreenState();
}

class _WordFinderScreenState extends ConsumerState<WordFinderScreen> {
  /// The answered conversation steps — the breadcrumb trail AND the pool
  /// filter. Each step carries a pure predicate; the live pool keeps only
  /// products for which EVERY step's predicate holds.
  final List<NewbieStep> stack = <NewbieStep>[];

  /// Emergency typing controller. Non-null only while the `הקלדה` surface is
  /// open; the real [BsKeyboard] inserts into it and submit re-seeds the pool.
  TextEditingController? _typeController;

  /// The active emergency-typed query, set by [_submitQuery]. Non-null only
  /// while the dive is seeded by a typed query; it makes [_pool] rank the
  /// re-seeded products DESCENDING by `searchRelevance`, so the most relevant
  /// product is `pool.first` (what a [Resolve] returns / a list would show
  /// first). Cleared whenever the stack is reset back to the word path.
  // OWNER-REVIEW: ranking the typed-query pool by searchRelevance is a
  // reversible default — drop this field (and the sort in `_pool`) to fall
  // back to plain base-pool order.
  String? _typedQuery;

  /// 7th engine ("מה מתחבר לזה" / connection-planner) view-state. Non-null only
  /// while the user is viewing the parts that connect to a reached anchor: it
  /// holds the anchor whose connections are shown. When set, the keyboard area
  /// renders the compatible parts (from [connectionsFor]) as plain product-keys
  /// instead of the word/chip keyboard; tapping one opens the existing product
  /// sheet (the same add-path as a reached product). Cleared by the back key and
  /// by any dive reset. This is the MINIMAL surface — the polished anchor UX is
  /// an OWNER-design decision (see the // OWNER-REVIEW affordance below).
  LipskeyCatalogProduct? _connectionsAnchor;

  /// 6th engine ("מתכון העבודה" / work-recipe) view-state. Non-null only while
  /// the user is viewing the assembled KIT for a reached WORK-product: it holds
  /// the [SmartProduct] recipe whose kit is shown. When set, the keyboard area
  /// renders the per-accessory kit (from [assembleKit]) — each resolved line as
  /// a product-key with its recommended product + collapsible alternatives, each
  /// unmatched line as plain text — instead of the word/chip keyboard. Tapping a
  /// product key opens the existing product sheet (the same add-path as a reached
  /// product / connections part). Cleared by the back key and by any dive reset.
  /// Mirrors [_connectionsAnchor] exactly; the polished kit UX is an OWNER-design
  /// decision (see the // OWNER-REVIEW affordances below).
  SmartProduct? _kitRecipe;

  /// @visibleForTesting — when false, reaching a [Resolve] does NOT auto-open
  /// the real [showLipskeyProductSheet]. Production keeps this true (the flow
  /// ENDS by opening the sheet). A behavioral widget test flips it off so it can
  /// assert the engine REACHED a single-card pool without supplying the sheet's
  /// heavy Riverpod deps (smartCart / catalogSettings / image assets).
  @visibleForTesting
  bool openSheetOnResolve = true;

  /// The base pool the dive walks. We use [kDivePool] DIRECTLY rather than
  /// `filterBySystem`: that helper lives in Flutter-/Riverpod-coupled screen +
  /// logic files and needs a `WaterSystem` argument we have no source for here,
  /// so applying it is NOT trivial. The full union pool is the correct newbie
  /// default — every product the app knows about is reachable.
  List<LipskeyCatalogProduct> get _basePool => kDivePool;

  /// The live pool: base products that satisfy EVERY answered step's predicate.
  ///
  /// When the dive was seeded by an emergency-typed query ([_typedQuery] set),
  /// the filtered pool is additionally sorted DESCENDING by
  /// `searchRelevance(p, query)` so the product the user most likely meant is
  /// `pool.first` — which is what a [Resolve] surfaces and what a ranked list
  /// would show on top. The sort is stable (it preserves base order on a tie),
  /// and `offerQuestion`/`distinctCardCount` stay order-independent, so this
  /// only affects WHICH single card a [Resolve] returns, never WHETHER one is
  /// reached.
  List<LipskeyCatalogProduct> get _pool {
    var pool = _basePool;
    for (final step in stack) {
      pool = pool.where(step.predicate).toList();
    }
    final query = _typedQuery;
    if (query != null && query.isNotEmpty) {
      // Stable descending sort by relevance: index-keyed so equal scores keep
      // their base-pool order rather than shuffling arbitrarily.
      final ranked = [for (var i = 0; i < pool.length; i++) (p: pool[i], i: i)]
        ..sort((a, b) {
          final byScore = searchRelevance(b.p, query)
              .compareTo(searchRelevance(a.p, query));
          return byScore != 0 ? byScore : a.i.compareTo(b.i);
        });
      pool = [for (final e in ranked) e.p];
    }
    return pool;
  }

  /// @visibleForTesting hook — the engine's verdict for the CURRENT state.
  ///
  /// A behavioral widget test that cannot supply the product sheet's heavy
  /// provider deps asserts on this instead: drive a bounded number of taps and
  /// check that the engine reached a [Resolve] OR a [ShowProducts] (the cascade
  /// converged on a product pick — see the multi-size loop fix). This is the
  /// same value `build` switches on, so the assertion mirrors real behaviour
  /// exactly.
  @visibleForTesting
  NewbieQuestion get currentQuestion =>
      offerQuestion(_pool, stack, wordFinderLexicon, widget.subtype);

  /// @visibleForTesting — distinct collapsed cards left in the live pool.
  @visibleForTesting
  int get distinctCardsLeft => distinctCardCount(_pool);

  /// @visibleForTesting — the answered breadcrumb words, in order.
  @visibleForTesting
  List<String> get crumbs => [for (final s in stack) s.crumbWord];

  /// @visibleForTesting — the first product of the live (possibly
  /// relevance-ranked) pool, or null if the pool is empty. Lets a behavioral
  /// test assert the emergency-typing rank order (Fix 2) WITHOUT needing the
  /// pool to collapse to a single [Resolve] card: `pool.first` is both what a
  /// ranked list shows on top and what a [Resolve] would return.
  @visibleForTesting
  LipskeyCatalogProduct? get firstPoolProduct {
    final p = _pool;
    return p.isEmpty ? null : p.first;
  }

  @override
  void dispose() {
    _typeController?.dispose();
    super.dispose();
  }

  /// Push a step, recompute, and — if the engine now RESOLVEs — open the
  /// reach-product sheet (the flow's terminus). Wrapped in `setState` so the
  /// breadcrumb + next question re-render.
  void _pushStep(NewbieStep step) {
    setState(() => stack.add(step));
    final q = currentQuestion;
    if (q is Resolve && openSheetOnResolve) {
      _openProduct(q);
    }
  }

  /// Pop the last answered step (the back affordance). A no-op on an empty
  /// stack. When the pop empties the stack, the dive is back at the first
  /// word question, so the typed-query rank context is cleared too.
  void _popStep() {
    if (stack.isEmpty) return;
    setState(() {
      stack.removeLast();
      if (stack.isEmpty) _typedQuery = null;
    });
  }

  /// @visibleForTesting — invoke the back-affordance's [_popStep] directly.
  /// The `חזרה` control is hidden once the stack is empty, so a test that wants
  /// to prove "popping at an empty stack is a safe no-op" cannot tap a button;
  /// it calls this instead.
  @visibleForTesting
  void popStepForTest() => _popStep();

  /// Clear the whole dive — every answered step and any typed-query rank
  /// context — back to the opening word question. Used by the empty-pool
  /// empty-state's restart affordance.
  void _restart() {
    setState(() {
      stack.clear();
      _typedQuery = null;
      _connectionsAnchor = null;
      _kitRecipe = null;
    });
  }

  /// 7th engine: ENTER the "מה מתחבר לזה" view for [anchor] — show the parts that
  /// connect to it. A no-op unless [anchor] is a valid connection anchor
  /// ([isConnectionAnchor]); the caller only offers the affordance for anchors,
  /// and this re-checks defensively so a non-anchor can never open an empty view.
  void _showConnections(LipskeyCatalogProduct anchor) {
    if (!isConnectionAnchor(anchor)) return;
    setState(() => _connectionsAnchor = anchor);
  }

  /// 7th engine: LEAVE the connections view, back to the converged product list.
  void _closeConnections() {
    setState(() => _connectionsAnchor = null);
  }

  /// 6th engine: ENTER the work-recipe KIT view for [recipe] — show its
  /// assembled per-accessory kit. Mirrors [_showConnections]: a pure state flip
  /// (the kit content is derived in [_buildKitView] via the pure [assembleKit]).
  void _showKit(SmartProduct recipe) {
    setState(() => _kitRecipe = recipe);
  }

  /// 6th engine: LEAVE the kit view, back to the converged product list.
  void _closeKit() {
    setState(() => _kitRecipe = null);
  }

  /// @visibleForTesting — true while the kit view is active. Mirrors
  /// [connectionsViewOpen]; lets a behavioral test assert the view opened
  /// without depending on rendered copy.
  @visibleForTesting
  bool get kitViewOpen => _kitRecipe != null;

  /// @visibleForTesting — drive the kit-view entry directly. The 'בנה לי את
  /// הערכה' key is only rendered inside a ShowProducts keyboard (and only when
  /// the reached product is a work-product), so a test reaches the view through
  /// this rather than synthesising a key tap on a specific dived-to product.
  /// Mirrors [showConnectionsForTest].
  @visibleForTesting
  void showKitForTest(SmartProduct recipe) => _showKit(recipe);

  /// @visibleForTesting — the parts shown in the connections view, or empty when
  /// the view is closed. Lets a behavioral test assert the affordance reached a
  /// non-empty compatible set for an anchor WITHOUT needing the product sheet's
  /// heavy Riverpod deps (the same pattern as [currentQuestion]).
  @visibleForTesting
  List<LipskeyCatalogProduct> get connectionsShown {
    final a = _connectionsAnchor;
    return a == null ? const [] : connectionsFor(a);
  }

  /// @visibleForTesting — true while the connections view is active.
  @visibleForTesting
  bool get connectionsViewOpen => _connectionsAnchor != null;

  /// @visibleForTesting — drive the "מה מתחבר לזה" entry directly (the affordance
  /// is only rendered inside the ShowProducts keyboard, so a test reaches it
  /// through this rather than synthesising a key tap).
  @visibleForTesting
  void showConnectionsForTest(LipskeyCatalogProduct anchor) =>
      _showConnections(anchor);

  /// @visibleForTesting — resolve a tapped product key against a supplied
  /// [products] list using the SAME sku-keyed lookup the live [_onWordTap]
  /// product branch uses ([_resolveBySku]). Lets a behavioral test seed a list
  /// where two DISTINCT cards share a plain-word label and prove the tap reaches
  /// the product by its unique sku payload — tapping the SECOND of a same-label
  /// pair resolves to the SECOND product, not the first (the label-match bug
  /// this fix removes). Routes through the one shared helper, so it cannot drift
  /// from production resolution.
  @visibleForTesting
  LipskeyCatalogProduct? resolveTappedProductForTest(
    List<LipskeyCatalogProduct> products,
    WordKey key,
  ) =>
      _resolveBySku(products, key.payload);

  /// Plain display label for a product key in a [ShowProducts] grid (and the
  /// connections view) — the SHORT plain word `quickLabel(p)`, NOT the full
  /// technical `nameHe` (full jargon violates the simplify-to-words vision; the
  /// quick pad already buckets by this same derived word). NO icon (rendered via
  /// the same icon-free `BsKey` idiom as word/chip keys).
  ///
  /// The label is display-only and intentionally NOT unique — two distinct skus
  /// can share a plain word (e.g. 'ונטיל'). Tapped-product resolution therefore
  /// keys on the WordKey PAYLOAD (the product's unique sku — see [_resolveBySku]
  /// / [WordKey] payloads in [_keysFor]), never on this label.
  String _productLabel(LipskeyCatalogProduct p) => quickLabel(p);

  /// The small product-thumbnail asset for a FINAL selection key, or null.
  ///
  /// Returns the product's [LipskeyCatalogProduct.imageAsset] ONLY when its
  /// underlying [LipskeyCatalogProduct.imageFile] is a real per-product CROP — i.e. non-null and NOT a
  /// full catalog-page image (those filenames start with `page_`, the same
  /// convention `_imgPath` uses to route into `pages/`). A zoomed-out full
  /// catalog page is useless as a tiny thumbnail (the product is a speck on it),
  /// so such products show TEXT ONLY (null → no thumbnail). Null is also the
  /// result for any product with no image at all — the safe default everywhere.
  // OWNER-REVIEW: gating thumbnails to real crops (excluding full `page_` images)
  // is a reversible product call — return p.imageAsset unconditionally to show a
  // (cropped-to-cover) page image too.
  String? _thumbAssetFor(LipskeyCatalogProduct p) {
    final file = p.imageFile;
    if (file == null || file.startsWith('page_')) return null;
    return p.imageAsset;
  }

  /// Resolve a tapped product key's PAYLOAD (a sku) back to the product in
  /// [products]. Keying on the unique sku — not the display label — is what lets
  /// two distinct cards that share a plain word (e.g. 'ונטיל' = skus
  /// 178700/187700) BOTH be reachable; a label match would always return the
  /// first. Returns null when no product in [products] carries [payload]
  /// (defensive — payload/state drift). This is the ONE definition both the live
  /// [_onWordTap] handler and the @visibleForTesting [resolveTappedProductForTest]
  /// route through, so render and resolve can never drift.
  LipskeyCatalogProduct? _resolveBySku(
    List<LipskeyCatalogProduct> products,
    Object? payload,
  ) {
    if (payload is! String) return null;
    for (final p in products) {
      if (p.sku == payload) return p;
    }
    return null;
  }

  /// 7th engine: the anchor the 'מה מתחבר לזה?' entry key targets for the current
  /// question, or null when no reached product is a valid connection anchor (so
  /// the affordance is NOT offered). Only a [ShowProducts] question carries the
  /// entry key (the keyboard that renders it) — it is the FIRST shown product
  /// that is an anchor (a stable, predictable pick). A [Resolve] opens the
  /// product sheet and renders NO keyboard, so the entry key never shows there;
  /// every other question returns null too.
  LipskeyCatalogProduct? get _connectionEntryAnchor {
    final q = currentQuestion;
    if (q is ShowProducts) {
      for (final p in q.products) {
        if (isConnectionAnchor(p)) return p;
      }
    }
    return null;
  }

  /// 6th engine: the WORK-recipe the 'בנה לי את הערכה' entry key targets for the
  /// current question, or null when no reached product is a work-product (so the
  /// affordance is NOT offered). Mirrors [_connectionEntryAnchor]: only a
  /// [ShowProducts] question carries the entry key (the keyboard that renders
  /// it), and it is the FIRST shown product that is a work-product — i.e. whose
  /// sku resolves via [smartProductForSku] to a [SmartProduct] recipe (a stable,
  /// predictable pick). A [Resolve] opens the product sheet and renders NO
  /// keyboard, so the entry key never shows there; every other question returns
  /// null too. The returned [SmartProduct] is the recipe whose kit [_showKit]
  /// will display.
  SmartProduct? get _kitEntryRecipe {
    final q = currentQuestion;
    if (q is ShowProducts) {
      for (final p in q.products) {
        final recipe = smartProductForSku(p.sku);
        if (recipe != null) return recipe;
      }
    }
    return null;
  }

  /// Handle a tapped word key, dispatched by its [WordKey.payload]:
  ///  • `'word'`    — seed the pool with the products the word names;
  ///  • `'chip'`    — narrow by the tapped axis chip;
  ///  • `'connect'` — open the "מה מתחבר לזה" connections view;
  ///  • anything else is a PRODUCT key whose payload is the product's unique
  ///    SKU — open the reach-product sheet for the product resolved by that sku
  ///    (the [ShowProducts] / connections terminus). Resolution keys on the sku,
  ///    NOT the display label, so two cards sharing a plain word both resolve.
  void _onWordTap(WordKey key) {
    final label = key.label;
    // 7th engine: a 'connect' key opens the "מה מתחבר לזה" view for the reached
    // anchor (the representative the affordance was offered for). The connect key
    // carries the literal 'connect' string as its payload (not a sku), so it is
    // matched here BEFORE the sku-payload product branch below.
    if (key.payload == 'connect') {
      final anchor = _connectionEntryAnchor;
      if (anchor != null) _showConnections(anchor);
      return;
    }
    // 6th engine: a 'buildkit' key opens the work-recipe KIT view for the reached
    // work-product (the representative the affordance was offered for). Like
    // 'connect', it carries the literal 'buildkit' string as its payload (not a
    // sku), so it is matched here BEFORE the sku-payload product branch below.
    if (key.payload == 'buildkit') {
      final recipe = _kitEntryRecipe;
      if (recipe != null) _showKit(recipe);
      return;
    }
    // 'word'/'chip' navigation keys carry those literal payloads; every OTHER
    // key the cascade renders is a PRODUCT key whose payload is the product's
    // unique sku (set in [_keysFor] / [_connectionKeys]).
    if (key.payload != 'word' && key.payload != 'chip') {
      // A product key reaches that product directly. While the connections view
      // is open the keys are the COMPATIBLE PARTS, so resolve against that list;
      // otherwise resolve against the converged ShowProducts list. Either way,
      // open the existing sheet with the surrounding list as category context —
      // the SAME add-path, no new cart route.
      final List<LipskeyCatalogProduct> products;
      if (_connectionsAnchor != null) {
        products = connectionsShown;
      } else {
        final current = currentQuestion;
        if (current is! ShowProducts) return; // defensive — state moved under us
        products = current.products;
      }
      // Resolve by the unique sku PAYLOAD, not the (non-unique) display label:
      // two distinct cards can share a plain word (e.g. 'ונטיל' = 178700/187700),
      // and a label match always returned the FIRST, making the 2nd unreachable.
      final picked = _resolveBySku(products, key.payload);
      if (picked == null) return; // defensive — payload/state drift
      if (openSheetOnResolve) {
        showLipskeyProductSheet(context, picked, products);
      }
      return;
    }
    if (key.payload == 'word') {
      // Precompute the resolved sku set ONCE so the per-product predicate is an
      // O(1) set lookup rather than re-resolving the lexicon for every product.
      final skuSet = {
        for (final p in resolveWord(label, wordFinderLexicon)) p.sku,
      };
      _pushStep(NewbieStep(
        axisLabel: 'דגם',
        chipLabel: label,
        crumbWord: label,
        predicate: (p) => skuSet.contains(p.sku),
      ));
    } else {
      // chip — narrow by this axis value using the SAME structural test the
      // finder UI uses (via the engine's `applyNarrow`/`productHasChip`).
      //
      // Record the TRUE axis label of the question being answered (read off the
      // current AskAxis) so the breadcrumb's axisLabel is the real axis
      // ('גודל' / 'זווית' / 'צבע' / 'דגם' / 'אפשרות') rather than a hard-coded
      // 'אפשרות'. crumbWord stays the tapped chip. Fall back to 'אפשרות' only
      // if the current question is somehow not an AskAxis (defensive).
      final current = currentQuestion;
      final trueAxis = current is AskAxis ? current.axisLabel : 'אפשרות';
      _pushStep(NewbieStep(
        axisLabel: trueAxis,
        chipLabel: label,
        crumbWord: label,
        predicate: (p) => applyNarrow([p], label).isNotEmpty,
      ));
    }
  }

  /// 6th engine: handle a tapped KIT product key. The key's payload is the
  /// product's unique sku; resolve it within [contextList] (the line's
  /// product + alternatives, the SAME list `distinctSelectionLabels` labelled)
  /// and open the existing product sheet with that list as its category context —
  /// the SAME sku-keyed add-path the ShowProducts / connections terminus uses, so
  /// the kit view adds NO new cart route. A no-op when the sku is not in
  /// [contextList] (defensive — payload/state drift) or when the sheet is
  /// suppressed in a behavioral test ([openSheetOnResolve] false).
  void _onKitProductTap(WordKey key, List<LipskeyCatalogProduct> contextList) {
    final picked = _resolveBySku(contextList, key.payload);
    if (picked == null) return; // defensive — payload/state drift
    if (openSheetOnResolve) {
      showLipskeyProductSheet(context, picked, contextList);
    }
  }

  /// `הכל` — skip the current axis (no narrowing). A genuine no-op for now: the
  /// engine offers the best splitting axis, and "all" means "don't pick a value
  /// on it". Re-render so the hint can update; the pool is unchanged.
  void _onAll() {
    setState(() {}); // no narrow; advance is a future refinement (skip-axis log)
  }

  /// `הקלדה` — reveal the emergency typing surface (real [BsKeyboard] over a
  /// [TextField]). Submit clears the stack and re-seeds by a catalog text query.
  void _onType() {
    setState(() => _typeController ??= TextEditingController());
  }

  /// Apply an emergency typed [query]: clear every answered step and re-seed the
  /// pool with a single `catalogProductMatchesQuery` predicate, recording the
  /// query in [_typedQuery] so [_pool] RANKS the matches DESCENDING by
  /// `searchRelevance` (the most relevant product becomes `pool.first`, hence
  /// the resolved / first card). The engine's `offerQuestion`/
  /// `distinctCardCount` stay order-independent, so the rank only chooses WHICH
  /// card resolves, never WHETHER one does.
  // OWNER-REVIEW: relevance ranking of the typed pool is a reversible default.
  void _submitQuery(String query) {
    final q = query.trim();
    setState(() {
      stack.clear();
      _typedQuery = null;
      _typeController?.dispose();
      _typeController = null;
      if (q.isEmpty) return;
      _typedQuery = q;
      stack.add(NewbieStep(
        axisLabel: 'חיפוש',
        chipLabel: q,
        crumbWord: q,
        predicate: (p) => catalogProductMatchesQuery(p, q),
      ));
    });
    if (q.isEmpty) return;
    // A typed query may itself collapse to one card → resolve straight away.
    final next = currentQuestion;
    if (next is Resolve && openSheetOnResolve) _openProduct(next);
  }

  /// Open the reach-product sheet for a resolved card — the flow's terminus.
  /// [Resolve.siblings] is the collapsed pool (every variant sharing the card),
  /// handed to the sheet as its `categoryProducts` so its variant pager works.
  void _openProduct(Resolve resolved) {
    showLipskeyProductSheet(context, resolved.product, resolved.siblings);
  }

  /// Map the engine's question to the word-key list the keyboard renders.
  List<WordKey> _keysFor(NewbieQuestion q) {
    if (q is AskWords) {
      return [for (final e in q.words) WordKey(e.word, payload: 'word')];
    }
    if (q is AskAxis) {
      return [for (final c in q.chips) WordKey(c, payload: 'chip')];
    }
    if (q is ShowProducts) {
      // The converged cascade: render each distinct product as a plain
      // icon-free word-key (same BsKey idiom). The key PAYLOAD is the product's
      // unique SKU, so the tap handler resolves it by sku — never by the
      // non-unique label (two cards can share a plain word). Tapping one opens
      // its sheet.
      //
      // KEY LABEL — to fix the identical-key bug (every converged key showing
      // the same plain `quickLabel`), compute a MINIMAL-distinction label map
      // ONCE over the whole list (`distinctSelectionLabels`) so each key is
      // UNIQUE in plain language. Fall back to the bare `_productLabel` only if
      // a sku is somehow missing from the map (defensive — never expected).
      final labels = distinctSelectionLabels(q.products);
      return [
        for (final p in q.products)
          WordKey(
            labels[p.sku] ?? _productLabel(p),
            payload: p.sku,
            // FINAL selection key → carry the small product thumbnail (a real
            // crop only; null for page-image / image-less products). The text
            // label is unchanged, so text-based finds still match the key.
            imageAsset: _thumbAssetFor(p), // OWNER-REVIEW: product thumbnails
          ),
        // 7th engine: when a reached product is a valid connection anchor, offer
        // a plain-text (icon-free) 'מה מתחבר לזה?' key that opens the parts-that-
        // connect view. Appended LAST so it never displaces a product key. Its
        // payload is the literal 'connect' sentinel (not a sku). It carries NO
        // imageAsset — a navigation key stays clean (text only).
        if (_connectionEntryAnchor != null)
          const WordKey(kConnectionsKey, payload: 'connect'), // OWNER-REVIEW copy
        // 6th engine: when a reached product is a WORK-product (its sku resolves
        // to a SmartProduct recipe), offer a plain-text (icon-free) 'בנה לי את
        // הערכה' key that builds + shows the recommended kit. Appended LAST (after
        // the connect key) so it never displaces a product key. Its payload is the
        // literal 'buildkit' sentinel (not a sku). NO imageAsset — a navigation
        // key stays clean (text only), like the connect key.
        if (_kitEntryRecipe != null)
          const WordKey(kBuildKitKey, payload: 'buildkit'), // OWNER-REVIEW copy
      ];
    }
    return const <WordKey>[]; // Resolve → handled by the sheet, no keys
  }

  /// 7th engine: the keys for the connections view — the compatible PARTS as
  /// plain product-keys. SAME icon-free idiom as a ShowProducts list: the
  /// payload is the product's unique SKU, so a tap reuses the existing
  /// sku-resolved open-sheet add-path. The connections list is NOT
  /// collapse-deduped, so size/angle/colour ALSO differ between parts.
  ///
  /// KEY LABEL — the connections list is also vulnerable to the identical-key
  /// bug (two parts sharing a plain `quickLabel`), so the SAME
  /// `distinctSelectionLabels` map is computed ONCE over the shown parts; each
  /// key takes its unique plain-language label from the map, falling back to the
  /// bare `_productLabel` only if a sku is missing (defensive). Keying the TAP
  /// on sku (not label) still keeps every part reachable.
  List<WordKey> _connectionKeys() {
    final parts = connectionsShown;
    final labels = distinctSelectionLabels(parts);
    return [
      for (final p in parts)
        WordKey(
          labels[p.sku] ?? _productLabel(p),
          payload: p.sku,
          // FINAL selection key (a compatible part) → carry its product
          // thumbnail (real crop only; null otherwise). Label unchanged.
          imageAsset: _thumbAssetFor(p), // OWNER-REVIEW: product thumbnails
        ),
    ];
  }

  /// The header prompt for the current question (empty for Resolve).
  String _headerFor(NewbieQuestion q) => switch (q) {
        AskWords(:final questionHe) => questionHe,
        AskAxis(:final questionHe) => questionHe,
        ShowProducts() => kPickProductQuestion,
        Resolve() => '',
      };

  /// Neutral empty-state shown when the derived pool is empty (e.g. an
  /// emergency-typed query that matched nothing). Without this the engine would
  /// surface a zero-chip [AskAxis] — a silent dead-end keyboard with no keys.
  /// Mirrors `quick_pad_screen.dart`'s `_buildEmptyState` styling (centered
  /// inkLight bold text) and adds a way back: a 'התחל מחדש' button that clears
  /// the whole dive via [_restart] (the breadcrumb's back arrow is also still
  /// shown above for a one-step undo).
  // OWNER-REVIEW: empty-state copy.
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(BsTokens.space3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            // OWNER-REVIEW: singular 'נסה' (was plural 'נסו') for one voice, and
            // 'מוצר מתאים' not search-jargon 'תוצאות' (was 'לא נמצאו תוצאות').
            'לא נמצא מוצר מתאים — נסה שוב', // OWNER-REVIEW
            textAlign: TextAlign.center,
            style: TextStyle(
              color: BsTokens.inkLight,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          TextButton(
            onPressed: _restart,
            child: const Text('התחל מחדש'), // OWNER-REVIEW
          ),
        ],
      ),
    );
  }

  /// 7th engine: the connections view — a MINIMAL parts-that-connect surface.
  /// Header ('מה מתחבר לזה?') + a back key (to the product list) + the compatible
  /// parts as plain icon-free product-keys (tapping one opens the existing
  /// product sheet). The polished anchor UX is OWNER-design; this is the smallest
  /// honest default. When an anchor somehow has no parts, a neutral line is shown
  /// instead of an empty keyboard.
  // OWNER-REVIEW: connections-view layout + copy.
  Widget _buildConnectionsView() {
    final keys = _connectionKeys();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              BsTokens.space2, 0, BsTokens.space2, 0),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: 'חזרה',
                child: IconButton(
                  // Icon-free copy is required on the word/chip KEYS; this is the
                  // same back-arrow IconButton the breadcrumb already uses (not a
                  // word-key), kept consistent with the dive's existing back.
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'חזרה',
                  onPressed: _closeConnections,
                ),
              ),
              const Expanded(
                child: Text(
                  kConnectionsHeader, // OWNER-REVIEW
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              // Symmetry spacer so the header text stays centred opposite the
              // back button.
              const SizedBox(width: 48),
            ],
          ),
        ),
        if (keys.isEmpty)
          const Padding(
            padding: EdgeInsets.all(BsTokens.space3),
            child: Text(
              kNoConnections, // OWNER-REVIEW
              textAlign: TextAlign.center,
              style: TextStyle(
                color: BsTokens.inkLight,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          // No skip/type affordance in the connections view, so suppress the
          // הכל/הקלדה utility row — those keys would be dead no-ops here (no
          // onAll/onType is wired). Only the compatible-part keys render.
          WordKeyboard(
            words: keys,
            onWordTap: _onWordTap,
            showUtilityRow: false,
          ),
      ],
    );
  }

  /// 6th engine: ONE kit line for accessory resolution [line], built in the SAME
  /// icon-free BsKey idiom as a ShowProducts / connections product key.
  ///
  ///  • [KitMatch.none] (product == null) → plain TEXT only (no key): the
  ///    accessory name plus a '(אין בקטלוג)' note, so the recipe still lists the
  ///    part honestly instead of hiding it. NOT tappable.
  ///  • otherwise → the RECOMMENDED [KitLine.product] as a product-key (thumbnail
  ///    via [_thumbAssetFor], DISTINCT plain label, payload = its sku; tap opens
  ///    the existing sheet). When [KitLine.alternatives] is non-empty, a
  ///    collapsible 'עוד אפשרויות (N)' row beneath it (DEFAULT COLLAPSED) reveals
  ///    the alternatives as the SAME idiom of product-keys.
  ///
  /// DISTINCT LABELS: the label map is computed ONCE over the line's
  /// `[product, ...alternatives]` TOGETHER, so three same-name products (e.g.
  /// three 'אטם דו צדדי' in different sizes) render with the minimal distinguishing
  /// suffix the labeller adds — never three identical-looking keys. The SAME list
  /// is the sheet's category context, so the sku-keyed [_onKitProductTap]
  /// resolution can never drift from the rendered keys.
  // OWNER-REVIEW: kit-line layout (product-key + collapsible alternatives) + the
  // text-only treatment of an un-catalogued accessory.
  Widget _buildKitLine(KitLine line) {
    final product = line.product;
    // Un-catalogued accessory → honest plain-text line, no key.
    if (product == null || line.match == KitMatch.none) {
      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: BsTokens.space2, vertical: BsTokens.space1),
        child: Text(
          // OWNER-REVIEW: 'name (אין בקטלוג)'.
          '${line.acc.name} ($kKitNotInCatalog)',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // Label the recommended product + its alternatives TOGETHER so identical
    // names (same-name, different-size variants) get distinct plain labels.
    final lineProducts = <LipskeyCatalogProduct>[product, ...line.alternatives];
    final labels = distinctSelectionLabels(lineProducts);

    final recKey = WordKey(
      labels[product.sku] ?? _productLabel(product),
      payload: product.sku,
      imageAsset: _thumbAssetFor(product), // OWNER-REVIEW: product thumbnails
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // The recommended product, rendered via the shared WordKeyboard idiom
        // (one key, no utility row). Tapping it opens the sheet with the whole
        // line (recommended + alternatives) as category context.
        WordKeyboard(
          words: [recKey],
          onWordTap: (k) => _onKitProductTap(k, lineProducts),
          showUtilityRow: false,
        ),
        // Collapsible alternatives — default COLLAPSED. The chevron is a standard
        // ExpansionTile control (not a word KEY), consistent with the back-arrow
        // IconButton the dive already uses; word keys themselves stay icon-free.
        if (line.alternatives.isNotEmpty)
          Theme(
            // Strip the default ExpansionTile divider lines so it blends with the
            // surrounding surfaceMid keyboard area.
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                  horizontal: BsTokens.space2),
              childrenPadding: EdgeInsets.zero,
              // OWNER-REVIEW: 'עוד אפשרויות (N)'.
              title: Text(
                '$kKitMoreOptions (${line.alternatives.length})',
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              children: [
                WordKeyboard(
                  words: [
                    for (final alt in line.alternatives)
                      WordKey(
                        labels[alt.sku] ?? _productLabel(alt),
                        payload: alt.sku,
                        imageAsset:
                            _thumbAssetFor(alt), // OWNER-REVIEW: thumbnails
                      ),
                  ],
                  onWordTap: (k) => _onKitProductTap(k, lineProducts),
                  showUtilityRow: false,
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 6th engine: the work-recipe KIT view — the assembled kit for [_kitRecipe].
  /// Header (the work-name) + a back key (to the product list) + one
  /// [_buildKitLine] per [assembleKit] line. Mirrors [_buildConnectionsView]'s
  /// header/back idiom.
  ///
  /// MUST be wrapped in a [SingleChildScrollView] (the build() caller already
  /// is): a long kit (many accessories, each with an expandable alternatives
  /// block) is taller than a normal phone viewport, and a non-scrolling Column
  /// throws a RenderFlex overflow on a short screen — the SAME crash the
  /// canonical audit caught for the main dive (see build()'s scroll note). The
  /// outer Expanded + SingleChildScrollView in build() supplies that scroll.
  // OWNER-REVIEW: kit-view layout + copy.
  Widget _buildKitView(SmartProduct recipe) {
    final lines = assembleKit(recipe);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              BsTokens.space2, 0, BsTokens.space2, 0),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: 'חזרה',
                child: IconButton(
                  // Same back-arrow IconButton the breadcrumb / connections view
                  // use (not a word-key), kept consistent with the dive's back.
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'חזרה',
                  onPressed: _closeKit,
                ),
              ),
              Expanded(
                child: Text(
                  recipe.name, // the work-name (OWNER-authored recipe title)
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              // Symmetry spacer so the title stays centred opposite the back
              // button (mirrors the connections-view header).
              const SizedBox(width: 48),
            ],
          ),
        ),
        for (final line in lines) _buildKitLine(line),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // SELF-GATE first — render nothing unless the flag is on. Mirrors the
    // `smart_suggestion_strip.dart` `.contains(flag) → SizedBox.shrink` idiom.
    final on = ref.watch(featureFlagsProvider).contains(kWordFinderFlag);
    if (!on) return const SizedBox.shrink();

    // Detect the empty-pool dead-end FIRST: when the derived pool is empty
    // (only possible once the stack is non-empty — the base pool is never
    // empty) and we are NOT mid-typing, the engine would otherwise hand back a
    // zero-chip AskAxis. Render a neutral empty-state with a way back instead.
    final poolIsEmpty = _pool.isEmpty && stack.isNotEmpty;
    final showEmptyState = poolIsEmpty && _typeController == null;

    final q = currentQuestion;
    final keys = _keysFor(q);
    final header = _headerFor(q);
    final crumbLine = crumbs.join(' · ');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: BsTokens.surfaceMid,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Breadcrumb + back ────────────────────────────────────────
              // Hidden while the connections OR kit view is open: each of those
              // views owns its single back control (otherwise two 'חזרה' arrows
              // would show).
              if (stack.isNotEmpty &&
                  _connectionsAnchor == null &&
                  _kitRecipe == null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      BsTokens.space2, BsTokens.space2, BsTokens.space2, 0),
                  child: Row(
                    children: [
                      Semantics(
                        button: true,
                        label: 'חזרה',
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          tooltip: 'חזרה',
                          onPressed: _popStep,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          crumbLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Question header ──────────────────────────────────────────
              // Hidden while the connections OR kit view is open — each carries
              // its own header (kConnectionsHeader / the work-recipe name).
              if (header.isNotEmpty && !showEmptyState &&
                  _connectionsAnchor == null &&
                  _kitRecipe == null)
                Padding(
                  padding: const EdgeInsets.all(BsTokens.space2),
                  child: Text(
                    header,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

              // The key region SCROLLS when its grid is taller than the
              // viewport — a well-connected connections anchor (uncapped) or a
              // full 24-word / 30-product grid on a short phone. The old
              // `const Spacer()` + a non-scrolling Column threw a RenderFlex
              // overflow (and crashed) on a normal-height device; the canonical
              // audit caught it (the screen test masked it at 1080x2400).
              // Expanded takes the remaining height; SingleChildScrollView lets
              // the content exceed it gracefully.
              Expanded(
                child: SingleChildScrollView(
                  child: _kitRecipe != null
                      // ── 6th engine: work-recipe kit view (when open) ──────
                      // Highest priority — a user inside the kit is deeper than
                      // the connections / typing surfaces. Captured into a local
                      // for null promotion.
                      ? _buildKitView(_kitRecipe!)
                      : _connectionsAnchor != null
                      // ── 7th engine: connections view (when open) ──────────
                      ? _buildConnectionsView()
                      : showEmptyState
                          // ── Empty-pool dead-end → neutral empty-state ─────
                          ? _buildEmptyState()
                          : _typeController != null
                              // ── Emergency typing surface (`הקלדה`) ────────
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: BsTokens.space2,
                                          vertical: BsTokens.space1),
                                      child: TextField(
                                        controller: _typeController,
                                        textDirection: TextDirection.rtl,
                                        decoration: const InputDecoration(
                                          hintText: 'מה לחפש?',
                                          border: OutlineInputBorder(),
                                        ),
                                        onSubmitted: _submitQuery,
                                      ),
                                    ),
                                    BsKeyboard(
                                      onKey: (s) {
                                        final c = _typeController!;
                                        c
                                          ..text = c.text + s
                                          ..selection =
                                              TextSelection.collapsed(
                                                  offset: c.text.length);
                                      },
                                      onBackspace: () {
                                        final c = _typeController!;
                                        if (c.text.isNotEmpty) {
                                          c
                                            ..text = c.text.substring(
                                                0, c.text.length - 1)
                                            ..selection =
                                                TextSelection.collapsed(
                                                    offset: c.text.length);
                                        }
                                      },
                                      onEnter: () =>
                                          _submitQuery(_typeController!.text),
                                      onSend: () =>
                                          _submitQuery(_typeController!.text),
                                    ),
                                  ],
                                )
                              // ── The word/chip keyboard — the happy path ───
                              : WordKeyboard(
                                  words: keys,
                                  onWordTap: _onWordTap,
                                  onAll: _onAll,
                                  onType: _onType,
                                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
