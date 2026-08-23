// B4 (owner policy): hide content-less catalog categories. A `kCatalogCats`
// title with no matching `kCatalogTree` node (or a node with an empty subtree)
// would drill straight into the `_TreeComingSoon` "בקרוב — הקטגוריה הזו בבנייה"
// placeholder, which the App Store rejects. The browse list filters those out
// with a reversible `where(_categoryHasContent)` — no catalog data is deleted.
//
// This is the DATA-LEVEL twin of the widget guard in widget_test.dart
// ('קטגוריות section shows only content-bearing categories, no בקרוב'). It
// pins the contract that drives the filter using only public symbols:
//   • a category renders  ⇔  it maps to a tree node with children
//   • the 5 known content-less titles have NO tree node (→ would be "בקרוב")
//
// MUTATION-VERIFY of the live filter happens in the widget test (drop the
// `where(_categoryHasContent)` → hidden categories leak / "בקרוב" appears RED).
import 'package:buildsmart/data/catalog.dart' show kCatalogCats;
import 'package:buildsmart/data/catalog_tree.dart'
    show CatalogNode, kCatalogTree;
import 'package:flutter_test/flutter_test.dart';

CatalogNode? _treeNodeFor(String title) {
  for (final n in kCatalogTree) {
    if (n.title == title) return n;
  }
  return null;
}

bool _hasContent(String title) {
  final node = _treeNodeFor(title);
  return node != null && node.children.isNotEmpty;
}

void main() {
  group('B4 — content-less catalog categories are filtered out of browse', () {
    // The five legacy top categories with no built tree (verbatim) — each one
    // would otherwise render the `_TreeComingSoon` "בקרוב" placeholder.
    const knownComingSoon = [
      'חימום מים',
      'מטבח',
      'גופי תברואה',
      'בנייה ומחיצות',
      'גמר',
    ];

    test('the known coming-soon categories have NO tree node (would be בקרוב)',
        () {
      for (final title in knownComingSoon) {
        // Data is KEPT in kCatalogCats (reversible) …
        expect(
          kCatalogCats.any((c) => c.title == title),
          isTrue,
          reason: '$title must stay in kCatalogCats data',
        );
        // … but it leads to no content, so the filter must drop it.
        expect(
          _hasContent(title),
          isFalse,
          reason: '$title unexpectedly gained content',
        );
      }
    });

    test('every kept category maps to a tree node WITH children', () {
      final shown = kCatalogCats.where((c) => _hasContent(c.title)).toList();
      // The 12 legacy categories minus the 5 coming-soon = 7 with content,
      // plus the new ppr supplier branch = 8 shown.
      expect(shown, hasLength(8));
      for (final c in shown) {
        final node = _treeNodeFor(c.title)!;
        expect(node.children, isNotEmpty, reason: '${c.title} has no subtree');
      }
      // None of the coming-soon titles survive the filter.
      for (final title in knownComingSoon) {
        expect(
          shown.any((c) => c.title == title),
          isFalse,
          reason: '$title leaked past the content filter',
        );
      }
    });
  });
}
