import 'dart:math' show Random;

import 'package:buildsmart/data/smart_tree.dart' show kSmartProducts;
import 'package:buildsmart/features/card_keyboard/card_seed.dart';
import 'package:buildsmart/features/card_keyboard/seed_sources.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/material_lexicon.dart'
    show materialOfEnriched, materialsInPoolEnriched;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show kFirstWordCount;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show buildWordLexicon;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lex = buildWordLexicon(kDivePool);

  group('wordSeeds (P6.52)', () {
    test('collapsed shows exactly the top-kFirstWordCount (24)', () {
      expect(wordSeeds(lex).length, kFirstWordCount);
      expect(kFirstWordCount, 24);
    });

    test('expanded shows the full long tail (more than collapsed)', () {
      expect(wordSeeds(lex, expanded: true).length,
          greaterThan(wordSeeds(lex).length));
    });

    test('every word seed carries the word mouth id + axis sentinel', () {
      for (final s in wordSeeds(lex)) {
        expect(s.mouthId, kWordMouth);
        expect(s.seedAxisLabel, kWordSeedAxis);
        expect(s.displayLabel, isNotEmpty);
      }
    });

    test('a word seed admits a non-empty subset of the pool', () {
      final first = wordSeeds(lex).first;
      final admitted = kDivePool.where(first.seedPredicate).toList();
      expect(admitted, isNotEmpty);
      expect(admitted.length, lessThanOrEqualTo(kDivePool.length));
    });
  });

  group('materialSeeds (P6.53)', () {
    test('one seed per enriched material in the pool', () {
      final seeds = materialSeeds(kDivePool);
      expect(seeds.map((s) => s.displayLabel).toSet(),
          materialsInPoolEnriched(kDivePool).toSet());
      for (final s in seeds) {
        expect(s.mouthId, kMaterialMouth);
        expect(s.seedAxisLabel, kMaterialSeedAxis);
      }
    });

    test('the נחושת seed admits ONLY copper-material products (rejects steel)',
        () {
      final copper = materialSeeds(kDivePool)
          .firstWhere((s) => s.displayLabel == 'נחושת');
      final admitted = kDivePool.where(copper.seedPredicate).toList();
      expect(admitted, isNotEmpty);
      for (final p in admitted) {
        expect(materialOfEnriched(p), 'נחושת',
            reason: 'a פלדה product can never be in the נחושת seed');
      }
    });

    test('brass folds into copper — no separate פליז seed', () {
      final labels =
          materialSeeds(kDivePool).map((s) => s.displayLabel).toSet();
      expect(labels, contains('נחושת'));
      expect(labels, isNot(contains('פליז')),
          reason: 'פליז folds into נחושת, never its own material seed');
    });
  });

  group('jobSeeds (P6.54)', () {
    test('one seed per smart product (recipe)', () {
      final seeds = jobSeeds();
      expect(seeds.length, kSmartProducts.length);
      for (final s in seeds) {
        expect(s.mouthId, kJobMouth);
        expect(s.seedAxisLabel, kJobSeedAxis);
      }
    });

    test('some job seeds admit real pool products (bound kit skus)', () {
      final resolving = jobSeeds().where((s) => kDivePool.any(s.seedPredicate));
      expect(resolving, isNotEmpty,
          reason: 'recipes resolve to real catalog skus, never invented');
    });
  });

  group('categorySeeds (P6.55)', () {
    test('the buckets cover 100% of the pool — ZERO orphan', () {
      final covered = <String>{};
      for (final s in categorySeeds(kDivePool)) {
        for (final p in kDivePool.where(s.seedPredicate)) {
          covered.add(p.sku);
        }
      }
      expect(covered, kDivePool.map((p) => p.sku).toSet(),
          reason: 'every card must land in some bucket (incl. אחר)');
    });

    test('buckets are disjoint — a card is in exactly one group', () {
      final counts = <String, int>{};
      for (final s in categorySeeds(kDivePool)) {
        for (final p in kDivePool.where(s.seedPredicate)) {
          counts[p.sku] = (counts[p.sku] ?? 0) + 1;
        }
      }
      expect(counts.values.every((c) => c == 1), isTrue,
          reason: 'groupOf is a function -> exactly one bucket per card');
    });

    test('every category seed carries the category mouth id + axis sentinel', () {
      for (final s in categorySeeds(kDivePool)) {
        expect(s.mouthId, kCategoryMouth);
        expect(s.seedAxisLabel, kCategorySeedAxis);
      }
    });
  });

  group('seed source invariants (P6.61 — fuzz)', () {
    List<String> labels(List<CardSeed> s) => [for (final x in s) x.displayLabel];

    test('material/category seeds are SHUFFLE-STABLE (input order irrelevant)',
        () {
      final shuffled = List.of(kDivePool)..shuffle(Random(7));
      expect(labels(materialSeeds(shuffled)).toSet(),
          labels(materialSeeds(kDivePool)).toSet());
      // categorySeeds sorts its groups, so even the order is identical
      expect(labels(categorySeeds(shuffled)), labels(categorySeeds(kDivePool)));
    });

    test('all four sources are PURE — a second call is equivalent', () {
      expect(labels(wordSeeds(lex)), labels(wordSeeds(lex)));
      expect(labels(materialSeeds(kDivePool)), labels(materialSeeds(kDivePool)));
      expect(labels(jobSeeds()), labels(jobSeeds()));
      expect(labels(categorySeeds(kDivePool)), labels(categorySeeds(kDivePool)));
    });

    test('every seed admits ONLY pool products (no orphan / invention)', () {
      final poolSkus = kDivePool.map((p) => p.sku).toSet();
      final all = [
        ...wordSeeds(lex),
        ...materialSeeds(kDivePool),
        ...jobSeeds(),
        ...categorySeeds(kDivePool),
      ];
      for (final seed in all) {
        for (final p in kDivePool.where(seed.seedPredicate)) {
          expect(poolSkus.contains(p.sku), isTrue);
        }
      }
    });

    test('each source stamps its own mouth id + axis sentinel', () {
      void check(List<CardSeed> seeds, String mouth, String axis) {
        for (final s in seeds) {
          expect(s.mouthId, mouth);
          expect(s.seedAxisLabel, axis);
        }
      }

      check(wordSeeds(lex), kWordMouth, kWordSeedAxis);
      check(materialSeeds(kDivePool), kMaterialMouth, kMaterialSeedAxis);
      check(jobSeeds(), kJobMouth, kJobSeedAxis);
      check(categorySeeds(kDivePool), kCategoryMouth, kCategorySeedAxis);
    });
  });
}
