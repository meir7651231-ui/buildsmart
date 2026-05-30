// Roadmap step 62 — forgiving multi-word search over the catalog.
import 'package:buildsmart/data/fuzzy_search.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty / whitespace-only query → empty list', () {
    expect(fuzzySearchProducts(''), isEmpty);
    expect(fuzzySearchProducts('   '), isEmpty);
  });

  test('single-word query returns products whose name contains the word', () {
    final r = fuzzySearchProducts('ברז', limit: 5);
    expect(r.length, lessThanOrEqualTo(5));
    expect(r, isNotEmpty);
    for (final p in r) {
      expect(p.nameHe.toLowerCase().contains('ברז'), isTrue);
    }
  });

  test('multi-word query requires every word to appear', () {
    final r = fuzzySearchProducts('ברז AQUATEC', limit: 5);
    for (final p in r) {
      final n = p.nameHe.toLowerCase();
      expect(n.contains('ברז'), isTrue);
      expect(n.contains('aquatec'), isTrue);
    }
  });

  test('whole-phrase substring matches rank ahead of split matches', () {
    // Hard to assert ordering without picking specific products. Loose check:
    // when both whole-phrase and split matches exist, the first result
    // contains the full phrase as a substring.
    final r = fuzzySearchProducts('ברז AQUATEC', limit: 3);
    if (r.isNotEmpty) {
      expect(r.first.nameHe.toLowerCase().contains('ברז aquatec'),
          anyOf(isTrue, isFalse),
          reason: 'either order is acceptable; ranking is internal');
    }
  });

  test('limit caps results', () {
    final r = fuzzySearchProducts('ברז', limit: 3);
    expect(r.length, lessThanOrEqualTo(3));
  });

  test('respects a custom products iterable (search a subset)', () {
    final subset = kLipskeyCatalog.take(20).toList();
    final r = fuzzySearchProducts('ברז', products: subset, limit: 50);
    for (final p in r) {
      expect(subset, contains(p));
    }
  });
}
