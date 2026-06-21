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
// I AM and WHAT I PRESSED, not just what I type — computed in [build] (the only
// place that can `ref.watch` the tab + read the drill stack):
//   • DRILLED (a tool node-list is open) → the chips ARE the current node-list
//     labels, one per node in index order; tapping a chip routes through the
//     EXISTING [_onTile] by index (leaf runs + keeps floating · branch drills ·
//     voice starts voice) — zero nav logic duplicated. Leaf/voice chips get the
//     nav glyph; a BRANCH chip morphs (no glyph), matching its tile.
//   • AT THE LETTERS (not drilled) → chips for the CURRENT TAB
//     (ref.watch(mainTabProvider)): tab 1 the 4 departments · tab 2 שיחות +
//     התראות · tab 3 הסל שלי + ההזמנות שלי + שירותים — each sourced from
//     [kbDestinations] BY LABEL so it carries its REAL run (typing it navigates
//     identically). Tab 0 (בית/catalog) keeps product opening-words, unchanged.
// Dispatch ([_onPrediction]) reads two MUTUALLY-EXCLUSIVE parallel maps rebuilt
// every build: [_drillIndexByChip] (drilled chips → node index) then
// [_destByChip] (tab/typed destination chips → [KbDestination]); a chip in
// neither is a product WORD (appended). The empty field at tab 0 still shows
// product opening-words ONLY (no destinations), unchanged.

import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show WordLexicon, buildWordLexicon;
import 'package:buildsmart/screens/card_keyboard_sheet.dart'
    show cardKeyboardPredictions;
import 'package:buildsmart/screens/chats_screen.dart'
    show ThreadLite, visibleThreadsProvider;
import 'package:buildsmart/screens/keyboard_destinations.dart'
    show KbDestination, kbDestinations, matchDestinations;
import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode, kbHomeNodes, kbKbdNodes, kbTilesFor;
import 'package:buildsmart/screens/keyboard_updates_deriver.dart'
    show KbRunByChip, KbUpdatesContext, deriveUpdatesContext;
import 'package:buildsmart/services/voice.dart' show VoiceService;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/feature_flags.dart'
    show featureFlagsProvider, kKbLiveMirrorFlag;
import 'package:buildsmart/state/keyboard_overlay.dart'
    show keyboardOverlayOpenProvider;
