// C1.4 — STORES + INVENTORY seed (SPEC-catalog-to-server).
//
// Proves the 2 demo stores + the 40 inventory rows (2 stores × 20 slice SKUs) seed to
// `stores/{id}` / `inventory/{storeId}_{sku}`, that the models round-trip, and that
// the headline 118220 carries the owner's demo numbers (אחים-כהן 38₪/12 · מרכז 42₪/3)
// — the data the C1.8 comparison gate reads. Fake sink — no Firebase.

import 'package:buildsmart/data/repositories/catalog_slice.dart'
    show kC1SliceSkus;
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:buildsmart/data/repositories/store_inventory.dart';
import 'package:flutter_test/flutter_test.dart';

/// A callable fake matching [FirestoreDocSink] — records id→doc writes. Passed as
/// `sink.call`.
class _FakeDocSink {
  final Map<String, Map<String, dynamic>> docs = {};
  int writes = 0;

  Future<void> call(String id, Map<String, dynamic> data) async {
    writes++;
    docs[id] = <String, dynamic>{...?docs[id], ...data};
  }
}

void main() {
  group('C1.4 — stores', () {
    test('seedC1Stores writes the 2 demo stores + round-trips', () async {
      final sink = _FakeDocSink();
      final n = await seedC1Stores(sink.call);

      expect(n, 2);
      expect(sink.docs.keys.toSet(), {'ahim_cohen', 'merkaz'});

      final a = Store.fromDoc(RemoteDoc('ahim_cohen', sink.docs['ahim_cohen']!));
      expect(a.id, 'ahim_cohen');
      expect(a.name, 'אחים כהן');
      expect(a.area, 'תל אביב');
    });
  });

  group('C1.4 — inventory', () {
    test('seedC1Inventory writes 40 rows (2×20), doc-id = storeId_sku', () async {
      final sink = _FakeDocSink();
      final n = await seedC1Inventory(sink.call);

      expect(n, 40);
      expect(sink.docs, hasLength(40));
      expect(sink.docs.containsKey('ahim_cohen_118220'), isTrue);
      expect(sink.docs.containsKey('merkaz_118220'), isTrue);

      // Every slice SKU has EXACTLY two offers (one per store).
      for (final sku in kC1SliceSkus) {
        final offers = sink.docs.keys.where((k) => k.endsWith('_$sku')).length;
        expect(offers, 2, reason: '$sku offers');
      }
    });

    test('headline 118220: אחים-כהן 38₪/12 · מרכז 42₪/3 (אחים is the cheaper)',
        () async {
      final sink = _FakeDocSink();
      await seedC1Inventory(sink.call);

      final a = InventoryItem.fromDoc(
          RemoteDoc('ahim_cohen_118220', sink.docs['ahim_cohen_118220']!));
      final m = InventoryItem.fromDoc(
          RemoteDoc('merkaz_118220', sink.docs['merkaz_118220']!));

      expect(a.price, 38);
      expect(a.stock, 12);
      expect(m.price, 42);
      expect(m.stock, 3);
      expect(a.price < m.price, isTrue, reason: 'אחים-כהן is "הזול"');
    });

    test('every inventory row round-trips: price>0 · stock>=0 · updatedAt set',
        () async {
      final sink = _FakeDocSink();
      await seedC1Inventory(sink.call);

      for (final entry in sink.docs.entries) {
        final it = InventoryItem.fromDoc(RemoteDoc(entry.key, entry.value));
        expect(it.docId, entry.key, reason: 'doc-id composite key');
        expect(it.price, greaterThan(0));
        expect(it.stock, greaterThanOrEqualTo(0));
        expect(it.updatedAt, isNotEmpty, reason: 'needed for re-sync (C1.6/C1.9)');
      }
    });
  });
}
