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

import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/caret.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/kb_field_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  const BsKeyboardHost({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
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

  @override
  Widget build(BuildContext context) {
    // GATE: feature OFF or screen reader active → render nothing; the OS
    // keyboard handles input instead.
    final use = useCustomKeyboard(ref, context);
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
        ),
      ),
    );
  }
}
