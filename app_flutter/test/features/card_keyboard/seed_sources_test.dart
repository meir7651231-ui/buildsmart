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
}
