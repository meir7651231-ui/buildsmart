/// PROPERTY / INVARIANT tests for the PURE word-finder engines.
///
/// WHY THIS FILE EXISTS (a DIFFERENT bug class than the line-coverage suites):
///   The per-engine tests (`word_finder_engine_test`, `narrow_axis_test`,
///   `material_lexicon_test`, `recipe_kit_test`, `word_lexicon_test`, …) already
///   reach 100% LINE coverage by walking the happy paths against the real pool.
///   Line coverage does NOT catch the bug class this file targets: an EDGE or
///   RANDOM input that crashes (throws / out-of-range) or VIOLATES an invariant
///   the engine implicitly promises. So here we hammer each pure engine with a
///   SEEDED `dart:math` Random over many iterations of random subsets AND the
///   pathological shapes — empty, single, all-identical, the whole pool — and
///   assert the invariants the code's own doc-comments and structure guarantee.
///
/// SEED: every Random is constructed `Random(12345)` (a fixed literal). A failure
///   is therefore REPRODUCIBLE — the same iteration index draws the same subset,
///   so a future run hits the identical counterexample. Each iteration that could
///   surface a counterexample includes the seed/iteration/pool in its `reason:`.
///
/// PURITY: imports ONLY the pure engines + their const data + flutter_test. NO
///   pumpScreen, NO widget, NO Riverpod. `flutter_test` is used solely for
///   `test`/`expect`/`group` — the same harness `word_finder_engine_test` uses
///   (the engines transitively pull `package:flutter/widgets` via `_size_norm`'s
///   `TextDirection` re-export, so a bare `dart test` cannot load them; this is a
///   PRE-EXISTING fact of the dependency chain, not introduced here).
///
/// THE-LAW NOTE (honest simplifications, called out loudly):
///   • TERMINATION of `offerQuestion` is driven the SAME way the engine itself
///     converges and the SAME way `word_finder_engine_test` drives it: at each
///     `AskAxis` we pick the chip that yields the smallest non-empty PROPER
///     subset, falling back to `chips.first` only when NO chip strictly shrinks
///     the pool (the ½"×¾"-multi-token case). We do NOT assert the literal
///     "applying the FIRST chip strictly reduces distinctCardCount", because the
///     real code legitimately VIOLATES that: a product carrying BOTH ½" and ¾"
///     stays in the ½" bucket AND the ¾" bucket, so `chips.first` can keep the
///     whole pool. The actual termination guarantee the code provides is the
///     ANSWERED-AXIS monotonicity (`bestUnansweredAxis` only ever returns an
///     UNANSWERED axis, so the answered-set strictly grows and is bounded by the
///     4 subtype-free axes + 1 curated facet). We assert THAT: bounded iters, no
///     axis re-asked, a terminal (Resolve/ShowProducts) always reached.
library;

import 'dart:math';

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/smart_tree.dart' show kSmartProducts;
import 'package:buildsmart/features/word_finder/dive_pool.dart'
    show divePoolIndex, kDivePool, offerAxis;
import 'package:buildsmart/features/word_finder/material_lexicon.dart';
import 'package:buildsmart/features/word_finder/narrow_axis.dart'
    show
        angleTokensIn,
        colorOptions,
        narrowAxis,
        productHasChip,
        sizeTokensIn,
        wordOptions;
import 'package:buildsmart/features/word_finder/quick_pad_engine.dart'
    show quickLabel;
import 'package:buildsmart/features/word_finder/recipe_kit.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart';
import 'package:buildsmart/features/word_finder/word_lexicon.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixed seed so any failure is reproducible (same iteration → same subset).
const int kSeed = 12345;

/// How many random iterations each property runs.
const int kIters = 200;

/// The set of axis labels `narrowAxis` is allowed to emit (plus the curated
/// 'אפשרות' facet and the empty "nothing splits" sentinel). Byte-checked against
/// the real `narrow_axis.dart` source (sizes→'גודל', angles→'זווית',
/// colours→'צבע', words→'דגם', curated→'אפשרות', none→'').
const Set<String> kAxisLabels = {'אפשרות', 'גודל', 'זווית', 'צבע', 'דגם'};

