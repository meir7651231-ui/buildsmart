// BILINGUAL search — every product carries nameEn/categoryEn, and [kGlobalSearch]
// folds them into the search haystack + relevance so an ENGLISH query finds the
// Hebrew product it names ("elbow" → ברך/זווית). Flag-off the English is compiled
// out, so an English query finds nothing (the base search is byte-identical).
//
//   flutter test --dart-define=GLOBAL_SEARCH=true test/features/global_search/bilingual_search_test.dart

import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/features/global_search/global_search.dart'
    show kGlobalSearch;
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogProductMatchesQuery, searchRelevance;
import 'package:flutter_test/flutter_test.dart';

int _matches(String q) =>
    kCatalogProducts.where((p) => catalogProductMatchesQuery(p, q)).length;

void main() {
  test('an English query finds Hebrew products only under the flag', () {
    const englishTerms = ['elbow', 'tee', 'coupler', 'valve', 'toilet', 'nipple'];

    if (!kGlobalSearch) {
      // Flag-off: English is folded out — the base search never matched English,
      // and still doesn't (byte-identical).
      for (final en in englishTerms) {
        expect(_matches(en), 0,
            reason: 'flag-off: English "$en" must find nothing');
      }
      return;
    }

    for (final en in englishTerms) {
      expect(_matches(en), greaterThan(0),
          reason: 'English "$en" must find its Hebrew products');
    }

    // The English hit is SCORED (so it ranks, not stuck at 0).
    final elbow =
        kCatalogProducts.firstWhere((p) => catalogProductMatchesQuery(p, 'elbow'));
    expect(searchRelevance(elbow, 'elbow'), greaterThan(0),
        reason: 'an English match must earn a relevance score');
  });

  test('a Hebrew query works identically in both modes', () {
    expect(_matches('ברז'), greaterThan(0));
    expect(_matches('אסלה'), greaterThan(0));
  });
}
