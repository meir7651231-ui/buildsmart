import 'package:buildsmart/features/card_keyboard/card_seed.dart';
import 'package:buildsmart/features/card_keyboard/seed_sources.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
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
}
