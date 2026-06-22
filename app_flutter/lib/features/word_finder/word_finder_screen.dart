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
    show SmartProduct, kSmartProducts, smartProductForSku;
import 'package:buildsmart/features/word_finder/distinct_label.dart'
    show distinctSelectionLabels;
import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/material_lexicon.dart';
import 'package:buildsmart/features/word_finder/quick_pad_engine.dart'
    show quickLabel;
import 'package:buildsmart/features/word_finder/recipe_kit.dart'
    show KitLine, KitMatch, assembleKit;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:buildsmart/features/word_finder/word_finder_flag.dart';
import 'package:buildsmart/features/word_finder/word_keyboard.dart';
import 'package:buildsmart/features/word_finder/word_keys_model.dart';
import 'package:buildsmart/features/word_finder/word_lexicon.dart';
import 'package:buildsmart/screens/ai_finder_screen.dart' show AiFinderScreen;
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogProductMatchesQuery, searchRelevance;
import 'package:buildsmart/screens/lipskey_product_sheet.dart' show showLipskeyProductSheet;
import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_key.dart' show BsKey;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/key_models.dart'
    show KbKey;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The finder's word lexicon, built ONCE over the union dive-pool. Top-level so
/// the (potentially large) build runs a single time per isolate rather than on
/// every screen mount — the engine's `resolveWord`/`offerQuestion` read it.
final WordLexicon wordFinderLexicon = buildWordLexicon(kDivePool);

/// Material axis: the materials present in the union dive-pool, in [kMaterials]
/// display order. Computed ONCE at the top level (like [wordFinderLexicon]) so
/// the pool scan does not re-run every build — the opening material chip-row
/// offers one key per entry.
final List<String> kMaterialsInDivePool = materialsInPool(kDivePool);

/// Jobs-first entry: the work-recipes ([kSmartProducts]) sorted by `.name`, for
/// the JOB LIST keys. Computed ONCE at the top level (like [kMaterialsInDivePool])
/// so the sort does not re-run every build. A flat A→Z list is the v1 ordering;
/// grouping by category is a future refinement.
// OWNER-REVIEW: a flat name-sorted job list (grouping/sort by category is a
// future refinement — the brief accepts a flat sorted list for v1).
final List<SmartProduct> kJobsByName = [...kSmartProducts]
  ..sort((a, b) => a.name.compareTo(b.name));

/// Jobs-first entry: `SmartProduct.key` → recipe, over [kSmartProducts]. Built
/// once. A tapped job key carries the recipe's unique `.key` as its payload (the
/// SAME sku-keyed-resolution philosophy the product keys use — resolve by a
/// stable id, never by the display label), and this index resolves it back to
/// the [SmartProduct] whose kit [_WordFinderScreenState._showKit] will show.
final Map<String, SmartProduct> kJobByKey = {
  for (final r in kSmartProducts) r.key: r,
};

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

/// OWNER-REVIEW: the icon-free key appended to the OPENING word list that reveals
/// the long tail of words hidden below the top-[kFirstWordCount] cut (the ~80
/// rarer part-nouns a non-technical user otherwise can't reach without typing —
/// `ניפל`, `רקורד`, `בושינג`). Tapping it shows EVERY lexicon word.
const String kMoreWordsKey = 'עוד…';

/// OWNER-REVIEW: the icon-free key shown IN PLACE OF [kMoreWordsKey] once the full
/// word list is revealed — tap it to collapse back to the top words.
const String kFewerWordsKey = 'פחות';

// ── Material axis ("ציר-חומר") view copy ─────────────────────────────────────
//
// The material entry is offered ONLY at the opening (empty stack): the user
// picks a material (נחושת / PPR / פקס…) → the dive filters to that material's
// products and the noun keys then show only that material's parts. These three
// strings are the ONLY display copy the material entry adds; all OWNER-REVIEW
// (reword/reorder freely — the detection LOGIC lives in `material_lexicon.dart`).

/// OWNER-REVIEW: the leading label of the opening MATERIAL chip-row — names the
/// row so the user reads it as "by material" before the per-material keys. It is
/// a plain non-tappable caption (rendered as a heading above the keys), NOT a
/// word key, so it carries no payload.
const String kByMaterialLabel = 'לפי חומר';

/// OWNER-REVIEW: the icon-free clear affordance shown once a material is picked —
/// tapping it drops the material filter (back to ALL materials) and clears the
/// dive. Rendered via the same BsKey letter idiom as every other key (no icon).
const String kAllMaterials = 'כל החומרים';

// ── Jobs-first entry ("לפי עבודה") view copy ─────────────────────────────────
//
// The recipe KIT (engine #6) is otherwise reachable ONLY when the dive happens
// to converge on a work-product — hard to discover. The jobs-first entry, like
// the material chip-row, is offered at the opening: tapping it opens a JOB LIST
// (every [kSmartProducts] recipe by `.name`, as icon-free keys); tapping a job
// opens its kit via the EXISTING [_WordFinderScreenState._showKit]. These two
// strings are the ONLY display copy the entry adds; both OWNER-REVIEW (reword
// freely — the kit LOGIC, assembleKit / KitMatch, is untouched by a copy change).