void main() {
  // The real union pool and the real lexicon built from it — the universe every
  // property draws its random subsets from.
  final pool = kDivePool;
  final lexicon = buildWordLexicon(pool);

  /// A reproducible random NON-EMPTY-or-empty subset of [pool] of size ~[size].
  /// Uses the supplied [rng] so the draw is seed-deterministic.
  List<LipskeyCatalogProduct> randomSubset(Random rng, int size) {
    if (size <= 0 || pool.isEmpty) return const [];
    final out = <LipskeyCatalogProduct>[];
    for (var i = 0; i < size; i++) {
      out.add(pool[rng.nextInt(pool.length)]);
    }
    return out;
  }

  /// A grab-bag of pathological pools the property loops mix in alongside random
  /// subsets. Index 0..N maps deterministically so a failure names its shape.
  List<List<LipskeyCatalogProduct>> edgeShapes() => <List<LipskeyCatalogProduct>>[
        const <LipskeyCatalogProduct>[], // empty
        <LipskeyCatalogProduct>[pool.first], // single
        <LipskeyCatalogProduct>[pool.last], // single (other end)
        <LipskeyCatalogProduct>[pool.first, pool.first, pool.first], // all-same
        List<LipskeyCatalogProduct>.filled(50, pool.first), // large all-same
        pool, // the whole pool (largest realistic input)
      ];

  // ── narrowAxis ────────────────────────────────────────────────────────────
  //
  // INVARIANTS (from `narrow_axis.dart` lines 106-130):
  //   • never throws for ANY pool + any subtype;
  //   • label ∈ {אפשרות,גודל,זווית,צבע,דגם} OR '' (empty);
  //   • label is empty IFF chips is empty (the only label-less return carries
  //     `chips: const []`, and every non-empty-label branch carries a non-empty
  //     chip list);
  //   • a NON-EMPTY label has >1 chip (every branch is gated on `> 1`).
  group('narrowAxis — invariants over random + edge pools', () {
    test('never throws; label-set; label-empty IFF chips-empty; >1 chip', () {
      final rng = Random(kSeed);
      // A handful of plausible subtypes: the 3 real curated keys + null + a
      // bogus one (which must behave exactly like null — no curated facet).
      const subtypes = <String?>[
        null,
        'מכסים ורשתות',
        'מחסומים גלויים',
        'מחסומי רצפה',
        'not-a-real-subtype',
      ];

      void check(List<LipskeyCatalogProduct> p, String? subtype, String tag) {
        late final ({String label, List<String> chips}) ax;
        // Never throws.
        expect(
          () => ax = narrowAxis(p, subtype),
          returnsNormally,
          reason: 'narrowAxis threw [$tag subtype=$subtype seed=$kSeed]',
        );
        // Label is one of the allowed labels OR empty.
        expect(
          ax.label.isEmpty || kAxisLabels.contains(ax.label),
          isTrue,
          reason: 'narrowAxis returned an unknown label "${ax.label}" '
              '[$tag subtype=$subtype seed=$kSeed]',
        );
        // Label empty IFF chips empty.
        expect(
          ax.label.isEmpty,
          ax.chips.isEmpty,
          reason: 'label-empty must match chips-empty (label="${ax.label}", '
              'chips=${ax.chips}) [$tag subtype=$subtype seed=$kSeed]',
        );
        // A non-empty label has >1 chip.
        if (ax.label.isNotEmpty) {
          expect(
            ax.chips.length,
            greaterThan(1),
            reason: 'a non-empty axis must offer >1 chip (label="${ax.label}", '
                'chips=${ax.chips}) [$tag subtype=$subtype seed=$kSeed]',
          );
        }
      }

      // Edge shapes × every subtype.
      final shapes = edgeShapes();
      for (var s = 0; s < shapes.length; s++) {
        for (final sub in subtypes) {
          check(shapes[s], sub, 'edge#$s');
        }
      }
      // Random subsets × a subtype drawn from the same rng.
      for (var i = 0; i < kIters; i++) {
        final size = rng.nextInt(40); // 0..39 → includes empty
        final sub = subtypes[rng.nextInt(subtypes.length)];
        check(randomSubset(rng, size), sub, 'iter#$i(size=$size)');
      }
    });
  });

  // ── offerQuestion ───────────────────────────────────────────────────────-
  //
  // INVARIANTS (from `word_finder_engine.dart` lines 461-522):
  //   • never throws for ANY pool + any answered stack + any subtype;
  //   • returns a non-null NewbieQuestion (Dart non-nullable return — we assert
  //     it is one of the 4 sealed kinds, which also documents the contract);
  //   • Resolve is returned IFF (stack non-empty AND pool non-empty AND
  //     distinctCardCount <= 1) — the exact guard at line 478;
  //   • any AskAxis has non-empty chips AND an axisLabel NOT already in the
  //     answered stack (lines 496-518: branch 4 only fires for an unanswered
  //     scored axis; branch 5 only when `axIsUnanswered && chips.isNotEmpty`).
  group('offerQuestion — invariants over random pools/stacks', () {
    // Build a plausible answered stack of [n] steps by picking real chips that
    // appear in the pool (so axisLabel values are realistic), using [rng].
    List<NewbieStep> randomStack(Random rng, List<LipskeyCatalogProduct> p, int n) {
      if (n <= 0) return const [];
      // Candidate (label, chip) pairs drawn from what the pool actually offers.
      final pairs = <({String label, String chip})>[];
      for (final t in sizeTokensIn(p)) {
        pairs.add((label: 'גודל', chip: t.label));
      }
      for (final t in angleTokensIn(p)) {
        pairs.add((label: 'זווית', chip: t.label));
      }
      for (final c in colorOptions(p)) {
        pairs.add((label: 'צבע', chip: c));
      }
      for (final c in wordOptions(p)) {
        pairs.add((label: 'דגם', chip: c));
      }
      if (pairs.isEmpty) {
        // No real chips — still exercise the "non-empty stack" branch with a
        // sentinel step (mirrors the engine test's seed step). Its label is
        // 'מילה' (the word seed), which is NOT a narrowAxis label, so it never
        // collides with the answered-axis logic.
        return <NewbieStep>[
          NewbieStep(
            axisLabel: 'מילה',
            chipLabel: 'seed',
            predicate: (_) => true,
            crumbWord: 'seed',
          ),
        ];
      }
      final out = <NewbieStep>[];
      for (var i = 0; i < n; i++) {
        final pr = pairs[rng.nextInt(pairs.length)];
        out.add(NewbieStep(
          axisLabel: pr.label,
          chipLabel: pr.chip,
          predicate: (prod) => productHasChip(prod, pr.chip),
          crumbWord: pr.chip,
        ));
      }
      return out;
    }

    test('never throws; returns a sealed kind; Resolve-IFF; AskAxis is clean',
        () {
      final rng = Random(kSeed);
      const subtypes = <String?>[null, 'מכסים ורשתות', 'מחסומי רצפה', 'bogus'];

      void check(
        List<LipskeyCatalogProduct> p,
        List<NewbieStep> stack,
        String? subtype,
        String tag,
      ) {
        final NewbieQuestion q;
        try {
          q = offerQuestion(p, stack, lexicon, subtype);
        } catch (e) {
          fail('offerQuestion threw [$tag stack=${stack.length} '
              'subtype=$subtype seed=$kSeed]: $e');
        }
        // One of exactly four sealed kinds (also asserts non-null).
        expect(
          q is AskWords || q is AskAxis || q is Resolve || q is ShowProducts,
          isTrue,
          reason: 'offerQuestion returned an unexpected kind ${q.runtimeType} '
              '[$tag seed=$kSeed]',
        );

        // Resolve IFF (non-empty stack AND non-empty pool AND distinct<=1).
        final shouldResolve =
            stack.isNotEmpty && p.isNotEmpty && distinctCardCount(p) <= 1;
        expect(
          q is Resolve,
          shouldResolve,
          reason: 'Resolve must be returned IFF distinctCardCount<=1 on a '
              'non-empty pool with a non-empty stack '
              '(stack=${stack.length}, poolLen=${p.length}, '
              'distinct=${p.isEmpty ? 0 : distinctCardCount(p)}, '
              'got ${q.runtimeType}) [$tag seed=$kSeed]',
        );
        if (q is Resolve) {
          // The representative is the pool's first; siblings are the whole pool.
          expect(q.product, same(p.first),
              reason: 'Resolve representative is pool.first [$tag]');
          expect(q.siblings, same(p),
              reason: 'Resolve siblings is the whole pool [$tag]');
        }

        // An AskAxis must carry chips and an UNANSWERED axis label.
        if (q is AskAxis) {
          final answered = {for (final s in stack) s.axisLabel};
          expect(q.chips, isNotEmpty,
              reason: 'AskAxis must offer chips [$tag seed=$kSeed]');
          expect(
            answered.contains(q.axisLabel),
            isFalse,
            reason: 'AskAxis must NOT re-ask an answered axis '
                '(answered=$answered, got "${q.axisLabel}") [$tag seed=$kSeed]',
          );
          // The question text is the mapped copy (or the fallback).
          expect(
            q.questionHe,
            kAxisQuestion[q.axisLabel] ?? kAxisFallbackQuestion,
            reason: 'AskAxis question must be the mapped/fallback copy [$tag]',
          );
        }

        // AskWords only ever appears on an EMPTY stack (branch 1).
        if (q is AskWords) {
          expect(stack, isEmpty,
              reason: 'AskWords is the empty-stack opener only [$tag]');
        }
      }

      // Edge shapes with stacks of size 0, 1, 3.
      final shapes = edgeShapes();
      for (var s = 0; s < shapes.length; s++) {
        for (final n in const [0, 1, 3]) {
          final stack = randomStack(rng, shapes[s], n);
          for (final sub in subtypes) {
            check(shapes[s], stack, sub, 'edge#$s(stack=$n)');
          }
        }
      }

      // Random subsets × random stack depth × random subtype.
      for (var i = 0; i < kIters; i++) {
        final size = rng.nextInt(40);
        final p = randomSubset(rng, size);
        final depth = rng.nextInt(4); // 0..3
        final stack = randomStack(rng, p, depth);
        final sub = subtypes[rng.nextInt(subtypes.length)];
        check(p, stack, sub, 'iter#$i(size=$size,depth=$depth)');
      }
    });

    // TERMINATION — drive the real loop the way the engine converges (best
    // shrinking chip, fall back to chips.first). Assert: bounded iterations, no
    // axis re-asked, a terminal reached. See the THE-LAW NOTE in the file header
    // for why we do NOT use a naive `chips.first` strict-shrink assertion.
    test('the dive always terminates (bounded, no axis re-asked)', () {
      final rng = Random(kSeed);
      // Bound: 4 subtype-free axes + 1 curated facet + generous slack. The
      // answered-set strictly grows each AskAxis turn, so any value > 5 suffices;
      // 12 leaves head-room and still catches an infinite loop.
      const maxIters = 12;

      // Seed each dive from a real word's pool (a genuinely narrowable start),
      // plus the edge shapes, so termination is checked on realistic AND
      // degenerate inputs.
      final seeds = <List<LipskeyCatalogProduct>>[...edgeShapes()];
      // 30 random word-seeded pools.
      for (var i = 0; i < 30; i++) {
        final e = lexicon.entries[rng.nextInt(lexicon.entries.length)];
        seeds.add(resolveWord(e.word, lexicon));
      }
      // 30 random subsets.
      for (var i = 0; i < 30; i++) {
        seeds.add(randomSubset(rng, 1 + rng.nextInt(40)));
      }

      const subtypes = <String?>[null, 'מכסים ורשתות', 'מחסומי רצפה'];

      for (var si = 0; si < seeds.length; si++) {
        for (final subtype in subtypes) {
          var p = seeds[si];
          // A non-empty sentinel stack so we leave the AskWords branch (the
          // dive only asks words while the stack is empty).
          final stack = <NewbieStep>[
            NewbieStep(
              axisLabel: 'מילה',
              chipLabel: 'seed',
              predicate: (_) => true,
              crumbWord: 'seed',
            ),
          ];
          final asked = <String>[];
          var iters = 0;
          var reachedTerminal = false;
          while (iters < maxIters) {
            iters++;
            final q = offerQuestion(p, stack, lexicon, subtype);
            if (q is Resolve || q is ShowProducts) {
              reachedTerminal = true;
              break;
            }
            // On a non-empty stack the only other kind is AskAxis.
            expect(q, isA<AskAxis>(),
                reason: 'non-first turn must be AskAxis/terminal '
                    '[seed#$si subtype=$subtype seed=$kSeed]');
            final axis = q as AskAxis;
            // No axis re-asked — THIS is the termination guarantee.
            expect(
              asked.contains(axis.axisLabel),
              isFalse,
              reason: 'the dive re-asked axis "${axis.axisLabel}" '
                  '(asked=$asked) — would loop forever '
                  '[seed#$si subtype=$subtype seed=$kSeed]',
            );
            asked.add(axis.axisLabel);

            // Pick the chip giving the smallest non-empty PROPER subset; fall
            // back to chips.first when nothing strictly shrinks (multi-token
            // axis). Either way the answered-set grows, bounding the loop.
            final before = p.length;
            String? best;
            var bestLen = before;
            for (final c in axis.chips) {
              final n = applyNarrow(p, c).length;
              if (n > 0 && n < bestLen) {
                bestLen = n;
                best = c;
              }
            }
            final chip = best ?? axis.chips.first;
            p = applyNarrow(p, chip);
            stack.add(NewbieStep(
              axisLabel: axis.axisLabel,
              chipLabel: chip,
              predicate: (prod) => productHasChip(prod, chip),
              crumbWord: chip,
            ));
            expect(p, isNotEmpty,
                reason: 'narrowing by a real pool chip never empties the pool '
                    '[seed#$si subtype=$subtype seed=$kSeed]');
            expect(p.length, lessThanOrEqualTo(before),
                reason: 'a narrow never grows the pool '
                    '[seed#$si subtype=$subtype seed=$kSeed]');
          }
          expect(reachedTerminal, isTrue,
              reason: 'the dive did not reach Resolve/ShowProducts within '
                  '$maxIters turns (asked=$asked) '
                  '[seed#$si subtype=$subtype seed=$kSeed]');
          expect(asked.toSet().length, asked.length,
              reason: 'no axis label may be asked twice '
                  '[seed#$si subtype=$subtype seed=$kSeed]');
        }
      }
    });
  });

  // ── materialOf ─────────────────────────────────────────────────────────-
  //
  // INVARIANTS (from `material_lexicon.dart` lines 81-89):
  //   • for EVERY product (whole pool + random draws), returns null OR a value
  //     in `kMaterials.keys`. The term-heuristic branch returns `entry.key`
  //     (∈ keys by construction); the fallback returns `kCategoryMaterial[cat]`,
  //     whose VALUES we FIRST prove are all `kMaterials` keys — so the union of
  //     possible non-null returns is exactly `kMaterials.keys`.
  //   • deterministic: the same product twice → the same result.
  group('materialOf — invariants over the whole pool', () {
    test('every kCategoryMaterial value is a kMaterials key (precondition)', () {
      // Guards the invariant below: if the override table ever maps a category
      // to a NON-kMaterials value, "returns null or a kMaterials key" would
      // silently break. Reading bytes today: every value is 'נחושת' ∈ keys.
      for (final entry in kCategoryMaterial.entries) {
        expect(
          kMaterials.keys.contains(entry.value),
          isTrue,
          reason: 'kCategoryMaterial["${entry.key}"] = "${entry.value}" is NOT '
              'a kMaterials key — breaks the materialOf range invariant',
        );
      }
    });

    test('returns null or a kMaterials key; deterministic', () {
      for (final p in pool) {
        final m1 = materialOf(p);
        final m2 = materialOf(p);
        // Deterministic.
        expect(m1, m2,
            reason: 'materialOf is not deterministic for sku=${p.sku}');
        // Range: null or a real material key.
        if (m1 != null) {
          expect(
            kMaterials.keys.contains(m1),
            isTrue,
            reason: 'materialOf returned "$m1" which is not a kMaterials key '
                '(sku=${p.sku}, cat="${p.categoryHe}")',
          );
        }
      }
    });

    test('materialsInPool keys are kMaterials keys, in kMaterials order', () {
      // Cross-check the pool-level helper over random subsets: every reported
      // material must be a real key, listed in kMaterials precedence order, and
      // each must actually have a product in the subset.
      final rng = Random(kSeed);
      for (var i = 0; i < kIters; i++) {
        final p = randomSubset(rng, rng.nextInt(40));
        late final List<String> mats;
        expect(() => mats = materialsInPool(p), returnsNormally,
            reason: 'materialsInPool threw [iter#$i seed=$kSeed]');
        var lastKeyIdx = -1;
        final keyList = kMaterials.keys.toList();
        for (final m in mats) {
          final idx = keyList.indexOf(m);
          expect(idx, greaterThanOrEqualTo(0),
              reason: 'materialsInPool reported non-key "$m" [iter#$i]');
          expect(idx, greaterThan(lastKeyIdx),
              reason: 'materialsInPool not in kMaterials order [iter#$i]');
          lastKeyIdx = idx;
          expect(p.any((x) => materialOf(x) == m), isTrue,
              reason: 'materialsInPool reported "$m" with no product [iter#$i]');
        }
      }
    });
  });

  // ── assembleKit / resolveAccessory ─────────────────────────────────────-
  //
  // INVARIANTS (from `recipe_kit.dart` lines 170-262):
  //   • for EVERY kSmartProducts recipe: assembleKit never throws;
  //   • every line.match is a valid KitMatch (one of the 5 enum values);
  //   • a resolved sku (line.product) exists in kDivePool;
  //   • a KitMatch.none line carries product == null; every other kind carries a
  //     non-null product (curated/auto/ambiguous/swarm all bind a product).
  group('assembleKit / resolveAccessory — invariants over every recipe', () {
    test('never throws; valid KitMatch; resolved product is in the pool', () {
      final poolSkus = {for (final p in pool) p.sku};
      for (final recipe in kSmartProducts) {
        late final List<KitLine> lines;
        expect(
          () => lines = assembleKit(recipe),
          returnsNormally,
          reason: 'assembleKit threw for recipe "${recipe.key}"',
        );
        // One line per accessory, in order.
        expect(lines.length, recipe.acc.length,
            reason: 'assembleKit must emit one line per accessory '
                '(recipe="${recipe.key}")');
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          // Valid enum value (KitMatch.values membership is structural, but
          // this documents the contract and guards a future widened enum).
          expect(KitMatch.values.contains(line.match), isTrue,
              reason: 'invalid KitMatch on recipe="${recipe.key}" acc#$i');
          if (line.match == KitMatch.none) {
            expect(line.product, isNull,
                reason: 'KitMatch.none must carry no product '
                    '(recipe="${recipe.key}" acc#$i "${line.acc.name}")');
          } else {
            // curated / auto / ambiguous / swarm all bind a real pool product.
            expect(line.product, isNotNull,
                reason: 'a resolved line must carry a product '
                    '(recipe="${recipe.key}" acc#$i match=${line.match})');
            expect(
              poolSkus.contains(line.product!.sku),
              isTrue,
              reason: 'resolved sku ${line.product!.sku} not in kDivePool '
                  '(recipe="${recipe.key}" acc#$i match=${line.match})',
            );
            // Swarm alternatives, when present, are also real pool products.
            for (final alt in line.alternatives) {
              expect(poolSkus.contains(alt.sku), isTrue,
                  reason: 'swarm alternative ${alt.sku} not in kDivePool '
                      '(recipe="${recipe.key}" acc#$i)');
            }
          }
        }
      }
    });

    test('resolveAccessory is deterministic (same acc → same line)', () {
      // Re-resolve every accessory twice; the binding must be identical (the
      // engine is documented PURE — ties broken by pool order, no randomness).
      for (final recipe in kSmartProducts) {
        for (final acc in recipe.acc) {
          final a = resolveAccessory(acc);
          final b = resolveAccessory(acc);
          expect(a.match, b.match,
              reason: 'match drifted for "${acc.name}" in "${recipe.key}"');
          expect(a.product?.sku, b.product?.sku,
              reason: 'product drifted for "${acc.name}" in "${recipe.key}"');
          expect(a.score, b.score,
              reason: 'score drifted for "${acc.name}" in "${recipe.key}"');
        }
      }
    });
  });

  // ── buildWordLexicon / quickLabel ──────────────────────────────────────-
  //
  // INVARIANTS (word_lexicon.dart 67-108; quick_pad_engine.dart 80-90):
  //   • buildWordLexicon is deterministic over random subsets (same pool in →
  //     identical entries + wordToSkus out);
  //   • no empty-string word KEYS (a word is only added after a non-empty token
  //     or a non-empty fallback — line 83 `continue`s on empty);
  //   • each entry.freq == entry.skus.length, and wordToSkus[word] == entry.skus;
  //   • quickLabel never returns empty for a REAL product (lines 80-90 guarantee
  //     a non-empty token / fallback / trimmed nameHe — every pooled product has
  //     a non-blank nameHe).
  group('buildWordLexicon / quickLabel — invariants', () {
    test('quickLabel never empty for any real pool product; deterministic', () {
      for (final p in pool) {
        final l1 = quickLabel(p);
        final l2 = quickLabel(p);
        expect(l1, l2, reason: 'quickLabel not deterministic for ${p.sku}');
        expect(l1, isNotEmpty,
            reason: 'quickLabel returned empty for sku=${p.sku} '
                '(nameHe="${p.nameHe}", cat="${p.categoryHe}")');
      }
    });

    test('buildWordLexicon: no empty keys; freq==skus.length; map matches',
        () {
      // The real lexicon first.
      void verify(WordLexicon lex, String tag) {
        for (final e in lex.entries) {
          expect(e.word, isNotEmpty,
              reason: 'empty-string word key in lexicon [$tag]');
          expect(e.freq, e.skus.length,
              reason: 'freq != skus.length for "${e.word}" [$tag]');
          expect(e.skus, isNotEmpty,
              reason: 'a word entry must name >=1 sku ("${e.word}") [$tag]');
          // wordToSkus is the same list the entry carries.
          expect(lex.wordToSkus[e.word], same(e.skus),
              reason: 'wordToSkus["${e.word}"] != entry.skus [$tag]');
        }
        // No empty key in the map either.
        expect(lex.wordToSkus.keys.any((k) => k.isEmpty), isFalse,
            reason: 'empty-string key in wordToSkus [$tag]');
        // entries and wordToSkus cover the same word set.
        expect({for (final e in lex.entries) e.word}, lex.wordToSkus.keys.toSet(),
            reason: 'entries / wordToSkus word-set mismatch [$tag]');
      }

      verify(lexicon, 'real-pool');

      // Determinism + the same invariants over random subsets.
      final rng = Random(kSeed);
      for (var i = 0; i < kIters; i++) {
        final p = randomSubset(rng, rng.nextInt(60));
        late final WordLexicon a;
        expect(() => a = buildWordLexicon(p), returnsNormally,
            reason: 'buildWordLexicon threw [iter#$i seed=$kSeed]');
        final b = buildWordLexicon(p);
        // Deterministic: identical ordered word lists and freqs.
        expect(
          [for (final e in a.entries) '${e.word}:${e.freq}:${e.sourceKind}'],
          [for (final e in b.entries) '${e.word}:${e.freq}:${e.sourceKind}'],
          reason: 'buildWordLexicon not deterministic [iter#$i seed=$kSeed]',
        );
        verify(a, 'iter#$i');
      }
    });

    test('resolveWord round-trips lexicon skus to real pool products', () {
      // For every lexicon word, resolveWord must recover products that are all
      // genuine pool members (skips unknown skus — but there should be none,
      // since the lexicon is built from the same pool).
      final poolSkus = {for (final p in pool) p.sku};
      for (final e in lexicon.entries) {
        final got = resolveWord(e.word, lexicon);
        for (final pr in got) {
          expect(poolSkus.contains(pr.sku), isTrue,
              reason: 'resolveWord("${e.word}") yielded non-pool sku ${pr.sku}');
        }
      }
    });
  });

  // ── connectionsFor / isConnectionAnchor (7th engine) ────────────────────-
  //
  // BONUS invariants (word_finder_engine.dart 570-598): connectionsFor never
  // throws; returns [] for a non-anchor; when non-empty, every connected product
  // is in kDivePool AND the anchor is never returned as its own connection.
  group('connectionsFor — invariants over random anchors', () {
    test('never throws; non-anchor→[]; results are real pool, exclude self', () {
      final rng = Random(kSeed);
      final poolSkus = {for (final p in pool) p.sku};
      for (var i = 0; i < kIters; i++) {
        final anchor = pool[rng.nextInt(pool.length)];
        late final List<LipskeyCatalogProduct> conns;
        expect(() => conns = connectionsFor(anchor), returnsNormally,
            reason: 'connectionsFor threw for sku=${anchor.sku} [iter#$i]');
        if (!isConnectionAnchor(anchor)) {
          expect(conns, isEmpty,
              reason: 'a non-anchor must yield no connections '
                  '(sku=${anchor.sku}) [iter#$i]');
        }
        for (final c in conns) {
          expect(poolSkus.contains(c.sku), isTrue,
              reason: 'connection ${c.sku} not in kDivePool [iter#$i]');
          expect(c.sku == anchor.sku, isFalse,
              reason: 'anchor returned as its own connection '
                  '(sku=${anchor.sku}) [iter#$i]');
        }
        // isConnectionAnchor only true when the index says inCompat && hasSpec.
        if (isConnectionAnchor(anchor)) {
          final m = divePoolIndex[anchor.sku];
          expect(m != null && m.inCompat && m.hasSpec, isTrue,
              reason: 'isConnectionAnchor true but membership says otherwise '
                  '(sku=${anchor.sku}) [iter#$i]');
        }
      }
    });
  });

  // ── narrowAxis vs offerAxis consistency ─────────────────────────────────-
  //
  // offerAxis is documented (dive_pool.dart 106-110) as a thin pass-through to
  // narrowAxis. Property: for ANY pool+subtype the two return byte-identical
  // (label, chips). A regression here would mean the finder's two entry points
  // drifted.
  group('offerAxis == narrowAxis (pass-through invariant)', () {
    test('identical label + chips for random + edge pools', () {
      final rng = Random(kSeed);
      const subtypes = <String?>[null, 'מכסים ורשתות', 'מחסומי רצפה', 'bogus'];
      void check(List<LipskeyCatalogProduct> p, String? sub, String tag) {
        final a = offerAxis(p, sub);
        final b = narrowAxis(p, sub);
        expect(a.label, b.label,
            reason: 'offerAxis/narrowAxis label drift [$tag sub=$sub]');
        expect(a.chips, b.chips,
            reason: 'offerAxis/narrowAxis chips drift [$tag sub=$sub]');
      }

      final shapes = edgeShapes();
      for (var s = 0; s < shapes.length; s++) {
        for (final sub in subtypes) {
          check(shapes[s], sub, 'edge#$s');
        }
      }
      for (var i = 0; i < kIters; i++) {
        final p = randomSubset(rng, rng.nextInt(40));
        check(p, subtypes[rng.nextInt(subtypes.length)], 'iter#$i');
      }
    });
  });
}
