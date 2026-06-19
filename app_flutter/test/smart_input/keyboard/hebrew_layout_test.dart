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

  test('Bottom row kinds are send, symbols, language, space, period, enter', () {
    expect(
      kBottomRow.map((k) => k.kind).toList(),
      <KeyKind>[
        KeyKind.send,
        KeyKind.symbols,
        KeyKind.language,
        KeyKind.space,
        KeyKind.period,
        KeyKind.enter,
      ],
    );
  });

  test('Space outputs a space and is wide; period outputs a dot', () {
    final space = kBottomRow.firstWhere((k) => k.kind == KeyKind.space);
    expect(space.effectiveOutput, ' ');
    expect(space.flex, greaterThan(1));

    final period = kBottomRow.firstWhere((k) => k.kind == KeyKind.period);
    expect(period.effectiveOutput, '.');
  });

  test('KeyKind has no shift member (Hebrew has no shift/caps)', () {
    // Guard: the frozen API must never grow a `shift` key. If this list ever
    // changes, the layout contract has been broken.
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