/// OWNER-REVIEW: the icon-free key shown at the OPENING (beside the material
/// chip-row) that opens the JOB LIST — the discoverable entry into the recipe
/// kit. Rendered via the same BsKey letter idiom as every other key (no icon);
/// its payload is the literal 'jobs' sentinel.
const String kByJobLabel = 'לפי עבודה';

/// OWNER-REVIEW: the leading caption of the JOB-LIST view — names the list so the
/// user reads it as "pick a job" above the per-job keys. A plain non-tappable
/// heading (mirrors [kConnectionsHeader] / the kit view's work-name header), NOT
/// a word key, so it carries no payload.
const String kJobsHeader = 'איזו עבודה?';

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

  /// Opening word-list expansion. False (default) → the opening [AskWords] shows
  /// only the top [kFirstWordCount] words by frequency plus a [kMoreWordsKey]
  /// ('עוד…') key. True → it shows EVERY lexicon word (via [wordsByFrequency])
  /// plus a [kFewerWordsKey] ('פחות') key to collapse back. Only meaningful at
  /// the opening word question (empty stack); reset to false on any restart /
  /// re-seed so a fresh dive always opens collapsed.
  bool _showAllWords = false;

  /// Material axis ("ציר-חומר") selection. Null (default) = ALL materials (the
  /// full [kDivePool] base). When set to a [kMaterials] key, [_basePool] narrows
  /// to that material's products, so the ENTIRE existing word→size→colour cascade
  /// runs over the material-scoped pool with zero engine changes. Picked at the
  /// opening only (via the material chip-row / [pickMaterialForTest]); cleared by
  /// the 'כל החומרים' affordance and by every dive reset.
  String? _material;

  /// MEMOIZED lexicon scoped to the current material's pool. Non-null only while
  /// [_material] is set. Built ONCE when the material is PICKED (in the tap
  /// handler / [pickMaterialForTest]) — NOT inside a getter/build: a fresh
  /// `buildWordLexicon` over 111–774 products on every frame would jank. Cleared
  /// (set null) whenever the material is cleared. The active-lexicon helper
  /// ([_activeLexicon]) reads it so both [currentQuestion] and the tapped-noun
  /// [resolveWord] resolve WITHIN the material pool.
  WordLexicon? _materialLexicon;

  /// Jobs-first entry ("לפי עבודה") view-state. False (default) → the opening
  /// shows the 'לפי עבודה' entry key (beside the material chip-row). True → the
  /// keyboard area renders the JOB LIST: every [kSmartProducts] recipe by `.name`
  /// as an icon-free key (via [_iconFreeKeyRows], NOT a second [WordKeyboard], so
  /// the opening keeps exactly one WordKeyboard — the cascade — when the list is
  /// closed, and ZERO while it is open). Tapping a job opens its kit via the
  /// existing [_showKit]. Like the material entry it is meaningful ONLY at the
  /// opening (empty stack); reset to false on any restart / re-seed / pop-to-empty
  /// so a fresh dive never lingers in the job list. Mirrors the material view-state
  /// flags exactly; the polished jobs UX (grouping/sort) is an OWNER-design
  /// decision (see the // OWNER-REVIEW affordance below).
  bool _jobsOpen = false;

  /// @visibleForTesting — when false, reaching a [Resolve] does NOT auto-open
  /// the real [showLipskeyProductSheet]. Production keeps this true (the flow
  /// ENDS by opening the sheet). A behavioral widget test flips it off so it can
  /// assert the engine REACHED a single-card pool without supplying the sheet's
  /// heavy Riverpod deps (smartCart / catalogSettings / image assets).
  @visibleForTesting
  bool openSheetOnResolve = true;

  /// The base pool the dive walks. With no material picked ([_material] null) it
  /// is [kDivePool] DIRECTLY — the full union pool is the correct newbie default
  /// (every product the app knows about is reachable; we do NOT apply
  /// `filterBySystem`, a Flutter-/Riverpod-coupled helper needing a `WaterSystem`
  /// we have no source for here). When a material IS picked, the base narrows to
  /// that material's products ([materialOf] == _material), so the ENTIRE existing
  /// word→size→colour cascade then runs over the material-scoped pool with zero
  /// engine changes.
  List<LipskeyCatalogProduct> get _basePool =>
      _material == null ? kDivePool : _materialPool!;

  /// The material-scoped pool, MEMOIZED alongside [_materialLexicon] (both are
  /// the costly `materialOf` / `buildWordLexicon` derivations of a material
  /// pick). Built once at each material pick-site, read by [_basePool], and
  /// cleared to null wherever [_materialLexicon] is — so the O(pool × terms)
  /// `materialOf` scan never runs on the per-build path (the sibling lexicon
  /// memoization the class already documents as necessary). The bang in
  /// [_basePool] is safe: non-null whenever [_material] is (set/cleared together).
  List<LipskeyCatalogProduct>? _materialPool;

  /// The lexicon the engine + tapped-noun resolution use for the CURRENT state:
  /// the full [wordFinderLexicon] when no material is picked, else the MEMOIZED
  /// [_materialLexicon] scoped to the material pool. Reading the memoized field
  /// (never rebuilding here) is what keeps the costly `buildWordLexicon` off the
  /// per-frame path — it is built once when the material is picked. The bang is
  /// safe: [_materialLexicon] is non-null whenever [_material] is non-null (both
  /// are set together in the 'material' tap and cleared together everywhere).
  WordLexicon get _activeLexicon =>
      _material == null ? wordFinderLexicon : _materialLexicon!;

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
      offerQuestion(_pool, stack, _activeLexicon, widget.subtype);

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
  /// stack. When the pop empties the stack, the dive is back at the opening word
  /// question, so the typed-query rank + expand context are cleared. A picked
  /// MATERIAL is KEPT (a stable scope): back returns to the material opening (its
  /// scoped word list + 'כל החומרים'); the user exits the material explicitly via
  /// the 'כל החומרים' key. // OWNER-REVIEW: back stays within the picked material.
  void _popStep() {
    if (stack.isEmpty) return;
    setState(() {
      stack.removeLast();
      if (stack.isEmpty) {
        _typedQuery = null;
        _showAllWords = false;
        _jobsOpen = false;
      }
    });
  }

  /// @visibleForTesting — invoke the back-affordance's [_popStep] directly.
  /// The `חזרה` control is hidden once the stack is empty, so a test that wants
  /// to prove "popping at an empty stack is a safe no-op" cannot tap a button;
  /// it calls this instead.
  @visibleForTesting
  void popStepForTest() => _popStep();

  /// Reset every SUB-VIEW flag to closed in ONE place, so the [_subViewOpen]
  /// sibling set (kit / connections / jobs) cannot drift: any new sub-view that
  /// ORs into [_subViewOpen] adds its reset here once, and every full dive-reset
  /// path ([_restart], [_submitQuery]) clears the whole set together. Field-only
  /// (no setState) — callers already wrap their own setState.
  void _resetSubViews() {
    _kitRecipe = null;
    _connectionsAnchor = null;
    _jobsOpen = false;
  }

  /// Clear the whole dive — every answered step and any typed-query rank
  /// context — back to the opening word question. Used by the empty-pool
  /// empty-state's restart affordance.
  void _restart() {
    setState(() {
      stack.clear();
      _typedQuery = null;
      _resetSubViews();
      _showAllWords = false;
      _material = null;
      _materialLexicon = null;
      _materialPool = null;
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

  /// Jobs-first entry: OPEN the JOB LIST (the 'לפי עבודה' affordance). A pure
  /// state flip (the list content is derived in [_buildJobsView] from
  /// [kJobsByName]). Mirrors [_showKit] / the material entry.
  void _openJobs() {
    setState(() => _jobsOpen = true);
  }

  /// Jobs-first entry: CLOSE the JOB LIST, back to the opening word cascade.
  void _closeJobs() {
    setState(() => _jobsOpen = false);
  }

  /// True while a SUB-VIEW that owns its OWN back control is open — the kit view
  /// ([_kitRecipe]), the connections view ([_connectionsAnchor]), or the JOB LIST
  /// ([_jobsOpen]). The dive's breadcrumb back ([_popStep]) and the question
  /// header are BOTH suppressed while this is true, so each state shows EXACTLY
  /// ONE 'חזרה' affordance: the sub-view's own back when a sub-view is open, the
  /// breadcrumb back otherwise. (The JOB LIST opens only at the empty-stack
  /// opening, where the breadcrumb back is already hidden, but ORing it in keeps
  /// the question header suppressed under the job list and future-proofs the
  /// invariant.) Defined ONCE here (rather than repeating the null/flag checks at
  /// each guard site) so the "one back per state" invariant cannot drift if a
  /// further sub-view is ever added — a new sub-view just ORs into this getter and
  /// the breadcrumb back stays correctly hidden.
  bool get _subViewOpen =>
      _kitRecipe != null || _connectionsAnchor != null || _jobsOpen;

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

  /// @visibleForTesting — true while the JOB LIST ('לפי עבודה') is open. Mirrors
  /// [kitViewOpen]; lets a behavioral test assert the list opened without
  /// depending on rendered copy.
  @visibleForTesting
  bool get jobsViewOpen => _jobsOpen;

  /// @visibleForTesting — drive the jobs-list entry directly (the SAME state
  /// change the 'לפי עבודה' key tap performs). The entry key only renders at the
  /// opening, so a test reaches the list through this rather than synthesising the
  /// key tap. Mirrors [showKitForTest].
  @visibleForTesting
  void openJobsForTest() => _openJobs();

  /// @visibleForTesting — true while the opening word list is expanded to the
  /// full lexicon (the 'עוד…' affordance was tapped). Lets a behavioral test
  /// assert the expand/collapse toggle without depending on rendered copy.
  @visibleForTesting
  bool get showAllWordsActive => _showAllWords;

  /// @visibleForTesting — the currently picked material, or null for all
  /// materials. Lets a behavioral test assert the material entry was taken (and
  /// cleared) without depending on rendered copy.
  @visibleForTesting
  String? get activeMaterial => _material;

  /// @visibleForTesting — drive the material entry directly (the SAME state
  /// change the 'material' key tap performs): set the material, clear the stack,
  /// build the scoped lexicon ONCE, and re-collapse the opening word list. The
  /// material chip-row only renders at the opening, so a test reaches the entry
  /// through this rather than synthesising the key tap. Mirrors [showKitForTest].
  @visibleForTesting
  void pickMaterialForTest(String m) {
    setState(() {
      _material = m;
      stack.clear();
      _materialPool = kDivePool.where((p) => materialOf(p) == m).toList();
      _materialLexicon = buildWordLexicon(_materialPool!);
      _showAllWords = false;
    });
  }

  /// @visibleForTesting — clear the whole dive (mirrors the empty-state's
  /// 'התחל מחדש' restart). Used to assert the opening-word expansion does not
  /// leak across dives.
  @visibleForTesting
  void restartForTest() => _restart();

  /// @visibleForTesting — drive a typed-query submit directly. The typing surface
  /// is mutually exclusive with the sub-views (a sub-view REPLACES the cascade,
  /// so 'הקלדה' is not on screen while a sub-view is open) — so a test cannot
  /// reach it through the UI from inside a sub-view; this exercises the
  /// [_submitQuery] reset path (incl. [_resetSubViews]) from any state. Mirrors
  /// [restartForTest].
  @visibleForTesting
  void submitQueryForTest(String query) => _submitQuery(query);

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

  /// 7th engine: the anchor the 'מה מתחבר לזה?' entry key targets for [q], or
  /// null when no reached product is a valid connection anchor (so the
  /// affordance is NOT offered). Only a [ShowProducts] question carries the
  /// entry key (the keyboard that renders it) — it is the FIRST shown product
  /// that is an anchor (a stable, predictable pick). A [Resolve] opens the
  /// product sheet and renders NO keyboard, so the entry key never shows there;
  /// every other question returns null too.
  ///
  /// PERF: takes the already-computed [q] so [build] (via [_keysFor]) does not
  /// re-derive [currentQuestion] — which re-derives [_pool] and re-runs
  /// `offerQuestion` — a second time per frame. The [_connectionEntryAnchor]
  /// getter below preserves the no-arg call for the tap-handler path, where a
  /// single re-eval is fine (it is one user tap, not the per-frame build path).
  LipskeyCatalogProduct? _connectionEntryAnchorFor(NewbieQuestion q) {
    if (q is ShowProducts) {
      for (final p in q.products) {
        if (isConnectionAnchor(p)) return p;
      }
    }
    return null;
  }

  /// The connection entry anchor for the CURRENT question — the no-arg wrapper
  /// for the tap-handler call site ([_onWordTap]'s 'connect' branch), where no
  /// pre-computed question is in scope. The per-frame build path uses
  /// [_connectionEntryAnchorFor] with the question it already computed instead.
  LipskeyCatalogProduct? get _connectionEntryAnchor =>
      _connectionEntryAnchorFor(currentQuestion);

  /// 6th engine: the WORK-recipe the 'בנה לי את הערכה' entry key targets for [q],
  /// or null when no reached product is a work-product (so the affordance is NOT
  /// offered). Mirrors [_connectionEntryAnchorFor]: only a [ShowProducts]
  /// question carries the entry key (the keyboard that renders it), and it is
  /// the FIRST shown product that is a work-product — i.e. whose sku resolves via
  /// [smartProductForSku] to a [SmartProduct] recipe (a stable, predictable
  /// pick). A [Resolve] opens the product sheet and renders NO keyboard, so the
  /// entry key never shows there; every other question returns null too. The
  /// returned [SmartProduct] is the recipe whose kit [_showKit] will display.
  ///
  /// PERF: takes the already-computed [q] (same reason as
  /// [_connectionEntryAnchorFor]).
  SmartProduct? _kitEntryRecipeFor(NewbieQuestion q) {
    if (q is ShowProducts) {
      for (final p in q.products) {
        final recipe = smartProductForSku(p.sku);
        if (recipe != null) return recipe;
      }
    }
    return null;
  }

  /// The kit entry recipe for the CURRENT question — the no-arg wrapper for the
  /// tap-handler call site ([_onWordTap]'s 'buildkit' branch). The per-frame
  /// build path uses [_kitEntryRecipeFor] with its already-computed question.
  SmartProduct? get _kitEntryRecipe => _kitEntryRecipeFor(currentQuestion);

  /// Handle a tapped word key, dispatched by its [WordKey.payload]:
  ///  • `'word'`    — seed the pool with the products the word names;
  ///  • `'chip'`    — narrow by the tapped axis chip;
  ///  • `'connect'` — open the "מה מתחבר לזה" connections view;
  ///  • `'jobs'`    — open the JOB LIST ('לפי עבודה' opening entry);
  ///  • while the JOB LIST is open, any OTHER key is a JOB key whose payload is
  ///    the recipe's unique `.key` — open that recipe's kit via [_showKit];
  ///  • anything else is a PRODUCT key whose payload is the product's unique
  ///    SKU — open the reach-product sheet for the product resolved by that sku
  ///    (the [ShowProducts] / connections terminus). Resolution keys on the sku,
  ///    NOT the display label, so two cards sharing a plain word both resolve.
  void _onWordTap(WordKey key) {
    final label = key.label;
    // Jobs-first entry: the 'לפי עבודה' opening key opens the JOB LIST. Sentinel
    // payload ('jobs'), matched here BEFORE the product branch — like 'material'.
    // (The list's own back is a header IconButton calling [_closeJobs], the same
    // back idiom the kit / connections views use — not a word key.)
    if (key.payload == 'jobs') {
      _openJobs();
      return;
    }
    // Jobs-first entry: while the JOB LIST is open, every remaining key IS a job
    // key — its payload is the recipe's unique `.key` (resolved via [kJobByKey],
    // the SAME stable-id resolution the product keys use on sku, never the label).
    // Tapping it opens that recipe's kit through the EXISTING [_showKit]. Handled
    // here (before the sku-payload product branch) because a job `.key` is not a
    // sku and would otherwise fall through to a no-op. A no-op if the payload is
    // somehow not a known job key (defensive — payload/state drift).
    if (_jobsOpen) {
      final recipe = kJobByKey[key.payload];
      if (recipe != null) _showKit(recipe);
      return;
    }
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
    // Material axis: a 'material' key (the label IS the material name) enters the
    // material-FIRST dive. Matched here BEFORE the sku-payload product branch,
    // exactly like 'connect'/'buildkit'. It sets the material, clears the stack
    // back to the opening, and BUILDS THE SCOPED LEXICON ONCE (memoized in
    // _materialLexicon) so the costly `buildWordLexicon` never runs per-frame —
    // the noun keys then show only this material's parts. Re-collapse the opening
    // word list so the fresh material opening starts collapsed.
    if (key.payload == 'material') {
      setState(() {
        _material = label;
        stack.clear();
        _materialPool = kDivePool.where((p) => materialOf(p) == label).toList();
        _materialLexicon = buildWordLexicon(_materialPool!);
        _showAllWords = false;
      });
      return;
    }
    // Material axis clear: 'כל החומרים' drops the material filter back to ALL
    // materials and clears the dive (via _restart, which nulls both _material and
    // _materialLexicon). Sentinel payload, matched here before the product branch.
    if (key.payload == 'clearmaterial') {
      _restart();
      return;
    }
    // Opening-list expansion toggle: 'עוד…' reveals every lexicon word, 'פחות'
    // collapses back to the top words. Sentinel payloads (not skus), matched
    // here BEFORE the product branch — exactly like 'connect'/'buildkit'.
    if (key.payload == 'morewords') {
      setState(() => _showAllWords = true);
      return;
    }
    if (key.payload == 'fewerwords') {
      setState(() => _showAllWords = false);
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
      // Resolve against the ACTIVE lexicon (the material-scoped one when a
      // material is picked) so a tapped noun resolves to skus WITHIN the material
      // pool, never the full union.
      final skuSet = {
        for (final p in resolveWord(label, _activeLexicon)) p.sku,
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
      _showAllWords = false;
      _resetSubViews();
      _material = null;
      _materialLexicon = null;
      _materialPool = null;
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
      // Collapsed → the engine's top-kFirstWordCount words (q.words). Expanded
      // ('עוד…' tapped) → EVERY lexicon word, SAME frequency order, via the
      // engine's wordsByFrequency (q.words is just its prefix, so the common
      // words stay on top). The lexicon is the ACTIVE one — the material-scoped
      // lexicon when a material is picked, so 'עוד…' reveals the rest of THAT
      // material's words (never a global word that names no material product),
      // matching the collapsed q.words which `currentQuestion` already scoped.
      // The toggle key trails the list: 'עוד…' while collapsed AND a tail
      // exists, 'פחות' while expanded. Sentinel payloads ('morewords'/
      // 'fewerwords'), like the 'connect'/'buildkit' keys.
      final shown =
          _showAllWords ? wordsByFrequency(_activeLexicon) : q.words;
      return [
        for (final e in shown) WordKey(e.word, payload: 'word'),
        if (!_showAllWords &&
            _activeLexicon.entries.length > q.words.length)
          const WordKey(kMoreWordsKey, payload: 'morewords'), // OWNER-REVIEW
        if (_showAllWords)
          const WordKey(kFewerWordsKey, payload: 'fewerwords'), // OWNER-REVIEW
      ];
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
        // imageAsset — a navigation key stays clean (text only). PERF: passes the
        // SAME `q` (the ShowProducts we are already inside) so the anchor scan
        // reuses this frame's question instead of re-deriving currentQuestion.
        if (_connectionEntryAnchorFor(q) != null)
          const WordKey(kConnectionsKey, payload: 'connect'), // OWNER-REVIEW copy
        // 6th engine: when a reached product is a WORK-product (its sku resolves
        // to a SmartProduct recipe), offer a plain-text (icon-free) 'בנה לי את
        // הערכה' key that builds + shows the recommended kit. Appended LAST (after
        // the connect key) so it never displaces a product key. Its payload is the
        // literal 'buildkit' sentinel (not a sku). NO imageAsset — a navigation
        // key stays clean (text only), like the connect key. PERF: passes the SAME
        // `q` (reuses this frame's question, same as the connect key above).
        if (_kitEntryRecipeFor(q) != null)
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
              // Back: a bare IconButton — its tooltip supplies BOTH the accessible
              // name ('חזרה') and the button role, so no wrapping Semantics(label)
              // is needed (a wrapper would double-announce 'חזרה'). Tests anchor on
              // find.byTooltip('חזרה').
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                tooltip: 'חזרה',
                onPressed: _closeConnections,
              ),
              Expanded(
                child: Semantics(
                  header: true,
                  child: const Text(
                    kConnectionsHeader, // OWNER-REVIEW
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
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
              // Back: bare IconButton; tooltip = accessible name + button role (no
              // wrapping Semantics → no double-announce). See connections view.
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                tooltip: 'חזרה',
                onPressed: _closeKit,
              ),
              Expanded(
                child: Semantics(
                  header: true,
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

  /// Material axis: the opening MATERIAL chip-row keys — one icon-free key per
  /// material present in the FULL union pool (in [kMaterials] display order),
  /// each carrying the literal 'material' payload and the material name as its
  /// label (so [_onWordTap] enters that material). SAME icon-free WordKey idiom
  /// as the word/chip keys. The materials are read off [kDivePool] (NOT the
  /// scoped pool) because this row only shows at the opening, when no material is
  /// picked yet.
  List<WordKey> _materialChips() => [
        for (final m in kMaterialsInDivePool) WordKey(m, payload: 'material'),
      ];

  /// Material axis: the opening chip-row — a 'לפי חומר' caption above one
  /// icon-free key per available material (the [WordKeyboard] idiom, no
  /// skip/type utility row — those keys would be dead no-ops here). Shown ONLY at
  /// the opening (see the gate in [build]); tapping a key enters that material's
  /// dive.
  /// Renders [keys] as icon-free BsKey rows (3 per row, each Expanded) — the
  /// same look as a WordKeyboard word-row, but WITHOUT being a [WordKeyboard],
  /// so the material chip-row + clear do NOT add a second WordKeyboard to the
  /// tree (the opening must keep exactly one — the word cascade). Taps route
  /// through [_onWordTap] by the key's payload, like every other key.
  ///
  /// [perRow] is keys-per-row (default 3, like the material chip-row); the job
  /// list passes 1 so long work-names render full-width and never clip.
  List<Widget> _iconFreeKeyRows(List<WordKey> keys, {int perRow = 3}) {
    final rows = <Widget>[];
    for (var i = 0; i < keys.length; i += perRow) {
      final end = (i + perRow < keys.length) ? i + perRow : keys.length;
      final rowKeys = keys.sublist(i, end);
      // OWNER-REVIEW: these rows follow the app's ambient RTL (Hebrew reading
      // order — first key on the right), UNLIKE the cascade WordKeyboard which
      // deliberately pins LTR for stable key-ORDER. The two opening surfaces thus
      // differ in horizontal order by design; wrap this in Directionality(ltr) if
      // you prefer the material chip-row to match the cascade's order.
      rows.add(Row(
        children: [
          for (var j = 0; j < rowKeys.length; j++) ...[
            if (j > 0) const SizedBox(width: BsTokens.space1),
            Expanded(
              child: BsKey(
                model: KbKey(rowKeys[j].label),
                onTap: () => _onWordTap(rowKeys[j]),
              ),
            ),
          ],
        ],
      ));
      if (i + perRow < keys.length) {
        rows.add(const SizedBox(height: BsTokens.space1));
      }
    }
    return rows;
  }

  // OWNER-REVIEW: material chip-row layout + copy.
  Widget _buildMaterialRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              BsTokens.space2, BsTokens.space1, BsTokens.space2, 0),
          child: Semantics(
            header: true,
            child: const Text(
              kByMaterialLabel, // OWNER-REVIEW
              textAlign: TextAlign.center,
              style: TextStyle(
                color: BsTokens.inkLight,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(BsTokens.space1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _iconFreeKeyRows(_materialChips()),
          ),
        ),
      ],
    );
  }

  /// Material axis: the picked-material breadcrumb + clear affordance, shown in
  /// the opening (empty-stack) state once a material IS picked. Mirrors the
  /// 'כל החומרים' clear: tapping it drops the material filter and clears the dive
  /// via [_restart] (which nulls [_material] + [_materialLexicon]). Rendered via
  /// the same WordKeyboard key idiom (icon-free), with no utility row.
  // OWNER-REVIEW: picked-material breadcrumb + clear copy/layout.
  Widget _buildMaterialClear() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              BsTokens.space2, BsTokens.space1, BsTokens.space2, 0),
          child: Text(
            // The picked material as a breadcrumb caption (e.g. 'נחושת').
            _material ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(BsTokens.space1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _iconFreeKeyRows(
              const [WordKey(kAllMaterials, payload: 'clearmaterial')],
            ),
          ),
        ),
      ],
    );
  }

  /// Jobs-first entry: the opening 'לפי עבודה' affordance — a single icon-free
  /// key (the SAME [_iconFreeKeyRows] / [BsKey] idiom as the material chip-row, so
  /// it adds NO second [WordKeyboard] to the opening). Its payload is the literal
  /// 'jobs' sentinel; tapping it opens the JOB LIST ([_openJobs] via [_onWordTap]).
  /// Shown ONLY at the opening (see the gate in [build]), beside the material row.
  // OWNER-REVIEW: jobs-entry affordance layout + copy.
  Widget _buildJobsEntry() {
    return Padding(
      padding: const EdgeInsets.all(BsTokens.space1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _iconFreeKeyRows(
          const [WordKey(kByJobLabel, payload: 'jobs')], // OWNER-REVIEW
        ),
      ),
    );
  }

  /// #ai-finder — opening affordance: a free-text entry that pushes the AI
  /// product finder ([AiFinderScreen]) — Claude narrows the catalog by category.
  /// Pure navigation; the pushed screen self-gates on the Claude gateway (an
  /// honest "requires connection" state when AI is off, so demo is unchanged).
  Widget _buildAiFinderEntry() => Padding(
        padding: const EdgeInsets.all(BsTokens.space1),
        child: OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(AiFinderScreen.route()),
          icon: const Text('🗣️'),
          label: const Text('תאר במילים שלך → חיפוש חכם'),
        ),
      );

  /// Jobs-first entry: the JOB LIST keys — one icon-free key per work-recipe in
  /// [kJobsByName] (A→Z by `.name`), each labelled by the recipe `.name` and
  /// carrying the recipe's unique `.key` as its payload (so [_onWordTap] resolves
  /// it via [kJobByKey] → [_showKit], keying on the stable id, never the label).
  /// SAME icon-free [WordKey] idiom as the material / word / chip keys.
  List<WordKey> _jobChips() => [
        for (final r in kJobsByName) WordKey(r.name, payload: r.key),
      ];

  /// Jobs-first entry: the JOB LIST view — the discoverable way into the recipe
  /// kit. Header ('איזו עבודה?') + a back IconButton (to the opening cascade, via
  /// [_closeJobs]) + every work-recipe as an icon-free key (via [_iconFreeKeyRows]
  /// — NOT a [WordKeyboard], so the opening's "exactly one WordKeyboard" invariant
  /// holds: the cascade keyboard is replaced by this list while it is open).
  /// Tapping a job opens its kit via the EXISTING [_showKit]. Mirrors
  /// [_buildConnectionsView]'s header/back idiom.
  ///
  /// MUST live inside a [SingleChildScrollView] (the build() caller already is):
  /// the list is ~80 keys, far taller than a phone viewport, so a non-scrolling
  /// Column would throw a RenderFlex overflow — the SAME crash the canonical audit
  /// caught for the main dive. The outer Expanded + SingleChildScrollView in
  /// build() supplies that scroll.
  // OWNER-REVIEW: jobs-list layout + copy (a flat A→Z list is v1; grouping by
  // category is a future refinement).
  Widget _buildJobsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              BsTokens.space2, 0, BsTokens.space2, 0),
          child: Row(
            children: [
              // Back: bare IconButton; tooltip = accessible name + button role (no
              // wrapping Semantics → no double-announce). See connections view.
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                tooltip: 'חזרה',
                onPressed: _closeJobs,
              ),
              Expanded(
                child: Semantics(
                  header: true,
                  child: const Text(
                    kJobsHeader, // OWNER-REVIEW
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              // Symmetry spacer so the header text stays centred opposite the
              // back button (mirrors the connections / kit view headers).
              const SizedBox(width: 48),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(BsTokens.space1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _iconFreeKeyRows(_jobChips(), perRow: 1),
          ),
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

    // PERF: derive the live pool ONCE per build and reuse it for BOTH the
    // empty-pool check below AND the engine question — `_pool` walks the stack
    // predicates (and may relevance-sort a typed query), so the canonical audit
    // flagged build re-deriving it 3-4× (once for poolIsEmpty, again via
    // currentQuestion, again via each entry-anchor getter). Computing it here
    // and feeding `offerQuestion` directly collapses that to a single derive;
    // `_keysFor(q)` already takes the question, and the entry-anchor helpers now
    // take it too, so no getter re-derives the pool this frame. Behaviour is
    // identical — same pool, same question — purely fewer recomputations.
    final pool = _pool;

    // Detect the empty-pool dead-end FIRST: when the derived pool is empty
    // (only possible once the stack is non-empty — the base pool is never
    // empty) and we are NOT mid-typing, the engine would otherwise hand back a
    // zero-chip AskAxis. Render a neutral empty-state with a way back instead.
    final poolIsEmpty = pool.isEmpty && stack.isNotEmpty;
    final showEmptyState = poolIsEmpty && _typeController == null;

    // The engine's verdict for THIS frame's pool — the same value the
    // `currentQuestion` getter computes, but over the already-derived `pool`
    // (the getter stays for the tap handlers / @visibleForTesting hooks).
    final q = offerQuestion(pool, stack, _activeLexicon, widget.subtype);
    final keys = _keysFor(q);
    final header = _headerFor(q);
    // Material axis: when scoped to a material, prefix it onto the trail so the
    // breadcrumb keeps the material context mid-dive (e.g. 'נחושת · ניפל · 1/2"'),
    // not just the answered steps. // OWNER-REVIEW
    final crumbLine = _material != null
        ? <String>[_material!, ...crumbs].join(' · ')
        : crumbs.join(' · ');

    // Material axis + jobs-first entry: the opening (empty stack, no typing, no
    // kit/connections view, NOT in the job list, pool non-empty) is where BOTH
    // the material entry and the 'לפי עבודה' jobs entry live. Material: with NO
    // material picked → the chip-row; with one picked → its breadcrumb + the
    // 'כל החומרים' clear. Jobs: the 'לפי עבודה' key (opens the JOB LIST). All
    // render only here, so a mid-dive (non-empty stack) — or the open job list
    // itself — never shows a material/jobs control. `!_jobsOpen` keeps the
    // opening controls hidden once the JOB LIST replaces the keyboard region.
    final atOpening = stack.isEmpty &&
        _typeController == null &&
        _connectionsAnchor == null &&
        _kitRecipe == null &&
        !_jobsOpen &&
        !showEmptyState;
    final showMaterialRow = atOpening && _material == null;
    final showMaterialClear = atOpening && _material != null;
    // Jobs-first entry: the 'לפי עבודה' affordance shows at the opening (beside
    // the material controls), regardless of whether a material is picked.
    final showJobsEntry = atOpening;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: BsTokens.surfaceMid,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Breadcrumb + back ────────────────────────────────────────
              // Hidden while a sub-view (connections OR kit) is open: each of
              // those views owns its single back control, so showing the
              // breadcrumb back too would put TWO 'חזרה' arrows on screen. The
              // single [_subViewOpen] guard keeps that invariant in one place.
              if (stack.isNotEmpty && !_subViewOpen)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      BsTokens.space2, BsTokens.space2, BsTokens.space2, 0),
                  child: Row(
                    children: [
                      // Back: bare IconButton; tooltip = name + role (no
                      // wrapping Semantics → no double-announce).
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        tooltip: 'חזרה',
                        onPressed: _popStep,
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
              // Hidden while a sub-view (connections OR kit) is open — each
              // carries its own header (kConnectionsHeader / the work-recipe
              // name). Same single [_subViewOpen] guard as the breadcrumb above.
              if (header.isNotEmpty && !showEmptyState && !_subViewOpen)
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

              // ── Material axis ("ציר-חומר") opening controls ──────────────
              // The material entry: at the opening, offer the material chip-row
              // (no material picked) OR the picked-material breadcrumb + clear
              // ('כל החומרים'). Placed ABOVE the word keyboard so the user picks
              // a material FIRST, then the noun keys below show only that
              // material's parts. Both are inside the build's scroll region only
              // via this Column child (they are short, so they sit above the
              // Expanded keyboard region).
              if (showMaterialRow) _buildMaterialRow(),
              if (showMaterialClear) _buildMaterialClear(),

              // ── Jobs-first entry ("לפי עבודה") opening affordance ─────────
              // Beside the material controls at the opening: a single icon-free
              // key that opens the JOB LIST (the discoverable way into the recipe
              // kit). Like the material row it is short and sits above the
              // Expanded keyboard region; it renders ONLY at the opening (the
              // showJobsEntry gate), and the list it opens then REPLACES the
              // cascade keyboard in the Expanded region below.
              if (showJobsEntry) _buildJobsEntry(),

              // #ai-finder — opening affordance: a free-text "תאר → מצא" entry
              // (Claude narrows the catalog by category). Same opening gate as
              // the jobs/material affordances.
              if (showJobsEntry) _buildAiFinderEntry(),

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
                      : _jobsOpen
                          // ── Jobs-first entry: the JOB LIST (when open) ────
                          // Below the kit/connections views (a job tap OPENS the
                          // kit on top, and closing the kit returns here while the
                          // list stays open), above the cascade — while open it
                          // REPLACES the word keyboard, so the opening still has
                          // exactly one WordKeyboard (zero while the list shows).
                          ? _buildJobsView()
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
