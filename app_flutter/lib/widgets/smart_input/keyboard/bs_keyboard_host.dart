// BsKeyboardHost — the self-gating, bottom-docked mount for [BsKeyboard].
//
// This is the thin stateful seam between the pure [BsKeyboard] presentation and
// the rest of the app. It owns exactly two responsibilities:
//   1. GATE: render nothing unless [useCustomKeyboard] is true (feature OFF or a
//      screen reader active → the OS keyboard is used instead, so we show
//      nothing here).
//   2. WIRE: route the keyboard's typed callbacks onto the caller's
//      [controller] via the caret helpers, and own the `?123` symbols-layer
//      toggle (the only piece of local state the keyboard needs).
//
// It deliberately does NOT touch focus or summon the OS keyboard: the field
// keeps its own focus, and (in the wired-up screen) is `readOnly:true` so the
// platform keyboard never appears. The globe key ([onLanguage]) toggles between
// the Hebrew and English letter layers (for typing English product names).

import 'package:buildsmart/screens/keyboard_tool_actions.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/caret.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/kb_field_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FLAG — the tool strip (grid/gear toggles + predictions + tool layers) is OFF
/// by default, so the LIVE keyboard renders exactly as before. Flip to true to
/// preview the keyboard-with-tools surface. Kept a top-level const so it folds
/// away entirely when off.
///
/// As of STEP 3 this flag is applied by the MOUNT (the screen that builds a
/// [BsKeyboardHost] passes it as `showToolStrip:`), NOT inside the host: the
/// host no longer reads it directly, so each mount decides whether its own
/// keyboard shows the strip. The live chat mount leaves `showToolStrip` at its
/// default (false), so the live keyboard stays byte-identical.
///
/// GO-LIVE (step 4): flipped to true so the home surfaces the card-keyboard
/// surface. STEP A: that surface is now a PERSISTENT FLOATING overlay
/// ([FloatingCardKeyboard]) opened by a keyboard FAB in [HomeShell] — both gated
/// by this flag — replacing the old modal launcher. Only the home opts in via
/// this flag; the chat mount still passes its own default (false), so its
/// keyboard is unchanged. With the flag OFF the shell is byte-identical (no FAB,
/// no overlay).
const bool kKeyboardToolStrip = true;

/// FLAG — the עדכונים LIVE-MIRROR keyboard (the floating keyboard becomes a live
/// mirror of the עדכונים tab: at every click it re-derives BOTH its tools AND its
/// predictions from the current spot). OFF by default, so the floating keyboard
/// is BYTE-IDENTICAL to today: the new `_rowFor` branch + the `build()` watches
/// in [FloatingCardKeyboard] all fold out under this const guard (they
/// tree-shake away when the define is absent), the hardcoded tab-2 row
/// ['שיחות','התראות'] stays, the typed path is untouched, and bs_keyboard.dart
/// stays PURE.
///
/// Same foldable idiom as [kKeyboardToolStrip]: a top-level
/// `bool.fromEnvironment` const, default OFF, flipped ON for a demo build via
/// `--dart-define=KB_LIVE_MIRROR=true`. A staged RUNTIME toggle for owner demos
/// is ALSO available without a rebuild via `featureFlagsProvider`
/// ([kKbLiveMirrorFlag] in state/feature_flags.dart) — the floating keyboard's
/// guard is `kKbLiveMirror || featureFlags.isOn(kKbLiveMirrorFlag)`, so either
/// path enables it and BOTH default OFF.
const bool kKbLiveMirror = bool.fromEnvironment('KB_LIVE_MIRROR');

/// Bottom-docked host that shows the custom [BsKeyboard] when (and only when)
/// [useCustomKeyboard] is true, and forwards its taps onto [controller].
class BsKeyboardHost extends ConsumerStatefulWidget {
  /// The field's controller; every key/backspace/enter mutates it at the caret.
  final TextEditingController controller;

  /// The field's focus node. Held so callers can wire it; the host itself does
  /// not request focus (the field keeps it) nor open the OS keyboard.
  final FocusNode focusNode;

  /// Fired by the brand-orange send key.
  final VoidCallback onSend;

  /// Close the floating overlay — wired to the strip's X (owner mobile redesign
  /// moved the close into the strip). Null on every non-floating mount.
  final VoidCallback? onClose;

  /// The current query text, shown inside the strip's middle (the separate
  /// search field was removed). Empty (default) → the strip shows a faint hint.
  final String typedText;

  /// Exit the tool view back to the letters — the floating keyboard wires this to
  /// the dual-mode bottom key (reads "אבג" while tools are open). Null elsewhere.
  final VoidCallback? onExitTools;

