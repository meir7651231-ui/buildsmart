// Unit tests for the build-time WORD LEXICON (STEP 2, word_lexicon.dart +
// word_extraction.dart).
//
// Pure-Dart assertions — no widgets pumped — building the lexicon from the real
// kDivePool and verifying that (a) a common plain word names more than one sku,
// and (b) NO blocked brand prefix ever leaks in as a lookup key (the adversarial
// byte-verify the swarm requires).

import 'package:buildsmart/data/lipskey_catalog.dart';
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
      // The 17 NEW brand prefixes must ALSO never be keys (verified to lead a
      // name, surfacing the real noun behind them). ג'נבה/אנג'ל use ASCII '.
      // ('זקיף' was REMOVED — the canonical audit found it is a product noun,
      // not a brand prefix; it is asserted to be a real key below.)
      const newBrands = [
        'טרפז', 'טולדו', 'טיטוניק', "ג'נבה", 'אוסלו', "אנג'ל", 'גאלרי',
        'גל', 'פלורה', 'כנרת', 'הוואי', 'אלפא', 'ויגה', 'גליל', 'דלתא',
        'פיטרה', 'בתא',
      ];
      for (final brand in newBrands) {
        expect(kBrandPrefixBlocklist.contains(brand), isTrue,
            reason: 'new brand "$brand" must be in the blocklist');
        expect(lex.wordToSkus.containsKey(brand), isFalse,
            reason: 'new brand "$brand" leaked into the lexicon as a key');
      }
      // REGRESSION (canonical audit, data-seed): 'זקיף' was wrongly blocklisted
      // as a brand. It is the product noun ('זקיף אסלה', sku 121216); while
      // blocked, that product mis-keyed to 'אסלה' and was unsearchable. After the
      // fix it must be OUT of the blocklist AND present as a real lexicon key.
      expect(kBrandPrefixBlocklist.contains('זקיף'), isFalse,
          reason: 'זקיף is a product noun, not a brand prefix (audit fix)');
      expect(lex.wordToSkus.containsKey('זקיף'), isTrue,
          reason: 'זקיף must now be a searchable lexicon key (sku 121216)');
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

  group('buildWordLexicon — category fallback branch (brand-led names)', () {
    // No REAL catalog product yields a NULL first meaningful token (every real
    // nameHe has a real noun after its brand prefix), so the category-fallback
    // branch is exercised with MINIMAL synthetic products whose nameHe is a
    // blocked brand prefix + numbers ONLY — the exact shape the branch exists
    // for ("all brand + numbers"). Built over a small controlled pool (not
    // kDivePool) so the fallback word's first-seen source is observably
    // 'category' rather than being shadowed by a real token-sourced entry.

    // 'בתא' is a blocked brand prefix; the rest are digit-bearing → no real word
    // survives → firstMeaningfulToken returns null → the category fallback runs.
    const brandLedSeeded = LipskeyCatalogProduct(
      sku: 'SYN-FALLBACK', nameHe: 'בתא 1/2" 250', nameEn: 'bta 1/2" 250',
      categoryHe: 'ברזי כיור', // seeded → kCategoryFallbackWord['ברזי כיור']='ברז'
      categoryEn: 'sink taps', categoryEmoji: '🚰', page: 1,
    );
    // Same null-token shape, but an UNSEEDED category → fallback is null → the
    // product is dropped from the lexicon (the `continue`).
    const brandLedUnseeded = LipskeyCatalogProduct(
      sku: 'SYN-DROP', nameHe: 'סיגמא 3/4" 40', nameEn: 'sigma 3/4" 40',
      categoryHe: 'קטגוריה-לא-זרועה-בכלל', // deliberately NOT in the fallback map
      categoryEn: 'no-fallback', categoryEmoji: '❓', page: 1,
    );
    // A normal product so the pool also has a 'token'-sourced control word.
    const tokenControl = LipskeyCatalogProduct(
      sku: 'SYN-TOKEN', nameHe: 'מחבר עגול', nameEn: 'connector round',
      categoryHe: 'מחברים', categoryEn: 'connectors', categoryEmoji: '🔩',
      page: 1,
    );

    test('a brand+number name in a SEEDED category falls back to the category '
        'word (sourceKind category)', () {
      // Guard the fixture: the first meaningful token really is null, and the
      // category really has a seeded fallback word.
      expect(firstMeaningfulToken(brandLedSeeded.nameHe, kBrandPrefixBlocklist),
          isNull,
          reason: 'brand+numbers ⇒ no meaningful token ⇒ the fallback fires');
      final fallbackWord = kCategoryFallbackWord[brandLedSeeded.categoryHe];
      expect(fallbackWord, 'ברז',
          reason: 'ברזי כיור is a seeded category fallback');

      final lex = buildWordLexicon(const [brandLedSeeded, tokenControl]);
      // The fallback word IS a key, names the fallback product, and is labelled
      // 'category' (the branch's distinctive output).
      final entry =
          lex.entries.firstWhere((e) => e.word == 'ברז', orElse: () {
        fail('the category-fallback word ברז must be a lexicon entry');
      });
      expect(entry.skus, contains(brandLedSeeded.sku),
          reason: 'the brand-led product is bucketed under its category word');
      expect(entry.sourceKind, 'category',
          reason: 'a word that came from kCategoryFallbackWord is source '
              "'category' — the branch under test");
      expect(lex.wordToSkus['ברז'], contains(brandLedSeeded.sku));
      // Control: the normal product is token-sourced, proving the two paths
      // diverge on source.
      expect(lex.entries.firstWhere((e) => e.word == 'מחבר').sourceKind,
          'token');
    });

    test('a brand+number name in an UNSEEDED category is DROPPED (continue)',
        () {
      // The unseeded category must genuinely have no fallback, else this would
      // not exercise the `continue`.
      expect(firstMeaningfulToken(
              brandLedUnseeded.nameHe, kBrandPrefixBlocklist),
          isNull);
      expect(kCategoryFallbackWord.containsKey(brandLedUnseeded.categoryHe),
          isFalse,
          reason: 'fixture category must have NO seeded fallback word');

      final lex = buildWordLexicon(const [brandLedUnseeded, tokenControl]);
      // The dropped product's sku appears under NO word — it has no searchable
      // word, so the lexicon omits it entirely (the `continue` path).
      for (final e in lex.entries) {
        expect(e.skus.contains(brandLedUnseeded.sku), isFalse,
            reason: 'a brand+number product with no category fallback is '
                'dropped — never keyed under any word');
      }
      // Only the token-sourced control survives.
      expect(lex.entries.map((e) => e.word).toList(), <String>['מחבר'],
          reason: 'exactly the one product that yields a word remains');
    });
  });
}
