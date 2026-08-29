// GO-LIVE SAFETY (C5.5) — a server browse failure must fall back to the bundled
// catalog, NEVER a blank/broken screen. Proves CatalogPagedBrowse.paged().page()
// degrades gracefully when the authored source throws.

import 'package:buildsmart/data/paged_query.dart' show Cursor;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/repositories/authored_products_firebase.dart'
    show AuthoredProductsSource, FirebaseAuthoredProductsRepository;
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:buildsmart/data/repositories/catalog_paged.dart';
import 'package:flutter_test/flutter_test.dart';

/// A source whose paged read always throws (a Firestore outage / permission blip).
class _ThrowingSource implements AuthoredProductsSource {
  @override
  Future<List<RemoteDoc>> page({required int limit, Cursor? after}) async =>
      throw StateError('simulated Firestore failure');

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  test('C5.5 — first-page server FAILURE → the whole bundled catalog (never blank)',
      () async {
    final repo = FirebaseAuthoredProductsRepository(source: _ThrowingSource());
    final browse = CatalogPagedBrowse.paged(repo, cache: CatalogPageCache());

    final page = await browse.page();
    expect(page.items.length, kCatalogProducts.length,
        reason: 'a server outage must still show the full bundled catalog');
    expect(page.hasMore, isFalse);
  });

  test('C5.5 — a LATER-page failure stops paging (empty terminal, no duplicates)',
      () async {
    final repo = FirebaseAuthoredProductsRepository(source: _ThrowingSource());
    final browse = CatalogPagedBrowse.paged(repo, cache: CatalogPageCache());

    final page = await browse.page(after: const Cursor('sku-x', 'item-x'));
    expect(page.items, isEmpty);
    expect(page.hasMore, isFalse);
  });
}
