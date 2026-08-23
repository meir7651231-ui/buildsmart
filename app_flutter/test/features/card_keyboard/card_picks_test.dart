// P10.92: the pick basket — addPick dedups by sku and preserves order; canCompleteLine
// turns true at >=2 picks; CardPick identity is the sku.

import 'package:buildsmart/features/card_keyboard/card_picks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('addPick appends, dedups by sku, and preserves order', () {
    final n = CardPicksNotifier();
    expect(n.state, isEmpty);
    expect(n.canCompleteLine, isFalse);

    n
      ..addPick(const CardPick(sku: 'A', label: 'a'))
      ..addPick(const CardPick(sku: 'B', label: 'b'))
      ..addPick(const CardPick(sku: 'A', label: 'a-again')); // dup sku → ignored

    expect(n.state.map((p) => p.sku).toList(), ['A', 'B']);
    expect(n.canCompleteLine, isTrue);
  });

  test('removePick drops by sku; clear empties the line', () {
    final n = CardPicksNotifier()
      ..addPick(const CardPick(sku: 'A', label: 'a'))
      ..addPick(const CardPick(sku: 'B', label: 'b'))
      ..removePick('A');
    expect(n.state.map((p) => p.sku).toList(), ['B']);
    expect(n.canCompleteLine, isFalse);
    n.clear();
    expect(n.state, isEmpty);
  });

  test('CardPick identity is the sku — the label never splits a pick', () {
    const a = CardPick(sku: 'A', label: 'x');
    const b = CardPick(sku: 'A', label: 'y');
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
}
