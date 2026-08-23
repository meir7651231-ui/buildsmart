import 'package:buildsmart/widgets/smart_input/keyboard/hebrew_layout.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/key_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Row 1 effectiveOutputs are the approved punct + 8 letters', () {
    expect(
      kHebrewRows[0].map((k) => k.effectiveOutput).toList(),
      <String>['־', '׳', 'ק', 'ר', 'א', 'ט', 'ו', 'ן', 'ם', 'פ'],
    );
  });

  test('Row 2 effectiveOutputs are the approved 10 letters', () {
    expect(
      kHebrewRows[1].map((k) => k.effectiveOutput).toList(),
      <String>['ש', 'ד', 'ג', 'כ', 'ע', 'י', 'ח', 'ל', 'ך', 'ף'],
    );
  });

  test('Row 3 effectiveOutputs are the approved 9 letters (no backspace)', () {
    expect(
      kHebrewRows[2].map((k) => k.effectiveOutput).toList(),
      <String>['ז', 'ס', 'ב', 'ה', 'נ', 'מ', 'צ', 'ת', 'ץ'],
    );
  });

  test('27 letters across the rows (22 base + 5 finals)', () {
    final letters = kHebrewRows
        .expand((row) => row)
        .where((k) => k.kind == KeyKind.letter)
        .length;
    expect(letters, 27);
  });

  test('Bottom row kinds are send, symbols, language, space, enter', () {
    // The period key was removed per owner request (a search/nav keyboard does
    // not need a near-empty '.'); the bottom row is now five keys.
    expect(
      kBottomRow.map((k) => k.kind).toList(),
      <KeyKind>[
        KeyKind.send,
        KeyKind.symbols,
        KeyKind.language,
        KeyKind.space,
        KeyKind.enter,
      ],
    );
  });

  test('Space outputs a space and is wide', () {
    final space = kBottomRow.firstWhere((k) => k.kind == KeyKind.space);
    expect(space.effectiveOutput, ' ');
    expect(space.flex, greaterThan(1));
  });

  test('KeyKind has no shift member (Hebrew has no shift/caps)', () {
    // Guard: the frozen API must never grow a `shift` key (Hebrew has no caps).
    // `gear` was added intentionally (the bottom-row keyboard-tools launcher that
    // moved out of the strip in the owner mobile redesign) — it is a legitimate
    // member, listed here; the real contract this guards is the ABSENCE of shift.
    expect(
      KeyKind.values.map((k) => k.name).toList(),
      <String>[
        'letter',
        'backspace',
        'enter',
        'space',
        'symbols',
        'language',
        'send',
        'period',
        'punct',
        'gear',
      ],
    );
    expect(KeyKind.values.any((k) => k.name == 'shift'), isFalse);
  });

  test('Symbols layer first row outputs the digits 1..0', () {
    expect(
      kSymbolsRows[0].map((k) => k.effectiveOutput).toList(),
      <String>['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    );
  });
}
