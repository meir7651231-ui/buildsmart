// SEED IMPORTER (Studio · Step 61, R2-9) — unit coverage for
// [FirebaseAuthoredProductsRepository.seedCatalog]: the OFF-by-default bulk seed of
// the catalog server store, its honest-empty gate, and the stage-to-pending /
// flip-on-FULL-success safety that guarantees a mid-batch abort can never leave a
// half-public catalog.
//
// NO Firebase here: the staging seam ([CatalogSeedSink]) is driven by a HAND-ROLLED
// fake ([_FakeSeedSink]) that MERGES into in-memory maps — the same Firebase-free
// strategy `authored_products_firebase_test.dart` / `paged_query_test.dart` use (no
// fake_cloud_firestore, no new packages). Because the gate ([live]/[seedFresh]) is
// an injectable parameter (not the global read directly), the ON branch — a live
// backend that must NOT auto-seed — is exercised DEFINE-LESS, exactly the
// `serverCallables`/`uidScoped` testability idiom.
//
// Pins (the Step-61 contract the spec lists in §61.5 / §61.8):
//   • the HONEST-EMPTY gate: `live && !seedFresh` → SKIPPED, ZERO writes (prod never
//     auto-seeds — real data is never shadowed by a demo seed);
//   • flag OFF (`live:false`) → the seed runs exactly as today (byte-identical);
//   • a full run STAGES → sets `complete` → FLIPS every row to the live catalog;
//   • a double run is IDEMPOTENT (doc-id=SKU ⇒ one live row per SKU, not duplicates);
//   • a MID-BATCH ABORT leaves the live catalog UNCHANGED (no half-public catalog)
//     and marks the pending batch `aborted` with a resume cursor;
//   • a RESUMED run continues from the cursor and flips the whole catalog.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/repositories/authored_products_firebase.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake [CatalogSeedSink]: three in-memory maps mirroring the
/// `catalogProducts` (live) collection, the `catalogPending/{batchId}` meta docs,
/// and the `catalogPending/{batchId}/items/{sku}` staged rows. [set*] MERGE
/// (Firestore `SetOptions(merge:true)` semantics). Counters prove the honest-empty
/// gate wrote NOTHING and the flip published exactly once per SKU.
class _FakeSeedSink implements CatalogSeedSink {
  /// The LIVE `catalogProducts`, keyed by sku — the flip target.
  final Map<String, Map<String, dynamic>> live = {};

  /// batchId → the pending META doc (cursor / complete / aborted).
  final Map<String, Map<String, dynamic>> meta = {};

  /// batchId → (sku → staged row).
  final Map<String, Map<String, Map<String, dynamic>>> items = {};

  int stageCalls = 0;
  int liveWrites = 0;

  @override
  Future<void> stagePending(
    String batchId,
    String sku,
    Map<String, dynamic> data,
  ) async {
    stageCalls++;
    final batch = items[batchId] ??= {};
    batch[sku] = <String, dynamic>{...?batch[sku], ...data};
  }

  @override
  Future<RemoteDoc?> pendingMeta(String batchId) async {
    final m = meta[batchId];
    return m == null ? null : RemoteDoc(batchId, m);
  }

  @override
  Future<void> setPendingMeta(String batchId, Map<String, dynamic> data) async {
    meta[batchId] = <String, dynamic>{...?meta[batchId], ...data};
  }

  @override
  Future<List<RemoteDoc>> pendingItems(String batchId) async {
    final batch = items[batchId] ?? const {};
    return [for (final e in batch.entries) RemoteDoc(e.key, e.value)];
  }

  @override
  Future<void> setLive(String sku, Map<String, dynamic> data) async {
    liveWrites++;
    live[sku] = <String, dynamic>{...?live[sku], ...data};
  }
}

