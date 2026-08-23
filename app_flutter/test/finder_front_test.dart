// Tests for the "salesperson leads on open" front-door classifier.
//
// The flag-ON branch itself is only reachable via a --dart-define build (flutter
// test does NOT forward defines to consts), so here we pin the PURE classifier
// (flag-independent) exhaustively, plus assert the flag defaults OFF.

import 'package:buildsmart/state/catalog_location.dart';
import 'package:buildsmart/state/finder_front.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('catalogLeadsWithFinder — the salesperson leads only on browse/landing', () {
    test('CatalogHome (smart-home landing) leads with the finder', () {
      expect(catalogLeadsWithFinder(const CatalogHome()), isTrue);
    });

    test('CatalogSmartTree GRID (no category) leads with the finder', () {
      expect(catalogLeadsWithFinder(const CatalogSmartTree(null)), isTrue);
    });

    test('CatalogSmartTree with a picked category leads with the MIRROR', () {
      // Already browsing a concrete product list — the finder would fight it.
      expect(catalogLeadsWithFinder(const CatalogSmartTree('ברזים')), isFalse);
    });

    test('CatalogSection (a user list section) leads with the MIRROR', () {
      expect(catalogLeadsWithFinder(const CatalogSection('קטגוריות')), isFalse);
      expect(catalogLeadsWithFinder(const CatalogSection('מועדפים')), isFalse);
    });

    test('CatalogDrill (open drill stack) leads with the MIRROR', () {
      expect(
        catalogLeadsWithFinder(
          CatalogDrill(pathIds: const ['a'], pathTitles: const ['A']),
        ),
        isFalse,
      );
    });
  });

  test('kFinderFront defaults OFF (byte-identical prod build)', () {
    // No --dart-define in `flutter test` ⇒ the const folds false, so the whole
    // finder-front branch tree-shakes and the keyboard stays the mirror row.
    expect(kFinderFront, isFalse);
  });
}
