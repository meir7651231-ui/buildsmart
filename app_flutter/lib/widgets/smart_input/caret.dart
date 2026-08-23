// Caret-aware text insertion for the smart-input surface (Phase-2 live wiring).
//
// Mirrors `_insertText` in `lib/screens/chats_screen.dart` so the suggestion
// strip drops a phrase exactly where the chat composer's emoji picker does:
// at the caret (or replacing the selection), leaving the caret after the
// inserted text. Extracted as a free function so any field — not just the chat
// composer — can reuse the identical behaviour without touching the screen.

import 'package:flutter/widgets.dart';

/// Inserts [text] at the [controller]'s caret (or appends if the selection is
/// invalid), leaving the caret collapsed immediately after the inserted text.
///
/// When a range is selected, that range is replaced by [text]. Clears any
/// in-progress composing region so the IME state stays consistent.
void insertAtCaret(TextEditingController controller, String text) {
  final value = controller.value;
  final sel = value.selection;
  if (!sel.isValid) {
    controller.text = value.text + text;
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);
    return;
  }
  final newText = value.text.replaceRange(sel.start, sel.end, text);
  controller.value = value.copyWith(
    text: newText,
    selection: TextSelection.collapsed(offset: sel.start + text.length),
    composing: TextRange.empty,
  );
}

/// Deletes one user-perceived character (grapheme cluster) before the caret —
/// or the selected range if a range is selected. No-op when the caret is at
/// offset 0 with no selection. Mirrors [insertAtCaret]'s value/selection discipline.
void deleteBackward(TextEditingController controller) {
  final value = controller.value;
  final sel = value.selection;
  if (!sel.isValid) return;

  // Non-collapsed range → remove it, collapsing the caret to the range start.
  if (!sel.isCollapsed) {
    final newText = value.text.replaceRange(sel.start, sel.end, '');
    controller.value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: sel.start),
      composing: TextRange.empty,
    );
    return;
  }

  // Collapsed caret at offset 0 → nothing before it to delete.
  final caret = sel.start;
  if (caret <= 0) return;

  // Delete the single grapheme cluster immediately before the caret. Counting
  // by `characters` (not UTF-16 code units) keeps a Hebrew base letter + its
  // combining niqqud/point as one unit, so they disappear together.
  final before = value.text.substring(0, caret);
  final lastGrapheme = before.characters.last;
  final removeStart = caret - lastGrapheme.length;
  final newText = value.text.replaceRange(removeStart, caret, '');
  controller.value = value.copyWith(
    text: newText,
    selection: TextSelection.collapsed(offset: removeStart),
    composing: TextRange.empty,
  );
}