/// [n] products with distinct, zero-padded SKUs (so SKU order is deterministic).
List<LipskeyCatalogProduct> _products(int n) => [
      for (var i = 0; i < n; i++)
        LipskeyCatalogProduct(
          sku: 'P-${i.toString().padLeft(3, '0')}',
          nameHe: 'מוצר $i',
          nameEn: 'Product $i',
          categoryHe: 'קטגוריה',
          categoryEn: 'Category',
          categoryEmoji: '🔧',
          page: 0,
        ),
    ];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('seedCatalog — honest-empty gate (prod never auto-seeds, §61.8)', () {
    test('live && !seedFresh → SKIPPED, ZERO writes (real data not shadowed)',
        () async {
      final sink = _FakeSeedSink();
      final repo = FirebaseAuthoredProductsRepository(seedSink: sink);

      final outcome =
          await repo.seedCatalog(_products(50), live: true, seedFresh: false);

      expect(outcome.status, SeedStatus.skipped);
      // The gate short-circuits BEFORE any read/write — honest-empty.
      expect(sink.stageCalls, 0);
      expect(sink.liveWrites, 0);
      expect(sink.items, isEmpty);
      expect(sink.meta, isEmpty);
      expect(sink.live, isEmpty);
    });

    test('flag OFF (live:false) → seeds exactly as today (byte-identical path)',
        () async {
      final sink = _FakeSeedSink();
      final repo = FirebaseAuthoredProductsRepository(seedSink: sink);

      final outcome = await repo.seedCatalog(_products(3), live: false);

      expect(outcome.status, SeedStatus.flipped);
      expect(sink.live, hasLength(3)); // the seed ran, unchanged from today
    });

    test('dev opt-in (live:true, seedFresh:true) → seeds (emulator path)',
        () async {
      final sink = _FakeSeedSink();
      final repo = FirebaseAuthoredProductsRepository(seedSink: sink);

      final outcome =
          await repo.seedCatalog(_products(3), live: true, seedFresh: true);

      expect(outcome.status, SeedStatus.flipped);
      expect(sink.live, hasLength(3));
    });
  });

  group('seedCatalog — stage-to-pending, flip-on-FULL-success (R2-9)', () {
    test('a full run stages every row, sets complete, then flips to live',
        () async {
      final sink = _FakeSeedSink();
      final repo = FirebaseAuthoredProductsRepository(seedSink: sink);

      final outcome = await repo.seedCatalog(_products(5), live: false);

      expect(outcome.status, SeedStatus.flipped);
      expect(outcome.count, 5);
      // Every row staged, complete flag set, and all flipped to live.
      expect(sink.items['seed'], hasLength(5));
      expect(sink.meta['seed']!['complete'], isTrue);
      expect(sink.live.keys.toSet(),
          {'P-000', 'P-001', 'P-002', 'P-003', 'P-004'});
      // The staged public doc carries no price (R1-6 preserved through the flip).
      expect(sink.live['P-000']!.containsKey('price'), isFalse);
      expect(sink.live['P-000']!['active'], isTrue);
    });

    test('doc-id = SKU ⇒ a double run is IDEMPOTENT (one live row per SKU)',
        () async {
      final sink = _FakeSeedSink();
      final repo = FirebaseAuthoredProductsRepository(seedSink: sink);

      await repo.seedCatalog(_products(4), live: false);
      final writesAfterFirst = sink.liveWrites;

      // Second run: the batch is already `complete`, so it just re-flips — no
      // duplicate rows (SKU-keyed), no re-staging.
      final second = await repo.seedCatalog(_products(4), live: false);

      expect(second.status, SeedStatus.flipped);
      expect(sink.live, hasLength(4)); // still 4, never 8
      expect(sink.stageCalls, 4); // staged once, not re-staged on the 2nd run
      expect(sink.liveWrites, writesAfterFirst + 4); // re-flip is idempotent
    });
  });

  group('seedCatalog — mid-batch abort leaves NO half-public catalog (R2-9)', () {
    test('an abort mid-stage keeps live UNCHANGED and marks the batch aborted',
        () async {
      final sink = _FakeSeedSink();
      final repo = FirebaseAuthoredProductsRepository(seedSink: sink);

      // Fail after the 3rd row is staged — simulates a crash / network drop.
      final outcome = await repo.seedCatalog(
        _products(10),
        live: false,
        onStaged: (n) async {
          if (n == 3) throw StateError('boom');
        },
      );

      expect(outcome.status, SeedStatus.aborted);
      expect(outcome.staged, 3);
      expect(outcome.cursor, 'P-002'); // last SKU staged before the abort

      // THE R2-9 GUARANTEE: the live catalog was never touched — no half-public
      // catalog (nothing flipped, because `complete` was never written).
      expect(sink.live, isEmpty);
      expect(sink.liveWrites, 0);

      // The pending batch is marked aborted (tombstone-partial), with a resume
      // cursor — the 3 rows that WERE staged live only in the DRAFT.
      expect(sink.meta['seed']!['aborted'], isTrue);
      expect(sink.meta['seed']!.containsKey('complete'), isFalse);
      expect(sink.meta['seed']!['cursor'], 'P-002');
      expect(sink.items['seed'], hasLength(3));
    });

    test('a resumed run continues from the cursor and flips the whole catalog',
        () async {
      final sink = _FakeSeedSink();
      final repo = FirebaseAuthoredProductsRepository(seedSink: sink);

      // First attempt aborts after 3 of 10.
      await repo.seedCatalog(
        _products(10),
        live: false,
        onStaged: (n) async {
          if (n == 3) throw StateError('boom');
        },
      );
      expect(sink.live, isEmpty); // still nothing live after the abort

      // Resume: no fail hook — picks up AFTER the cursor, stages the rest, flips.
      final resumed = await repo.seedCatalog(_products(10), live: false);

      expect(resumed.status, SeedStatus.flipped);
      expect(resumed.count, 10);
      // Only the remaining 7 were re-staged (3 already in the draft) — resume, not
      // restart-from-zero.
      expect(sink.stageCalls, 10); // 3 (first) + 7 (resume) — never 3 + 10
      expect(sink.live, hasLength(10));
      expect(sink.meta['seed']!['complete'], isTrue);
      expect(sink.meta['seed']!['aborted'], isFalse);
    });
  });
}
