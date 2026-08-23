// kEnglishRows — the English QWERTY letter layer.
//
// Asserts the three rows carry exactly the QWERTY letters in order, that every
// key is a plain letter (no Shift/tool kinds), and that there are 26 in total.

import 'package:buildsmart/widgets/smart_input/keyboard/english_layout.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/key_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Maps a row of [KbKey]s to the list of text each inserts on tap.
  List<String> outputs(List<KbKey> row) =>
      <String>[for (final k in row) k.effectiveOutput];

  test('row 1 is q..p', () {
    expect(
      outputs(kEnglishRows[0]),
      <String>['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    );
  });

  test('row 2 is a..l', () {
    expect(
      outputs(kEnglishRows[1]),
      <String>['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
    );
  });

  test('row 3 is z..m', () {
    expect(
      outputs(kEnglishRows[2]),
      <String>['z', 'x', 'c', 'v', 'b', 'n', 'm'],
    );
  });

  test('every key is a letter kind', () {
    for (final row in kEnglishRows) {
      for (final k in row) {
        expect(
          k.kind,
          KeyKind.letter,
          reason: 'key "${k.label}" should be KeyKind.letter',
        );
      }
    }
  });

  test('26 letters in total', () {
    final total = kEnglishRows.fold<int>(0, (sum, r) => sum + r.length);
    expect(total, 26);
  });
}
