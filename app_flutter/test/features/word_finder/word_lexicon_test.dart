// Unit tests for the build-time WORD LEXICON (STEP 2, word_lexicon.dart +
// word_extraction.dart).
//
// Pure-Dart assertions — no widgets pumped — building the lexicon from the real
// kDivePool and verifying that (a) a common plain word names more than one sku,
// and (b) NO blocked brand prefix ever leaks in as a lookup key (the adversarial
// byte-verify the swarm requires).

import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/word_extraction.dart';
import 'package:buildsmart/features/word_finder/word_lexicon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lex = buildWordLexicon(kDivePool);

  group('buildWordLexicon(kDivePool)', () {
    test('(a) a common plain word names >1 sku', () {
      // At least one of these everyday plumbing words must exist AND map to
      // more than one product — proof the lexicon actually buckets the pool.
      const common = ['ברך', 'צינור', 'ברז'];
      final present = common
          .where((w) => (lex.wordToSkus[w]?.length ?? 0) > 1)
          .toList();
      expect(present, isNotEmpty,
          reason: 'expected at least one of $common to name >1 sku; '
              'lexicon has ${lex.wordToSkus.length} words');

      // And the entries/map agree on that word's sku count (freq invariant).
      final w = present.first;
      final entry = lex.entries.firstWhere((e) => e.word == w);
      expect(entry.freq, lex.wordToSkus[w]!.length);
      expect(entry.freq, greaterThan(1));
    });

    test('(b) NO blocked brand prefix is ever a key (adversarial)', () {
      for (final brand in kBrandPrefixBlocklist) {
        expect(lex.wordToSkus.containsKey(brand), isFalse,
            reason: 'blocked brand "$brand" leaked into the lexicon as a key');
      }
      // Spot the two named in the swarm brief explicitly.
      expect(lex.wordToSkus.containsKey('סיגמא'), isFalse);
      expect(lex.wordToSkus.containsKey('דיור'), isFalse);
    });

    test('every entry agrees with wordToSkus (freq + ordering invariant)', () {
      // entries and wordToSkus are the same data in the same first-seen order.
      expect(lex.entries.length, lex.wordToSkus.length);
      for (final e in lex.entries) {
        expect(e.freq, e.skus.length, reason: 'freq must equal sku count');
        expect(lex.wordToSkus[e.word], same(e.skus),
            reason: 'entry and map must share the SAME sku list for ${e.word}');
        expect(const ['token', 'category', 'curated'].contains(e.sourceKind),
            isTrue,
            reason: 'unexpected sourceKind "${e.sourceKind}"');
      }
    });

    test('lexicon is deterministic — same pool builds identically', () {
      final again = buildWordLexicon(kDivePool);
      expect(again.entries.map((e) => e.word).toList(),
          lex.entries.map((e) => e.word).toList(),
          reason: 'word order must be stable across builds');
      expect(again.wordToSkus.length, lex.wordToSkus.length);
    });
  });

  group('word_extraction primitives', () {
    test('firstMeaningfulToken skips a leading brand prefix', () {
      // "דיור ראש מקלחת…" → first non-brand real word is 'ראש'.
      expect(firstMeaningfulToken('דיור ראש מקלחת עגול 250 מ"מ',
              kBrandPrefixBlocklist),
          'ראש');
      // "קיסר ברז נשלף למטבח" → 'ברז'.
      expect(firstMeaningfulToken('קיסר ברז נשלף למטבח שחור מט',
              kBrandPrefixBlocklist),
          'ברז');
    });

    test('firstMeaningfulToken skips pure-number/size tokens', () {
      // Leading size + fraction are dropped; the real word wins.
      expect(firstMeaningfulToken('250 ברך 87', const <String>{}), 'ברך');
      // All-numeric/symbol name yields null (caller uses category fallback).
      expect(firstMeaningfulToken('1/2" 250', const <String>{}), isNull);
    });

    test('canonicalizeWord is identity with the EMPTY default synonyms', () {
      expect(canonicalizeWord('זווית', kWordSynonyms), 'זווית');
    });

    test('kWordSynonyms is empty pending owner sign-off', () {
      expect(kWordSynonyms, isEmpty);
    });
  });
}
