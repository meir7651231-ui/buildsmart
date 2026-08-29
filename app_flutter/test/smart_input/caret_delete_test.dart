// caret_delete_test.dart — grapheme-safe backspace for the smart-input surface.
//
// Five behaviours: delete one grapheme before a caret at end; delete one
// grapheme before a mid-text caret; remove a selected range (caret collapses
// to range start); no-op at offset 0; and treat a Hebrew base letter plus its
// combining point as a SINGLE deletable unit (not one UTF-16 code unit).

import 'package:buildsmart/widgets/smart_input/caret.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('delete the grapheme before a caret at end', () {
    final c = TextEditingController(text: 'שלום');
    c.selection = const TextSelection.collapsed(offset: 4);

    deleteBackward(c);

    expect(c.text, 'שלו');
    expect(c.selection.isCollapsed, isTrue);
    expect(c.selection.baseOffset, 3);
  });

  test('delete the grapheme before a mid-text caret', () {
    final c = TextEditingController(text: 'שלום');
    // Caret between "של" and "ום" → deletes 'ל' (the grapheme before offset 2).
    c.selection = const TextSelection.collapsed(offset: 2);

    deleteBackward(c);

    expect(c.text, 'שום');
    expect(c.selection.isCollapsed, isTrue);
    expect(c.selection.baseOffset, 1);
  });

  test('remove a selected range, caret collapses to range start', () {
    final c = TextEditingController(text: 'שלום');
    // Select offsets 1..3 ("לו").
    c.selection = const TextSelection(baseOffset: 1, extentOffset: 3);

    deleteBackward(c);

    expect(c.text, 'שם');
    expect(c.selection.isCollapsed, isTrue);
    expect(c.selection.baseOffset, 1);
  });

  test('no-op when the caret is at offset 0', () {
    final c = TextEditingController(text: 'שלום');
    c.selection = const TextSelection.collapsed(offset: 0);

    deleteBackward(c);

    expect(c.text, 'שלום'); // unchanged
    expect(c.selection.baseOffset, 0);
  });

  test('a Hebrew letter + combining point deletes as one grapheme', () {
    // 'בְ' = ב (U+05D1) + sheva (U+05B0): two UTF-16 code units, one grapheme.
    const bet = 'ב';
    const sheva = 'ְ';
    final c = TextEditingController(text: 'ש$bet$sheva');
    // Sanity: the niqqud-bearing letter spans two code units.
    expect(c.text.length, 3);
    c.selection = TextSelection.collapsed(offset: c.text.length);

    deleteBackward(c);

    // Both the base letter and its point are gone — only 'ש' remains.
    expect(c.text, 'ש');
    expect(c.selection.isCollapsed, isTrue);
    expect(c.selection.baseOffset, 1);
  });
}
