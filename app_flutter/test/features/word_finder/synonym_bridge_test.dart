import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/material_lexicon.dart'
    show kMaterials;
import 'package:buildsmart/features/word_finder/synonym_bridge.dart';
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show buildWordLexicon;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kQuerySynonyms values cover every kMaterials key', () {
    expect(kQuerySynonyms.values.toSet().containsAll(kMaterials.keys), isTrue,
        reason: 'every material query needs an alias path to its canonical key');
  });

  test('PPR stays PPR — no PP substring fire (word-boundary)', () {
    expect(normalizeQuery('PPR'), 'PPR');
  });

  test('copper / brass / פליז all fold to נחושת', () {
    expect(normalizeQuery('copper'), 'נחושת');
    expect(normalizeQuery('brass'), 'נחושת');
    expect(normalizeQuery('פליז'), 'נחושת');
  });

  test('a mixed query folds each token', () {
    expect(normalizeQuery('copper PPR ברז'), 'נחושת PPR ברז');
  });

  test('מרפק → ברך (everyday-noun alias)', () {
    expect(normalizeQuery('מרפק'), 'ברך');
  });

  test('case-insensitive for Latin aliases', () {
    expect(normalizeQuery('Copper'), 'נחושת');
  });

  test('idempotent', () {
    final once = normalizeQuery('copper פליז מרפק');
    expect(normalizeQuery(once), once);
  });

  group('resolveQuery (P4.55 — the copper text-search fix)', () {
    final lex = buildWordLexicon(kDivePool);

    test('a material token resolves to its SUBSET, not the whole pool', () {
      final copper = resolveQuery('נחושת', lex);
      expect(copper, isNotEmpty);
      expect(copper.length, lessThan(kDivePool.length),
          reason: 'נחושת routes to productsOfMaterial, never dumps the pool');
      // copper == פליז == 'נחושת' all land on the same copper subset
      expect(resolveQuery('copper', lex).toSet(), copper.toSet());
      expect(resolveQuery('פליז', lex).toSet(), copper.toSet());
    });

    test('AND-intersect: a repeated material token is itself', () {
      expect(resolveQuery('נחושת נחושת', lex).toSet(),
          resolveQuery('נחושת', lex).toSet());
    });

    test('non-intersecting terms fall back to UNION (never dead-end)', () {
      expect(resolveQuery('נחושת HDPE', lex), isNotEmpty,
          reason: 'an empty AND must not dead-end');
    });

    test('a two-term query is never a dead-end', () {
      expect(resolveQuery('ברז נחושת', lex), isNotEmpty);
    });

    test('every resolved sku is in divePoolBySku', () {
      for (final sku in resolveQuery('ברז נחושת', lex)) {
        expect(divePoolBySku.containsKey(sku), isTrue);
      }
    });
  });
}
