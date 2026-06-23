// Unified card-keyboard engine (#38) — Phase 0 skeleton coverage.
//
// Asserts the verdict LADDER ([mergedKeys], build plan §1.2) routes correctly
// over the REAL union pool ([kDivePool]) + the REAL lexicon, and the
// [SignalChip] value/displayLabel split + equality. The merge rung is stubbed in
// Phase 0, so a large pool falls to the convergence floor ([CardShowProducts]) —
// that expectation flips to [MergedKeys] in Phase 2.

import 'dart:math' show Random;

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

    test('large pool → MergedKeys (Phase 2 live merge: ranked row)', () {
      expect(
        distinctCardCount(kDivePool),
        greaterThan(kShowProductsThreshold),
      );
      final v = mergedKeys(kDivePool, [step()], lexicon, null);
      expect(v, isA<MergedKeys>(),
          reason: 'Phase 2: the live merge produces chips for a large pool');
      final chips = (v as MergedKeys).chips;
      expect(chips, isNotEmpty);
      expect(chips.length, lessThanOrEqualTo(kMergedKeyCap),
          reason: 'capped at kMergedKeyCap');
      expect(chips.every((c) => !c.soft), isTrue,
          reason: 'every merged key is a hard-axis chip (soft re-weight only)');
      // Per-axis FLOOR: each represented axis carries ≥ kMergedAxisFloor chips
      // (no lonely single-chip axis is laid out).
      final byAxis = <String, int>{};
      for (final c in chips) {
        byAxis[c.axisId] = (byAxis[c.axisId] ?? 0) + 1;
      }
      for (final e in byAxis.entries) {
        expect(e.value, greaterThanOrEqualTo(kMergedAxisFloor),
            reason: 'axis ${e.key} must carry ≥ floor chips');
      }
    });

    test('merged row is byte-stable under ARBITRARY pool shuffle (incl. word)',
        () {
      // The merged row must be identical regardless of pool order. The axis
      // RANKING is order-free (integer cross-multiply over set-counts); the WORD
      // axis — wordOptions' equal-count tie-break, the one order-sensitive helper
      // — is now canonicalised by WordSignal.chipsFor (sku-sort), so the
      // guarantee is TOTAL, not just under reversal (swarm R2). Answer SIZE so the
      // WORD axis surfaces in the row, then drive several SEEDED shuffles.
      final s = NewbieStep(
        axisLabel: 'גודל',
        chipLabel: 'x',
        predicate: (_) => true,
        crumbWord: 'x',
      );
      String key(CardVerdict v) => v is MergedKeys
          ? v.chips.map((c) => '${c.axisId}:${c.value}').join('|')
          : v.runtimeType.toString();
      final base = mergedKeys(kDivePool, [s], lexicon, null);
      expect(base, isA<MergedKeys>());
      final want = key(base);
      for (final seed in [1, 7, 42, 99, 1234]) {
        final shuffled = [...kDivePool]..shuffle(Random(seed));
        expect(key(mergedKeys(shuffled, [s], lexicon, null)), want,
            reason: 'byte-stable merged row under shuffle seed=$seed');
      }
    });

    test('single product never throws', () {
      final one = distinctProducts(kDivePool).take(1).toList();
      expect(() => mergedKeys(one, [step()], lexicon, null), returnsNormally);
    });

    test('empty pool → CardShowProducts(empty) — the dead-end the screen guards',
        () {
      // An over-narrowed (empty) pool: rung-3 returns CardShowProducts with an
      // empty list (swarm R1 — the screen now renders an empty-state for it
      // instead of a bare header).
      final v = mergedKeys([], [step()], lexicon, null);
      expect(v, isA<CardShowProducts>());
      expect((v as CardShowProducts).products, isEmpty);
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

  group('representativeTake (dense-axis buckets, §1.4 #11)', () {
    List<SignalChip> sizes(int n) => <SignalChip>[
          for (var i = 0; i < n; i++)
            SignalChip(axisId: 'size', value: 's$i', displayLabel: 's$i'),
        ];

    test('spreads across the range incl. both endpoints (no tail-cut)', () {
      final picked = representativeTake(sizes(15), 4);
      expect(picked.length, 4);
      expect(picked.first.value, 's0', reason: 'smallest included');
      expect(picked.last.value, 's14',
          reason: 'largest included — NOT front-truncated');
      expect(picked.map((c) => c.value).toList(),
          isNot(<String>['s0', 's1', 's2', 's3']),
          reason: 'not simply the first 4');
    });

    test('returns all (unchanged) when it already fits', () {
      expect(representativeTake(sizes(3), 4).length, 3);
    });

    test('no duplicate chips; both endpoints kept', () {
      final picked = representativeTake(sizes(20), 5);
      expect(picked.map((c) => c.value).toSet().length, picked.length,
          reason: 'no duplicate index');
      expect(picked.first.value, 's0');
      expect(picked.last.value, 's19');
    });
  });

  test('merge constant invariants (swarm R5): 2 ≤ floor ≤ maxPerAxis ≤ cap', () {
    // The layout knobs are OWNER-REVIEW tunables; this pins the invariant so a
    // bad tuning fails loudly in CI instead of silently mis-laying-out the row.
    // floor ≥ 2: an axis needs ≥ 2 chips to offer a real choice (no lonely chip).
    expect(kMergedAxisFloor, greaterThanOrEqualTo(2));
    expect(kMergedAxisFloor, lessThanOrEqualTo(kMergedAxisMaxPerAxis));
    expect(kMergedAxisMaxPerAxis, lessThanOrEqualTo(kMergedKeyCap));
  });
}
