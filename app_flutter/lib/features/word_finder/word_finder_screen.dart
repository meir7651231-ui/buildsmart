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
import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/quick_pad_engine.dart'
    show quickLabel;
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
      // icon-free word-key (same BsKey idiom). The key LABEL is the SHORT plain
      // word (`_productLabel` → `quickLabel`); the key PAYLOAD is the product's
      // unique SKU, so the tap handler resolves it by sku — never by the
      // non-unique label (two cards can share a plain word). Tapping one opens
      // its sheet.
      return [
        for (final p in q.products) WordKey(_productLabel(p), payload: p.sku),
        // 7th engine: when a reached product is a valid connection anchor, offer
        // a plain-text (icon-free) 'מה מתחבר לזה?' key that opens the parts-that-
        // connect view. Appended LAST so it never displaces a product key. Its
        // payload is the literal 'connect' sentinel (not a sku).
        if (_connectionEntryAnchor != null)
          const WordKey(kConnectionsKey, payload: 'connect'), // OWNER-REVIEW copy
      ];
    }
    return const <WordKey>[]; // Resolve → handled by the sheet, no keys
  }

  /// 7th engine: the keys for the connections view — the compatible PARTS as
  /// plain product-keys. SAME icon-free idiom as a ShowProducts list: the label
  /// is the SHORT plain word (`_productLabel` → `quickLabel`) and the payload is
  /// the product's unique SKU, so a tap reuses the existing sku-resolved
  /// open-sheet add-path. The connections list is NOT collapse-deduped, so two
  /// parts CAN share a plain word — keying the tap on sku (not label) is what
  /// keeps both reachable.
  List<WordKey> _connectionKeys() => [
        for (final p in connectionsShown) WordKey(_productLabel(p), payload: p.sku),
      ];

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
              // Hidden while the connections view is open: that view owns the
              // single back control (otherwise two 'חזרה' arrows would show).
              if (stack.isNotEmpty && _connectionsAnchor == null)
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
              // Hidden while the connections view is open — that view carries
              // its own header (kConnectionsHeader).
              if (header.isNotEmpty && !showEmptyState &&
                  _connectionsAnchor == null)
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

              const Spacer(),

              // ── 7th engine: connections view (highest priority when open) ─
              if (_connectionsAnchor != null)
                _buildConnectionsView()
              // ── Empty-pool dead-end → neutral empty-state (no keyboard) ───
              else if (showEmptyState) ...[
                _buildEmptyState(),
                const Spacer(),
              ]
              // ── Emergency typing surface (only when `הקלדה` was tapped) ───
              else if (_typeController != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: BsTokens.space2, vertical: BsTokens.space1),
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
                          TextSelection.collapsed(offset: c.text.length);
                  },
                  onBackspace: () {
                    final c = _typeController!;
                    if (c.text.isNotEmpty) {
                      c
                        ..text = c.text.substring(0, c.text.length - 1)
                        ..selection =
                            TextSelection.collapsed(offset: c.text.length);
                    }
                  },
                  onEnter: () => _submitQuery(_typeController!.text),
                  onSend: () => _submitQuery(_typeController!.text),
                ),
              ] else
                // ── The word/chip keyboard — the happy path ───────────────
                WordKeyboard(
                  words: keys,
                  onWordTap: _onWordTap,
                  onAll: _onAll,
                  onType: _onType,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
