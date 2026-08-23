// caret.dart — caret-aware insertion matches the chat composer's `_insertText`.
//
// Four behaviours: append when the selection is invalid; insert at a mid-text
// caret; replace a selected range; and in every case leave the caret collapsed
// immediately after the inserted text.

import 'package:buildsmart/widgets/smart_input/caret.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // No SharedPreferences in play here, but keep the harness style uniform
    // with the rest of the smart-input suite.
  });

  test('append when the selection is invalid', () {
    final c = TextEditingController(text: 'שלום');
    // A fresh controller's selection has offset -1 → invalid → append.
    expect(c.selection.isValid, isFalse);

    insertAtCaret(c, ' עולם');

    expect(c.text, 'שלום עולם');
    expect(c.selection.isCollapsed, isTrue);
    expect(c.selection.baseOffset, c.text.length); // caret after inserted text
  });

  test('insert at a mid-text caret', () {
    final c = TextEditingController(text: 'abcdef');
    // Collapsed caret between "abc" and "def".
    c.selection = const TextSelection.collapsed(offset: 3);

    insertAtCaret(c, 'XYZ');

    expect(c.text, 'abcXYZdef');
    expect(c.selection.isCollapsed, isTrue);
    expect(c.selection.baseOffset, 6); // 3 + 'XYZ'.length, after inserted text
  });

  test('replace a selection range', () {
    final c = TextEditingController(text: 'abcdef');
    // Select "cd" (indices 2..4).
    c.selection = const TextSelection(baseOffset: 2, extentOffset: 4);

    insertAtCaret(c, 'Z');

    expect(c.text, 'abZef');
    expect(c.selection.isCollapsed, isTrue);
    expect(c.selection.baseOffset, 3); // sel.start (2) + 'Z'.length (1)
  });

  test('caret ends after inserted text on an empty controller', () {
    final c = TextEditingController();
    c.selection = const TextSelection.collapsed(offset: 0);

    insertAtCaret(c, 'היי');

    expect(c.text, 'היי');
    expect(c.selection.isCollapsed, isTrue);
    expect(c.selection.baseOffset, c.text.length);
  });
}
