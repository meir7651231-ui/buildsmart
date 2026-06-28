// P9.85: near-convergence chips that land directly on a single product are tagged
// isDestination (#41 — a visual accent distinguishing a destination from a further
// filter). It is RENDER-ONLY: excluded from ==/hashCode (so it never changes chip
// identity, the row order, or any golden) and absent on a wide pool (no destinations
// until convergence).

import 'package:buildsmart/features/card_keyboard/card_engine.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show buildWordLexicon;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lex = buildWordLexicon(kDivePool);

  test('a wide pool tags NO destination chip (only near convergence)', () {
    final v = mergedKeys(kDivePool.take(200).toList(), const [], lex, null);
    if (v is MergedKeys) {
      expect(v.chips.any((c) => c.isDestination), isFalse);
    }
  });

  test('isDestination is a render-only accent — EXCLUDED from == / hashCode', () {
    const a = SignalChip(axisId: 'x', value: 'v', displayLabel: 'v');
    final b = a.withInfoGain(3, isDestination: true);
    expect(b.isDestination, isTrue);
    expect(a, b, reason: 'a destination accent must not change chip identity');
    expect(a.hashCode, b.hashCode);
  });
}
