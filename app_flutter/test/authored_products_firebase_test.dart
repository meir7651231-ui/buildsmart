// FIRESTORE CACHE-PATTERN (Studio · Step 60, R1-6 / R1-9) — unit coverage for
// [FirebaseAuthoredProductsRepository]: the paged `catalogProducts/{sku}` access layer,
// its tolerant round-trip mapper, the role-scoped price sub-doc, and the tombstone
// archive + cycle-guarded `replacedBy` resolver.
//
// NO Firebase here: the catalog seam ([AuthoredProductsSource]) is driven by a
// HAND-ROLLED fake ([_FakeAuthoredProductsSource]) that SLICES / MERGES an in-memory map —
// the same Firebase-free strategy `paged_query_test.dart` / `studio_config_firebase_test.dart`
// use (no fake_cloud_firestore, no new packages). The fake also has NO delete — the
// seam offers none (deletion is a tombstone `set`), so "not hard-deleted" is
// structural.
//
// Pins (the Step-60 contract the spec lists in §60.5):
//   • BROWSE returns cursor PAGES (page 2 continues from page 1's cursor);
//   • the mapper ROUND-TRIPS a product (`toDoc ∘ fromDoc` preserves the model);
//   • the PRICE is never in the public doc — only in `pricing/{audience}` (R1-6);
//   • doc-id = SKU ⇒ upsert is IDEMPOTENT (a re-upsert is one doc);
//   • a TOMBSTONE marks `active:false` (dropped from browse) and is NOT deleted
//     (still gettable), with a `replacedBy` pointer (R1-9);
//   • the `replacedBy` resolver breaks a CYCLE (A→B→A can't hang) and follows a
//     real chain to its live terminal.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/paged_query.dart' show Cursor;
import 'package:buildsmart/data/repositories/authored_products_firebase.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake [AuthoredProductsSource]: an in-memory `sku → field-map` store.
/// [set] MERGES (Firestore `SetOptions(merge:true)` semantics) so a tombstone
/// keeps the product's fields; [page] returns only `active != false` docs, sorted
/// by (`nameHe`, id) and sliced after the cursor (the `paged_query_test` idiom);
/// [setPricing] records every price write for the "price is not in the public doc"
/// assertion. There is NO delete — the real seam has none.
class _FakeAuthoredProductsSource implements AuthoredProductsSource {
  final Map<String, Map<String, dynamic>> docs = {};

  /// Every `pricing/{audience}` write, in arrival order.
  final List<({String sku, String audience, Map<String, dynamic> data})>
      pricings = [];

  /// Seed [n] active products `sku-0000..` with zero-padded `nameHe` so their
  /// lexicographic (`nameHe`, id) order equals their index order.
  void seedProducts(int n) {
    for (var i = 0; i < n; i++) {
      final id = 'sku-${i.toString().padLeft(4, '0')}';
      docs[id] = <String, dynamic>{
        'sku': id,
        'nameHe': 'item ${i.toString().padLeft(4, '0')}',
        'active': true,
      };
    }
  }

  @override
  bool get isSinglePage => false;

  @override
  Future<List<RemoteDoc>> page({required int limit, Cursor? after}) async {
    final live = docs.entries
        .where((e) => e.value['active'] != false)
        .toList()
      ..sort((a, b) {
        final an = (a.value['nameHe'] as String?) ?? a.key;
        final bn = (b.value['nameHe'] as String?) ?? b.key;
        final c = an.compareTo(bn);
        return c != 0 ? c : a.key.compareTo(b.key);
      });
    // Resume after the cursor by last-doc-id (unique, deterministic order).
    final start =
        after == null ? 0 : live.indexWhere((e) => e.key == after.lastDocId) + 1;
    return live
        .skip(start)
        .take(limit)
        .map((e) => RemoteDoc(e.key, e.value))
        .toList(growable: false);
  }

  @override
  Future<RemoteDoc?> get(String sku) async {
    final data = docs[sku];
    return data == null ? null : RemoteDoc(sku, data);
  }

  @override
  Future<void> set(String sku, Map<String, dynamic> data) async {
    // Merge (not overwrite) — a partial tombstone keeps the product's fields.
    docs[sku] = <String, dynamic>{...?docs[sku], ...data};
  }

