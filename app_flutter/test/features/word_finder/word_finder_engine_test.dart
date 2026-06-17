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
      // Axis labels asked across the dive — the Phase-1b engine asks each
      // splitting axis AT MOST once, so this list must stay duplicate-free.
      final askedAxes = <String>[];
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
          // Converged to a product pick (the small-pool shortcut, or every
          // splitting axis answered) — a valid terminal state, not necessarily
          // a single card.
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

        // Each AskAxis is for a DISTINCT axis the dive has not answered yet
        // (the Phase-1b engine walks size → angle → colour → word, asking each
        // at most once). Track the asked labels so we can prove no axis repeats.
        expect(askedAxes.contains(axis.axisLabel), isFalse,
            reason: 'the dive must NEVER re-ask an axis label it already asked '
                '(asked so far: $askedAxes, got "${axis.axisLabel}")');
        askedAxes.add(axis.axisLabel);

        final before = pool.length;
        // Choose a chip that makes progress. Most chips strictly shrink the
        // pool, but a product can carry SEVERAL tokens of one axis (cross-dims
        // like `25 ס"מ × 30 ס"מ`, or a faucet's ½"+¾"), so `chips.first` alone
        // might keep every product. We pick the chip giving the smallest
        // non-empty PROPER subset — the user-meaningful narrowing step.
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

        // If NO chip on this axis shrinks the pool, it is a NON-narrowing axis
        // for this pool (every product carries every chip — e.g. the faucet
        // that has BOTH ½" and ¾"). That is NOT a dead end under the Phase-1b
        // engine: answering it (any chip) lets the engine advance to the NEXT
        // unanswered axis, and once every splitting axis is answered it converges
        // to ShowProducts. So we answer with `chips.first` and continue, instead
        // of failing — forward progress is guaranteed by the bounded, each-axis-
        // once walk, not by a strict per-step shrink.
        final chip = bestChip ?? axis.chips.first;
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
        // Non-increasing every step; STRICTLY decreasing whenever a narrowing
        // chip existed (the common case). A non-narrowing axis keeps the size
        // but is asked at most once, so the bounded walk still terminates.
        expect(pool.length, lessThanOrEqualTo(before),
            reason: 'a narrow never grows the pool');
        if (bestChip != null) {
          expect(pool.length, lessThan(before),
              reason: 'a narrowing chip strictly shrinks the pool toward one '
                  'card');
        }
      }

      expect(iters, lessThanOrEqualTo(maxIters),
          reason: 'the dive must terminate within the iteration bound');
      // No axis label was asked twice — the dive narrows through each available
      // axis ONCE (the Phase-1b invariant), which is also what bounds it.
      expect(askedAxes.toSet().length, askedAxes.length,
          reason: 'every asked axis label is distinct — the dive never re-asks '
              'an axis (asked: $askedAxes)');
      // The cascade converges — EITHER to a single resolved card, OR to a
      // ShowProducts pick (the small-pool / no-more-axes shortcut). Both are
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
        'multi-size pool NARROWS THROUGH the other axes (size → angle → colour) '
        'then converges — never re-asks the SAME axis label twice', () {
      // REPRODUCES THE LIVE LOOP, then proves the Phase-1b enhancement. Faucet
      // names carry MULTIPLE size tokens (e.g. ½"×¾") AND multiple angle tokens
      // (45°/90°), space-separated so the tokenizer yields TWO distinct inch
      // tokens and TWO distinct angle tokens — NOT one cross-size. Every product
      // carries BOTH sizes AND BOTH angles, so tapping a size (or an angle)
      // removes NO product and the pool STILL surfaces that axis.
      //
      // OLD behaviour: after the user tapped a size, `offerAxis` re-offered the
      // SAME size axis; the engine converged STRAIGHT to a 14-product
      // ShowProducts (the repeat-axis shortcut). That dumped a long product list
      // the instant a second size couldn't narrow.
      //
      // NEW behaviour (this test): a repeated/answered axis is SKIPPED and the
      // dive walks to the next UNANSWERED axis — size → angle → colour — narrow-
      // ing the user through each available axis ONCE before it finally shows
      // products. The SAME axis label is never asked twice.
      //
      // We build MORE than kShowProductsThreshold distinct cards so the small-
      // pool shortcut does NOT fire on the early turns — every early turn is a
      // genuine AskAxis, and ONLY the colour tap (which halves the pool below
      // the threshold) trips the final ShowProducts.
      final pool = <LipskeyCatalogProduct>[
        for (var i = 0; i < kShowProductsThreshold + 2; i++)
          LipskeyCatalogProduct(
            sku: 'FAUCET-$i',
            // Distinct non-size/non-angle word ('דגם<i>') so the products DON'T
            // collapse onto one card (else it would Resolve immediately).
            // Stripping ½"/¾"/45°/90° + colour leaves 'ברז דגם<i>' — exactly
            // kShowProductsThreshold+2 distinct cards. BOTH sizes AND BOTH
            // angles on every product make size/angle the NON-narrowing
            // (loop-trigger) axes; colour is the axis that finally splits.
            nameHe: 'ברז דגם$i ½" ¾" 45° 90°',
            nameEn: 'faucet model$i 1/2" 3/4" 45deg 90deg',
            categoryHe: 'ברזים',
            categoryEn: 'faucets',
            categoryEmoji: '🚰',
            // Two distinct colours, evenly split → a colour axis with >1 chip
            // that HALVES the pool when answered (the converging tap).
            color: i.isEven ? 'שחור' : 'כרום',
            page: 1,
          ),
      ];

      // Sanity: the fixture really is a multi-size, multi-angle, multi-card
      // pool whose collapse strips size+angle+colour down to one card per דגם.
      expect(distinctCardCount(pool), kShowProductsThreshold + 2,
          reason: 'each faucet model is its own collapsed card');
      expect(
          productHasChip(pool.first, '½"') &&
              productHasChip(pool.first, '¾"') &&
              productHasChip(pool.first, '45°') &&
              productHasChip(pool.first, '90°'),
          isTrue,
          reason: 'every faucet carries BOTH sizes AND BOTH angles (the loop '
              'trigger on two axes)');

      // A sentinel word-step so offerQuestion leaves the AskWords branch.
      final stack = <NewbieStep>[
        const NewbieStep(
          axisLabel: 'מילה',
          chipLabel: 'ברז',
          predicate: _alwaysTrue,
          crumbWord: 'ברז',
        ),
      ];

      // TURN 1 — the engine offers the SIZE axis (genuine AskAxis; the pool is
      // larger than the small-pool shortcut threshold). narrowAxis ranks size
      // before angle/colour, so size is asked first.
      final t1 = offerQuestion(pool, stack, lexicon, null);
      expect(t1, isA<AskAxis>(),
          reason: 'the first turn over a multi-size pool asks a size axis');
      final axis1 = t1 as AskAxis;
      expect(axis1.axisLabel, 'גודל');
      expect(axis1.questionHe, kAxisQuestion['גודל']);
      expect(axis1.chips, containsAll(<String>['½"', '¾"']),
          reason: 'both size tokens are offered as chips');

      // Tap the SHARED size ½" — removes NO product (all carry it): the classic
      // non-narrowing tap that USED to feed the loop. 'גודל' is now answered.
      final afterSize = applyNarrow(pool, '½"');
      expect(afterSize.length, pool.length,
          reason: 'tapping the shared ½" narrows nothing — the loop trigger');
      stack.add(NewbieStep(
        axisLabel: axis1.axisLabel,
        chipLabel: '½"',
        predicate: (p) => productHasChip(p, '½"'),
        crumbWord: '½"',
      ));

      // TURN 2 — the OLD engine re-asked 'גודל' (then short-circuited to a long
      // ShowProducts). The FIX skips the answered size axis and asks the next
      // UNANSWERED axis: ANGLE. NOT a ShowProducts, NOT another size question.
      final t2 = offerQuestion(afterSize, stack, lexicon, null);
      expect(t2, isA<AskAxis>(),
          reason: 'turn 2 narrows by the NEXT unanswered axis, not a product '
              'dump — the Phase-1b enhancement');
      final axis2 = t2 as AskAxis;
      expect(axis2.axisLabel, 'זווית',
          reason: 'after size is answered the dive moves to the angle axis '
              '(narrowAxis priority size → angle → colour → word)');
      expect(axis2.axisLabel, isNot('גודל'),
          reason: 'the SAME size axis is never asked twice');
      expect(axis2.questionHe, kAxisQuestion['זווית']);
      expect(axis2.chips, containsAll(<String>['45°', '90°']),
          reason: 'both angle tokens are offered as chips');

      // Tap the SHARED angle 45° — again removes NO product. 'זווית' answered.
      final afterAngle = applyNarrow(afterSize, '45°');
      expect(afterAngle.length, afterSize.length,
          reason: 'tapping the shared 45° narrows nothing — the angle loop');
      stack.add(NewbieStep(
        axisLabel: axis2.axisLabel,
        chipLabel: '45°',
        predicate: (p) => productHasChip(p, '45°'),
        crumbWord: '45°',
      ));

      // TURN 3 — size AND angle answered; the dive walks to the next unanswered
      // axis: COLOUR. Still an AskAxis (the pool is still > threshold cards),
      // and still a NEW axis label.
      final t3 = offerQuestion(afterAngle, stack, lexicon, null);
      expect(t3, isA<AskAxis>(),
          reason: 'turn 3 narrows by colour — the third distinct axis');
      final axis3 = t3 as AskAxis;
      expect(axis3.axisLabel, 'צבע',
          reason: 'after size+angle the dive moves to the colour axis');
      expect(<String>{'גודל', 'זווית'}.contains(axis3.axisLabel), isFalse,
          reason: 'no axis label is asked twice across the dive');
      expect(axis3.questionHe, kAxisQuestion['צבע']);
      expect(axis3.chips, containsAll(<String>['כרום', 'שחור']),
          reason: 'both colours are offered as chips');

      // Tap a colour — THIS narrows (halves the pool below the threshold).
      final afterColor = applyNarrow(afterAngle, 'שחור');
      expect(afterColor.length, lessThan(afterAngle.length),
          reason: 'a colour tap finally narrows the pool');
      stack.add(NewbieStep(
        axisLabel: axis3.axisLabel,
        chipLabel: 'שחור',
        predicate: (p) => productHasChip(p, 'שחור'),
        crumbWord: 'שחור',
      ));

      // TURN 4 — the colour-narrowed pool is now at/under the threshold, so the
      // small-pool shortcut converges to a ShowProducts product pick.
      final t4 = offerQuestion(afterColor, stack, lexicon, null);
      expect(t4, isA<ShowProducts>(),
          reason: 'once the pool is small enough the dive shows the products');
      final show = t4 as ShowProducts;
      expect(show.products, isNotEmpty,
          reason: 'the converged pick offers the remaining products');
      expect(show.products.length, distinctProducts(afterColor).length,
          reason: 'ShowProducts carries exactly the distinct products');
      expect(show.products.length, lessThanOrEqualTo(kShowProductsCap),
          reason: 'the product pick is capped at kShowProductsCap');
      final poolSkus = {for (final p in afterColor) p.sku};
      for (final p in show.products) {
        expect(poolSkus.contains(p.sku), isTrue,
            reason: 'every shown product is a real pool member');
      }
      expect(show.products.map((p) => p.sku).toSet().length,
          show.products.length,
          reason: 'the shown products are distinct (no duplicate card)');

      // INVARIANT (bounded convergence + no repeated axis): replay the whole
      // dive generically from the seed, tapping the first chip each turn, and
      // assert it reaches a terminal pick within a bounded number of taps while
      // NEVER asking the same axis label twice in a row OR across the dive.
      var replayPool = pool;
      final replayStack = <NewbieStep>[
        const NewbieStep(
          axisLabel: 'מילה',
          chipLabel: 'ברז',
          predicate: _alwaysTrue,
          crumbWord: 'ברז',
        ),
      ];
      final askedAxes = <String>[];
      const maxTaps = 8;
      var taps = 0;
      var q = offerQuestion(replayPool, replayStack, lexicon, null);
      while (q is AskAxis && taps < maxTaps) {
        expect(askedAxes.contains(q.axisLabel), isFalse,
            reason: 'the dive must NEVER re-ask an axis label it already asked '
                '(asked so far: $askedAxes, got "${q.axisLabel}")');
        askedAxes.add(q.axisLabel);
        final chip = q.chips.first;
        replayPool = applyNarrow(replayPool, chip);
        replayStack.add(NewbieStep(
          axisLabel: q.axisLabel,
          chipLabel: chip,
          predicate: (p) => productHasChip(p, chip),
          crumbWord: chip,
        ));
        taps++;
        q = offerQuestion(replayPool, replayStack, lexicon, null);
      }
      expect(q, anyOf(isA<ShowProducts>(), isA<Resolve>()),
          reason: 'the dive converges to a product pick within $maxTaps taps, '
              'never an endless axis loop (asked axes: $askedAxes)');
      expect(askedAxes.toSet().length, askedAxes.length,
          reason: 'every asked axis label is distinct — no axis asked twice');
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