  /// Whether to render the flagged tool strip (grid/gear toggles + prediction
  /// row + tool layers). Off by default so every existing mount stays
  /// byte-identical; the MOUNT passes [kKeyboardToolStrip] (or its own flag)
  /// here to opt in. STEP 3.
  final bool showToolStrip;

  /// The prediction-row chips to show in the strip's MIDDLE (rendered no-scroll
  /// by [BsKeyboard]). Empty by default; a mount feeds the live finder engine's
  /// chips here (see `keyboard_predictions.dart`). Ignored while
  /// [showToolStrip] is false. STEP 3.
  final List<String> predictions;

  /// The subset of [predictions] that are navigable DESTINATIONS (a tap
  /// navigates) rather than query-narrowing product WORDS. Forwarded verbatim to
  /// [BsKeyboard] so those chips get the nav glyph + brand accent. Empty by
  /// default → every chip renders as a plain word chip (byte-identical).
  final Set<String> destinationChips;

  /// Fired with the chip text when the user taps a prediction. Null by default
  /// (no-op). STEP 3.
  final ValueChanged<String>? onPrediction;

  /// Override for a tapped tool tile. Null by default → the host uses the
  /// step-2 seam ([runKeyboardTool]) directly, so every existing mount keeps its
  /// behaviour. A mount that must act BEFORE navigating (e.g. the card-keyboard
  /// sheet, which closes itself first) supplies this and drives
  /// [runKeyboardTool] on the right navigator itself. STEP 4.
  final ValueChanged<KbTool>? onTool;

  /// When true, BYPASS the [useCustomKeyboard] gate entirely and always show the
  /// keyboard. For a DEDICATED keyboard surface the user opened on purpose (the
  /// card-keyboard sheet), where the keyboard must appear regardless of the
  /// opt-in [kSmartInputFlag]. Default false → existing mounts (chat/finder)
  /// stay gated by the flag + screen-reader check. STEP 4 (go-live fix).
  final bool forceShow;

  // ── MORPH path (drill-stack) — STEP B ─────────────────────────────────────
  // A mount that drives its OWN morph engine (the floating keyboard) supplies
  // [tiles]/[onTile]/[showBack]/[onBack]; when [tiles] is non-null the host
  // forwards them to [BsKeyboard] (which then renders those pure tiles instead
  // of the letters/[toolLayer] grid) AND routes the strip grid/gear toggles to
  // [onToolGrid]/[onToolGear] instead of its internal [_toolLayer] toggle. Every
  // existing mount leaves these null and keeps the legacy internal behaviour.

  /// The pure tiles to render (the current drill node-list). Null → the host's
  /// own letters/symbols/[toolLayer] grid (legacy behaviour).
  final List<KbTile>? tiles;

  /// Tapped a [tiles] tile — bubbles the tile's opaque id to the mount's drill
  /// engine. Ignored while [tiles] is null.
  final ValueChanged<int>? onTile;

  /// Whether to show the leading BACK tile in the morph grid. Ignored while
  /// [tiles] is null.
  final bool showBack;

  /// Tapped the BACK tile. Ignored while [tiles] is null.
  final VoidCallback? onBack;

  /// Override for the strip GRID toggle. Null → the host's internal home-layer
  /// toggle (legacy). The floating keyboard supplies this to push its home
  /// node-list onto the drill stack.
  final VoidCallback? onToolGrid;

  /// Override for the strip GEAR toggle. Null → the host's internal kbd-layer
  /// toggle (legacy). The floating keyboard supplies this to push its kbd
  /// node-list onto the drill stack.
  final VoidCallback? onToolGear;

  /// Which toggle the strip should highlight while a morph mount drives the grid
  /// ([KbToolLayer.home] when the home node-list is on the stack base,
  /// [KbToolLayer.kbd] for the kbd list, [KbToolLayer.none] when neither). Null
  /// → the host uses its own internal [_toolLayer] (legacy). Only consulted for
  /// the strip's active-highlight; the grid render is driven by [tiles].
  final KbToolLayer? activeLayer;

  const BsKeyboardHost({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    this.onClose,
    this.typedText = '',
    this.onExitTools,
    this.showToolStrip = false,
    this.predictions = const <String>[],
    this.destinationChips = const <String>{},
    this.onPrediction,
    this.onTool,
    this.forceShow = false,
    this.tiles,
    this.onTile,
    this.showBack = false,
    this.onBack,
    this.onToolGrid,
    this.onToolGear,
    this.activeLayer,
  });

  @override
  ConsumerState<BsKeyboardHost> createState() => _BsKeyboardHostState();
}

