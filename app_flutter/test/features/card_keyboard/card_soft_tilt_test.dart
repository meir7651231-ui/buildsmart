// P9.84: softTilt is woven into _mergedChips as a WITHIN-axis tie-break near convergence.
// It must (a) never inject a soft chip — every merged key stays a hard axis key, (b) keep
// the row byte-stable under pool shuffle (the soft sort is stable on the helper order), and
// (c) stay deterministic (pure). Byte-identity of the wide-open row is covered by the p1
// golden; here we guard the soft layer does not break those invariants.
//
// Swarm-review (high): these used an EMPTY stack → mergedKeys short-circuits to CardAskWords
// BEFORE _mergedChips runs, so the `is MergedKeys` guards were vacuous and the soft path was
// never actually exercised. They now drive a non-empty stack AND pin pools where the soft
// anchor genuinely engages (distinctCardCount in the (threshold, kNearConvergence] window),
// then assert MergedKeys so the guard can never silently skip.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/features/card_keyboard/card_engine.dart';
import 'package:buildsmart/features/card_keyboard/soft_signals.dart'
    show softAnchor;
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show NewbieStep;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show buildWordLexicon;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lex = buildWordLexicon(kDivePool);
  final stack = [
    NewbieStep(
      axisLabel: 'seed',
      chipLabel: 'seed',
      crumbWord: 'seed',
      predicate: (_) => true,
    ),
  ];

  test('soft tilt is byte-stable under pool shuffle, WITH the anchor engaged', () {
    // Pools that BOTH engage the soft anchor and still merge chips (distinct-card count
    // above the show-products threshold yet within the soft window). Proves the shuffle
    // stability on the path the old empty-stack test never reached.
    final anchored = <List<LipskeyCatalogProduct>>[];
    for (var k = 2; k <= kDivePool.length && anchored.length < 3; k++) {
      final p = kDivePool.take(k).toList();
      if (softAnchor(p) != null && mergedKeys(p, stack, lex, null) is MergedKeys) {
        anchored.add(p);
      }
    }
    expect(anchored, isNotEmpty,
        reason: 'a pool that engages the anchor AND merges must exist (non-vacuous)');
    for (final pool in anchored) {
      final a = mergedKeys(pool, stack, lex, null) as MergedKeys;
      final b = mergedKeys(pool.reversed.toList(), stack, lex, null);
      expect(b, isA<MergedKeys>(), reason: 'the shuffle keeps it merged');
      expect((b as MergedKeys).chips, a.chips,
          reason: 'soft tilt must be shuffle-stable with the anchor active');
    }
  });

  test('soft signals never inject a soft chip — every merged key is a hard axis key',
      () {
    final v = mergedKeys(kDivePool.take(60).toList(), stack, lex, null);
    expect(v, isA<MergedKeys>());
    expect((v as MergedKeys).chips.every((c) => !c.soft), isTrue);
  });

  test('mergedKeys is deterministic (pure) including the soft layer', () {
    final pool = kDivePool.take(16).toList();
    final a = mergedKeys(pool, stack, lex, null);
    final b = mergedKeys(pool, stack, lex, null);
    expect(a, isA<MergedKeys>());
    expect((a as MergedKeys).chips, (b as MergedKeys).chips);
  });
}
