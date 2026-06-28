// P9.84: softTilt is woven into _mergedChips as a WITHIN-axis tie-break near convergence.
// It must (a) never inject a soft chip — every merged key stays a hard axis key, (b) keep
// the row byte-stable under pool shuffle (the soft sort is stable on the helper order), and
// (c) stay deterministic (pure). Byte-identity of the wide-open row is covered by the p1
// golden; here we guard the soft layer does not break those invariants.

import 'package:buildsmart/features/card_keyboard/card_engine.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show buildWordLexicon;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lex = buildWordLexicon(kDivePool);

  test('soft tilt preserves byte-stability under pool shuffle', () {
    for (final n in [14, 16, 40, 200]) {
      final pool = kDivePool.take(n).toList();
      final a = mergedKeys(pool, const [], lex, null);
      final b = mergedKeys(pool.reversed.toList(), const [], lex, null);
      expect(a.runtimeType, b.runtimeType, reason: 'same verdict kind at n=$n');
      if (a is MergedKeys && b is MergedKeys) {
        expect(b.chips, a.chips, reason: 'soft tilt must be shuffle-stable at n=$n');
      }
    }
  });

  test('soft signals never inject a soft chip — every merged key is a hard axis key',
      () {
    final v = mergedKeys(kDivePool.take(60).toList(), const [], lex, null);
    if (v is MergedKeys) {
      expect(v.chips.every((c) => !c.soft), isTrue);
    }
  });

  test('mergedKeys is deterministic (pure) including the soft layer', () {
    final pool = kDivePool.take(16).toList();
    final a = mergedKeys(pool, const [], lex, null);
    final b = mergedKeys(pool, const [], lex, null);
    expect(a.runtimeType, b.runtimeType);
    if (a is MergedKeys && b is MergedKeys) {
      expect(a.chips, b.chips);
    }
  });
}
