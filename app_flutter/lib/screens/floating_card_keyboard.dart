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
// or a product word (→ append to the field, as before). The empty field shows
// product opening-words ONLY (no destinations), unchanged.

import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show WordLexicon, buildWordLexicon;
import 'package:buildsmart/screens/card_keyboard_sheet.dart'
    show cardKeyboardPredictions;
import 'package:buildsmart/screens/keyboard_destinations.dart'
    show KbDestination, matchDestinations;
import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode, kbHomeNodes, kbKbdNodes, kbTilesFor;
import 'package:buildsmart/services/voice.dart' show VoiceService;
import 'package:buildsmart/state/keyboard_overlay.dart'
    show keyboardOverlayOpenProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/caret.dart' show insertAtCaret;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart'
    show KbToolLayer;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_host.dart'
    show BsKeyboardHost;
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

class _FloatingCardKeyboardState extends ConsumerState<FloatingCardKeyboard> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  /// Lexicon built ONCE from the dive pool (pure + deterministic); reused for
  /// every keystroke's recompute so we never rebuild it per change.
  late final WordLexicon _lexicon;

  /// The current prediction-row chips (LIVE: recomputed from `_controller.text`).
  /// Destinations FIRST (exact nav targets), then product words; capped at
  /// [_kRowCap]. This is the plain `List<String>` handed to the pure keyboard.
  late List<String> _preds;

  /// Parallel map from a shown chip label → the [KbDestination] it stands for.
  /// Only the destination chips appear here; a chip absent from this map is a
  /// product WORD (appended to the field on tap, as before). Rebuilt on every
  /// recompute alongside [_preds] so the two never drift.
  Map<String, KbDestination> _destByChip = const <String, KbDestination>{};

  /// The MORPH drill-stack: each entry is the tool node-list at that depth. Empty
  /// (the default) → the keyboard shows its LETTERS (no tool view). Pushing the
  /// home/kbd node-list (grid/gear) makes `_stack == [thatList]`; drilling a
  /// BRANCH pushes its children; BACK pops the last entry.
  final List<List<KbToolNode>> _stack = <List<KbToolNode>>[];

  /// Which strip toggle to highlight: the layer of the stack BASE. Set when
  /// grid/gear pushes the first node-list; back to `none` when the stack clears.
  KbToolLayer _baseLayer = KbToolLayer.none;

  /// The node-list currently shown (null while the stack is empty → letters).
  List<KbToolNode>? get _currentNodes => _stack.isEmpty ? null : _stack.last;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focus = FocusNode();
    _lexicon = buildWordLexicon(kDivePool);
    // Seed: empty field → product opening-words ONLY (no destinations, empty
    // map), exactly as before. _build below produces this for the empty text.
    final seed = _buildRow('');
    _preds = seed.chips;
    _destByChip = seed.destByChip;
    _controller.addListener(_recompute);
  }

  /// Recompute the prediction row from the field text. Cheap (pure pool filter +
  /// engine verdict + pure destination match); guarded by `mounted` so a late
  /// listener tick after dispose can never `setState` on a defunct element.
  void _recompute() {
    if (!mounted) return;
    final next = _buildRow(_controller.text);
    setState(() {
      _preds = next.chips;
      _destByChip = next.destByChip;
    });
  }

  /// Builds the merged prediction row for [text]: navigable DESTINATIONS first
  /// (exact nav targets via [matchDestinations]), then the product WORDS
  /// ([cardKeyboardPredictions]), de-duplicated and capped at [_kRowCap]. Also
  /// returns the parallel chip→destination map (only destination chips are
  /// keyed; everything else is a product word).
  ///
  /// Empty/blank [text] → product opening-words ONLY (matchDestinations returns
  /// empty for a blank query), so the empty-field row is byte-identical to the
  /// product-only behaviour. Pure: no side effects, no provider/context reads.
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

  @override
  void dispose() {
    _controller
      ..removeListener(_recompute)
      ..dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Tapped a prediction chip. If it is a DESTINATION (present in [_destByChip])
  /// → run its nav action on THIS widget's own ref/context and KEEP the overlay
  /// floating (do NOT close): a tab/section swaps the screen underneath while the
  /// keyboard keeps floating; a route pushes over everything (the keyboard
  /// reappears when it pops). Otherwise it is a product WORD → append it (+ a
  /// trailing space) at the caret to narrow further, exactly as before; the
  /// controller listener then recomputes the row. [insertAtCaret] leaves the
  /// caret collapsed after the inserted text (and appends when no selection).
  void _onPrediction(String chip) {
    final dest = _destByChip[chip];
    if (dest != null) {
      dest.run(ref, context);
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
  void _onGrid() => setState(() {
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
  /// KBD is already the base. Never closes the overlay.
  void _onGear() => setState(() {
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
                predictions: _preds,
                onPrediction: _onPrediction,
                // MORPH drill state → the keyboard. The grid/gear toggles push
                // the home/kbd node-list; a tapped tile bubbles its index to
                // [_onTile] (leaf → keep-floating action · branch → morph). The
                // BACK tile shows on EVERY tool-view (incl. a top one): it pops
                // one drill level, and from a top tool-view that empties the
                // stack → the letters return (spec: "from a top tool-view, back
                // returns to the letters").
                tiles: nodes == null ? null : kbTilesFor(nodes),
                onTile: _onTile,
                showBack: _stack.isNotEmpty,
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

/// The result of [_FloatingCardKeyboardState._buildRow]: the merged chip labels
/// ([chips], destinations-first then product words, capped) AND the parallel map
/// from a destination chip's label to its [KbDestination]. A chip absent from
/// [destByChip] is a product word. Bundling the two keeps them in lock-step (one
/// build produces both), so the row the keyboard shows and the tap-dispatch map
/// can never disagree.
@immutable
class _PredRow {
  const _PredRow(this.chips, this.destByChip);

  final List<String> chips;
  final Map<String, KbDestination> destByChip;
}
