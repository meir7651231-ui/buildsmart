// BsKeyboardField — the DROP-IN text field that brings our keyboard with it.
//
// WHY THIS EXISTS (owner: "no device keyboard — only the app's keyboard"):
// suppressing the platform keyboard is TWO coupled edits (`readOnly:true` on the
// field + mounting a [BsKeyboardHost] wired to the SAME controller), and getting
// only the first one gives a field NOBODY can type into. `chats_screen` does that
// pair by hand — fine for one screen, but there are ~109 fields across ~52 files,
// and a dialog/sheet field has no bottom bar to dock a host into at all.
//
// So this widget owns BOTH halves behind ONE call site:
//   • it builds the [TextField] with `readOnly` driven by [useCustomKeyboard] —
//     the SAME shared predicate the host gates on, so the two can never disagree
//     (the split-brain the gate's own doc-comment warns about); and
//   • while the field holds focus it docks a [BsKeyboardHost] in the root
//     [Overlay], so it works identically from a screen body, a dialog or a
//     bottom sheet.
//
// STRICT PASSTHROUGH when the feature is off: with the flag OFF (every build that
// does not pass `--dart-define=SMART_INPUT=true`) — or with a screen reader active
// — [useCustomKeyboard] is false, `readOnly` stays false, NO overlay is ever
// inserted, and what renders is a plain [TextField] with the caller's own
// arguments. That is the zero-regression contract: same widget, same behaviour,
// device keyboard exactly as today.
//
// The overlay is inserted/removed from a focus listener (never during build), and
// is always removed in [dispose], so it cannot outlive the field.

import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_host.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/kb_field_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A [TextField] that uses the in-app [BsKeyboardHost] instead of the device
/// keyboard whenever [useCustomKeyboard] is true, and is a plain [TextField]
/// otherwise.
class BsKeyboardField extends ConsumerStatefulWidget {
  const BsKeyboardField({
    required this.controller,
    super.key,
    this.focusNode,
    this.decoration,
    this.style,
    this.cursorColor,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.onSubmitted,
    this.onChanged,
    this.showToolStrip = false,
  });

  /// The text being edited — the SAME controller the docked keyboard types into.
  final TextEditingController controller;

  /// Optional externally-owned focus node. When null one is created and disposed
  /// here (the common case at a call site that had none).
  final FocusNode? focusNode;

  final InputDecoration? decoration;
  final TextStyle? style;

  /// Caret colour. Load-bearing under this widget: with the feature ON the caret
  /// is the ONLY thing marking the edit position (the device keyboard is gone),
  /// so a call site that themed it must keep that theming.
  final Color? cursorColor;

  final TextAlign textAlign;
  final TextDirection? textDirection;
  final int? maxLines;
  final int? minLines;
  final bool autofocus;

  /// Fired by the keyboard's send/done key AND by a real submit — the caller
  /// decides what "done" means (run the search, save the name, …).
  final ValueChanged<String>? onSubmitted;

  final ValueChanged<String>? onChanged;

  /// Forwarded to [BsKeyboardHost] — whether the docked keyboard shows the tool
  /// strip. Default false: a plain typing field wants letters, not tools.
  final bool showToolStrip;

  @override
  ConsumerState<BsKeyboardField> createState() => _BsKeyboardFieldState();
}

class _BsKeyboardFieldState extends ConsumerState<BsKeyboardField> {
  FocusNode? _ownedFocus;
  OverlayEntry? _entry;

  FocusNode get _focus => widget.focusNode ?? (_ownedFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChanged);
    // Remove BEFORE the element goes away — an entry left in the overlay would
    // outlive this field and keep typing into a disposed controller.
    _removeKeyboard();
    _ownedFocus?.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!mounted) return;
    if (_focus.hasFocus) {
      _showKeyboard();
    } else {
      _removeKeyboard();
    }
  }

  /// Dock the keyboard in the ROOT overlay so it clears dialogs and sheets.
  void _showKeyboard() {
    if (_entry != null) return; // idempotent — focus can fire more than once
    if (!useCustomKeyboard(ref, context)) return; // OFF / a11y ⇒ OS keyboard
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return; // no overlay (bare test harness) — stay plain
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Material(
          color: Colors.transparent,
          child: BsKeyboardHost(
            controller: widget.controller,
            focusNode: _focus,
            onSend: _submit,
            onClose: _dismiss,
            typedText: widget.controller.text,
            showToolStrip: widget.showToolStrip,
          ),
        ),
      ),
    );
    overlay.insert(entry);
    _entry = entry;
  }

  void _removeKeyboard() {
    _entry?.remove();
    _entry = null;
  }

  void _submit() {
    widget.onSubmitted?.call(widget.controller.text);
    _dismiss();
  }

  /// Drop focus — the focus listener tears the overlay down.
  void _dismiss() => _focus.unfocus();

  @override
  Widget build(BuildContext context) {
    final custom = useCustomKeyboard(ref, context);
    // Rebuild the docked keyboard as the text changes so its predictions/typed
    // strip stay in sync; cheap because it only marks the one entry dirty.
    _entry?.markNeedsBuild();
    return TextField(
      controller: widget.controller,
      focusNode: _focus,
      // THE pair — both sides of the one shared decision.
      readOnly: custom,
      showCursor: custom ? true : null,
      decoration: widget.decoration,
      style: widget.style,
      cursorColor: widget.cursorColor,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
  }
}
