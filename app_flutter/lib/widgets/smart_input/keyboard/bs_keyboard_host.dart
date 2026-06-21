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

  const BsKeyboardHost({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    this.showToolStrip = false,
    this.predictions = const <String>[],
    this.onPrediction,
    this.onTool,
    this.forceShow = false,
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
        color: BsTokens.surfaceMid,
        child: BsKeyboard(
          showSymbols: _showSymbols,
          english: _english,
          onKey: (ch) => insertAtCaret(widget.controller, ch),
          onBackspace: () => deleteBackward(widget.controller),
          onEnter: () => insertAtCaret(widget.controller, '\n'),
          onSend: widget.onSend,
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
          toolLayer: _toolLayer,
          predictions: widget.predictions,
          onPrediction: widget.onPrediction,
          onToolGrid: _onToolGrid,
          onToolGear: _onToolGear,
          // STEP 4: a mount may override onTool (the card-keyboard sheet closes
          // itself first, then drives runKeyboardTool on the home's navigator);
          // with no override every existing mount keeps the step-2 default.
          onTool: widget.onTool ?? (t) => runKeyboardTool(ref, context, t),
        ),
      ),
    );
  }
}
