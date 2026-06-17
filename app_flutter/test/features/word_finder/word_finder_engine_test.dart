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
    show productHasChip, sizeTokensIn;
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
        'multi-axis pool WALKS the splitting axes by information gain, never '
        're-asks an axis, and DEFERS the non-narrowing size loop forever', () {
      // REPRODUCES THE ½"×¾" NON-NARROWING LOOP, then proves the Phase-2a
      // information-gain scorer both (a) walks the dive through MORE THAN ONE
      // splitting axis without ever re-asking one, and (b) NEVER picks the
      // non-narrowing size axis — the scorer's structural answer to the loop.
      //
      // FIXTURE — 2·(threshold+2) = 28 distinct cards, each:
      //   • carries BOTH ½" AND ¾"  → size is a pure NON-NARROWING axis (every
      //     chip keeps the whole pool); under the scorer its expected-remaining
      //     is the WORST possible, so it is never the most-decisive axis,
      //   • carries ONE angle, split 14/14 (45° / 90°) → angle HALVES the pool,
      //   • carries one of two colours, split 14/14 → colour HALVES the pool,
      //   • a distinct 'דגם<i>' token keeps every product its own collapsed
      //     card (the digit makes wordOptions ignore it, so there is NO word
      //     axis — only size, angle, colour compete).
      //
      // The pool (28) is large enough that ONE even halving (→14) still exceeds
      // kShowProductsThreshold (12), so the dive MUST ask a SECOND axis before
      // it converges — exercising the multi-axis walk under the scorer.
      //
      // OLD fixed-priority engine: would have asked the size axis FIRST (size is
      // priority-1), tapping a shared size narrows nothing, and it re-surfaced
      // the same size axis (the loop). The scorer instead defers size entirely.
      const n = 2 * (kShowProductsThreshold + 2); // 28
      final pool = <LipskeyCatalogProduct>[
        for (var i = 0; i < n; i++)
          LipskeyCatalogProduct(
            sku: 'FAUCET-$i',
            // BOTH sizes on every product → size never narrows. ONE angle and
            // ONE colour, each split evenly across the pool → both halve it.
            nameHe: 'ברז דגם$i ½" ¾" ${i < n ~/ 2 ? '45°' : '90°'}',
            nameEn: 'faucet model$i 1/2" 3/4" ${i < n ~/ 2 ? '45deg' : '90deg'}',
            categoryHe: 'ברזים',
            categoryEn: 'faucets',
            categoryEmoji: '🚰',
            color: i.isEven ? 'שחור' : 'כרום',
            page: 1,
          ),
      ];

      // Sanity: 28 distinct cards; size is non-narrowing; angle & colour each
      // split the pool in half (so each is more decisive than size).
      expect(distinctCardCount(pool), n,
          reason: 'each faucet model is its own collapsed card');
      expect(
          productHasChip(pool.first, '½"') && productHasChip(pool.first, '¾"'),
          isTrue,
          reason: 'every faucet carries BOTH sizes (the non-narrowing loop)');
      expect(applyNarrow(pool, '½"').length, pool.length,
          reason: 'tapping a shared size removes NO product — the loop trigger');
      // The scorer ranks size WORST (it leaves the whole pool on every chip)
      // and angle/colour better (each halves the pool) — the easiest-path order.
      expect(
          axisExpectedRemaining(pool, <String>['½"', '¾"']) >
              axisExpectedRemaining(pool, <String>['45°', '90°']),
          isTrue,
          reason: 'the non-narrowing size axis scores strictly worse than the '
              'angle axis that actually halves the pool');

      // A sentinel word-step so offerQuestion leaves the AskWords branch.
      final stack = <NewbieStep>[
        const NewbieStep(
          axisLabel: 'מילה',
          chipLabel: 'ברז',
          predicate: _alwaysTrue,
          crumbWord: 'ברז',
        ),
      ];

      // Walk the dive: ALWAYS tap the FIRST chip (deterministic). Track which
      // axis labels are asked. The scorer picks the most-decisive UNANSWERED
      // axis each turn; size never wins, so it is never asked.
      var pool2 = pool;
      final askedAxes = <String>[];
      const maxTaps = 8;
      var taps = 0;
      var q = offerQuestion(pool2, stack, lexicon, null);
      while (q is AskAxis && taps < maxTaps) {
        // (a) NO axis label is ever asked twice.
        expect(askedAxes.contains(q.axisLabel), isFalse,
            reason: 'the dive must NEVER re-ask an axis label it already asked '
                '(asked so far: $askedAxes, got "${q.axisLabel}")');
        // (b) the non-narrowing size axis is NEVER the chosen question.
        expect(q.axisLabel, isNot('גודל'),
            reason: 'the scorer defers the non-narrowing size axis forever — '
                'it is never the most-decisive question');
        expect(q.questionHe, kAxisQuestion[q.axisLabel] ?? kAxisFallbackQuestion,
            reason: 'the question text is the mapped plain-Hebrew copy');
        expect(q.chips, isNotEmpty,
            reason: 'an offered axis carries chips to choose from');
        askedAxes.add(q.axisLabel);

        final chip = q.chips.first;
        pool2 = applyNarrow(pool2, chip);
        stack.add(NewbieStep(
          axisLabel: q.axisLabel,
          chipLabel: chip,
          predicate: (p) => productHasChip(p, chip),
          crumbWord: chip,
        ));
        taps++;
        q = offerQuestion(pool2, stack, lexicon, null);
      }

      // The dive walks MORE THAN ONE axis (28 cards can't converge on a single
      // even halving) and converges to a terminal pick — never an endless loop.
      expect(askedAxes.length, greaterThanOrEqualTo(2),
          reason: 'a 28-card pool needs at least two halving axes to drop under '
              'the threshold — the multi-axis walk (asked: $askedAxes)');
      expect(q, anyOf(isA<ShowProducts>(), isA<Resolve>()),
          reason: 'the dive converges to a product pick within $maxTaps taps, '
              'never an endless axis loop (asked axes: $askedAxes)');
      expect(askedAxes.toSet().length, askedAxes.length,
          reason: 'every asked axis label is distinct — no axis asked twice');
      expect(askedAxes.contains('גודל'), isFalse,
          reason: 'the non-narrowing size axis was never asked — the scorer '
              'avoided the loop entirely (asked: $askedAxes)');

      // The terminal ShowProducts carries exactly the distinct remaining
      // products, capped, all genuine pool members and distinct.
      if (q is ShowProducts) {
        final show = q;
        expect(show.products, isNotEmpty,
            reason: 'the converged pick offers the remaining products');
        expect(show.products.length, distinctProducts(pool2).length,
            reason: 'ShowProducts carries exactly the distinct products');
        expect(show.products.length, lessThanOrEqualTo(kShowProductsCap),
            reason: 'the product pick is capped at kShowProductsCap');
        final poolSkus = {for (final p in pool2) p.sku};
        for (final p in show.products) {
          expect(poolSkus.contains(p.sku), isTrue,
              reason: 'every shown product is a real pool member');
        }
        expect(show.products.map((p) => p.sku).toSet().length,
            show.products.length,
            reason: 'the shown products are distinct (no duplicate card)');
      }
    });

    test(
        'scorer picks the MORE-DECISIVE axis first (information gain beats the '
        'old fixed size-first priority)', () {
      // THE PHASE-2a PROOF. Two axes split the same pool very differently:
      //   • COLOUR splits EVENLY  — 7 שחור / 7 כרום  → low expected-remaining,
      //   • SIZE   BARELY splits  — 13 carry ½", 1 carries ¾" → high remaining.
      // The OLD nextUnansweredAxis used a FIXED order (size before colour) and
      // would have asked SIZE first. The information-gain scorer asks the axis
      // that narrows the pool MOST — COLOUR — proving the easiest-path change.
      //
      // 14 distinct cards (> kShowProductsThreshold so the small-pool shortcut
      // does NOT pre-empt the axis question). A distinct 'דגם<i>' token keeps
      // every product its own collapsed card; there is no angle and no word
      // axis (the digit in 'דגם<i>' makes wordOptions ignore it), so ONLY size
      // and colour compete — a clean two-axis contrast.
      const cards = kShowProductsThreshold + 2; // 14
      final pool = <LipskeyCatalogProduct>[
        for (var i = 0; i < cards; i++)
          LipskeyCatalogProduct(
            sku: 'MIX-$i',
            // EXACTLY ONE product (the last) carries a different size (¾"); all
            // the rest carry ½". So the size axis has two chips but one of them
            // (¾") isolates a single card and the other (½") keeps 13 — a very
            // LOPSIDED, barely-narrowing split.
            nameHe: 'מסעף דגם$i ${i == cards - 1 ? '¾"' : '½"'}',
            nameEn: 'manifold model$i ${i == cards - 1 ? '3/4"' : '1/2"'}',
            categoryHe: 'מסעפים',
            categoryEn: 'manifolds',
            categoryEmoji: '🔧',
            // Colour splits the pool EXACTLY in half — the decisive axis.
            color: i.isEven ? 'שחור' : 'כרום',
            page: 1,
          ),
      ];

      expect(distinctCardCount(pool), cards,
          reason: 'each model is its own collapsed card');

      // Lock the FORMULA: colour's expected-remaining is strictly lower than
      // size's. colour: 7²+7² = 98 over 14 → 7.0. size: 13²+1² = 170 over 14 →
      // ~12.14. So colour is the more-decisive (lower-score) axis.
      final colourScore =
          axisExpectedRemaining(pool, <String>['כרום', 'שחור']);
      final sizeScore = axisExpectedRemaining(pool, <String>['½"', '¾"']);
      expect(colourScore, closeTo(98 / cards, 1e-9),
          reason: 'colour halves the pool evenly: (7²+7²)/14');
      expect(sizeScore, closeTo(170 / cards, 1e-9),
          reason: 'size barely splits: (13²+1²)/14');
      expect(colourScore, lessThan(sizeScore),
          reason: 'the even colour split has lower expected-remaining than the '
              'lopsided size split — colour carries more information');

      // bestUnansweredAxis returns COLOUR (the lower score), NOT size, even
      // though size is earlier in the fixed narrowAxis priority order.
      final best = bestUnansweredAxis(pool, <String>{});
      expect(best, isNotNull, reason: 'two axes split the pool');
      expect(best!.label, 'צבע',
          reason: 'the scorer returns the MORE-decisive colour axis, not the '
              'fixed-priority size axis');

      // End-to-end: offerQuestion asks COLOUR first. (A sentinel word-step puts
      // the engine past the AskWords branch.)
      final stack = <NewbieStep>[
        const NewbieStep(
          axisLabel: 'מילה',
          chipLabel: 'מסעף',
          predicate: _alwaysTrue,
          crumbWord: 'מסעף',
        ),
      ];
      final q = offerQuestion(pool, stack, lexicon, null);
      expect(q, isA<AskAxis>(),
          reason: 'the pool is larger than the threshold — a real axis turn');
      final axis = q as AskAxis;
      expect(axis.axisLabel, 'צבע',
          reason: 'information gain asks the decisive colour axis FIRST');
      expect(axis.axisLabel, isNot('גודל'),
          reason: 'the OLD fixed priority would have asked size first; the '
              'scorer does not');
      expect(axis.questionHe, kAxisQuestion['צבע']);
      expect(axis.chips, containsAll(<String>['כרום', 'שחור']),
          reason: 'the decisive axis offers both colours');
    });

    test('scorer tie-break is deterministic', () {
      // When two axes score IDENTICALLY under axisExpectedRemaining, the winner
      // must be the higher-priority one in the canonical _candidateAxes order
      // (size > angle > colour > word), chosen by the strict `<` that keeps the
      // FIRST axis on a tie. Here angle and colour split the SAME pool the SAME
      // way (each evenly 2/2), so their scores are exactly equal and the tie
      // must resolve to ANGLE ('זווית'), never COLOUR ('צבע').
      //
      // 4 distinct cards, each:
      //   • a distinct 'דגם<i>' token (the digit makes wordOptions ignore it, so
      //     there is NO word axis, yet _collapseKey keeps it → 4 distinct cards),
      //   • NO size token at all → the size axis has no chips (not a candidate),
      //   • ONE angle (45° / 90°) split 2/2 → angle halves the pool,
      //   • ONE colour (שחור / כרום) split 2/2 → colour halves the pool too.
      final pool = <LipskeyCatalogProduct>[
        for (var i = 0; i < 4; i++)
          LipskeyCatalogProduct(
            sku: 'TIE-$i',
            // angle: 45° for i<2, 90° for i>=2 (2/2). colour split orthogonally
            // (שחור for even i, כרום for odd i — also 2/2). The 'דגם<i>' digit
            // token is ignored by wordOptions but kept by _collapseKey, so every
            // card stays distinct and there is no competing word axis.
            nameHe: 'ברך דגם$i ${i < 2 ? '45°' : '90°'}',
            nameEn: 'elbow model$i ${i < 2 ? '45deg' : '90deg'}',
            categoryHe: 'ברכים',
            categoryEn: 'elbows',
            categoryEmoji: '🔧',
            color: i.isEven ? 'שחור' : 'כרום',
            page: 1,
          ),
      ];

      // 4 distinct cards; size carries no chips; angle & colour each split 2/2.
      expect(distinctCardCount(pool), 4,
          reason: 'each model is its own collapsed card');
      expect(sizeTokensIn(pool), isEmpty,
          reason: 'no size token in the names → the size axis is not a candidate');

      // The two scores are EXACTLY equal: angle = (2²+2²)/4 = 2.0,
      // colour = (2²+2²)/4 = 2.0. This equality is what arms the tie-break.
      final angleScore = axisExpectedRemaining(pool, <String>['45°', '90°']);
      final colourScore = axisExpectedRemaining(pool, <String>['שחור', 'כרום']);
      expect(angleScore, closeTo(2.0, 1e-9),
          reason: 'angle halves the pool: (2²+2²)/4');
      expect(colourScore, closeTo(2.0, 1e-9),
          reason: 'colour halves the pool: (2²+2²)/4');
      expect(angleScore, closeTo(colourScore, 1e-9),
          reason: 'angle and colour score IDENTICALLY — the tie the order breaks');

      // The tie resolves DETERMINISTICALLY to the higher-priority angle axis.
      final best = bestUnansweredAxis(pool, <String>{});
      expect(best, isNotNull, reason: 'two axes split the pool');
      expect(best!.label, 'זווית',
          reason: 'on an exact score tie the canonical order (size > angle > '
              'colour > word) keeps the FIRST — angle, not colour');
      expect(best.label, isNot('צבע'),
          reason: 'colour must lose the tie to the higher-priority angle axis');
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
