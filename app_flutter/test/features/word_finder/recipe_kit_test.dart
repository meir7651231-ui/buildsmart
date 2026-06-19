// Tests for the WORK-RECIPE data-bridge (engine #6, recipe_kit.dart).
//
// HARNESS: runs under `flutter_test`, NOT a bare `dart test`. recipe_kit imports
// `searchRelevance` from `screens/catalog_screen.dart`, which transitively pulls
// `package:flutter/...` into the chain (the same pre-existing coupling every
// other word-finder library carries — see word_finder_engine.dart's note). The
// logic under test is pure; the harness choice is only about that import chain.
//
// The fixtures below (מד לחץ → auto, אטם → ambiguous, basin's curated סיפון, the
// real coverage totals) were all confirmed against the live tree + catalog, not
// guessed: accessory names do NOT necessarily appear in catalog product names
// (e.g. "טפלון" is absent from every catalog name), so the verdicts are anchored
// to actual `searchRelevance` output.

// The coverage test intentionally prints the real curated/auto/ambiguous/none
// numbers so they surface in the gate output (that visibility is the whole point
// of the coverage test), so avoid_print is disabled for this test file.
// ignore_for_file: avoid_print

import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/features/word_finder/recipe_kit.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a bare name-only [SmartAcc] for ad-hoc resolution tests.
SmartAcc _acc(String name) =>
    SmartAcc(name: name, emoji: '', why: '', must: true);

