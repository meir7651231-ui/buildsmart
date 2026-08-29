// STUDIO step 53 — unit coverage for [PagedQuery], the cursor-pagination helper
// over the neutral remote seam.
//
// NO Firebase here: the paged seam ([PagedSource]) is driven by a HAND-ROLLED
// fake ([_FakePagedSource]) that SLICES an in-memory list — the same Firebase-free
// test strategy `firestore_cached_repo_test.dart` uses for [RemoteCollectionSource]
// (no fake_cloud_firestore, no new packages). The fake records the last requested
// limit so the defensive cap can be proven end-to-end.
//
// Pins (the contract a catalog browse consumer will rely on):
//   • page 1 returns a full page (40) and page 2 CONTINUES from the returned
//     cursor (the next slice — never an offset re-scan);
//   • the OFF / local single-page source returns the WHOLE list in ONE page
//     (hasMore=false) SYNCHRONOUSLY (a SynchronousFuture);
//   • the hard cap holds — asking for >40 clamps the request to 40.

import 'package:buildsmart/data/paged_query.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake [PagedSource] that SLICES an in-memory list — the neutral,
/// Firebase-free stand-in the seam is built for. Records [lastRequestedLimit] so
/// the cap assertion can prove [PagedQuery] never asks the backend for >40.
class _FakePagedSource implements PagedSource {
  _FakePagedSource(this.docs);

  final List<RemoteDoc> docs;

  /// The `limit` the most recent [page] call was asked for (cap probe).
  int? lastRequestedLimit;

  @override
  bool get isSinglePage => false;

  @override
  Future<List<RemoteDoc>> page({required int limit, Cursor? after}) {
    lastRequestedLimit = limit;
    final afterId = after?.lastDocId;
    final afterIdx =
        afterId == null ? -1 : docs.indexWhere((d) => d.id == afterId);
    final start = afterIdx + 1;
    final end = start + limit > docs.length ? docs.length : start + limit;
    return Future<List<RemoteDoc>>.value(docs.sublist(start, end));
  }
}

/// A trivial domain model — proves [PagedQuery] maps each [RemoteDoc] to a model.
class _Product {
  const _Product(this.sku, this.name);

  final String sku;
  final String name;
}

_Product _fromDoc(RemoteDoc d) =>
    _Product(d.id, (d.data['nameHe'] as String?) ?? '');

List<RemoteDoc> _makeDocs(int n) => List<RemoteDoc>.generate(
      n,
      (i) => RemoteDoc(
        'sku-${i.toString().padLeft(4, '0')}',
        {'nameHe': 'item $i'},
      ),
      growable: false,
    );

void main() {
  group('PagedQuery', () {
    test('page 1 returns 40 and page 2 continues from the returned cursor', () async {
      final source = _FakePagedSource(_makeDocs(100));
      final query = PagedQuery<_Product>(source: source, fromDoc: _fromDoc);

      final p1 = await query.page();
      expect(p1.items, hasLength(40));
      expect(p1.hasMore, isTrue);
      expect(p1.items.first.sku, source.docs[0].id);
      expect(p1.items.first.name, 'item 0'); // fromDoc mapped the field, not just id
      expect(p1.items.last.sku, source.docs[39].id);
      expect(p1.cursor, isNotNull);
      expect(p1.cursor!.lastDocId, source.docs[39].id);

      // Page 2 resumes AFTER the cursor — the NEXT slice, not a re-scan.
      final p2 = await query.page(after: p1.cursor);
      expect(p2.items, hasLength(40));
      expect(p2.hasMore, isTrue);
      expect(p2.items.first.sku, source.docs[40].id);
      expect(p2.items.last.sku, source.docs[79].id);
      expect(p2.cursor!.lastDocId, source.docs[79].id);
    });

    test('OFF / local single-page source returns the FULL list in one sync page', () async {
      final docs = _makeDocs(137);
      final query = PagedQuery<_Product>(
        source: LocalPagedSource(docs),
        fromDoc: _fromDoc,
      );

      final future = query.page();
      // The OFF path resolves in-frame — proven by the concrete future type.
      expect(future, isA<SynchronousFuture<PagedResult<_Product>>>());

      final result = await future;
      expect(result.items, hasLength(137)); // the WHOLE list, never capped to 40
      expect(result.hasMore, isFalse);
      expect(result.cursor, isNull);
    });

    test('limit cap holds — requesting >40 clamps the request to 40', () async {
      final source = _FakePagedSource(_makeDocs(100));
      final query =
          PagedQuery<_Product>(source: source, fromDoc: _fromDoc, limit: 10000);

      expect(query.limit, 40); // effective page size clamped
      final p1 = await query.page();
      expect(source.lastRequestedLimit, 40); // source was never asked for >40
      expect(p1.items, hasLength(40));
    });
  });
}
