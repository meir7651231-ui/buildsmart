import 'package:buildsmart/features/card_keyboard/card_signals.dart'
    show sourcesFor;
import 'package:buildsmart/features/card_keyboard/pool_seed.dart';
import 'package:buildsmart/features/card_keyboard/seed_sources.dart'
    show materialSeeds, wordSeeds;
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show buildWordLexicon;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lex = buildWordLexicon(kDivePool);

  test('seedStep keeps the seed predicate — same admitted skus', () {
    final seed =
        materialSeeds(kDivePool).firstWhere((s) => s.displayLabel == 'נחושת');
    final step = seedStep(seed);
    final viaStep = kDivePool.where(step.predicate).map((p) => p.sku).toSet();
    final viaPool = seedPool(seed, kDivePool).map((p) => p.sku).toSet();
    expect(viaStep, viaPool, reason: 'the step and the pool admit the same set');
    expect(viaStep, isNotEmpty);
  });

  test('every mouth produces a step on the SINGLE opening axis', () {
    for (final seed in [...wordSeeds(lex), ...materialSeeds(kDivePool)]) {
      expect(seedStep(seed).axisLabel, kOpeningSeedAxis);
    }
  });

  test('the opening seed axis is a non-signal sentinel', () {
    final signalAxes = sourcesFor(null).map((s) => s.axisName).toSet();
    expect(signalAxes.contains(kOpeningSeedAxis), isFalse,
        reason: 'a seed must not pre-answer a real axis');
  });

  test('seedPool never invents — every result is a universe product', () {
    final poolSkus = kDivePool.map((p) => p.sku).toSet();
    final seed = wordSeeds(lex).first;
    for (final p in seedPool(seed, kDivePool)) {
      expect(poolSkus.contains(p.sku), isTrue);
    }
  });
}
