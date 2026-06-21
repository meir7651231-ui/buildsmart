// 🃏 floating_card_keyboard — the PERSISTENT floating card-keyboard panel.
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
// Differences from the deleted modal sheet:
//   • No modal route. [HomeShell] mounts this directly in its body Stack (gated
//     by [kKeyboardToolStrip] + [keyboardOverlayOpenProvider]).
//   • The drag handle becomes a real CLOSE affordance: a down-chevron that sets
//     [keyboardOverlayOpenProvider] to false (there is no route to pop).
//   • `onTool` must NOT pop a route (there is none). It closes the overlay (sets
//     the provider false) THEN runs [runKeyboardTool] with THIS widget's own
//     ref/context — both stay valid because the home stays mounted underneath.
//   • A Material/Container with rounded-top corners + a subtle top shadow gives
//     it the lifted "floating keyboard" look in place of the sheet chrome.
//
// Only the PURE [cardKeyboardPredictions] helper is imported from
// card_keyboard_sheet.dart — never a widget (the modal widget is deleted).

import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show WordLexicon, buildWordLexicon;
import 'package:buildsmart/screens/card_keyboard_sheet.dart'
    show cardKeyboardPredictions;
import 'package:buildsmart/screens/keyboard_tool_actions.dart'
    show runKeyboardTool;
import 'package:buildsmart/state/keyboard_overlay.dart'
    show keyboardOverlayOpenProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/caret.dart' show insertAtCaret;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart'
    show KbTool;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_host.dart'
    show BsKeyboardHost;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The persistent floating card-keyboard panel: a read-only field driven by the
/// custom keyboard, with a LIVE prediction row recomputed from the field text on
/// every change. Self-contained and crash-safe: the controller/focus are owned
/// here; this widget's own `ref`/`context` drive tool navigation (the home stays
/// mounted under the overlay, so they stay valid).
class FloatingCardKeyboard extends ConsumerStatefulWidget {
  const FloatingCardKeyboard({super.key});

  @override
  ConsumerState<FloatingCardKeyboard> createState() =>
      _FloatingCardKeyboardState();
}

class _FloatingCardKeyboardState extends ConsumerState<FloatingCardKeyboard> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  /// Lexicon built ONCE from the dive pool (pure + deterministic); reused for
  /// every keystroke's recompute so we never rebuild it per change.
  late final WordLexicon _lexicon;

  /// The current prediction-row chips (LIVE: recomputed from `_controller.text`).
  late List<String> _preds;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focus = FocusNode();
    _lexicon = buildWordLexicon(kDivePool);
    _preds = cardKeyboardPredictions('', kDivePool, _lexicon);
    _controller.addListener(_recompute);
  }

  /// Recompute the prediction row from the field text. Cheap (pure pool filter +
  /// engine verdict); guarded by `mounted` so a late listener tick after dispose
  /// can never `setState` on a defunct element.
  void _recompute() {
    if (!mounted) return;
    final next = cardKeyboardPredictions(_controller.text, kDivePool, _lexicon);
    setState(() => _preds = next);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_recompute)
      ..dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Append a tapped chip (+ a trailing space) at the caret to narrow further;
  /// the controller listener then recomputes the row. [insertAtCaret] leaves the
  /// caret collapsed after the inserted text (and appends when no selection).
  void _onPrediction(String chip) {
    insertAtCaret(_controller, '$chip ');
  }

  /// Close the floating overlay (no route to pop — flip the provider instead).
  void _close() {
    ref.read(keyboardOverlayOpenProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    // A floating panel (rounded-top Material + a subtle top shadow), NOT a modal
    // sheet. SafeArea(top:false) keeps the home-indicator inset clear; the host
    // adds its own bottom SafeArea too, which is harmless (nested insets clamp).
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
              // The assembled keyboard-with-tools, fed the LIVE finder chips.
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
                // Close the overlay FIRST (no route to pop), then navigate on
                // THIS widget's own ref/context — both stay valid because the
                // home stays mounted under the floating panel.
                onTool: (KbTool t) {
                  _close();
                  runKeyboardTool(ref, context, t);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
