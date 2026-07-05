// 🃏 floating_card_keyboard — the PERSISTENT floating card-keyboard panel AND
// the MORPH NAVIGATOR (STEP B).
//
// This is the same surface the old modal `_CardKeyboardSheet` rendered (a
// read-only query field driven by the custom keyboard, plus a LIVE prediction
// row recomputed from the field text on every change), but rendered as a
// FLOATING panel that overlays the bottom of the screen — NOT a modal bottom
// sheet. The owner model: the keyboard is the NAVIGATOR, a floating independent
// layer on top; the full screen UNDERNEATH stays full (it is a sibling
// Positioned in [HomeShell]'s body Stack, so it never wraps/resizes/dims the
// IndexedStack).
//
// STEP B — the morph engine. This widget owns a DRILL-STACK of tool node-lists
// ([keyboard_tool_tree.dart]). The strip's grid/gear toggles PUSH the home/kbd
// node-list; tapping a node either:
//   • LEAF  → runs the node's action (navigate the screen underneath / push a
//             route) and KEEPS the overlay floating (the panel does NOT close);
//   • BRANCH→ pushes its children onto the stack, MORPHING the tool view in
//             place (e.g. תפריט → its AI-hub/settings tiles) with no navigation.
// A BACK tile pops the stack; popping the last tool-view returns to the letters
// (stack empty). The only explicit dismiss is the close-chevron (unchanged).
//
// The keyboard itself ([bs_keyboard.dart]) stays PURE: it is handed the current
// node-list projected to pure [KbTile]s and bubbles a tapped tile back as an
// opaque int — all the navigation meaning lives in the tree here.
//
// Only the PURE [cardKeyboardPredictions] helper is imported from
// card_keyboard_sheet.dart — never a widget (the modal widget is deleted).
//
// TYPE-TO-NAVIGATE (universal destinations). When the field text is non-empty
// the prediction row MERGES navigable DESTINATIONS ([matchDestinations],
// keyboard_destinations.dart) AHEAD of the product words — destinations are
// exact nav targets, so they lead. The row is still a plain `List<String>` to
// the pure keyboard; this widget keeps a parallel map from each shown chip label
// to either a [KbDestination] (→ run its nav action, KEEP the overlay floating)
// or a product word (→ append to the field, as before).
//
// CONTEXT-FITTING (empty field). When the field is EMPTY the row reflects WHERE
// I AM, not just what I type — computed in [build] (the only place that can
// `ref.watch` the tab). Owner decision (option 1): a DRILL does NOT add chips —
// drilling already morphs the BODY tiles (that IS the "what I pressed" feedback),
// and mirroring those tools as chips would DUPLICATE them on-screen. So the empty
// row reflects the CURRENT TAB whether or not a tool is drilled:
//   • CURRENT TAB chips (ref.watch(mainTabProvider)): tab 1 the 4 departments ·
//     tab 2 שיחות + התראות · tab 3 הסל שלי + ההזמנות שלי + שירותים — each sourced
//     from [kbDestinations] BY LABEL so it carries its REAL run (typing it
//     navigates identically). Tab 0 (בית/catalog) keeps product opening-words.
// Dispatch ([_onPrediction]) reads two DISJOINT parallel maps rebuilt every build:
// [_destByChip] (tab/typed destination chips → [KbDestination]) then [_runByChip]
// (LIVE-MIRROR dynamic chips → tap closure); a chip in neither is a product WORD
// (appended). The empty field at tab 0 still shows product opening-words ONLY (no
// destinations), unchanged.

import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/features/card_keyboard/find_keyboard_panel.dart'
    show FindKeyboardPanel;
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show WordLexicon, buildWordLexicon;
import 'package:buildsmart/screens/card_keyboard_sheet.dart'
    show cardKeyboardPredictions;
import 'package:buildsmart/screens/catalog_screen.dart'
    show keyboardDiveQueryProvider;
import 'package:buildsmart/screens/chats_screen.dart'
    show ThreadLite, visibleThreadsProvider;
import 'package:buildsmart/screens/keyboard_catalog_deriver.dart'
    show deriveCatalogContext;
import 'package:buildsmart/screens/keyboard_dept_deriver.dart'
    show deriveDeptContext;
import 'package:buildsmart/screens/keyboard_destinations.dart'
    show KbDestination, kbDestinations, matchDestinations;
import 'package:buildsmart/screens/keyboard_store_deriver.dart'
    show deriveStoreContext;
import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show
        KbToolNode,
        kbHomeNodes,
        kbKbdNodes,
        kbScreenMenuNodes,
        kbTabToolNodes,
        kbTilesFor;
import 'package:buildsmart/screens/keyboard_updates_deriver.dart'
    show KbRunByChip, KbUpdatesContext, deriveUpdatesContext;
import 'package:buildsmart/screens/lipskey_product_sheet.dart'
    show showLipskeyProductSheet;
import 'package:buildsmart/services/voice.dart' show VoiceService;
import 'package:buildsmart/state/catalog_location.dart'
    show CatalogLocation, catalogLocationProvider;
import 'package:buildsmart/state/dept_location.dart'
    show DeptLocation, deptLocationProvider;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/feature_flags.dart'
    show featureFlagsProvider, kKbLiveMirrorFlag;
import 'package:buildsmart/state/finder_front.dart'
    show catalogLeadsWithFinder, kFinderFront;
import 'package:buildsmart/state/keyboard_overlay.dart'
    show kKbGlobal, keyboardOverlayOpenProvider, keyboardSearchModeProvider;
import 'package:buildsmart/state/keyboard_screen_tools.dart'
    show currentScreenTools, keyboardScreenToolsProvider;
import 'package:buildsmart/state/orders_engine.dart'
    show Order, ordersEngineProvider;
import 'package:buildsmart/state/smart_cart.dart'
    show SmartCartLine, smartCartProvider;
import 'package:buildsmart/state/store_location.dart'
    show StoreLocation, storeLocationProvider;
import 'package:buildsmart/state/updates_location.dart'
    show UpdatesLocation, updatesLocationProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/caret.dart' show insertAtCaret;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart'
    show KbToolLayer;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_host.dart'
    show BsKeyboardHost, kKbButtonsV2, kKbLiveMirror;
import 'package:buildsmart/widgets/toast.dart' show bsNavigatorKey;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The live set of product categories that actually have rows — lets the pure
/// catalog deriver tell a product-leaf from a smart/dead leaf WITHOUT importing
/// the product list at the tap site (mirrors `_TreeDrill`'s `p.categoryHe`
/// test). Hoisted to a module-level lazy `final` (top-level vars are lazy — no
/// `late` needed) so the ~928-element `kCatalogProducts` scan runs ONCE, not on
/// every keystroke rebuild of the tab==0 branch (the scan's result is identical
/// per build — the catalog is const — so recomputing it each build was pure
/// waste while typing).
final Set<String> _kCatalogProductCats = <String>{
  for (final p in kCatalogProducts) p.categoryHe,
};

/// The persistent floating card-keyboard panel: a read-only field driven by the
/// custom keyboard, with a LIVE prediction row recomputed from the field text on
/// every change, AND the morph drill-stack navigator. Self-contained and
/// crash-safe: the controller/focus/stack are owned here; this widget's own
/// `ref`/`context` drive tool navigation (the home stays mounted under the
/// overlay, so they stay valid).
class FloatingCardKeyboard extends ConsumerStatefulWidget {
  const FloatingCardKeyboard({super.key});

  @override
  ConsumerState<FloatingCardKeyboard> createState() =>
      _FloatingCardKeyboardState();
}

/// Total prediction-row chips shown at once (destinations + product words). The
/// product-only helper caps at 4; with destinations merged in ahead we allow one
/// more so a couple of nav targets never fully crowd out the product words.
const int _kRowCap = 5;

/// MEMOIZED label→destination index, built ONCE from [kbDestinations] on first
/// use and reused for every build thereafter. [kbDestinations] is a factory that
/// re-allocates the whole ~50-entry registry on each call; rebuilding this map
/// inside [build] (which fires on every keystroke / tab change / drill setState)
/// re-scanned all ~50 destinations every frame. The registry is deterministic
/// and its labels are unique (see keyboard_destinations.dart header), so a single
/// lazy `final` is safe to share across all builds — the lookup drops from O(n)
/// per build to O(1). Lazy (not a top-level `const`) because the `run` closures
/// and the list literal are not const-constructible; `late final` resolves the
/// factory exactly once, on the first build that reads it.
late final Map<String, KbDestination> _kbDestinationByLabel =
    <String, KbDestination>{
  for (final d in kbDestinations()) d.label: d,
};