  @override
  Future<void> setPricing(
    String sku,
    String audience,
    Map<String, dynamic> data,
  ) async {
    pricings.add((sku: sku, audience: audience, data: data));
  }
}

/// A fully-populated product — exercises every mapper branch on round-trip.
const _kRich = LipskeyCatalogProduct(
  sku: 'X-1',
  nameHe: 'ברז כדורי',
  nameEn: 'Ball valve',
  color: 'כחול',
  qtyPack: 10,
  qtyPallet: 100,
  categoryHe: 'ברזים',
  categoryEn: 'Valves',
  categoryEmoji: '🚿',
  page: 12,
  dims: {'DN': '25', 'L (cm)': '30'},
  imageFile: 'x1.jpg',
  imageFiles: ['x1.jpg', 'x1b.jpg'],
  specImageFile: 'x1-spec.jpg',
  brand: 'פולירול',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseAuthoredProductsRepository — browse (paged, Step 60)', () {
    test('returns cursor PAGES — page 2 continues from page 1 cursor', () async {
      final source = _FakeAuthoredProductsSource()..seedProducts(100);
      final repo = FirebaseAuthoredProductsRepository(source: source);

      final p1 = await repo.browse();
      expect(p1.items, hasLength(40));
      expect(p1.hasMore, isTrue);
      expect(p1.items.first.sku, 'sku-0000');
      expect(p1.items.first.nameHe, 'item 0000'); // fromDoc mapped the field
      expect(p1.items.last.sku, 'sku-0039');
      expect(p1.cursor, isNotNull);
      expect(p1.cursor!.lastDocId, 'sku-0039');
      expect(p1.cursor!.sortValue, 'item 0039'); // nameHe rides the cursor

      // Page 2 resumes AFTER the cursor — the next slice, never an offset re-scan.
      final p2 = await repo.browse(after: p1.cursor);
      expect(p2.items, hasLength(40));
      expect(p2.items.first.sku, 'sku-0040');
      expect(p2.items.last.sku, 'sku-0079');
      expect(p2.hasMore, isTrue);
    });

    test('page size is capped at 40 even when a larger limit is asked', () async {
      final source = _FakeAuthoredProductsSource()..seedProducts(60);
      final repo = FirebaseAuthoredProductsRepository(source: source);

      final page = await repo.browse(limit: 10000);
      expect(page.items, hasLength(40)); // clamped by PagedQuery.maxLimit
    });
  });

  group('FirebaseAuthoredProductsRepository — mapper (round-trip + doc-id)', () {
    test('toDoc ∘ fromDoc preserves the model (tolerant round-trip)', () {
      final repo = FirebaseAuthoredProductsRepository(source: _FakeAuthoredProductsSource());

      final rt = repo.fromDoc(RemoteDoc(_kRich.sku, repo.toDoc(_kRich)));

      expect(rt.sku, _kRich.sku);
      expect(rt.nameHe, _kRich.nameHe);
      expect(rt.nameEn, _kRich.nameEn);
      expect(rt.color, _kRich.color);
      expect(rt.qtyPack, _kRich.qtyPack);
      expect(rt.qtyPallet, _kRich.qtyPallet);
      expect(rt.categoryHe, _kRich.categoryHe);
      expect(rt.categoryEn, _kRich.categoryEn);
      expect(rt.categoryEmoji, _kRich.categoryEmoji);
      expect(rt.page, _kRich.page);
      expect(rt.dims, _kRich.dims);
      expect(rt.imageFile, _kRich.imageFile);
      expect(rt.imageFiles, _kRich.imageFiles);
      expect(rt.specImageFile, _kRich.specImageFile);
      expect(rt.brand, _kRich.brand);
    });

    test('a sparse/empty doc decodes to defaults — fromDoc NEVER throws', () {
      final repo = FirebaseAuthoredProductsRepository(source: _FakeAuthoredProductsSource());

      // An almost-empty doc must not throw (a throwing mapper tears a page).
      final p = repo.fromDoc(const RemoteDoc('sku-9', <String, dynamic>{}));
      expect(p.sku, 'sku-9'); // falls back to the doc id
      expect(p.nameHe, '');
      expect(p.brand, 'ליפסקי'); // model default
      expect(p.color, isNull);
    });

    test('doc-id = SKU ⇒ upsert is idempotent (a re-upsert is ONE doc)', () async {
      final source = _FakeAuthoredProductsSource();
      final repo = FirebaseAuthoredProductsRepository(source: source);

      expect(repo.idOf(_kRich), 'X-1');
      await repo.upsert(_kRich);
      await repo.upsert(_kRich); // same natural key
      expect(source.docs.keys.where((k) => k == 'X-1'), hasLength(1));
      expect(source.docs['X-1']!['sku'], 'X-1');
      expect(source.docs['X-1']!['active'], isTrue); // stamped for the filter
    });
  });

  group('FirebaseAuthoredProductsRepository — price sub-doc (R1-6)', () {
    test('price is NEVER in the public doc — only in pricing/{audience}', () async {
      final source = _FakeAuthoredProductsSource();
      final repo = FirebaseAuthoredProductsRepository(source: source);

      // The public mapper carries no price.
      expect(repo.toDoc(_kRich).containsKey('price'), isFalse);

      // The price rides the role-scoped sub-doc.
      final pricing = FirebaseAuthoredProductsRepository.pricingDoc(price: 1234);
      expect(pricing['price'], 1234);

      // setPrice writes ONLY to pricing/{audience} — the public doc stays priceless.
      await repo.upsert(_kRich);
      await repo.setPrice('X-1', 'contractor', price: 1234);
      expect(source.pricings, hasLength(1));
      expect(source.pricings.single.sku, 'X-1');
      expect(source.pricings.single.audience, 'contractor');
      expect(source.pricings.single.data['price'], 1234);
      expect(source.docs['X-1']!.containsKey('price'), isFalse);
    });
  });

  group('FirebaseAuthoredProductsRepository — tombstone archive (R1-9)', () {
    test('archive marks active:false (dropped from browse), NOT deleted', () async {
      final source = _FakeAuthoredProductsSource();
      final repo = FirebaseAuthoredProductsRepository(source: source);
      await repo.upsert(_kRich);

      // Present in browse while active…
      final before = await repo.browse();
      expect(before.items.map((e) => e.sku), contains('X-1'));

      await repo.archive('X-1', replacedBy: 'X-2', tombstonedAt: '2026-07-06');

      // …soft-deleted: the doc SURVIVES (still gettable), flagged, and pointed.
      final still = await repo.productForSku('X-1');
      expect(still, isNotNull); // NOT hard-deleted
      expect(source.docs['X-1']!['active'], isFalse);
      expect(source.docs['X-1']!['tombstone'], isTrue);
      expect(source.docs['X-1']!['replacedBy'], 'X-2');
      // The product fields survived the partial merge (nameHe still there).
      expect(source.docs['X-1']!['nameHe'], _kRich.nameHe);

      // …and it no longer appears in browse (active == true filter).
      final after = await repo.browse();
      expect(after.items.map((e) => e.sku), isNot(contains('X-1')));
    });
  });

  group('FirebaseAuthoredProductsRepository — replacedBy resolver (R1-9, cycle-guard)', () {
    test('a real chain A→B→C resolves to the live terminal C', () async {
      final source = _FakeAuthoredProductsSource();
      final repo = FirebaseAuthoredProductsRepository(source: source);
      source.docs['A'] = {'sku': 'A', 'active': false, 'replacedBy': 'B'};
      source.docs['B'] = {'sku': 'B', 'active': false, 'replacedBy': 'C'};
      source.docs['C'] = {'sku': 'C', 'active': true};

      expect(await repo.resolveReplacement('A'), 'C');
    });

    test('a cycle A→B→A is broken (returns a link, never hangs)', () async {
      final source = _FakeAuthoredProductsSource();
      final repo = FirebaseAuthoredProductsRepository(source: source);
      source.docs['A'] = {'sku': 'A', 'active': false, 'replacedBy': 'B'};
      source.docs['B'] = {'sku': 'B', 'active': false, 'replacedBy': 'A'};

      final resolved = await repo.resolveReplacement('A');
      expect(['A', 'B'], contains(resolved)); // terminated inside the cycle
    });

    test('a missing SKU resolves to itself', () async {
      final repo = FirebaseAuthoredProductsRepository(source: _FakeAuthoredProductsSource());
      expect(await repo.resolveReplacement('ghost'), 'ghost');
    });
  });
}
