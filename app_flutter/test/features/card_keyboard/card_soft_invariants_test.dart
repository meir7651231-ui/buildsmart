// P9.91: the soft-signal isolation invariants. The soft layer (softTilt + softAnchor +
// history) only RE-ORDERS chips within an axis near convergence — it never injects a soft
// chip, never moves a chip across axes, and never adds or drops one. (Flag-OFF byte-
// identity is the p1 golden's job; here we fence the soft layer itself.)

import 'package:buildsmart/features/card_keyboard/card_engine.dart';
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

  test('soft signals never inject a soft chip — every key is a hard axis key', () {
    for (final n in [40, 80, 200]) {
      final v = mergedKeys(kDivePool.take(n).toList(), stack, lex, null);
      if (v is MergedKeys) {
        expect(v.chips.every((c) => !c.soft), isTrue, reason: 'n=$n');
      }
    }
  });

  test('soft tilt re-orders WITHIN an axis — axis blocks stay contiguous', () {
    final pool = kDivePool.take(60).toList();
    final v = mergedKeys(pool, stack, lex, null,
        historySkus: {pool.first.sku, pool.last.sku});
    if (v is MergedKeys) {
      final started = <String>{};
      String? prev;
      for (final c in v.chips) {
        if (c.axisId != prev) {
          expect(started.contains(c.axisId), isFalse,
              reason: 'axis ${c.axisId} is split — the soft layer crossed axes');
          started.add(c.axisId);
          prev = c.axisId;
        }
      }
    }
  });

  test('history never changes the chip SET — a tie-break, never a filter', () {
    final pool = kDivePool.take(60).toList();
    final base = mergedKeys(pool, stack, lex, null);
    final hist = mergedKeys(pool, stack, lex, null,
        historySkus: {pool.first.sku, pool[5].sku, pool.last.sku});
    if (base is MergedKeys && hist is MergedKeys) {
      expect(hist.chips.toSet(), base.chips.toSet());
    }
  });
}
