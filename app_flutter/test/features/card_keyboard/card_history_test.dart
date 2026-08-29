// P9.88: the engine takes an optional identity-scoped historySkus set that feeds
// softTilt's history signal. Empty history (the default, an anchorless or fresh card) is
// byte-identical to no history at all, and history is a TIE-BREAK — it never adds or
// drops a chip. Cross-identity isolation is the recentlyViewedProvider's job (it
// namespaces by uid when the flag is on) and is covered by its own tests.

import 'package:buildsmart/features/card_keyboard/card_engine.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show NewbieStep;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show buildWordLexicon;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lex = buildWordLexicon(kDivePool);
  // One no-op dive step so mergedKeys reaches the merge rung (an empty stack returns
  // CardAskWords).
  final stack = [
    NewbieStep(
      axisLabel: 'seed',
      chipLabel: 'seed',
      crumbWord: 'seed',
      predicate: (_) => true,
    ),
  ];
  final pool = kDivePool.take(60).toList();

  // (Empty history == the default is the byte-identity guarantee — covered by the p1
  // golden, which calls mergedKeys with no historySkus.)

  test('a history-tilted row is deterministic (pure)', () {
    final hist = {pool.first.sku, pool.last.sku};
    final a = mergedKeys(pool, stack, lex, null, historySkus: hist);
    final b = mergedKeys(pool, stack, lex, null, historySkus: hist);
    expect(a.runtimeType, b.runtimeType);
    if (a is MergedKeys && b is MergedKeys) {
      expect(a.chips, b.chips);
    }
  });

  test('history never adds or drops a chip — it is a tie-break only', () {
    final base = mergedKeys(pool, stack, lex, null);
    final withHist = mergedKeys(pool, stack, lex, null,
        historySkus: {pool.first.sku, pool.last.sku, pool[10].sku});
    expect(withHist.runtimeType, base.runtimeType);
    if (base is MergedKeys && withHist is MergedKeys) {
      expect(withHist.chips.toSet(), base.chips.toSet());
    }
  });
}
