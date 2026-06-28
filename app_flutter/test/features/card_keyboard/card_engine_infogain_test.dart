// P7.64: mergedKeys stamps SignalChip.infoGain = n - distinctCardCount(narrowed)
// on each emitted chip, WITHOUT changing the chip order (infoGain is excluded from
// ==/hashCode). Drives the engine directly over a seeded pool.

import 'package:buildsmart/features/card_keyboard/card_engine.dart';
import 'package:buildsmart/features/card_keyboard/pool_seed.dart'
    show seedPool, seedStep;
import 'package:buildsmart/features/card_keyboard/seed_sources.dart'
    show materialSeeds;
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show buildWordLexicon;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lex = buildWordLexicon(kDivePool);
  final copper =
      materialSeeds(kDivePool).firstWhere((s) => s.displayLabel == 'נחושת');
  final pool = seedPool(copper, kDivePool);
  final stack = [seedStep(copper)];

  test('mergedKeys stamps infoGain on every chip — at least one narrows', () {
    final v = mergedKeys(pool, stack, lex, null);
    expect(v, isA<MergedKeys>());
    final chips = (v as MergedKeys).chips;
    expect(chips, isNotEmpty);
    for (final c in chips) {
      expect(c.infoGain, greaterThanOrEqualTo(0));
    }
    expect(chips.any((c) => c.infoGain > 0), isTrue,
        reason: 'a kept axis splits, so some chip has a positive gain');
  });

  test('infoGain leaves the chip ORDER untouched (deterministic)', () {
    final a = mergedKeys(pool, stack, lex, null) as MergedKeys;
    final b = mergedKeys(pool, stack, lex, null) as MergedKeys;
    expect(a.chips.map((c) => c.displayLabel).toList(),
        b.chips.map((c) => c.displayLabel).toList());
  });
}