class _FloatingCardKeyboardState extends ConsumerState<FloatingCardKeyboard>
    with WidgetsBindingObserver {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  /// Lexicon built ONCE from the dive pool (pure + deterministic); reused for
  /// every keystroke's recompute so we never rebuild it per change.
  late final WordLexicon _lexicon;

  /// Parallel map from a shown chip label → the [KbDestination] it stands for.
  /// Only DESTINATION chips appear here: the typed-row matches AND the empty-field
  /// TAB chips (both navigate via [KbDestination.run]). A chip absent from BOTH
  /// this map and [_runByChip] is a product WORD (appended to the field on tap, as
  /// before). REBUILT on every [build] (the chips themselves are computed there
  /// now), so the dispatch map can never drift from the rendered row, and a stale
  /// tab's mapping is never carried into the next tap.
  Map<String, KbDestination> _destByChip = const <String, KbDestination>{};

  /// THE SECOND dispatch map (עדכונים LIVE-MIRROR, [kKbLiveMirror]) — from a
  /// truly-dynamic chip label (a conversation name · a notification TYPE label) →
  /// the closure to run on tap with THIS widget's own `ref`/`context`. These chips
  /// belong to NEITHER static destination ([_destByChip]) nor the product-word
  /// fallback: they have no static nav target, so without this map [_onPrediction]
  /// would WRONGLY type them into the search field. The deriver
  /// ([deriveUpdatesContext]) populates it (each closure sets a provider —
  /// `notifSectionProvider` / `updatesChatOpenProvider` — so the SCREEN reacts; the
  /// keyboard never pushes a route, keeping the overlay floating). Checked AFTER
  /// [_destByChip] and BEFORE the product-word fallback, so the two are disjoint by
  /// the [_PredRow] ctor assert. EMPTY on every path except the flag-ON mirror-tab
  /// branch (default const-empty → byte-identical when the flag is off), rebuilt
  /// every [build] alongside [_destByChip] so it can never drift from the rendered
  /// row.
  Map<String, KbRunByChip> _runByChip = const <String, KbRunByChip>{};

  /// The MORPH drill-stack: each entry is the tool node-list at that depth. Empty
  /// (the default) → the keyboard shows its LETTERS (no tool view). Pushing the
  /// home/kbd node-list (grid/gear) makes `_stack == [thatList]`; drilling a
  /// BRANCH pushes its children; BACK pops the last entry.
  final List<List<KbToolNode>> _stack = <List<KbToolNode>>[];

  /// Which strip toggle to highlight: the layer of the stack BASE. Set when
  /// grid/gear pushes the first node-list; back to `none` when the stack clears.
  /// A LIVE-MIRROR context base ([_syncContextToolBase]) is "ambient": it leaves
  /// [_baseLayer] at `none` (no grid/gear highlight), so the strip toggles only
  /// ever light for a MANUAL drill — the context base and a manual drill are
  /// mutually exclusive by the `_baseLayer == none` guard in the sync.
  KbToolLayer _baseLayer = KbToolLayer.none;

  /// True while the user is TYPING: tapping the read-only search field enters
  /// this mode, which suppresses the ambient live-mirror context base so the
  /// alphabet (the letter keys) shows. Tapping the ▦ grid or ⚙️ gear toggle
  /// leaves it, returning to the tab's contextual navigation tools.
  bool _typing = false;

  /// FIND-MODE — when true, the keyboard body is replaced by [FindKeyboardPanel]
  /// (the in-keyboard product-finder). Entered by the 'מאתר' tool; the panel's
  /// onExit clears this. Default false ⇒ the keyboard stays byte-identical.
  bool _findMode = false;

  /// FINDER-FRONT (kFinderFront) dismissal: set when the user leaves the auto-led
  /// finder via the mode-switch bar (→ letters or → tools), so the finder stops
  /// leading THIS catalog surface until they navigate (a tab change clears it,
  /// re-arming the lead). Only ever set under kFinderFront, so it folds to a
  /// const-false read when the flag is off (byte-identical).
  bool _finderOff = false;

  /// The node-list currently shown (null while the stack is empty → letters).
  List<KbToolNode>? get _currentNodes => _stack.isEmpty ? null : _stack.last;

  /// The LABELS of the LIVE-MIRROR tool base currently installed by
  /// [_syncContextToolBase] (null when none is installed). Used to (a) detect when
  /// the deriver's toolBase actually CHANGED — so the sync re-installs only on a
  /// real change, never every frame (the no-churn guard, plan risk "tool-base
  /// in-build mutation") — and (b) know whether the live base is mine to tear down
  /// when the deriver stops supplying one (flag off / left tab). Compared by label
  /// (tool closures are never structurally equal), matching [KbUpdatesContext]'s
  /// own equality. Always null when [kKbLiveMirror] is off (the sync's `base` arg
  /// is always null), so the manual drill behaviour is byte-identical.
  List<String>? _lastDerivedBase;

  @override
  void initState() {
    super.initState();
    // ANDROID hardware / gesture BACK (audit fix): register as a binding observer
    // so [didPopRoute] fires on a system back request. The keyboard lives in an
    // Overlay ABOVE the app Navigator (KB_GLOBAL) / a sibling Positioned in the
    // body Stack — NOT a route — so PopScope never sees it, and the app is a
    // classic MaterialApp (no Router), so BackButtonListener would throw. An
    // observer is the Overlay-safe, Router-free hook; it is registered ONLY while
    // this widget (⇒ the open keyboard) is mounted, so BACK behaves normally once
    // the keyboard is closed.
    WidgetsBinding.instance.addObserver(this);
    _controller = TextEditingController();
    _focus = FocusNode();
    _lexicon = buildWordLexicon(kDivePool);
    // No row seed here: [build] is the single source of truth for the row (it is
    // the only place that can `ref.watch(mainTabProvider)` + read the drill
    // stack), and it runs before the first frame is shown. The dispatch maps keep
    // their const-empty defaults until that first build assigns them; a tap is
    // impossible before the first frame, so the empty maps are never read stale.
    // The listener stays a pure repaint trigger so the text-conditional in build
    // re-evaluates on every keystroke (see [_recompute]).
    _controller.addListener(_recompute);
    // OWNER (A slice 2 — unify): when the overlay was opened by tapping the SEARCH
    // bar, LEAD with the letters (typing mode), ready to type, instead of the tool
    // mirror — you tapped "search". One-shot: consume the flag after reading it.
    if (ref.read(keyboardSearchModeProvider)) {
      _typing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(keyboardSearchModeProvider.notifier).state = false;
        }
      });
    }
  }

  /// REPAINT trigger on every field-text change: [build] is the single source of
  /// truth for the prediction row (it computes the chips + the two dispatch maps
  /// from the text, the watched tab, and the drill stack), so the listener only
  /// needs to mark this element dirty — the row is rebuilt in the next [build].
  /// Guarded by `mounted` so a late listener tick after dispose can never
  /// `setState` on a defunct element (the guard also keeps the closure non-empty,
  /// so very_good_analysis's empty-block lint stays quiet).
  void _recompute() {
    if (!mounted) return;
    // Live-mirror DIVE (owner): on the catalog tab the typed query filters the
    // SCREEN underneath in real time — the screen dives WITH the keyboard, via
    // the catalog's [keyboardDiveQueryProvider] → [diveResultsProvider].
    // Gated to tab 0 (only the catalog reads this provider); off-tab typing
    // leaves the screen untouched.
    if (ref.read(mainTabProvider) == 0) {
      // Live DIVE: the typed query drives the catalog's NATIVE narrowed product
      // list (the app dives IN PLACE) — NOT a flat search panel. The engine that
      // proved most reliable ([catalogProductMatchesQuery]) runs in
      // [diveResultsProvider]; the catalog body swaps to it when this is set.
      //
      // kKbGlobal gate: when the keyboard floats over a PUSHED route (above
      // HomeShell) the catalog underneath is NOT visible, so diving it would write
      // a query the user can't see take effect. Only write when no route is pushed
      // above HomeShell (`canPop() == false`). With [kKbGlobal] const-false the `||`
      // short-circuits TRUE at compile time and the `bsNavigatorKey` read tree-
      // shakes, so the write is exactly the prior unconditional line (byte-identical).
      if (!kKbGlobal || bsNavigatorKey.currentState?.canPop() == false) {
        ref.read(keyboardDiveQueryProvider.notifier).state = _controller.text;
      }
    }
    setState(() {});
  }

  /// Builds the merged prediction row for [text]: navigable DESTINATIONS first
  /// (exact nav targets via [matchDestinations]), then the product WORDS
  /// ([cardKeyboardPredictions]), de-duplicated and capped at [_kRowCap]. Also
  /// returns the parallel chip→destination map (only destination chips are
  /// keyed; everything else is a product word).
  ///
  /// This is the TYPED-query builder, now invoked from [_rowFor] for the NON-EMPTY
  /// branch (its output is byte-identical to before — the body is unchanged). It
  /// is also reused for the EMPTY field at tab 0 (catalog): [_rowFor] routes empty
  /// text here only for tab 0, where [matchDestinations] returns empty for the
  /// blank query, so the row is product opening-words ONLY (empty destByChip) —
  /// byte-identical to the legacy empty-field behaviour. Pure: no side effects,
  /// no provider/context reads.
  _PredRow _buildRow(String text) {
    // Product WORDS for the query. We RESERVE one row slot for a word when any
    // exists, so a flood of nav matches never fully hides the catalogue words —
    // destinations still LEAD, they just cannot take the very last slot.
    final words = cardKeyboardPredictions(text, kDivePool, _lexicon);
    final reserve = words.isEmpty ? 0 : 1;
    final destCap = _kRowCap - reserve;

    // DESTINATIONS lead, up to destCap (leaving the reserved word slot free).
    final dests = matchDestinations(text, max: destCap);
    final chips = <String>[];
    final destByChip = <String, KbDestination>{};
    for (final d in dests) {
      if (chips.length >= destCap) break;
      // De-dupe by visible label (two destinations sharing a label collapse to
      // the first — none do today, but the row stays unambiguous regardless).
      if (destByChip.containsKey(d.label) || chips.contains(d.label)) continue;
      chips.add(d.label);
      destByChip[d.label] = d;
    }

    // Then product WORDS fill the remaining slots (including the reserved one),
    // skipping any string already shown as a destination chip.
    for (final w in words) {
      if (chips.length >= _kRowCap) break;
      if (chips.contains(w)) continue;
      chips.add(w);
    }
    return _PredRow(chips, destByChip);
  }

  /// THE ROW SELECTOR — the single decision for what the prediction row shows,
  /// called from [build] (the only place that can read [tab]). PURE (no side
  /// effects, no setState): it returns a [_PredRow] of chips + the two dispatch
  /// maps; [build] persists those maps to fields.
  ///
  ///   1. [text] NON-EMPTY → the TYPED row, byte-identical to before:
  ///      [_buildRow] (destinations-first merge + reserved word slot).
  ///   2. [text] EMPTY → the CURRENT [tab]'s chips (option 1: a DRILL does NOT add
  ///      chips — the drilled tools already morph the BODY tiles, so mirroring them
  ///      as chips would duplicate them on-screen). tabs 1/2/3 source their
  ///      [KbDestination]s from [kbDestinations] BY LABEL (each carries its REAL
  ///      run); tab 0 keeps product opening-words via [_buildRow] (empty destByChip
  ///      — today's exact empty-field behaviour).
  ///
  /// LIVE-MIRROR ([kKbLiveMirror], guarded): when the flag is on AND we are on a
  /// MIRRORED tab — מחלקות (tab == 1) OR עדכונים (tab == 2) OR חנות (tab == 3) —
  /// AND [ctx] was derived in [build], this returns the PURE deriver's row instead
  /// of the hardcoded tab fallback (the 4 departments for tab 1, ['שיחות','התראות']
  /// for tab 2, the store sections for tab 3) — re-derived at every click. [ctx]
  /// is non-null ONLY on a flag-ON mirrored-tab path (see [build], which derives
  /// the WHOLE [KbUpdatesContext] once — both the row AND the tool base — from one
  /// location snapshot via the matching deriver (`deriveDeptContext` at tab 1,
  /// `deriveUpdatesContext` at tab 2, `deriveStoreContext` at tab 3), then passes
  /// it here and uses its toolBase for [_syncContextToolBase]). All three derivers
  /// emit the SAME [KbUpdatesContext] type, so this ONE adapter serves all tabs.
  /// With the flag OFF [ctx] is always null and this branch is skipped, so the
  /// hardcoded tab fallback below runs and every path stays byte-identical.
  _PredRow _rowFor({
    required String text,
    required int tab,
    KbUpdatesContext? ctx,
  }) {
    // (1) TYPED row — unchanged path. Typed text never enters the mirror branch
    // (the deriver mirrors the EMPTY-field surfaces), so it leads even under the
    // flag — the universal typed path stays untouched.
    if (text.isNotEmpty) return _buildRow(text);

    // (1.5) LIVE-MIRROR — folds out entirely when [kKbLiveMirror] is false (const
    // guard ⇒ tree-shaken) OR when [ctx] is null (every non-flag-ON-mirrored-tab
    // path). The tab guard accepts the FOUR mirrored tabs (0 = בית/catalog,
    // 1 = מחלקות, 2 = עדכונים, 3 = חנות); they are mutually exclusive and [ctx] is
    // built by the matching deriver in [build], so this one branch routes all four.
    // ADAPTER: the deriver returns a PUBLIC [KbUpdatesContext] whose row is a
    // [KbPredRow] (a leaf file cannot construct this private [_PredRow]); copy it
    // field-for-field into [_PredRow] — chips + destByChip + destinationChips +
    // the runByChip map. [build] then persists row.runByChip into [_runByChip].
    if (kKbLiveMirror &&
        ctx != null &&
        (tab == 0 || tab == 1 || tab == 2 || tab == 3)) {
      final r = ctx.row;
      return _PredRow(
        r.chips,
        r.destByChip,
        runByChip: r.runByChip,
        destinationChips: r.destinationChips,
      );
    }

    // (2) EMPTY — CONTEXT row by TAB ("where I am"). Owner decision (option 1): a
    // DRILL does NOT add chips here. Drilling already morphs the BODY tiles (that
    // IS the "what I pressed" feedback); mirroring those tools as chips would
    // DUPLICATE them on-screen (tool tile + prediction chip). So the empty row
    // reflects the current TAB whether or not a tool is drilled. Tab 0 keeps
    // product opening-words (today's behaviour: _buildRow('') → matchDestinations
    // ('') empty, so product words only with an empty destByChip). Tabs 1/2/3 show
    // their destination chips, sourced from the registry BY LABEL (REAL run each).
    if (tab == 0) return _buildRow('');

    // Label→destination lookup, MEMOIZED at module scope ([_kbDestinationByLabel])
    // so it is built ONCE from the registry instead of re-scanning all ~50
    // destinations on every build (kbDestinations' labels are unique, so the map
    // is total + unambiguous). The per-tab label lists below are copied
    // BYTE-FOR-BYTE from the registry labels (owner-verbatim Hebrew strings).
    final byLabel = _kbDestinationByLabel;
    const labelsByTab = <int, List<String>>{
      // tab 1 (מחלקות) — the 4 live departments, owner order.
      1: <String>[
        'אינסטלציה',
        'ברזים וסניטריים',
        'כלי עבודה ידני',
        'כלי עבודה חשמלי',
      ],
      // tab 2 (עדכונים) — שיחות first (owner order), then התראות.
      2: <String>['שיחות', 'התראות'],
      // tab 3 (חנות).
      3: <String>['הסל שלי', 'ההזמנות שלי', 'שירותים'],
    };

    final chips = <String>[];
    final destByChip = <String, KbDestination>{};
    for (final label in labelsByTab[tab] ?? const <String>[]) {
      // Defensive: cannot miss given the registry presence+uniqueness, but stays
      // deref-safe (never key a null destination).
      final d = byLabel[label];
      if (d == null) continue;
      chips.add(label);
      destByChip[label] = d;
    }
    // Every tab chip is a destination → all are navigable (get the nav glyph).
    return _PredRow(
      chips,
      destByChip,
      destinationChips: destByChip.keys.toSet(),
    );
  }

  /// LIVE-MIRROR tool-base sync (plan seam 5) — install the deriver's [base] as
  /// the drill-stack base via a PLAIN in-build field write (the SAME discipline as
  /// the dispatch-map writes; NEVER setState in build — that is illegal, and a
  /// post-frame callback would leave the tool view stale for THIS frame's taps,
  /// the precedent documented at the dispatch-map persist). Two guards keep it
  /// safe and churn-free:
  ///
  ///   • `_baseLayer == KbToolLayer.none` — a context base is AMBIENT, never
  ///     clobbers a MANUAL grid/gear drill. While the user has grid/gear (or a
  ///     deeper drill) open, the context base waits; the manual stack is left
  ///     exactly as-is (interaction-matrix invariant: open grid → change location
  ///     → BACK must not corrupt the stack).
  ///   • label-equality vs [_lastDerivedBase] — re-install ONLY when the derived
  ///     base actually changed (compared by LABEL, since tool closures are never
  ///     structurally equal), so an unchanged context does NOT re-push every frame
  ///     (the no-churn guard; plan risk "tool-base in-build mutation").
  ///
  /// [base] is null whenever the mirror is inactive ([kKbLiveMirror] off / not on
  /// a mirrored tab (1, 2, or 3) / runtime tier off), in which case this either (a)
  /// tears down a context
  /// base THIS widget previously installed — returning to the letters — or (b)
  /// does nothing if none was installed or a manual drill owns the stack. So with
  /// the flag off this is a pure no-op and the manual drill behaviour is
  /// byte-identical.
  ///
  /// ROUTE-STACK PREFERENCE (kKbGlobal): [routeBase] is the front-most PUSHED
  /// route's own tools ([currentScreenTools] of [keyboardScreenToolsProvider]),
  /// `null` when no [KbScreen]-adopting route is on top (or the flag is off). The
  /// route stack is MORE SPECIFIC than the tab, so when [routeBase] is non-null it
  /// WINS over the tab-derived [base] — and because [build] `ref.watch`es the
  /// provider, a push/pop while the grid is open re-runs this and re-mirrors the
  /// new top (push) or restores the parent/tab (pop). With [kKbGlobal] const-false
  /// the caller always passes `routeBase: null` and this collapses to the prior
  /// tab-only behaviour, byte-identical.
  void _syncContextToolBase(
    List<KbToolNode>? base, {
    List<KbToolNode>? routeBase,
  }) {
    // The route stack (a pushed KbScreen) is more specific than the tab, so prefer
    // it when present. Null ⇒ fall back to the tab-derived [base] (or no base).
    final effective = routeBase ?? base;

    // A manual grid/gear drill owns the stack → leave it untouched. We also do NOT
    // touch [_lastDerivedBase] here: when the manual drill closes (back to
    // `_baseLayer == none`) the next build re-runs this and installs/clears the
    // context base correctly from the then-current base.
    if (_baseLayer != KbToolLayer.none) return;

    // Typing mode (the user tapped the search field) suppresses the ambient
    // context base so the LETTERS show — tear down any installed context base
    // and stop re-installing it until the user taps back to the tools (▦ / ⚙️).
    if (_typing) {
      if (_lastDerivedBase != null) {
        _stack.clear();
        _lastDerivedBase = null;
      }
      return;
    }

    final newLabels = effective == null
        ? null
        : <String>[for (final n in effective) n.label];

    // No change since the last context sync → nothing to do (the churn guard).
    if (listEquals(newLabels, _lastDerivedBase)) return;

    if (effective == null || effective.isEmpty) {
      // No base to install (flag off / left tab / no pushed route / empty list).
      // If a CONTEXT base is currently installed (the stack base is mine, marked
      // by a non-null [_lastDerivedBase]), tear it down so the letters return.
      // Never clear a non-context stack (guarded above by `_baseLayer == none`,
      // and a non-null [_lastDerivedBase] proves the current base is the context's).
      if (_lastDerivedBase != null) _stack.clear();
      _lastDerivedBase = null;
      return;
    }

    // Install (or swap) the context base as the SINGLE stack entry. `_baseLayer`
    // stays `none` (ambient — the strip toggles do not light for a context base).
    _stack
      ..clear()
      ..add(effective);
    _lastDerivedBase = newLabels;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller
      ..removeListener(_recompute)
      ..dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Tapped a prediction chip — THREE cases, read from the two parallel maps that
  /// [build] rebuilt for the CURRENT row (so dispatch always matches what is on
  /// screen). The maps are DISJOINT by construction and each is checked with a
  /// null-guard, so a tap can never mis-route or deref a missing entry:
  ///   (i) a DESTINATION chip ([_destByChip] — a typed match OR an empty-field
  ///       TAB chip) → run its nav action on THIS widget's own ref/context and
  ///       KEEP the overlay floating: a tab/section swaps the screen underneath
  ///       while the keyboard keeps floating; a route pushes over everything (the
  ///       keyboard reappears when it pops). Checked FIRST.
  ///   (ii) a LIVE-MIRROR dynamic chip ([_runByChip] — a עדכונים conversation or
  ///       a notification TYPE chip, flag [kKbLiveMirror]) → run its closure on
  ///       THIS widget's own ref/context. The closure only SETS a provider
  ///       (`notifSectionProvider` / `updatesChatOpenProvider`) for the SCREEN to
  ///       react to — it never pushes a route from the keyboard, so the overlay
  ///       stays floating. EMPTY (so this step is a no-op) on every path but the
  ///       flag-ON mirrored-tab mirrors (tabs 1/2/3), keeping flag-OFF dispatch
  ///       byte-identical. Checked AFTER [_destByChip] and BEFORE the word
  ///       fallback; the two maps are disjoint (the [_PredRow] ctor asserts it),
  ///       so the order only sets precedence for an impossible collision.
  ///   (iii) otherwise a product WORD → append it (+ a trailing space) at the
  ///       caret to narrow further, exactly as before; the controller listener
  ///       then repaints. [insertAtCaret] leaves the caret collapsed after the
  ///       inserted text (and appends when no selection).
  void _onPrediction(String chip) {
    final dest = _destByChip[chip];
    if (dest != null) {
      dest.run(ref, _navContext);
      return;
    }
    final run = _runByChip[chip];
    if (run != null) {
      run(ref, _navContext);
      return;
    }
    // Separate the appended narrowing word from the preceding token with a
    // space, so a multi-word query STAYS multi-token ("ברז" + "מכסה" → "ברז
    // מכסה", never "ברזמכסה"). [catalogProductMatchesQuery] AND-matches each
    // token (`tokens.every`), so every tap NARROWS step-by-step instead of
    // dead-ending on a merged string that matches no product.
    final existing = _controller.text;
    final sep = existing.isEmpty || existing.endsWith(' ') ? '' : ' ';
    insertAtCaret(_controller, '$sep$chip ');
  }

  /// Close the floating overlay (no route to pop — flip the provider instead).
  /// The ONLY explicit dismiss (the close-chevron + the send key).
  void _close() {
    // Clear the live DIVE so the catalog returns to its home grid (a fresh dive
    // every time the keyboard re-opens).
    ref.read(keyboardDiveQueryProvider.notifier).state = '';
    ref.read(keyboardOverlayOpenProvider.notifier).state = false;
  }

  /// GRID toggle: open the HOME node-list as the stack base — or, if HOME is
  /// already the base, toggle the whole stack closed back to the letters (so a
  /// second tap on the lit toggle dismisses the tool view, matching the legacy
  /// strip behaviour). Never closes the overlay.
  ///
  /// A MANUAL drill takes over the stack from any LIVE-MIRROR context base, so it
  /// clears [_lastDerivedBase] (the stack is no longer the context's): on close
  /// (or on a deeper BACK) the next build's [_syncContextToolBase] re-installs the
  /// then-current context base afresh. Null-safe no-op when the mirror is off.
  /// Owner button-spec v2 (#6): the floating globe's cycle language state —
  /// false = Hebrew letters, true = English letters. The THIRD state (buttons-
  /// mode) is represented by the tool stack, not this bool. Consulted only when
  /// [kKbButtonsV2] is on (passed to the host as `englishOverride`).
  bool _kbEnglish = false;

  /// Owner button-spec v2 (#6): the globe key's 3-way cycle —
  /// עברית → אנגלית → buttons-mode → עברית. "Showing buttons" is derived from the
  /// live stack (single source of truth — no separate counter to desync):
  ///   • showing buttons (a base/stack is open) → back to Hebrew letters
  ///   • Hebrew letters → English letters
  ///   • English letters → buttons-mode (push the tools view)
  /// Wired ONLY under [kKbButtonsV2]; otherwise the host's plain He↔En toggle runs.
  void _onKbCycle() => setState(() {
        if (_stack.isNotEmpty || _baseLayer != KbToolLayer.none) {
          _stack.clear();
          _baseLayer = KbToolLayer.none;
          _lastDerivedBase = null;
          _kbEnglish = false;
          // FINDER-FRONT (owner spec #6): from the tools (buttons-mode) the globe
          // cycles to the FINDER (the "מקלדת המילים" — the 3rd face) rather than
          // to the letters: re-arm the lead (_finderOff=false, _typing=false) so
          // the finder shows. Elsewhere (v2 buttons, no finder) it returns to the
          // Hebrew letters. kFinderFront const-false folds finderCap false ⇒ just
          // `_typing = true` (byte-identical; the ref.reads tree-shake).
          final finderCap = kFinderFront &&
              ref.read(mainTabProvider) == 0 &&
              catalogLeadsWithFinder(ref.read(catalogLocationProvider));
          if (finderCap) {
            _findMode = false;
            _finderOff = false;
            _typing = false;
          } else {
            _typing = true;
          }
        } else if (!_kbEnglish) {
          _kbEnglish = true;
          _typing = true;
        } else {
          _kbEnglish = false;
          _typing = false;
          _lastDerivedBase = null;
          // LIVE-MIRROR of the CURRENT screen ([kKbGlobal]), exactly as in
          // [_onGrid]: the front-most route's own tools lead; null ⇒ fall back to
          // the tab tools BYTE-IDENTICALLY (the flag-OFF disjunct folds to null
          // and the provider read tree-shakes).
          final screenTools = kKbGlobal
              ? currentScreenTools(ref.read(keyboardScreenToolsProvider))
              : null;
          final nodes = _frontTools(
            screenTools,
            () => kbTabToolNodes(ref.read(mainTabProvider), ref),
          );
          _stack.clear();
          if (nodes != null) _stack.add(nodes);
          // AMBIENT (not [KbToolLayer.home]): leave `_baseLayer` at `none` so the
          // installed nodes are a CONTEXT base, exactly like [_syncContextToolBase]
          // installs one (see its doc: a context base is ambient, `_baseLayer`
          // stays `none`). This lets the sync's `_baseLayer == none` guard re-run
          // on a tab/route change and RE-MIRROR the new screen while buttons-mode
          // is still active — instead of `.home` pinning a stale base that blocks
          // the sync. (Globe-cycle still dismisses via the first `_onKbCycle`
          // branch.) `_lastDerivedBase` was cleared just above, so the next build
          // installs the current context base cleanly.
          _baseLayer = KbToolLayer.none;
        }
      });

  void _onGrid() => setState(() {
        _lastDerivedBase = null;
        if (_baseLayer == KbToolLayer.home) {
          // CLOSE (second tap on the lit ▦): tear the stack down AND enter typing
          // mode, so [_syncContextToolBase]'s typing-suppression guard keeps the
          // letters showing instead of the ambient live-mirror base re-installing
          // them away on the very next build (matching [_exitTools] and the
          // flag-OFF behaviour where closing the tools shows the letters).
          _stack.clear();
          _baseLayer = KbToolLayer.none;
          _typing = true;
        } else {
          // OPEN: leave typing mode so the tools show.
          _typing = false;
          // LIVE-MIRROR of the CURRENT screen ([kKbGlobal]): the front-most route
          // (top of [keyboardScreenToolsProvider]) supplies its OWN tools, so ▦
          // mirrors the screen I am actually looking at — including a PUSHED route
          // whose tools differ from the last HomeShell tab. `ref.read` (a one-shot
          // at tap time) is enough here (the OPEN base; the live re-mirror on a
          // push/pop is handled by the watched [routeBase] in [build]). Null ⇒ no
          // screen registered ⇒ fall back to the tab/home source below.
          //
          // FLAG-OFF IDENTITY: with [kKbGlobal] const-false this disjunct is dead
          // code (the `kKbGlobal ? … : null` folds to null and the provider read
          // tree-shakes), so the fallback expression is exactly the prior line.
          final screenTools = kKbGlobal
              ? currentScreenTools(ref.read(keyboardScreenToolsProvider))
              : null;
          // ▦ opens the CURRENT tab's tools when EITHER global-keyboard (kKbGlobal,
          // which implies the v2 tab behaviour) OR the v2 button-spec (kKbButtonsV2)
          // is on; the legacy fixed home set only when BOTH are off (byte-identical,
          // since `screenTools` is null off-flag and `kKbGlobal||kKbButtonsV2` is
          // then const-false).
          final nodes = _frontTools(
            screenTools,
            () => kKbGlobal || kKbButtonsV2
                ? kbTabToolNodes(ref.read(mainTabProvider), ref)
                : kbHomeNodes(),
          );
          _stack.clear();
          if (nodes != null) _stack.add(nodes);
          _baseLayer = nodes != null ? KbToolLayer.home : KbToolLayer.none;
        }
      });

  /// GEAR toggle: open the KBD node-list as the stack base — or toggle closed if
  /// KBD is already the base. Never closes the overlay. Clears [_lastDerivedBase]
  /// (a manual drill takes over the stack from any context base — see [_onGrid]).
  void _onGear() => setState(() {
        _lastDerivedBase = null;
        if (_baseLayer == KbToolLayer.kbd) {
          // CLOSE (second tap on the lit ⚙): tear the stack down AND enter typing
          // mode, so the typing-suppression guard in [_syncContextToolBase] keeps
          // the letters showing instead of the ambient live-mirror base re-
          // installing them away on the next build (mirrors [_onGrid] / [_exitTools]
          // and the flag-OFF behaviour where closing the tools shows the letters).
          _stack.clear();
          _baseLayer = KbToolLayer.none;
          _typing = true;
        } else {
          // OPEN: leave typing mode so the tools show.
          _typing = false;
          // LIVE-MIRROR of the CURRENT screen ([kKbGlobal]), exactly as in [_onGrid]:
          // the front-most pushed route's OWN overflow tools lead, so ⚙ mirrors the
          // screen I am actually looking at — including a PUSHED route. Null ⇒ no
          // screen registered ⇒ fall back to the tab/legacy source below.
          // FLAG-OFF IDENTITY: with [kKbGlobal] const-false this folds to null and
          // the provider read tree-shakes, so the fallback is exactly the prior line.
          final screenTools = kKbGlobal
              ? currentScreenTools(ref.read(keyboardScreenToolsProvider))
              : null;
          // Owner button-spec v2 (#4): ⚙ opens the CURRENT screen's ⋮ overflow
          // menu; the legacy fixed kbd tools when the flag is off (byte-identical).
          final nodes = _frontTools(
            screenTools,
            () => kKbButtonsV2
                ? kbScreenMenuNodes(ref.read(mainTabProvider), ref)
                : kbKbdNodes(),
          );
          _stack.clear();
          if (nodes != null) _stack.add(nodes);
          _baseLayer = nodes != null ? KbToolLayer.kbd : KbToolLayer.none;
        }
      });

  /// Tapped a tool tile (its opaque [id] is the node's index in the current
  /// node-list). LEAF → run its action and KEEP the overlay floating (do NOT
  /// flip the provider); BRANCH → push its children, morphing the tool view in
  /// place. Bounds-guarded so a stale id can never throw.
  void _onTile(int id) {
    final nodes = _currentNodes;
    if (nodes == null || id < 0 || id >= nodes.length) return;
    final node = nodes[id];
    // FIND-MODE entry: the 'מאתר' tool opens the in-keyboard product-finder
    // (FindKeyboardPanel replaces the keyboard body) instead of navigating to
    // the finder screen. Gated to the exact 'מאתר' label, so every other tool
    // dispatches byte-identically.
    if (node.label == 'מאתר') {
      setState(() => _findMode = true);
      return;
    }
    // SEARCH tool (owner): tapping 'חיפוש' CLEARS the field and drops straight to
    // the LETTERS (typing mode) for a fresh search. Like 'מאתר', this needs THIS
    // widget's own controller + typing state — the node's generic (ref, context)
    // action can't reach them — so it is intercepted here. Clearing the field fires
    // [_recompute] → the live DIVE query resets to '' (the search bar clears);
    // [_exitTools] tears the tool stack down and enters typing mode → the letters.
    if (node.label == 'חיפוש') {
      _controller.clear();
      _exitTools();
      return;
    }
    if (node.isBranch) {
      setState(() => _stack.add(node.children));
    } else if (node.isVoiceInput) {
      // STEP D — VOICE-INPUT leaf (קולי): the field controller lives HERE, not
      // in the (ref, context) action, so the floating keyboard runs the mic
      // itself: VoiceService.listen → insertAtCaret(_controller, transcript).
      // Keep-floating (the spoken text lands in the field; the prediction-row
      // listener then recomputes). The node's own action is the legacy fallback
      // only — we do NOT call it here.
      _startVoiceInput();
    } else {
      // KEEP-FLOATING: run the leaf action on THIS widget's own ref/context
      // (the home stays mounted under the overlay) and leave the overlay OPEN.
      // Leaf actions that change a tab/section swap the screen UNDERNEATH while
      // the keyboard keeps floating; leaf actions that push a full route push
      // over everything (the keyboard reappears when that route pops). Neither
      // closes the overlay.
      node.action?.call(ref, _navContext);
    }
  }

  /// The context the keyboard dispatches NAV actions through. When mounted as the
  /// app-global overlay ([kKbGlobal]) the keyboard's own context sits ABOVE the
  /// Navigator, so `Navigator.of` would miss it; it routes through the Navigator's
  /// OVERLAY context instead (a Navigator descendant → push + sheets resolve).
  /// Falls back to the widget's own [context] (the HomeShell mount, or before the
  /// navigator is ready) — so flag-OFF stays byte-identical.
  BuildContext get _navContext =>
      (kKbGlobal ? bsNavigatorKey.currentState?.overlay?.context : null) ??
      context;

  /// The tool node-list for the CURRENT front surface, per the owner rule: a
  /// PUSHED route shows its OWN `KbScreen` tools or NOTHING — never the tab
  /// tools. [screenTools] = the front pushed route's tools (null if it didn't
  /// adopt KbScreen); [tabNodes] builds the tab-root tools.
  ///   * screenTools != null            -> the pushed route's own tools.
  ///   * else at a TAB ROOT (!canPop()) -> tabNodes().
  ///   * else (pushed but UNWIRED)      -> null => the letters (NO tab fallback).
  /// With kKbGlobal const-false the `!kKbGlobal ||` disjunct folds to true, the
  /// canPop() read tree-shakes, and this returns tabNodes() exactly as before.
  List<KbToolNode>? _frontTools(
    List<KbToolNode>? screenTools,
    List<KbToolNode> Function() tabNodes,
  ) {
    if (screenTools != null) return screenTools;
    final atTabRoot =
        !kKbGlobal || bsNavigatorKey.currentState?.canPop() != true;
    return atTabRoot ? tabNodes() : null;
  }

  /// STEP D — start a voice-to-text session that drops the final transcript into
  /// the search field. Async + crash-safe: the [VoiceService.listen] callbacks
  /// can fire after this element is gone (a long mic session, a late error), so
  /// EVERY callback is `mounted`-guarded before it touches `_controller` or
  /// shows a SnackBar. The spoken text is inserted at the caret via
  /// [insertAtCaret] (exactly like a tapped prediction word), and the
  /// controller listener then recomputes the prediction row. A failure (no mic
  /// permission, no speech recognized, unsupported platform) surfaces a quiet
  /// "בקרוב" — never a silent dead button.
  Future<void> _startVoiceInput() async {
    try {
      final ok = await VoiceService.instance.listen(
        onFinal: (text) {
          if (!mounted) return;
          final t = text.trim();
          if (t.isEmpty) return;
          // Append a trailing space so the next word/prediction is separated,
          // matching the product-word append path (`_onPrediction`).
          insertAtCaret(_controller, '$t ');
        },
        onError: (_) {
          if (!mounted) return;
          _voiceUnavailable();
        },
      );
      // A `false` return means the platform has no speech support at all (onError
      // is NOT called in that case — the `false` is the signal); surface it.
      if (!ok && mounted) _voiceUnavailable();
    } on Object catch (_) {
      // The STT plugin can throw before any callback (e.g. a MissingPlugin /
      // PlatformException when the engine can't init — on an unsupported host or
      // a test harness with no plugin registered). Never let that crash the
      // overlay: swallow it into the same quiet "בקרוב".
      if (mounted) _voiceUnavailable();
    }
  }

  /// Quiet, non-crashing feedback when voice can't run (no mic / no result /
  /// unsupported). Mirrors the tool seam's "בקרוב" SnackBar style.
  void _voiceUnavailable() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('קולי — בקרוב')));
  }

  /// BACK tile: pop one drill level. From a deeper view this returns to the
  /// parent node-list; from a TOP tool-view (the base) it empties the stack so
  /// the LETTERS return — and the [_baseLayer] strip highlight is cleared with
  /// it. Present on every tool-view (see [build]'s `showBack`).
  void _onBack() => setState(() {
        if (_stack.isNotEmpty) _stack.removeLast();
        if (_stack.isEmpty) _baseLayer = KbToolLayer.none;
      });

  /// EXIT the tool view back to the LETTERS — the action of the dual-mode bottom
  /// key (it reads "אבג" while a tool layer is open). Clears the whole drill
  /// stack AND enters typing mode, so the letters show and STAY: the [_typing]
  /// guard in [_syncContextToolBase] suppresses the ambient live-mirror context
  /// base from re-installing until the user taps ▦/⚙️ again. This is the exact
  /// mirror of the old design's "tap the search field to type" (which also set
  /// [_typing] = true); with the field gone, this key is the way into typing
  /// from a tool view. A second tap of ▦ (or ⚙️) clears [_typing] and reopens
  /// the tools, so the path back to navigation is preserved.
  void _exitTools() => setState(() {
        _stack.clear();
        _baseLayer = KbToolLayer.none;
        _lastDerivedBase = null;
        _typing = true;
      });

  // ── FINDER-FRONT (kFinderFront): the finder IS the globe's "buttons-mode" ────
  // Per the owner button-spec #6, the floating globe cycles the keyboard's faces
  // (עברית → אנגלית → מקלדת-המילים) — and the "מקלדת המילים" (words) face IS the
  // finder. So switching is the GLOBE ([_onKbCycle]) + the finder's own 'אבג',
  // with NO extra bar. This one helper is the finder's 'אבג' → the letters.

  /// The finder's 'אבג': leave the finder for the Hebrew letters. Dismisses the
  /// lead ([_finderOff]) and enters typing mode. From the letters the globe then
  /// cycles אנגלית → כלים → back to the finder (see [_onKbCycle]).
  void _finderToLetters() => setState(() {
        _findMode = false;
        _finderOff = true;
        _typing = true;
      });

  /// Open a finder product's sheet via the ROOT-navigator context ([_navContext]),
  /// so it works under KB_GLOBAL where the finder panel sits ABOVE the app
  /// Navigator (the audit's product-tap crash fix — showModalBottomSheet needs a
  /// Navigator ancestor). In a plain build [_navContext] is just `context`, so the
  /// manual מאתר finder is unaffected.
  void _openFinderProduct(
    LipskeyCatalogProduct product,
    List<LipskeyCatalogProduct> siblings,
  ) =>
      showLipskeyProductSheet(_navContext, product, siblings);

  /// ANDROID hardware / gesture BACK while the keyboard is open (audit fix): step
  /// OUT of the current face instead of backgrounding / exiting the app — pop a
  /// tool drill, then the finder → letters, then close the keyboard. Returns true
  /// (handled) so the request never falls through to the app while the keyboard is
  /// up; once [_close] runs this observer is removed ([dispose]), so the NEXT back
  /// propagates normally. This observer is registered ([initState]) only while the
  /// keyboard is open. On web the same hook fires for the browser back button.
  @override
  Future<bool> didPopRoute() async {
    // Defer to the Navigator FIRST: if a route is stacked over the app — a pushed
    // screen, or the product sheet the finder itself opens via [_navContext] —
    // BACK belongs to THAT route, not the keyboard underneath. This observer is
    // registered AFTER the app Navigator, so it is consulted FIRST; returning
    // false lets the request fall through to the Navigator's own observer, which
    // pops the top route. Only when nothing is poppable (a bare tab root) do we
    // own BACK and unwind the keyboard's own faces below.
    final nav =
        kKbGlobal ? bsNavigatorKey.currentState : Navigator.maybeOf(context);
    if (nav?.canPop() ?? false) return false;
    if (_stack.isNotEmpty || _baseLayer != KbToolLayer.none) {
      _onBack();
      return true;
    }
    final finderShowing = _findMode ||
        (kFinderFront &&
            !_finderOff &&
            ref.read(mainTabProvider) == 0 &&
            catalogLeadsWithFinder(ref.read(catalogLocationProvider)));
    if (finderShowing) {
      _finderToLetters();
      return true;
    }
    _close();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // A floating panel (rounded-top Material + a subtle top shadow), NOT a modal
    // sheet. SafeArea(top:false) keeps the home-indicator inset clear; the host
    // adds its own bottom SafeArea too, which is harmless (nested insets clamp).
    //
    // [_currentNodes] is read LATER (after [_syncContextToolBase]), so the tiles
    // reflect a LIVE-MIRROR context base installed THIS frame rather than lagging
    // it by one frame.

    // WATCH the active tab so the EMPTY-field row recomputes when the user
    // switches tabs (req D) — drill changes already setState. Then compute the
    // whole prediction row HERE (the single source of truth): the text decides
    // typed-vs-context, the tab + drill decide the context chips.
    final tab = ref.watch(mainTabProvider);

    // A DELIBERATE tab switch means the user navigated, so the ambient live-mirror
    // should re-appear: clear the typing-suppression (and the find panel) so the
    // mirror follows navigation instead of staying stuck on the LETTERS / finder.
    // Guarded by the `if` so this is a NO-OP (no rebuild churn) when none of those
    // modes is active — keeping the kKbLiveMirror-OFF / kKbButtonsV2-OFF paths
    // byte-identical (same-tab typing is untouched; only a tab CHANGE fires this).
    ref.listen<int>(mainTabProvider, (_, __) {
      if (_typing || _kbEnglish || _findMode || _finderOff) {
        setState(() {
          _typing = false;
          _kbEnglish = false;
          _findMode = false;
          // Re-arm the finder-front lead on navigation (folds to a no-op write
          // when kFinderFront is off — _finderOff is only ever set true there).
          _finderOff = false;
        });
      }
    });

    // LIVE-MIRROR ([kKbLiveMirror], plan seam 2 + Q4) — two-stage guard.
    //
    // OUTER tab gate: the mirror covers exactly THREE tabs (1 = מחלקות,
    // 2 = עדכונים, 3 = חנות); every other tab skips all of this with a single int
    // compare (zero new cost off-tab). The three are an `if`/`else if` chain
    // because `mainTabProvider` is a single int — they are mutually exclusive, so
    // at most one assigns [ctx].
    //
    // INNER `kKbLiveMirror || featureFlagsProvider.contains(kKbLiveMirrorFlag)`:
    // EITHER the compile flag (a `--dart-define` demo build) OR the runtime tier
    // (the orchestrator's no-rebuild `enable(kKbLiveMirrorFlag)`, plan Q4) turns
    // the mirror on; BOTH default OFF. When the compile flag is on, the `||`
    // short-circuits TRUE and the featureFlags watch is dead code (tree-shaken).
    // When the compile flag is OFF, the runtime tier is still reachable on a
    // mirrored tab at the cost of ONE cheap Set-contains watch — the deliberate
    // price of a no-rebuild demo toggle (plan Q4 names this exact guard). The
    // EXPENSIVE watches stay INSIDE `if (live)`, so a plain prod build (both flags
    // off) never subscribes to them and their rebuild timing is unchanged (plan
    // risk "flag-OFF timing leak").
    //
    // ATOMIC SNAPSHOT (plan, async-race lens): when active we derive the ENTIRE
    // [KbUpdatesContext] ONCE — both the prediction row AND the tool base — from a
    // single location (+ live-data) snapshot, so the two halves can never disagree.
    // `ctx.row` feeds [_rowFor]; `ctx.toolBase` feeds [_syncContextToolBase] below.
    KbUpdatesContext? ctx;
    // FINDER-FRONT (kFinderFront): does the finder ("the salesperson") LEAD this
    // open instead of the mirror row? Set true only on a קטלוג browse/landing
    // location (the tab==0 branch below). Gated on the [kFinderFront] const, so
    // when the flag is off it stays false and every use of it folds away — the
    // whole finder-front path is byte-identical.
    bool leadWithFinder = false;
    // Whether this surface CAN lead with the finder (home / smart-tree grid) —
    // regardless of whether it currently does ([leadWithFinder] adds !_finderOff).
    // Drives the mode-switch bar, which rides EVERY face (finder / letters /
    // tools) so 'מוכר' is always one tap away. Also gated on the const ⇒ folds.
    bool finderCapable = false;
    if (tab == 1) {
      // PARALLEL מחלקות mirror — the same two-tier gate as the tab-2/3 blocks
      // below, just for the departments tab. It is the HEAD of the `else if` chain
      // (the three mirrored tabs are mutually exclusive at the tab== level, so this
      // branch completely replaces the tab==2/3 checks when tab==1; both blocks
      // below stay untouched). The EXPENSIVE watch [deptLocationProvider] stays
      // INSIDE `if (live)`, so off-tab cost is one int compare. UNLIKE store/updates
      // the four department surfaces are STATIC (no live cart/orders/threads to
      // snapshot), so the deriver takes only the [deptLocationProvider] location —
      // but that watch still stays INSIDE `if (live)`, so a plain prod build (both
      // flags off) never subscribes to it and the off-tab cost is one int compare. The deriver emits the SAME
      // [KbUpdatesContext], so `ctx.row`/`ctx.toolBase` flow through the SAME
      // [_rowFor] adapter + [_syncContextToolBase] below as tabs 2/3.
      //
      // Two-tier gate (identical to the tab-2/3 blocks): [kKbLiveMirror] at compile
      // time short-circuits the `||` so when it is ON the [featureFlagsProvider]
      // watch is dead code and tree-shakes; the runtime tier is only ever watched
      // when the compile flag is OFF (the deliberate one-Set-contains cost of the
      // no-rebuild toggle).
      final live = kKbLiveMirror ||
          ref.watch(featureFlagsProvider).contains(kKbLiveMirrorFlag);
      if (live) {
        final DeptLocation dept = ref.watch(deptLocationProvider);
        ctx = deriveDeptContext(dept);
      }
    } else if (tab == 2) {
      // The SECOND of the three mutually-exclusive mirrored-tab branches (tab 1 =
      // מחלקות is the HEAD; tab 3 = חנות follows). Two-tier gate: the compile-time
      // flag (kKbLiveMirror) short-circuits at build time, so when it is ON the
      // featureFlags watch is dead code and tree-shakes; the runtime flag is only
      // ever watched when the compile flag is OFF (the deliberate one-Set-contains
      // cost of the no-rebuild toggle).
      final live = kKbLiveMirror ||
          ref.watch(featureFlagsProvider).contains(kKbLiveMirrorFlag);
      if (live) {
        final UpdatesLocation upd = ref.watch(updatesLocationProvider);
        final List<ThreadLite> threads = ref.watch(visibleThreadsProvider);
        ctx = deriveUpdatesContext(upd, threads: threads);
      }
    } else if (tab == 3) {
      // PARALLEL חנות mirror — byte-for-byte the same two-tier gate + atomic
      // snapshot as the tab-2 (עדכונים) block above, just for the store tab. It
      // is an `else if` because the two mirrored tabs are mutually exclusive
      // (mainTabProvider is a single int), so at most one assigns [ctx]; the
      // tab-2 path is completely untouched. The EXPENSIVE watches
      // ([storeLocationProvider] + [smartCartProvider] + [ordersEngineProvider])
      // stay INSIDE `if (live)`, so a plain prod build (both flags off) never
      // subscribes to them and the off-tab cost is one int compare. Both derivers
      // emit the SAME [KbUpdatesContext], so `ctx.row`/`ctx.toolBase` flow through
      // the SAME [_rowFor] adapter + [_syncContextToolBase] below as tab 2.
      //
      // Two-tier gate (identical to the tab-2 block): [kKbLiveMirror] at compile
      // time short-circuits the `||` so when it is ON the [featureFlagsProvider]
      // watch is dead code and tree-shakes; the runtime tier is only ever watched
      // when the compile flag is OFF (the deliberate one-Set-contains cost of the
      // no-rebuild toggle).
      final live = kKbLiveMirror ||
          ref.watch(featureFlagsProvider).contains(kKbLiveMirrorFlag);
      if (live) {
        final StoreLocation st = ref.watch(storeLocationProvider);
        final List<SmartCartLine> cart = ref.watch(smartCartProvider);
        final List<Order> orders = ref.watch(ordersEngineProvider);
        ctx = deriveStoreContext(st, cart: cart, orders: orders);
      }
    } else if (tab == 0) {
      // PARALLEL קטלוג mirror — the FOURTH mirrored tab, the same two-tier gate as
      // the tab-1/2/3 blocks above, just for the catalog tab. It is the TAIL of the
      // `else if` chain (the four mirrored tabs are mutually exclusive at the tab==
      // level, so this branch completely replaces the others when tab==0; they all
      // stay untouched). The EXPENSIVE watch [catalogLocationProvider] stays INSIDE
      // `if (live)`, so a plain prod build (both flags off) never subscribes to it
      // and the off-tab cost is one int compare. The deriver emits the SAME
      // [KbUpdatesContext], so `ctx.row`/`ctx.toolBase` flow through the SAME
      // [_rowFor] adapter + [_syncContextToolBase] below as tabs 1/2/3.
      //
      // FLAG-OFF BYTE-IDENTITY (tab 0's unique obligation): with [kKbLiveMirror]
      // const-false the `||` makes `live` const-false ⇒ this whole block (and the
      // [catalogLocationProvider] watch) tree-shakes ⇒ [ctx] stays null ⇒ the
      // [_rowFor] guard's tab==0 disjunct is dead ⇒ control falls to the UNCHANGED
      // `if (tab == 0) return _buildRow('')` there. Net flag-OFF diff = ZERO.
      //
      // Two-tier gate (identical to the tab-1/2/3 blocks): [kKbLiveMirror] at
      // compile time short-circuits the `||` so when it is ON the
      // [featureFlagsProvider] watch is dead code and tree-shakes; the runtime tier
      // is only ever watched when the compile flag is OFF (the deliberate
      // one-Set-contains cost of the no-rebuild toggle).
      final live = kKbLiveMirror ||
          ref.watch(featureFlagsProvider).contains(kKbLiveMirrorFlag);
      // kFinderFront ALSO needs the קטלוג location — to decide whether the finder
      // (the salesperson) LEADS on this browse/landing surface. Read it when
      // EITHER flag wants it; with kFinderFront const-false the `|| kFinderFront`
      // folds to `|| false` (⇒ the read stays inside `if (live)`, unchanged) and
      // the lead block below tree-shakes (⇒ leadWithFinder stays false), so the
      // whole finder-front path is byte-identical when the flag is off.
      if (live || kFinderFront) {
        final CatalogLocation loc = ref.watch(catalogLocationProvider);
        // This surface CAN lead with the finder (home / smart-tree grid). It
        // actually leads unless the user left it via the mode-switch bar
        // ([_finderOff], cleared on a tab change → re-arms). When it can lead, the
        // switch bar (מוכר / אותיות / כלים) rides EVERY face so the user can always
        // return to the seller. Elsewhere (a concrete list) the mirror leads.
        if (kFinderFront && catalogLeadsWithFinder(loc)) {
          finderCapable = true;
          if (!_finderOff) leadWithFinder = true;
        }
        if (live) {
          // The product-category set is the module-level [_kCatalogProductCats]
          // (computed ONCE — the catalog is const), not rebuilt on every keystroke.
          ctx = deriveCatalogContext(loc, productCats: _kCatalogProductCats);
        }
      }
    }

    final row = _rowFor(text: _controller.text, tab: tab, ctx: ctx);
    // Persist the dispatch maps to fields EVERY build (even to empty) so the
    // out-of-build [_onPrediction] callback reads the CURRENT row's mapping and a
    // stale tab/drill's mapping is never carried into the next tap. This is a
    // plain field write inside an already-running build (no setState).
    //
    // DISPATCH-UNAMBIGUITY (spec 318-320) — ACCEPTED, DOCUMENTED RISK. The two
    // alternatives are both worse here: `setState` is illegal inside `build`, and
    // deferring the write to an `addPostFrameCallback` would leave the maps stale
    // (or empty) for THIS frame's taps — directly violating the invariant that
    // each tap reads the CURRENT row's mapping, since the chips paint this frame
    // but their dispatch would lag one frame. A plain in-build field write is the
    // only option that keeps the maps in lock-step with the rendered chips.
    //
    // Why this is race-free in practice: Flutter is single-isolate and runs on
    // one event loop. `build` (assigning these fields) and `_onPrediction` (a
    // synchronous tap callback reading them) are BOTH ordinary microtask/event
    // work on that loop — they NEVER interleave. A `mainTabProvider` change from
    // the bottom-nav also runs on the same loop and schedules a rebuild; the
    // rebuild's field write and any subsequent tap are serialized after it. There
    // is no preemption point between paint and the tap handler, so the "<1ms"
    // window in the audit cannot actually be hit. Documented rather than wrapped
    // in an epoch counter, which would add state without removing a real race.
    _destByChip = row.destByChip;
    // The SECOND dispatch map (LIVE-MIRROR dynamic chips), persisted in lock-step
    // with [_destByChip] so [_onPrediction] reads the CURRENT row's closures.
    // const-empty on every non-mirrored-tab path (tabs 0 and 4+, non-tabs-1-2-3)
    // and on every flag-OFF path; the mirrored tabs (1/2/3) populate it only when
    // the flag is ON, so this write is a no-op otherwise and flag-OFF dispatch
    // stays byte-identical.
    _runByChip = row.runByChip;

    // ROUTE-STACK base (kKbGlobal) — the LIVE top of [keyboardScreenToolsProvider]
    // (the front-most pushed [KbScreen] route's tools), `ref.watch`ed so a push/pop
    // while the grid is open re-runs this build and re-mirrors the new top (push)
    // or restores the parent/tab (pop). More specific than the tab, so it WINS over
    // `ctx?.toolBase` in [_syncContextToolBase]. With [kKbGlobal] const-false the
    // `? … : null` folds to null and the provider watch tree-shakes ⇒ byte-identical.
    final routeBase = kKbGlobal
        ? currentScreenTools(ref.watch(keyboardScreenToolsProvider))
        : null;
    // OWNER RULE: a pushed route shows its OWN tools or NOTHING — never the
    // tab-derived ambient base. kKbGlobal const-false => routePushed folds to
    // false => tabBase == ctx?.toolBase (byte-identical).
    final routePushed =
        kKbGlobal && (bsNavigatorKey.currentState?.canPop() ?? false);
    final tabBase = routePushed ? null : ctx?.toolBase;

    // TOOL-BASE sync (LIVE-MIRROR, plan seam 5) — install the route-stack base (or
    // the deriver's toolBase) as the drill-stack base via a PLAIN in-build field
    // write (same discipline as the dispatch maps; never setState in build).
    // Guarded INSIDE the method so that with both flags off `routeBase`/`ctx` are
    // null ⇒ this is a no-op and the stack is untouched; otherwise it installs only
    // when no manual grid/gear drill is open and only when the base actually changed
    // (so it never re-installs every frame and never clobbers a manual drill).
    //
    // FIND-MODE / FINDER-FRONT gate: while the finder panel is shown — manually
    // (the מאתר tool) OR auto-leading on a browse surface (kFinderFront) — the
    // hidden tool stack must not be churned (the panel replaces the keyboard
    // body), so skip the sync entirely. [leadWithFinder] folds to false when
    // kFinderFront is off, so this stays byte-identical there.
    if (!_findMode && !leadWithFinder) {
      _syncContextToolBase(tabBase, routeBase: routeBase);
    }

    // Read the current node-list AFTER the context-base sync so the tiles (and
    // [showBack]) reflect a base installed this frame (no one-frame lag). Null →
    // the keyboard shows its letters; otherwise the synced node-list as tiles.
    final nodes = _currentNodes;
    // OWNER (dedup): on a live-mirror tab, drilling ▦ renders the SAME items as
    // tiles that the prediction chips already show (e.g. מחלקות → the department
    // list appears both as chips AND as drilled tiles). Drop any chip whose label
    // is already a visible tile so each item shows ONCE. Chips that are NOT tiles
    // (a shallower/other drill, product words, the store pills) stay untouched, and
    // with no tiles (nodes == null → the letters/finder face, and every flag-off
    // surface) nothing is dropped — so those paths are byte-identical.
    final tileList = nodes == null ? null : kbTilesFor(nodes);
    final tileLabels = tileList == null
        ? const <String>{}
        : <String>{for (final t in tileList) t.label};
    final dedupedChips = tileLabels.isEmpty
        ? row.chips
        : <String>[for (final c in row.chips) if (!tileLabels.contains(c)) c];

    return Material(
      color: Colors.transparent,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: DecoratedBox(
        // Light-orange seam fill (owner): the keyboard's gaps read as a warm
        // light orange behind the opaque buttons — not see-through, not grey.
        decoration: const BoxDecoration(
          color: BsTokens.kbSeam,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // X (close) + the separate search field were REMOVED here (owner
              // mobile redesign): the X now lives at the LEADING edge of the tool
              // strip (wired via [onClose] below) and the typed query shows
              // INSIDE the strip (wired via [typedText]) — no own row, no field,
              // reclaiming the vertical space that made the phone keyboard cover
              // half the screen. Typing still drives [_controller] through the
              // host's onKey → insertAtCaret (the field was only ever a display).
              // The assembled keyboard-with-tools, fed the LIVE finder chips AND
              // the morph drill state. When [nodes] is null the keyboard shows
              // its letters; otherwise it renders the current node-list as pure
              // tiles (with a BACK tile once the stack is deeper than its base).
              // KEYBOARD BODY — the finder (seller) leads on a finder-capable
              // browse surface; otherwise the normal letters/tools keyboard. The
              // mode-switch bar (added below as a SIBLING) rides EVERY
              // finder-capable face, so 'מוכר' is always one tap away.
              if (_findMode || leadWithFinder)
                (leadWithFinder
                    ? FindKeyboardPanel(
                        onExit: _finderToLetters,
                        onOpenProduct: _openFinderProduct,
                      )
                    // Manual מאתר-tool find-mode (also the only branch when
                    // kFinderFront is off): the panel's 'אבג' clears find-mode.
                    // onOpenProduct opens the sheet via the root-navigator context
                    // (KB_GLOBAL-safe — the audit's finder product-tap crash fix).
                    : FindKeyboardPanel(
                        onExit: () => setState(() => _findMode = false),
                        onOpenProduct: _openFinderProduct,
                      ))
              else
              BsKeyboardHost(
                controller: _controller,
                focusNode: _focus,
                // 'done' — close the overlay (the field text is the search seed).
                onSend: _close,
                // X at the strip's leading edge closes the overlay; the typed
                // query renders INSIDE the strip; and the dual-mode bottom key
                // (reads "אבג" while a tool layer is open) exits back to the
                // letters via [_exitTools].
                onClose: _close,
                typedText: _controller.text,
                onExitTools: _exitTools,
                showToolStrip: true,
                // Owner button-spec v2 (#7): the layer key toggles letters↔
                // numbers only (never "exit tools"). The flag is const-false in
                // a plain build (= the default, hence "redundant") and true with
                // --dart-define=KB_BUTTONS_V2=true, which is the whole point.
                // ignore: avoid_redundant_argument_values
                symbolsAlwaysToggles: kKbButtonsV2,
                // Owner button-spec #6: the floating globe runs the 3-way cycle
                // עברית → אנגלית → מקלדת-המילים (which, under finder-front, IS the
                // FINDER). Enabled under the v2 buttons OR finder-front; null (⇒
                // the host's plain He↔En toggle) when BOTH are off, so a plain
                // build is byte-identical (kFinderFront folds finderCapable false).
                englishOverride:
                    kKbButtonsV2 || finderCapable ? _kbEnglish : null,
                onLanguageOverride:
                    kKbButtonsV2 || finderCapable ? _onKbCycle : null,
                // This IS a dedicated keyboard surface the user opened on
                // purpose, so it shows the keyboard regardless of the opt-in
                // kSmartInput feature flag (off by default in production).
                forceShow: true,
                predictions: dedupedChips,
                // The chips that are NAVIGABLE (get the nav glyph + brand accent
                // in the pure keyboard): typed/tab destination chips AND LIVE-MIRROR
                // dynamic chips. Product WORDS are absent, so they stay plain — the
                // user can tell a one-tap nav target from a query-narrowing word.
                destinationChips: row.destinationChips,
                onPrediction: _onPrediction,
                // MORPH drill state → the keyboard. The grid/gear toggles push
                // the home/kbd node-list; a tapped tile bubbles its index to
                // [_onTile] (leaf → keep-floating action · branch → morph). The
                // BACK tile shows on a MANUAL drill (grid/gear base, or any deeper
                // level): it pops one drill level, and from a top MANUAL tool-view
                // that empties the stack → the letters return (spec: "from a top
                // tool-view, back returns to the letters").
                //
                // A LIVE-MIRROR context base ([_syncContextToolBase]) is AMBIENT
                // and always depth-1 (its nodes are all leaves — no branches), so
                // it carries NO back tile (`_baseLayer == none` && `length == 1`):
                // it is replaced by switching context, not dismissed by BACK, so
                // BACK never strands the ambient base. When the flag is off the
                // stack is non-empty ONLY via a manual base (which sets
                // `_baseLayer != none`), so this is byte-identical to the prior
                // `_stack.isNotEmpty` there.
                tiles: tileList,
                onTile: _onTile,
                showBack: _baseLayer != KbToolLayer.none || _stack.length > 1,
                onBack: _onBack,
                activeLayer: _baseLayer,
                onToolGrid: _onGrid,
                onToolGear: _onGear,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The result of [_FloatingCardKeyboardState._rowFor]: the [chips] to render plus
/// the THREE mutually-exclusive dispatch maps and the navigable-chip set.
///
///
///   • [chips] — the row labels (typed merge · tab dest labels · LIVE-MIRROR
///     dynamic labels), already ordered + capped by the producing branch.
///   • [destByChip] — chip label → [KbDestination] for the TYPED matches and the
///     empty-field TAB chips (dispatch (i): run the nav action).
///   • [runByChip] — chip label → tap closure for the LIVE-MIRROR dynamic chips
///     (a עדכונים conversation / a notification TYPE chip; dispatch (ii)). EMPTY
///     on every branch but the flag-ON mirror tabs (so flag-OFF carries the
///     const-empty default). The deriver supplies it (copied straight from
///     [KbUpdatesContext]'s [KbRunByChip] map — identical type); [build] persists
///     it into [_runByChip].
///   • [destinationChips] — the subset of [chips] that are NAVIGABLE (get the nav
///     glyph in the pure keyboard): tab/typed dest labels + LIVE-MIRROR dynamic
///     labels (NOT product words). Defaults to the [destByChip] keys when the
///     producer doesn't pass an explicit set, so the typed path ([_buildRow])
///     stays byte-identical without naming it.
///
/// A chip in NEITHER map is a product word (appended on tap). The two maps are
/// DISJOINT (asserted in the ctor), so the dispatch fall-through in
/// [_onPrediction] is STRUCTURAL, not coincidental. Bundling all of this keeps the
/// rendered row and the tap dispatch in lock-step (one build produces them
/// together), so they can never disagree.
@immutable
class _PredRow {
  // DISPATCH DISJOINTNESS (plan, lenses): [_onPrediction] checks the two maps in
  // order (dest → run) then falls through to a product word, so the maps MUST be
  // disjoint for the fall-through to be structural — a label in both would route by
  // accident of order. Asserted in the initializer list (debug only; release strips
  // it) so a producer that ever overlapped them fails loud in tests. Today each
  // branch fills at most one map, so the sets are trivially disjoint; the deriver's
  // own [KbPredRow] ctor re-asserts dest∩run as well.
  _PredRow(
    this.chips,
    this.destByChip, {
    this.runByChip = const <String, KbRunByChip>{},
    Set<String>? destinationChips,
  })  : _destinationChips = destinationChips,
        assert(
          _disjoint(destByChip, runByChip),
          '_PredRow: destByChip / runByChip key-sets must be disjoint '
          '(each chip dispatches via exactly one map).',
        );

  /// True when the two dispatch maps share NO chip label (the disjointness the
  /// ctor asserts). A static helper so the assert can live in the initializer
  /// list (no constructor body needed just for the check).
  static bool _disjoint(
    Map<String, KbDestination> dest,
    Map<String, KbRunByChip> run,
  ) =>
      dest.keys.toSet().intersection(run.keys.toSet()).isEmpty;

  final List<String> chips;
  final Map<String, KbDestination> destByChip;

  /// LIVE-MIRROR dynamic-chip dispatch (dispatch (ii)); const-empty except on the
  /// flag-ON mirror-tab branch. Same value type as the deriver's map, so the
  /// adapter in [_rowFor] copies it through unchanged.
  final Map<String, KbRunByChip> runByChip;

  /// Explicit navigable set when the producer supplies one (tab/mirror branches);
  /// null on the typed path, where it falls back to the [destByChip] keys.
  final Set<String>? _destinationChips;

  /// The chips that get the nav glyph (see class doc). For the typed path this is
  /// exactly the destination keys — byte-identical to the previous
  /// `_destByChip.keys.toSet()` the host used to pass.
  Set<String> get destinationChips =>
      _destinationChips ?? destByChip.keys.toSet();
}
