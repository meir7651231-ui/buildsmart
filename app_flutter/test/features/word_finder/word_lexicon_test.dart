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
      // Spot the two seed brands named in the swarm brief explicitly.
      expect(lex.wordToSkus.containsKey('סיגמא'), isFalse);
      expect(lex.wordToSkus.containsKey('דיור'), isFalse);
      // The 18 NEW brand prefixes must ALSO never be keys (verified to lead a
      // name, surfacing the real noun behind them). ג'נבה/אנג'ל use ASCII '.
      const newBrands = [
        'טרפז', 'טולדו', 'טיטוניק', "ג'נבה", 'אוסלו', "אנג'ל", 'גאלרי',
        'גל', 'פלורה', 'כנרת', 'הוואי', 'אלפא', 'ויגה', 'גליל', 'דלתא',
        'זקיף', 'פיטרה', 'בתא',
      ];
      for (final brand in newBrands) {
        expect(kBrandPrefixBlocklist.contains(brand), isTrue,
            reason: 'new brand "$brand" must be in the blocklist');
        expect(lex.wordToSkus.containsKey(brand), isFalse,
            reason: 'new brand "$brand" leaked into the lexicon as a key');
      }
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

    test('canonicalizeWord folds a synonym onto its canonical word', () {
      // 'זווית' (elbow) now folds onto the canonical elbow word 'ברך'; an
      // unmapped word passes through unchanged.
      expect(canonicalizeWord('זווית', kWordSynonyms), 'ברך');
      expect(canonicalizeWord('צינור', kWordSynonyms), 'צינור');
    });

    test('kWordSynonyms maps the signed-off folds (and NOT the rejected ones)',
        () {
      // The owner-signed-off folds: tee family → מסעף, elbow → ברך, coupler
      // family → מצמד, reducer plural → מצרה, plus two tokenizer/leak fixes.
      expect(kWordSynonyms['טי'], 'מסעף');
      expect(kWordSynonyms['הסתעפות'], 'מסעף');
      expect(kWordSynonyms['סעף'], 'מסעף');
      expect(kWordSynonyms['זווית'], 'ברך');
      expect(kWordSynonyms['מקשר'], 'מצמד');
      expect(kWordSynonyms['מופה'], 'מצמד');
      expect(kWordSynonyms['מצרות'], 'מצרה');
      expect(kWordSynonyms['פלוס'], 'תעלה');
      expect(kWordSynonyms['אל'], 'אל-חזור');
      // Explicitly REJECTED pairs must NOT be present (distinct products).
      expect(kWordSynonyms.containsKey('מחבר'), isFalse,
          reason: "'מחבר גמיש' flex-connectors must NOT fold into מצמד");
      expect(kWordSynonyms.containsKey('מקטין'), isFalse,
          reason: "'מקטין לחץ' pressure-reducer must NOT fold into מצרה");
    });

    test('a folded word resolves into its canonical bucket, not its own key',
        () {
      // After folding, the source words ('זווית','טי','הסתעפות') are NOT their
      // own lexicon keys — their products live under the canonical word.
      for (final folded in const ['זווית', 'טי', 'הסתעפות']) {
        expect(lex.wordToSkus.containsKey(folded), isFalse,
            reason: '"$folded" folds into its canonical word — not a key');
      }
      // And the canonical targets are real keys naming products.
      for (final canon in const ['ברך', 'מסעף']) {
        expect((lex.wordToSkus[canon]?.length ?? 0) > 1, isTrue,
            reason: 'canonical word "$canon" must name >1 sku after folding');
      }
    });
  });
}
