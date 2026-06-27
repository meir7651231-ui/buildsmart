import 'package:buildsmart/features/word_finder/material_lexicon.dart'
    show kMaterials;
import 'package:buildsmart/features/word_finder/synonym_bridge.dart';
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
}