class _BsKeyboardHostState extends ConsumerState<BsKeyboardHost> {
  /// Whether the `?123` symbols layer is showing (vs. the letters).
  bool _showSymbols = false;

  /// Whether the English QWERTY letter layer is showing (vs. Hebrew). Toggled
  /// by the globe key.
  bool _english = false;

  /// Which tool layer (if any) the strip toggles have opened over the letter
  /// grid. Always [KbToolLayer.none] while the strip flag is off.
  KbToolLayer _toolLayer = KbToolLayer.none;

  /// Grid toggle: open the home-tools layer, or close it back to the letters.
  void _onToolGrid() => setState(() {
        _toolLayer =
            _toolLayer == KbToolLayer.home ? KbToolLayer.none : KbToolLayer.home;
      });

  /// Gear toggle: open the keyboard-tools layer, or close it back to letters.
  void _onToolGear() => setState(() {
        _toolLayer =
            _toolLayer == KbToolLayer.kbd ? KbToolLayer.none : KbToolLayer.kbd;
      });

  @override
  Widget build(BuildContext context) {
    // GATE: feature OFF or screen reader active → render nothing; the OS
    // keyboard handles input instead. [forceShow] bypasses this for a dedicated
    // keyboard surface (the card-keyboard sheet) the user opened on purpose.
    final use = widget.forceShow || useCustomKeyboard(ref, context);
    if (!use) return const SizedBox.shrink();

    // Bottom-docked panel. SafeArea(top:false) keeps the home-indicator inset
    // clear without padding the top. The neutral surface matches the keyboard.
    return SafeArea(
      top: false,
      child: Material(
        // Light-orange seam fill (owner): this host shell sits BEHIND the
        // BsKeyboard, so its colour is what shows in every seam between the
        // opaque buttons (was surfaceMid grey, then transparent — now warm).
        color: BsTokens.kbSeam,
        child: BsKeyboard(
          showSymbols: _showSymbols,
          english: _english,
          onKey: (ch) => insertAtCaret(widget.controller, ch),
          onBackspace: () => deleteBackward(widget.controller),
          onEnter: () => insertAtCaret(widget.controller, '\n'),
          onSend: widget.onSend,
          // The X (strip) and the dual-mode bottom key (exit tools) — forwarded
          // from the floating mount; null elsewhere, so other mounts unchanged.
          onClose: widget.onClose,
          typedText: widget.typedText,
          onExitTools: widget.onExitTools,
          onToggleSymbols: () =>
              setState(() => _showSymbols = !_showSymbols),
          // Globe toggles Hebrew<->English, landing on the letters layer.
          onLanguage: () => setState(() {
            _english = !_english;
            _showSymbols = false;
          }),
          // FLAGGED tool surface — controlled by the MOUNT via [showToolStrip].
          // When false (every current mount), this is a no-op overlay that
          // leaves the live keyboard unchanged. The prediction row now carries
          // the mount-supplied [predictions] (the live finder chips) and reports
          // taps via [onPrediction]; onTool routes each typed KbTool through the
          // single keyboard→app seam ([runKeyboardTool]).
          showToolStrip: widget.showToolStrip,
          // Strip highlight: a morph mount drives the active toggle via
          // [activeLayer]; otherwise the host's own [_toolLayer] decides.
          toolLayer: widget.activeLayer ?? _toolLayer,
          predictions: widget.predictions,
          // The destination subset → BsKeyboard tints those chips (nav glyph +
          // brand accent). Empty by default, so legacy mounts are unchanged.
          destinationChips: widget.destinationChips,
          onPrediction: widget.onPrediction,
          // Grid/gear: a morph mount overrides both toggles to push its
          // home/kbd node-list onto the drill stack; otherwise the host's
          // internal layer toggle runs (legacy mounts).
          onToolGrid: widget.onToolGrid ?? _onToolGrid,
          onToolGear: widget.onToolGear ?? _onToolGear,
          // STEP 4: a mount may override onTool (the card-keyboard sheet closes
          // itself first, then drives runKeyboardTool on the home's navigator);
          // with no override every existing mount keeps the step-2 default.
          onTool: widget.onTool ?? (t) => runKeyboardTool(ref, context, t),
          // STEP B morph path: forward the mount's pure tiles + drill controls.
          // Null tiles (every legacy mount) → BsKeyboard renders its letters/
          // [toolLayer] grid exactly as before.
          tiles: widget.tiles,
          onTile: widget.onTile,
          showBack: widget.showBack,
          onBack: widget.onBack,
        ),
      ),
    );
  }
}
