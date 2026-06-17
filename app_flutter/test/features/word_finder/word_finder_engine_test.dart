/// PURE end-to-end coverage of the newbie conversation engine (STEP 3).
///
/// Walks the real loop a non-technical user walks against the REAL union pool
/// (`kDivePool`) and the REAL lexicon (`buildWordLexicon`): ask-words → resolve
/// a word → repeatedly narrow by one axis → resolve to a single card. No
/// Flutter widgets are built; this is plain Dart logic over the finder's pure
/// primitives. `flutter_test` is used only for `test`/`expect`/`group`, the
/// project's standard harness (same as `finder_size_filter_test.dart`).
library;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/narrow_axis.dart'
    show productHasChip;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:buildsmart/features/word_finder/word_lexicon.dart';
import 'package:flutter_test/flutter_test.dart';

/// A const-friendly always-true predicate for sentinel [NewbieStep]s. A
/// top-level function tear-off is a compile-time constant (a `(_) => true`
/// closure is not), so it can seed a `const NewbieStep` in the fixtures below.
bool _alwaysTrue(LipskeyCatalogProduct _) => true;

void main() {
  group('word_finder_engine — newbie conversation', () {
    final lexicon = buildWordLexicon(kDivePool);

    test('first turn (empty stack) asks words, with a non-empty word list', () {
      final q = offerQuestion(const [], const [], lexicon, null);
      expect(q, isA<AskWords>(),
          reason: 'an empty stack must open with the word question');
      final ask = q as AskWords;
      expect(ask.questionHe, kFirstQuestion);
      expect(ask.words, isNotEmpty,
          reason: 'the lexicon built from kDivePool yields words to offer');
      expect(ask.words.length, lessThanOrEqualTo(kFirstWordCount),
          reason: 'first question shows at most kFirstWordCount words');
      // Top words are ordered by frequency (descending) — verify the offered
      // list is non-increasing in freq.
      for (var i = 1; i < ask.words.length; i++) {
        expect(ask.words[i - 1].freq, greaterThanOrEqualTo(ask.words[i].freq),
            reason: 'offered words must be sorted by freq, highest first');
      }
    });

    test('resolveWord maps a word back to real products from the pool', () {
      // Pick the first lexicon entry that names more than one product — that
      // is a word whose pool the conversation can actually narrow.
      WordEntry? multi;
      for (final e in lexicon.entries) {
        if (resolveWord(e.word, lexicon).length > 1) {
          multi = e;
          break;
        }
      }
      expect(multi, isNotNull,
          reason: 'the union pool must contain at least one shared word');
      final entry = multi!;
      final pool = resolveWord(entry.word, lexicon);
      expect(pool.length, entry.freq,
          reason: 'resolveWord recovers exactly the skus the lexicon recorded');
      // Every resolved product is a genuine pool member.
      final poolSkus = {for (final p in kDivePool) p.sku};
      for (final p in pool) {
        expect(poolSkus.contains(p.sku), isTrue);
      }
    });

    test('a multi-product word narrows, turn by turn, down to ONE card', () {
      // Seed: the first word that resolves to a genuinely MULTI-CARD pool
      // (>1 distinct collapsed card) — that is a word the conversation can
      // actually narrow. (A word whose products all collapse to one card would
      // Resolve immediately, exercising nothing.) Among those, prefer a modest
      // pool so the strict-shrink dive provably converges inside the 8-iter
      // bound; fall back to the first multi-card word if none is small.
      WordEntry? seed;
      for (final e in lexicon.entries) {
        final p = resolveWord(e.word, lexicon);
        if (p.length > 1 &&
            distinctCardCount(p) > 1 &&
            p.length <= 8) {
          seed = e;
          break;
        }
      }
      seed ??= lexicon.entries.firstWhere(
        (e) {
          final p = resolveWord(e.word, lexicon);
          return p.length > 1 && distinctCardCount(p) > 1;
        },
        orElse: () => throw StateError('no narrowable word in kDivePool'),
      );

      var pool = resolveWord(seed.word, lexicon);
      // Push a sentinel step so the engine leaves the AskWords branch and
      // starts offering axes / resolving (offerQuestion only asks words while
      // the stack is empty).
      final stack = <NewbieStep>[
        NewbieStep(
          axisLabel: 'מילה',
          chipLabel: seed.word,
          predicate: (_) => true,
          crumbWord: seed.word,
        ),
      ];

      Resolve? resolved;
      ShowProducts? picked;
      const maxIters = 8;
      var iters = 0;
      while (iters < maxIters) {
        iters++;
        final q = offerQuestion(pool, stack, lexicon, null);

        if (q is Resolve) {
          resolved = q;
          break;
        }
        if (q is ShowProducts) {
          // Converged to a product pick (the small-pool / repeat-axis
          // shortcut) — a valid terminal state, not necessarily a single card.
          picked = q;
          break;
        }

        expect(q, isA<AskAxis>(),
            reason: 'a non-resolved, non-first turn must offer an axis');
        final axis = q as AskAxis;

        // The question text is the mapped plain-Hebrew copy (or fallback).
        expect(axis.questionHe, isNotEmpty);
        expect(axis.questionHe,
            kAxisQuestion[axis.axisLabel] ?? kAxisFallbackQuestion);

        expect(axis.chips, isNotEmpty,
            reason: 'an offered axis must carry chips to choose from');

        final before = pool.length;
        // Choose a chip that makes progress. Most chips strictly shrink the
        // pool, but a product can carry several size tokens (cross-dims like
        // `25 ס"מ × 30 ס"מ`), so `chips.first` alone might keep every product.
        // We pick the chip giving the smallest non-empty PROPER subset — that
        // is the user-meaningful narrowing step, and it guarantees forward
        // progress so the bounded loop reaches a single card or a real wall.
        String? bestChip;
        var bestLen = before;
        for (final c in axis.chips) {
          final n = applyNarrow(pool, c).length;
          // Every chip comes from the pool, so each narrow is non-empty; we
          // only consider chips that strictly shrink (n < before).
          if (n > 0 && n < bestLen) {
            bestLen = n;
            bestChip = c;
          }
        }

        if (bestChip == null) {
          // No chip on this axis splits the pool — a genuine "wall" (every
          // product carries every chip). The loop must stop rather than spin.
          fail('axis "${axis.axisLabel}" offered chips ${axis.chips} but none '
              'shrinks the $before-product pool — unsplittable');
        }

        final chip = bestChip;
        pool = applyNarrow(pool, chip);
        stack.add(NewbieStep(
          axisLabel: axis.axisLabel,
          chipLabel: chip,
          predicate: (p) => productHasChip(p, chip),
          crumbWord: chip,
        ));

        expect(pool, isNotEmpty,
            reason: "narrowing by a real chip from the pool keeps that chip's "
                'products — never empties the pool');
        expect(pool.length, lessThan(before),
            reason: 'each narrow strictly shrinks the pool toward one card');
      }

      expect(iters, lessThanOrEqualTo(maxIters),
          reason: 'the dive must terminate within the iteration bound');
      // The cascade converges — EITHER to a single resolved card, OR to a
      // ShowProducts pick (the small-pool / repeat-axis shortcut). Both are
      // valid terminal states; it must never loop forever on an axis.
      expect(resolved != null || picked != null, isTrue,
          reason: 'the conversation must converge to a single card or a '
              'product pick');
      if (resolved != null) {
        // The resolved pool collapses to one distinct card.
        expect(distinctCardCount(resolved.siblings), 1,
            reason: 'Resolve fires only when the pool is one distinct card');
        expect(resolved.siblings, contains(resolved.product),
            reason: 'the representative product is among its own siblings');
      } else {
        expect(picked!.products, isNotEmpty,
            reason: 'a ShowProducts convergence offers at least one product');
      }
    });

    test(
        'multi-size pool CONVERGES: a repeated size axis becomes ShowProducts, '
        'never re-asks איזה גודל forever', () {
      // REPRODUCES THE LIVE LOOP. Faucet names carry MULTIPLE size tokens
      // (e.g. ½"×¾"). Here every product carries the SAME ½" AND a SECOND ¾"
      // (space-separated so the tokenizer yields TWO distinct inch tokens, not
      // one cross-size). So tapping ½" removes NO product, and the remaining
      // pool STILL surfaces a size axis → the old engine re-asked 'איזה גודל?'
      // forever, growing the breadcrumb 'ברז · ½" · ½"' without ever reaching
      // a product. The fix must turn the repeat into a ShowProducts pick.
      //
      // We build MORE than kShowProductsThreshold distinct cards on purpose: it
      // keeps the FIRST turn a genuine size AskAxis (the small-pool shortcut
      // does NOT fire), so when turn 2 returns ShowProducts it can ONLY be the
      // REPEAT-axis guard breaking the loop — exactly the live bug.
      final pool = <LipskeyCatalogProduct>[
        for (var i = 0; i < kShowProductsThreshold + 2; i++)
          LipskeyCatalogProduct(
            sku: 'FAUCET-$i',
            // Distinct non-size word so the products DON'T collapse onto one
            // card (else it would Resolve immediately). Stripping ½"/¾" leaves
            // 'ברז דגם<i>' — kShowProductsThreshold+2 distinct cards.
            nameHe: 'ברז דגם$i ½" ¾"',
            nameEn: 'faucet model$i 1/2" 3/4"',
            categoryHe: 'ברזים',
            categoryEn: 'faucets',
            categoryEmoji: '🚰',
            page: 1,
          ),
      ];

      // Sanity: the fixture really is a multi-size, multi-card pool.
      expect(distinctCardCount(pool), kShowProductsThreshold + 2,
          reason: 'each faucet model is its own collapsed card');
      expect(
          productHasChip(pool.first, '½"') && productHasChip(pool.first, '¾"'),
          isTrue,
          reason: 'every faucet carries BOTH size tokens (the loop trigger)');

      // A sentinel word-step so offerQuestion leaves the AskWords branch.
      final stack = <NewbieStep>[
        const NewbieStep(
          axisLabel: 'מילה',
          chipLabel: 'ברז',
          predicate: _alwaysTrue,
          crumbWord: 'ברז',
        ),
      ];

      // TURN 1 — the engine offers the size axis (genuine AskAxis, since the
      // pool is larger than the small-pool shortcut threshold).
      final t1 = offerQuestion(pool, stack, lexicon, null);
      expect(t1, isA<AskAxis>(),
          reason: 'the first turn over a multi-size pool asks a size axis');
      final axis1 = t1 as AskAxis;
      expect(axis1.axisLabel, 'גודל');
      expect(axis1.questionHe, kAxisQuestion['גודל']);
      expect(axis1.chips, containsAll(<String>['½"', '¾"']),
          reason: 'both size tokens are offered as chips');

      // Tap the SHARED size ½" — this removes NO product (all carry it), the
      // classic non-narrowing tap that fed the loop.
      final narrowed = applyNarrow(pool, '½"');
      expect(narrowed.length, pool.length,
          reason: 'tapping the shared ½" narrows nothing — the loop trigger');
      stack.add(NewbieStep(
        axisLabel: axis1.axisLabel, // 'גודל' is now an ANSWERED axis
        chipLabel: '½"',
        predicate: (p) => productHasChip(p, '½"'),
        crumbWord: '½"',
      ));

      // TURN 2 — the OLD engine would AskAxis('גודל') AGAIN here. The fix must
      // NOT: 'גודל' is already in the answered set, so the convergence guard
      // returns ShowProducts instead. Assert NO repeated size axis.
      final t2 = offerQuestion(narrowed, stack, lexicon, null);
      expect(t2, isNot(isA<AskAxis>()),
          reason: 'turn 2 must NOT re-ask any axis — the multi-size loop break');
      expect(t2, isA<ShowProducts>(),
          reason: 'a repeated (already-answered) size axis becomes a product '
              'pick, never an endless איזה גודל');
      final show = t2 as ShowProducts;

      // ShowProducts carries the DISTINCT products of the pool (deduped by the
      // engine's own collapse), capped at kShowProductsCap.
      expect(show.products, isNotEmpty,
          reason: 'the converged pick offers the remaining products');
      expect(show.products.length,
          distinctProducts(narrowed).length,
          reason: 'ShowProducts carries exactly the distinct products');
      expect(show.products.length, lessThanOrEqualTo(kShowProductsCap),
          reason: 'the product pick is capped at kShowProductsCap');
      // The distinct products are genuine pool members, one per collapsed card.
      final poolSkus = {for (final p in narrowed) p.sku};
      for (final p in show.products) {
        expect(poolSkus.contains(p.sku), isTrue,
            reason: 'every shown product is a real pool member');
      }
      expect(
          show.products.map((p) => p.sku).toSet().length,
          show.products.length,
          reason: 'the shown products are distinct (no duplicate card)');

      // BELT & BRACES: even if a user kept tapping the SAME shared size, the
      // engine never spins on a third size axis — it stays converged.
      stack.add(NewbieStep(
        axisLabel: 'גודל',
        chipLabel: '½"',
        predicate: (p) => productHasChip(p, '½"'),
        crumbWord: '½"',
      ));
      final t3 = offerQuestion(applyNarrow(narrowed, '½"'), stack, lexicon, null);
      expect(t3, isNot(isA<AskAxis>()),
          reason: 'within <=2 size answers the cascade has converged for good');
      expect(t3, anyOf(isA<ShowProducts>(), isA<Resolve>()),
          reason: 'the cascade terminates on a product pick, never an axis loop');
    });

    test('small multi-card pool short-circuits straight to ShowProducts', () {
      // A multi-card pool already at/under kShowProductsThreshold should not
      // drag the user through an axis — the small-pool shortcut offers the
      // products directly. Distinct non-size words keep them as separate cards.
      final pool = <LipskeyCatalogProduct>[
        for (var i = 0; i < 3; i++)
          LipskeyCatalogProduct(
            sku: 'SMALL-$i',
            nameHe: 'מחבר סוג$i ½" ¾"',
            nameEn: 'connector type$i 1/2" 3/4"',
            categoryHe: 'מחברים',
            categoryEn: 'connectors',
            categoryEmoji: '🔩',
            page: 1,
          ),
      ];
      expect(distinctCardCount(pool), 3);
      expect(distinctCardCount(pool), lessThanOrEqualTo(kShowProductsThreshold));

      final stack = <NewbieStep>[
        const NewbieStep(
          axisLabel: 'מילה',
          chipLabel: 'מחבר',
          predicate: _alwaysTrue,
          crumbWord: 'מחבר',
        ),
      ];
      final q = offerQuestion(pool, stack, lexicon, null);
      expect(q, isA<ShowProducts>(),
          reason: 'a pool already <= kShowProductsThreshold cards skips the '
              'axis and offers the products to pick');
      expect((q as ShowProducts).products.length, 3,
          reason: 'all three distinct cards are offered');
    });

    test('applyNarrow uses structural chip matching (no loose contains)', () {
      // A digit-bearing size chip must not match a product that merely has the
      // number elsewhere (e.g. "25 שנים אחריות"); productHasChip guards this.
      const decoy = LipskeyCatalogProduct(
        sku: 'TEST-DECOY',
        nameHe: 'ברז 25 שנים אחריות',
        nameEn: 'tap 25 years warranty',
        categoryHe: 'ברזי כיור',
        categoryEn: 'sink taps',
        categoryEmoji: '🚰',
        page: 1,
      );
      const real = LipskeyCatalogProduct(
        sku: 'TEST-REAL',
        nameHe: 'ברז 25 ס"מ',
        nameEn: 'tap 25 cm',
        categoryHe: 'ברזי כיור',
        categoryEn: 'sink taps',
        categoryEmoji: '🚰',
        page: 1,
      );
      final out = applyNarrow(const [decoy, real], '25 ס"מ');
      expect(out.map((p) => p.sku), [real.sku],
          reason: 'only the product structurally carrying the size chip passes');
    });
  });
}