void main() {
  group('resolveAccessory', () {
    test('(curated) an accessory that already carries a sku → KitMatch.curated, '
        'bound to that exact product', () {
      // basin ("כיור אמבטיה") lists סיפון לכיור with the owner sku 217861, a real
      // catalog product (American bottle trap). It must bind as curated to 217861.
      final basin = kSmartProducts.firstWhere((p) => p.key == 'basin');
      final sipon = basin.acc.firstWhere((a) => a.sku == '217861');

      final line = resolveAccessory(sipon);

      expect(line.match, KitMatch.curated);
      expect(line.product, isNotNull);
      expect(line.product!.sku, '217861',
          reason: 'curated binding must resolve to the owner-set sku');
      expect(line.acc, same(sipon),
          reason: 'the line carries the original SmartAcc');
    });

    test('(precedence) a ranked override wins over the auto scorer — מד לחץ '
        'resolves as swarm, not auto', () {
      // "מד לחץ" scores high enough for the scorer to auto-match it, but it is
      // ALSO in the swarm-ranked overrides — and the override layer (1b) runs
      // BEFORE the scorer (2), so it resolves as KitMatch.swarm (the ranked
      // recommended), not KitMatch.auto. With the ranked overrides in place the
      // auto scorer-branch is shadowed for all current recipe data (auto == 0);
      // the branch stays as a defensive fallback for a future un-ranked name.
      final line = resolveAccessory(_acc('מד לחץ'));
      expect(line.match, KitMatch.swarm,
          reason: 'the ranked override takes precedence over the auto scorer');
      expect(line.product, isNotNull,
          reason: 'the top ranked sku binds to a real pooled product');
    });

    test('(ambiguous) a generic name ("אטם") → KitMatch.ambiguous, NOT auto', () {
      // Dozens of catalog products are literally named with "אטם" (אטם כדורי, אטם
      // דו צדדי, …), so the top score TIES across many products (margin 0). It
      // must be flagged for owner review, never auto-bound — even though its raw
      // top score (120) is high.
      final line = resolveAccessory(_acc('אטם'));

      expect(line.match, KitMatch.ambiguous,
          reason: 'a generic name with many tied candidates must be ambiguous');
      expect(line.match, isNot(KitMatch.auto),
          reason: 'high raw score must NOT auto-bind when the margin is small');
      expect(line.product, isNotNull,
          reason: 'ambiguous keeps the best candidate for owner review');
    });

    test('(none) a name absent from the catalog → KitMatch.none, no product', () {
      // "משקוף" (door frame) has no catalog counterpart — score 0.
      final line = resolveAccessory(_acc('משקוף'));

      expect(line.match, KitMatch.none);
      expect(line.product, isNull,
          reason: 'a none verdict attaches no product');
    });

    test('(regression) a single-token generic never auto-binds, even if it hits '
        'exactly ONE product name', () {
      // LATENT FALSE-AUTO guard: a one-word accessory whose token coincidentally
      // appears in just one product scores at most ~120 (+100 whole-phrase, +20
      // token) with a LARGE margin — under the old floor (40) that wrongly
      // auto-bound. The auto floor is now 140 (a genuine TWO-token whole-phrase
      // match), structurally above the single-token ceiling, so a lone generic
      // word can never reach auto. "בורג" (screw) is exactly such a name.
      final line = resolveAccessory(_acc('בורג'));
      expect(line.match, isNot(KitMatch.auto),
          reason: 'a single-token name (max ~120) must never reach the auto '
              'floor (140) — it stays ambiguous/none for owner review');
    });

    test('(swarm) a ranked accessory → KitMatch.swarm with recommended + '
        'alternatives', () {
      // 'מחסום רצפה' has a swarm-ranked candidate list (best first). It resolves
      // to swarm: product = the RECOMMENDED (top), alternatives = the rest — the
      // "take this, or here are other options" model. No owner pick needed.
      final line = resolveAccessory(_acc('מחסום רצפה'));
      expect(line.match, KitMatch.swarm,
          reason: 'a ranked accessory resolves as swarm');
      expect(line.product, isNotNull,
          reason: 'the top ranked sku binds to a real pooled product');
      expect(line.alternatives, isNotEmpty,
          reason: 'a multi-candidate accessory offers alternatives beside the '
              'recommended default');
      for (final alt in line.alternatives) {
        expect(alt.sku, isNot(line.product!.sku),
            reason: 'an alternative is never a duplicate of the recommended top');
      }
    });

    test('every line falls in exactly one bucket (enum is total)', () {
      for (final recipe in kSmartProducts) {
        for (final a in recipe.acc) {
          final m = resolveAccessory(a).match;
          expect(KitMatch.values, contains(m));
        }
      }
    });
  });

  group('assembleKit', () {
    test('returns one line per accessory, in order, for a known recipe', () {
      // basinTrap (סיפון לכיור רחצה) — a known recipe with a fixed accessory list.
      final recipe =
          kSmartProducts.firstWhere((p) => p.key == 'basinTrap');

      final kit = assembleKit(recipe);

      expect(kit.length, recipe.acc.length,
          reason: 'one KitLine per SmartAcc');
      // Same order, same underlying accessories.
      for (var i = 0; i < kit.length; i++) {
        expect(kit[i].acc, same(recipe.acc[i]),
            reason: 'line $i must wrap accessory $i (order preserved)');
      }
    });

    test('every recipe in the tree assembles a kit of matching length', () {
      for (final recipe in kSmartProducts) {
        expect(assembleKit(recipe).length, recipe.acc.length,
            reason: 'recipe ${recipe.key}: line count == accessory count');
      }
    });
  });

  group('measureKitCoverage', () {
    test('prints the REAL coverage and holds sane bounds', () {
      final cov = measureKitCoverage();

      // The true total = every SmartAcc across every recipe (computed live, so
      // this stays correct no matter how the tree grows).
      final liveTotal =
          kSmartProducts.fold<int>(0, (n, r) => n + r.acc.length);

      // ── PRINT the real numbers so they show up in the gate output. ──
      String pct(double r) => '${(r * 100).toStringAsFixed(1)}%';
      print('=== RECIPE-KIT COVERAGE (engine #6) ===');
      print('total accessories : ${cov.total}');
      print('curated  : ${cov.curated}  (${pct(cov.curatedRatio)})');
      print('auto     : ${cov.auto}  (${pct(cov.autoRatio)})');
      print('swarm    : ${cov.swarm}  (${pct(cov.swarmRatio)})');
      print('ambiguous: ${cov.ambiguous}  (${pct(cov.ambiguousRatio)})');
      print('none     : ${cov.none}  (${pct(cov.noneRatio)})');
      print('resolved (curated+auto+swarm): ${cov.resolved}  '
          '(${pct(cov.resolvedRatio)})');

      // ── Sane bounds. ──
      expect(cov.total, liveTotal,
          reason: "total must equal the sum of every recipe's accessories");
      expect(cov.curated + cov.auto + cov.swarm + cov.ambiguous + cov.none,
          cov.total,
          reason: 'every accessory lands in exactly one bucket');
      expect(cov.resolved, greaterThan(0),
          reason: 'curated + auto + swarm must be > 0 (the bridge resolves '
              'something)');
      // Each bucket is a non-negative share of the whole.
      for (final n in [
        cov.curated,
        cov.auto,
        cov.swarm,
        cov.ambiguous,
        cov.none,
      ]) {
        expect(n, greaterThanOrEqualTo(0));
        expect(n, lessThanOrEqualTo(cov.total));
      }
      expect(cov.resolvedRatio, inInclusiveRange(0.0, 1.0));
    });

    test('per-recipe breakdown covers every recipe and sums to the totals', () {
      final cov = measureKitCoverage();

      expect(cov.perRecipe.length, kSmartProducts.length,
          reason: 'one breakdown entry per recipe');
      for (final r in kSmartProducts) {
        expect(cov.perRecipe.containsKey(r.key), isTrue,
            reason: 'recipe ${r.key} must appear in the breakdown');
        expect(cov.perRecipe[r.key]!.total, r.acc.length,
            reason: 'recipe ${r.key}: per-recipe total == its accessory count');
      }
      // The per-recipe buckets must re-sum to the aggregate buckets.
      final sumTotal =
          cov.perRecipe.values.fold<int>(0, (n, c) => n + c.total);
      final sumResolved =
          cov.perRecipe.values.fold<int>(0, (n, c) => n + c.resolved);
      expect(sumTotal, cov.total);
      expect(sumResolved, cov.resolved);
    });
  });
}
