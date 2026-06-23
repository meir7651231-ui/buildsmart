// Unified card-keyboard engine (#38) — Phase 0 skeleton coverage.
//
// Asserts the verdict LADDER ([mergedKeys], build plan §1.2) routes correctly
// over the REAL union pool ([kDivePool]) + the REAL lexicon, and the
// [SignalChip] value/displayLabel split + equality. The merge rung is stubbed in
// Phase 0, so a large pool falls to the convergence floor ([CardShowProducts]) —
// that expectation flips to [MergedKeys] in Phase 2.

import 'package:buildsmart/features/card_keyboard/card_engine.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show
        NewbieStep,
        distinctCardCount,
        distinctProducts,
        kShowProductsThreshold;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show WordLexicon, buildWordLexicon;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final WordLexicon lexicon = buildWordLexicon(kDivePool);

  // A dummy answered step. The ladder reads only the stack's EMPTINESS; the pool
  // is already narrowed by the caller, so this step's predicate is irrelevant to
  // the verdict — it just makes the stack non-empty (past rung 1).
  NewbieStep step() => NewbieStep(
        axisLabel: 'גודל',
        chipLabel: 'x',
        predicate: (_) => true,
        crumbWord: 'x',
      );

  group('mergedKeys verdict ladder (Phase 0)', () {
    test('empty stack → CardAskWords (top words by frequency)', () {
      final v = mergedKeys(kDivePool, const <NewbieStep>[], lexicon, null);
      expect(v, isA<CardAskWords>());
      final w = v as CardAskWords;
      expect(w.words, isNotEmpty);
      expect(w.words.length, lessThanOrEqualTo(24));
      expect(w.questionHe, isNotEmpty);
    });

    test('single distinct card → CardResolve', () {
      final pool = distinctProducts(kDivePool).take(1).toList();
      expect(distinctCardCount(pool), 1, reason: 'sanity: one distinct card');
      final v = mergedKeys(pool, [step()], lexicon, null);
      expect(v, isA<CardResolve>());
      expect((v as CardResolve).product, pool.first);
    });

    test('small pool (≤ threshold) → CardShowProducts', () {
      final small = distinctProducts(kDivePool).take(5).toList();
      expect(
        distinctCardCount(small),
        lessThanOrEqualTo(kShowProductsThreshold),
      );
      expect(distinctCardCount(small), greaterThan(1));
      final v = mergedKeys(small, [step()], lexicon, null);
      expect(v, isA<CardShowProducts>());
      expect((v as CardShowProducts).products, isNotEmpty);
    });

    test('large pool, merge stubbed → CardShowProducts floor (Phase 0)', () {
      // The full pool has many distinct cards (> threshold), so the ladder
      // reaches the merge rung. In Phase 0 the merge is stubbed to empty, so it
      // falls to the convergence floor. Phase 2 makes this rung return
      // MergedKeys — this expectation changes then.
      expect(
        distinctCardCount(kDivePool),
        greaterThan(kShowProductsThreshold),
      );
      final v = mergedKeys(kDivePool, [step()], lexicon, null);
      expect(
        v,
        isA<CardShowProducts>(),
        reason: 'Phase 0: empty merge → floor; Phase 2 → MergedKeys',
      );
    });

    test('deterministic — same inputs, same verdict shape', () {
      final a = mergedKeys(kDivePool, [step()], lexicon, null);
      final b = mergedKeys(kDivePool, [step()], lexicon, null);
      expect(a.runtimeType, b.runtimeType);
    });
  });

  group('SignalChip', () {
    test('value/displayLabel split + value-equality', () {
      const a = SignalChip(
        axisId: 'size',
        value: 'DN15',
        displayLabel: '1/2"',
        axisName: 'גודל',
      );
      const b = SignalChip(
        axisId: 'size',
        value: 'DN15',
        displayLabel: '1/2"',
        axisName: 'גודל',
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a.value, isNot(a.displayLabel),
          reason: 'size axis: predicate key ≠ rendered label');

      const word =
          SignalChip(axisId: 'word', value: 'ברז', displayLabel: 'ברז');
      expect(word.value, word.displayLabel,
          reason: 'word axis: key == render');
      expect(word.soft, isFalse, reason: 'an emitted key is never soft');
    });
  });
}
