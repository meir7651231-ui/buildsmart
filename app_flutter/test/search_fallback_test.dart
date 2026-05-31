// Roadmap step 62 — the UI's product-search uses a three-tier fallback chain
// (AND → OR → fuzzy) so a user never hits a dead end. We lock the contract
// statically: `_SearchResultsList` references all three matchers, and
// `fuzzySearchProducts` actually returns results on a typical Hebrew query.

import 'dart:io';

import 'package:buildsmart/data/fuzzy_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('search UI references the three-tier fallback (AND → OR → fuzzy)', () {
    final src =
        File('lib/screens/catalog_screen.dart').readAsStringSync();
    // The matchProducts closure must mention all three matchers.
    expect(src.contains('catalogProductMatchesQuery'), isTrue,
        reason: 'AND/OR matcher missing');
    expect(src.contains('requireAll: false'), isTrue,
        reason: 'OR (any-word) fallback missing');
    expect(src.contains('fuzzySearchProducts'), isTrue,
        reason: 'fuzzy (proximity) fallback missing');
  });

  test('fuzzySearchProducts returns hits for a typical Hebrew query', () {
    final r = fuzzySearchProducts('ברז');
    expect(r, isNotEmpty);
    // The helper caps at limit (20 by default).
    expect(r.length, lessThanOrEqualTo(20));
  });

  test('fuzzySearchProducts is empty on empty / whitespace input', () {
    expect(fuzzySearchProducts(''), isEmpty);
    expect(fuzzySearchProducts('   '), isEmpty);
  });
}
