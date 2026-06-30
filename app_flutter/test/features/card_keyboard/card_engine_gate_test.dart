// P7.67: the HARD ≤6 turn gate. mergedKeys stops asking by turn (kMaxDiveTurns - 1)
// and shows the scan-list, so the dive can NEVER exceed the contract — a STRUCTURAL
// guarantee on top of the empirical census (max depth 4).

import 'package:buildsmart/features/card_keyboard/card_engine.dart';
import 'package:buildsmart/features/card_keyboard/decisions.dart'
    show kMaxDiveTurns, kMaxQuestions;
import 'package:buildsmart/features/card_keyboard/pool_seed.dart' show seedPool;
import 'package:buildsmart/features/card_keyboard/seed_sources.dart'
    show materialSeeds;
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show NewbieStep;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show buildWordLexicon;
import 'package:flutter_test/flutter_test.dart';

NewbieStep _dummy(int i) => NewbieStep(
      axisLabel: '_t$i',
      chipLabel: 'x',
      crumbWord: 'x',
      predicate: (_) => true,
    );

void main() {
  final lex = buildWordLexicon(kDivePool);
  // A large pool (> the scan threshold) so the ladder would normally keep asking.
  final pool = seedPool(
    materialSeeds(kDivePool).firstWhere((s) => s.displayLabel == 'נחושת'),
    kDivePool,
  );

  test('kMaxDiveTurns is the same ceiling as kMaxQuestions', () {
    expect(kMaxDiveTurns, kMaxQuestions);
  });

  test('AT the gate, a large pool shows the list — no more questions', () {
    final stack = [for (var i = 0; i < kMaxDiveTurns - 1; i++) _dummy(i)];
    final v = mergedKeys(pool, stack, lex, null);
    expect(v, isA<CardShowProducts>(),
        reason: 'past the gate the dive scans, never asks again');
  });

  test('BELOW the gate, a large pool still asks (MergedKeys)', () {
    final v = mergedKeys(pool, [_dummy(0)], lex, null);
    expect(v, isA<MergedKeys>(),
        reason: 'with turns to spare, keep narrowing');
  });
}