import 'package:buildsmart/state/updates_location.dart'
    show UpdatesLocation, updatesLocationProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/caret.dart' show insertAtCaret;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart'
    show KbToolLayer;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_host.dart'
    show BsKeyboardHost, kKbLiveMirror;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _FloatingCardKeyboardState extends ConsumerState<FloatingCardKeyboard> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  /// Lexicon built ONCE from the dive pool (pure + deterministic); reused for
  /// every keystroke's recompute so we never rebuild it per change.
  late final WordLexicon _lexicon;

  /// Parallel map from a shown chip label → the [KbDestination] it stands for.
  /// Only DESTINATION chips appear here: the typed-row matches AND the empty-field
  /// TAB chips (both navigate via [KbDestination.run]). A chip absent from BOTH
  /// this map and [_drillIndexByChip] is a product WORD (appended to the field on
  /// tap, as before). REBUILT on every [build] (the chips themselves are computed
  /// there now), so the dispatch map can never drift from the rendered row, and a
  /// stale tab/drill's mapping is never carried into the next tap.
  Map<String, KbDestination> _destByChip = const <String, KbDestination>{};

  /// Parallel map from an empty-field DRILLED chip label → its node INDEX in the
  /// current node-list (`_currentNodes`), so [_onPrediction] can route a tapped
  /// drill chip through the EXISTING [_onTile] by index (leaf/branch/voice). Set
  /// ONLY on the drilled empty-field branch; EMPTY on the typed and tab branches,
  /// so it is MUTUALLY EXCLUSIVE with [_destByChip] by construction (dispatch
  /// checks this map first, so the two can never mis-route). Rebuilt every [build]
  /// from the CURRENT nodes, so the index always matches the list the tiles tap.
  Map<String, int> _drillIndexByChip = const <String, int>{};

  /// THE THIRD dispatch map (עדכונים LIVE-MIRROR, [kKbLiveMirror]) — from a
  /// truly-dynamic chip label (a conversation name · a notification TYPE label) →
  /// the closure to run on tap with THIS widget's own `ref`/`context`. These chips
  /// belong to NEITHER existing map: they are not registry destinations (no static
  /// nav target) and not drill-node indices, so without this map [_onPrediction]
  /// would WRONGLY type them into the search field. The deriver
  /// ([deriveUpdatesContext]) populates it (each closure sets a provider —
  /// `notifSectionProvider` / `updatesChatOpenProvider` — so the SCREEN reacts; the
  /// keyboard never pushes a route, keeping the overlay floating). Checked AFTER
  /// the two existing maps and BEFORE the product-word fallback, so the three are
  /// pairwise-disjoint by the [_PredRow] ctor assert. EMPTY on every path except
  /// the flag-ON tab-2 mirror branch (default const-empty → byte-identical when the
  /// flag is off), rebuilt every [build] alongside the other two so it can never
  /// drift from the rendered row.
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

  /// THE 3-WAY ROW SELECTOR — the single decision for what the prediction row
  /// shows, called from [build] (the only place that can read [tab] +
  /// [nodes]). PURE (no side effects, no setState): it returns a [_PredRow] of
  /// chips + the two dispatch maps; [build] persists those maps to fields.
  ///
  ///   1. [text] NON-EMPTY → the TYPED row, byte-identical to before:
  ///      [_buildRow] (destinations-first merge + reserved word slot). The drill
  ///      map is EMPTY here (typed text never enters the drilled branch).
  ///   2. [text] EMPTY + DRILLED ([nodes] != null) → the current node-list
  ///      LABELS, one per node in index order; tapping routes through [_onTile]
  ///      by that index. destByChip is EMPTY (drill chips dispatch via the drill
  ///      map only — mutually exclusive). LEAF/voice chips are "navigable" (get
  ///      the nav glyph via [_PredRow.destinationChips]); a BRANCH chip morphs.
  ///   3. [text] EMPTY + NOT drilled → the CURRENT [tab]'s chips: tabs 1/2/3
  ///      source their [KbDestination]s from [kbDestinations] BY LABEL (each
  ///      carries its REAL run); tab 0 keeps product opening-words via
  ///      [_buildRow] (empty destByChip — today's exact empty-field behaviour).
  ///
  /// LIVE-MIRROR ([kKbLiveMirror], guarded): when the flag is on AND we are on the
  /// עדכונים tab (tab == 2) AND [ctx] was derived in [build], this returns the PURE
  /// deriver's row instead of the hardcoded ['שיחות','התראות'] tab-2 fallback —
  /// re-derived at every click. [ctx] is non-null ONLY on that flag-ON tab-2 path
  /// (see [build], which derives the WHOLE [KbUpdatesContext] once — both the row
  /// AND the tool base — from one location snapshot, then passes it here and uses
  /// its toolBase for [_syncContextToolBase]). With the flag OFF [ctx] is always
  /// null and this branch is skipped, so the tab-2 fallback below runs and every
  /// path stays byte-identical.
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
    // guard ⇒ tree-shaken) OR when [ctx] is null (every non-flag-ON-tab-2 path).
    // ADAPTER: the deriver returns a PUBLIC [KbUpdatesContext] whose row is a
    // [KbPredRow] (a leaf file cannot construct this private [_PredRow]); copy it
    // field-for-field into [_PredRow] — chips + destByChip + destinationChips, plus
    // the NEW runByChip map (the deriver never drills, so drillIndexByChip stays
    // const-empty). [build] then persists row.runByChip into [_runByChip].
    if (kKbLiveMirror && tab == 2 && ctx != null) {
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
  /// tab 2 / runtime tier off), in which case this either (a) tears down a context
  /// base THIS widget previously installed — returning to the letters — or (b)
  /// does nothing if none was installed or a manual drill owns the stack. So with
  /// the flag off this is a pure no-op and the manual drill behaviour is
  /// byte-identical.
  void _syncContextToolBase(List<KbToolNode>? base) {
    // A manual grid/gear drill owns the stack → leave it untouched. We also do NOT
    // touch [_lastDerivedBase] here: when the manual drill closes (back to
    // `_baseLayer == none`) the next build re-runs this and installs/clears the
    // context base correctly from the then-current [base].
    if (_baseLayer != KbToolLayer.none) return;

    final newLabels =
        base == null ? null : <String>[for (final n in base) n.label];

    // No change since the last context sync → nothing to do (the churn guard).
    if (listEquals(newLabels, _lastDerivedBase)) return;

    if (base == null || base.isEmpty) {
      // The deriver stopped supplying a base (flag off / left tab / empty list).
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
      ..add(base);
    _lastDerivedBase = newLabels;
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_recompute)
      ..dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Tapped a prediction chip — THREE cases, read from the two parallel maps that
  /// [build] rebuilt for the CURRENT row (so dispatch always matches what is on
  /// screen). The maps are MUTUALLY EXCLUSIVE by construction and each is checked
  /// with a null-guard, so a tap can never mis-route or deref a missing entry:
  ///   (i) a DRILLED-node chip ([_drillIndexByChip]) → route through the EXISTING
  ///       [_onTile] by index (leaf runs + keeps floating · branch drills · voice
  ///       starts voice). [_onTile] is itself bounds-guarded, so a stale index is
  ///       safe. Checked FIRST (the drill branch never populates [_destByChip]).
  ///   (ii) a DESTINATION chip ([_destByChip] — a typed match OR an empty-field
  ///       TAB chip) → run its nav action on THIS widget's own ref/context and
  ///       KEEP the overlay floating: a tab/section swaps the screen underneath
  ///       while the keyboard keeps floating; a route pushes over everything (the
  ///       keyboard reappears when it pops).
  ///   (iii) a LIVE-MIRROR dynamic chip ([_runByChip] — a עדכונים conversation or
  ///       a notification TYPE chip, flag [kKbLiveMirror]) → run its closure on
  ///       THIS widget's own ref/context. The closure only SETS a provider
  ///       (`notifSectionProvider` / `updatesChatOpenProvider`) for the SCREEN to
  ///       react to — it never pushes a route from the keyboard, so the overlay
  ///       stays floating. EMPTY (so this step is a no-op) on every path but the
  ///       flag-ON tab-2 mirror, keeping flag-OFF dispatch byte-identical. Checked
  ///       AFTER [_destByChip] and BEFORE the word fallback; the three maps are
  ///       pairwise-disjoint (the [_PredRow] ctor asserts it), so the order only
  ///       sets precedence for an impossible collision.
  ///   (iv) otherwise a product WORD → append it (+ a trailing space) at the
  ///       caret to narrow further, exactly as before; the controller listener
  ///       then repaints. [insertAtCaret] leaves the caret collapsed after the
  ///       inserted text (and appends when no selection).
  void _onPrediction(String chip) {
    final idx = _drillIndexByChip[chip];
    if (idx != null) {
      _onTile(idx);
      return;
    }
    final dest = _destByChip[chip];
    if (dest != null) {
      dest.run(ref, context);
      return;
    }
    final run = _runByChip[chip];
    if (run != null) {
      run(ref, context);
      return;
    }
    insertAtCaret(_controller, '$chip ');
  }

  /// Close the floating overlay (no route to pop — flip the provider instead).
  /// The ONLY explicit dismiss (the close-chevron + the send key).
  void _close() {
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
  void _onGrid() => setState(() {
        _lastDerivedBase = null;
        if (_baseLayer == KbToolLayer.home) {
          _stack.clear();
          _baseLayer = KbToolLayer.none;
        } else {
          _stack
            ..clear()
            ..add(kbHomeNodes());
          _baseLayer = KbToolLayer.home;
        }
      });

  /// GEAR toggle: open the KBD node-list as the stack base — or toggle closed if
  /// KBD is already the base. Never closes the overlay. Clears [_lastDerivedBase]
  /// (a manual drill takes over the stack from any context base — see [_onGrid]).
  void _onGear() => setState(() {
        _lastDerivedBase = null;
        if (_baseLayer == KbToolLayer.kbd) {
          _stack.clear();
          _baseLayer = KbToolLayer.none;
        } else {
          _stack
            ..clear()
            ..add(kbKbdNodes());
          _baseLayer = KbToolLayer.kbd;
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
      node.action?.call(ref, context);
    }
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

    // LIVE-MIRROR ([kKbLiveMirror], plan seam 2 + Q4) — two-stage guard.
    //
    // OUTER `tab == 2`: the deriver mirrors the עדכונים tab ONLY, so every other
    // tab skips all of this with a single int compare (zero new cost off-tab).
    //
    // INNER `kKbLiveMirror || featureFlagsProvider.contains(kKbLiveMirrorFlag)`:
    // EITHER the compile flag (a `--dart-define` demo build) OR the runtime tier
    // (the orchestrator's no-rebuild `enable(kKbLiveMirrorFlag)`, plan Q4) turns
    // the mirror on; BOTH default OFF. When the compile flag is on, the `||`
    // short-circuits TRUE and the featureFlags watch is dead code (tree-shaken).
    // When the compile flag is OFF, the runtime tier is still reachable on tab 2 at
    // the cost of ONE cheap Set-contains watch — the deliberate price of a
    // no-rebuild demo toggle (plan Q4 names this exact guard). The EXPENSIVE watches
    // ([updatesLocationProvider] + [visibleThreadsProvider]) stay INSIDE `if
    // (live)`, so a plain prod build (both flags off) never subscribes to them and
    // their rebuild timing is unchanged (plan risk "flag-OFF timing leak").
    //
    // ATOMIC SNAPSHOT (plan, async-race lens): when active we derive the ENTIRE
    // [KbUpdatesContext] ONCE — both the prediction row AND the tool base — from a
    // single [updatesLocationProvider] + [visibleThreadsProvider] snapshot, so the
    // two halves can never disagree. `ctx.row` feeds [_rowFor]; `ctx.toolBase`
    // feeds [_syncContextToolBase] below.
    KbUpdatesContext? ctx;
    if (tab == 2) {
      // Two-tier gate: the compile-time flag (kKbLiveMirror) short-circuits at
      // build time, so when it is ON the featureFlags watch is dead code and
      // tree-shakes; the runtime flag is only ever watched when the compile flag
      // is OFF (the deliberate one-Set-contains cost of the no-rebuild toggle).
      final live = kKbLiveMirror ||
          ref.watch(featureFlagsProvider).contains(kKbLiveMirrorFlag);
      if (live) {
        final UpdatesLocation upd = ref.watch(updatesLocationProvider);
        final List<ThreadLite> threads = ref.watch(visibleThreadsProvider);
        ctx = deriveUpdatesContext(upd, threads: threads);
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
    _drillIndexByChip = row.drillIndexByChip;
    // The THIRD dispatch map (LIVE-MIRROR dynamic chips), persisted in lock-step
    // with the other two so [_onPrediction] reads the CURRENT row's closures.
    // const-empty on every flag-OFF / non-tab-2 path, so this write is a no-op
    // there and flag-OFF dispatch stays byte-identical.
    _runByChip = row.runByChip;

    // TOOL-BASE sync (LIVE-MIRROR, plan seam 5) — install the deriver's toolBase
    // as the drill-stack base via a PLAIN in-build field write (same discipline as
    // the dispatch maps; never setState in build). Guarded INSIDE the method so
    // that with the flag off `ctx` is null ⇒ this is a no-op and the stack is
    // untouched; with the flag on it installs only when no manual grid/gear drill
    // is open and only when the base actually changed (so it never re-installs
    // every frame and never clobbers a manual drill).
    _syncContextToolBase(ctx?.toolBase);

    // Read the current node-list AFTER the context-base sync so the tiles (and
    // [showBack]) reflect a base installed this frame (no one-frame lag). Null →
    // the keyboard shows its letters; otherwise the synced node-list as tiles.
    final nodes = _currentNodes;

    return Material(
      color: const Color(0xFFFFFFFF),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            // Subtle lift so the floating keyboard reads as a layer above the
            // (still full-size) screen underneath.
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CLOSE affordance — a down-chevron / handle that dismisses the
              // floating overlay (sets keyboardOverlayOpenProvider false). The
              // visible glyph stays small; a ≥48dp tap target wraps it (a11y).
              Semantics(
                button: true,
                label: 'סגור מקלדת',
                child: Tooltip(
                  message: 'סגור',
                  child: InkWell(
                    onTap: _close,
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                    child: const SizedBox(
                      width: 48,
                      height: 28,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 22,
                        color: Color(0x66000000),
                      ),
                    ),
                  ),
                ),
              ),
              // Read-only query field — the custom keyboard drives it, so the OS
              // keyboard never appears. RTL for Hebrew product words.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BsTokens.space4,
                  vertical: BsTokens.space2,
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  readOnly: true,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    hintText: 'מה לחפש?',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              // The assembled keyboard-with-tools, fed the LIVE finder chips AND
              // the morph drill state. When [nodes] is null the keyboard shows
              // its letters; otherwise it renders the current node-list as pure
              // tiles (with a BACK tile once the stack is deeper than its base).
              BsKeyboardHost(
                controller: _controller,
                focusNode: _focus,
                // 'done' — close the overlay (the field text is the search seed).
                onSend: _close,
                showToolStrip: true,
                // This IS a dedicated keyboard surface the user opened on
                // purpose, so it shows the keyboard regardless of the opt-in
                // kSmartInput feature flag (off by default in production).
                forceShow: true,
                predictions: row.chips,
                // The chips that are NAVIGABLE (get the nav glyph + brand accent
                // in the pure keyboard): typed/tab destination chips AND drill
                // LEAF/voice chips. Product WORDS and drill BRANCH chips are
                // absent, so they stay plain — the user can tell a one-tap nav
                // target from a query-narrowing word or a morph-in-place tile.
                // [_PredRow] already unions the dest + navigable-drill labels.
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
                tiles: nodes == null ? null : kbTilesFor(nodes),
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
///   • [chips] — the row labels (typed merge · drill node labels · tab dest
///     labels · LIVE-MIRROR dynamic labels), already ordered + capped by the
///     producing branch.
///   • [destByChip] — chip label → [KbDestination] for the TYPED matches and the
///     empty-field TAB chips (dispatch (ii): run the nav action).
///   • [drillIndexByChip] — chip label → node INDEX for the empty-field DRILLED
///     chips (dispatch (i): route through `_onTile`). EMPTY on every non-drilled
///     branch, so it is mutually exclusive with [destByChip].
///   • [runByChip] — chip label → tap closure for the LIVE-MIRROR dynamic chips
///     (a עדכונים conversation / a notification TYPE chip; dispatch (iii)). EMPTY
///     on every branch but the flag-ON tab-2 mirror (so flag-OFF carries the
///     const-empty default). The deriver supplies it (copied straight from
///     [KbUpdatesContext]'s [KbRunByChip] map — identical type); [build] persists
///     it into [_runByChip].
///   • [destinationChips] — the subset of [chips] that are NAVIGABLE (get the nav
///     glyph in the pure keyboard): tab/typed dest labels + drill LEAF/voice
///     labels + LIVE-MIRROR dynamic labels (NOT product words, NOT drill BRANCH
///     labels). Defaults to the [destByChip] keys when the producer doesn't pass
///     an explicit set, so the typed path ([_buildRow]) stays byte-identical
///     without naming it.
///
/// A chip in NONE of the three maps is a product word (appended on tap). The
/// three maps are PAIRWISE-DISJOINT (asserted in the ctor), so the dispatch
/// fall-through in [_onPrediction] is STRUCTURAL, not coincidental. Bundling all
/// of this keeps the rendered row and the tap dispatch in lock-step (one build
/// produces them together), so they can never disagree.
@immutable
class _PredRow {
  _PredRow(
    this.chips,
    this.destByChip, {
    this.drillIndexByChip = const <String, int>{},
    this.runByChip = const <String, KbRunByChip>{},
    Set<String>? destinationChips,
  }) : _destinationChips = destinationChips {
    // DISPATCH DISJOINTNESS (plan, lenses): [_onPrediction] checks the three maps
    // in order (drill → dest → run) then falls through to a product word, so the
    // maps MUST be pairwise-disjoint for the fall-through to be structural — a
    // label in two maps would route by accident of order. Asserted here (debug
    // only; release strips it) so a producer that ever overlapped them fails loud
    // in tests. Today each branch fills at most one map, so the sets are trivially
    // disjoint; the deriver's own [KbPredRow] ctor re-asserts dest∩run as well.
    assert(
      () {
        final drill = drillIndexByChip.keys.toSet();
        final dest = destByChip.keys.toSet();
        final run = runByChip.keys.toSet();
        return drill.intersection(dest).isEmpty &&
            drill.intersection(run).isEmpty &&
            dest.intersection(run).isEmpty;
      }(),
      '_PredRow: drillIndexByChip / destByChip / runByChip key-sets must be '
      'pairwise-disjoint (each chip dispatches via exactly one map).',
    );
  }

  final List<String> chips;
  final Map<String, KbDestination> destByChip;
  final Map<String, int> drillIndexByChip;

  /// LIVE-MIRROR dynamic-chip dispatch (dispatch (iii)); const-empty except on the
  /// flag-ON tab-2 mirror branch. Same value type as the deriver's map, so the
  /// adapter in [_rowFor] copies it through unchanged.
  final Map<String, KbRunByChip> runByChip;

  /// Explicit navigable set when the producer supplies one (drill/tab/mirror
  /// branches); null on the typed path, where it falls back to the [destByChip]
  /// keys.
  final Set<String>? _destinationChips;

  /// The chips that get the nav glyph (see class doc). For the typed path this is
  /// exactly the destination keys — byte-identical to the previous
  /// `_destByChip.keys.toSet()` the host used to pass.
  Set<String> get destinationChips =>
      _destinationChips ?? destByChip.keys.toSet();
}
