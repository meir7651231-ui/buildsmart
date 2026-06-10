// FIRESTORE CACHE-PATTERN (S3.T) — unit coverage for the stock `_firebase` repo
// [FirebaseStockRepository] over the offline-first cache base.
//
// NO Firebase here: the Firestore seam ([RemoteCollectionSource]) is driven by a
// HAND-ROLLED fake ([_FakeSource]) — no fake_cloud_firestore, no new packages.
// The fake captures every `set`/`delete` and lets a test push snapshot events,
// so we can assert the whole bridge deterministically.
//
// Pins (S3.T contract):
//   • the inventory cache is BORN seeded (`stockDemo()` non-empty before snap 1);
//   • doc-ids are the `STK-##` surrogates (Hebrew names with `/` are NOT ids);
//   • a snapshot REPLACES the cache (name→location), in seed order;
//   • optimistic `move` flips 'warehouse'⇄'site', visible SYNCHRONOUSLY + writes;
//   • `move` on an UNKNOWN name is a no-op (verbatim `StockNotifier.move`);
//   • a write FAILURE corrupts neither cache nor throws;
//   • first-empty snapshot seeds the remote from the seed;
//   • the const-backed analytics reads stay byte-identical to the local impl;
//   • the provider resolves to the LOCAL impl when Firebase is uninitialised.

import 'dart:async';

import 'package:buildsmart/data/phaseb_seeds.dart' show kStockDemo;
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/stock_firebase.dart';
import 'package:buildsmart/data/repositories/stock_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A hand-rolled fake [RemoteCollectionSource]. Backs the cache base in tests
/// with a broadcast stream we drive manually + an in-memory record of writes.
class _FakeSource implements RemoteCollectionSource {
  final _controller = StreamController<List<RemoteDoc>>.broadcast();

  /// Captured `set` calls (id → last field-map written), in arrival order.
  final List<MapEntry<String, Map<String, dynamic>>> sets = [];

  /// Captured `delete` calls (ids).
  final List<String> deletes = [];

  /// When true, the next [set] throws — to exercise the guarded write path.
  bool failNextSet = false;

  /// Push a snapshot event to listeners.
  void emit(List<RemoteDoc> docs) => _controller.add(docs);

  @override
  Stream<List<RemoteDoc>> snapshots() => _controller.stream;

  @override
  Future<void> set(String id, Map<String, dynamic> data) async {
    if (failNextSet) {
      failNextSet = false;
      throw StateError('boom (simulated write failure)');
    }
    sets.add(MapEntry(id, data));
  }

  @override
  Future<void> delete(String id) async => deletes.add(id);

  Future<void> close() => _controller.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseStockRepository — inventory (seed · move · mapping)', () {
    FirebaseStockRepository repo(_FakeSource src) =>
        FirebaseStockRepository(source: src);

    test('cache born seeded: stockDemo() == kStockDemo (11 rows, seed order)',
        () {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      // The 📦 screen is non-empty before snapshot 1 — identical 11-row map.
      expect(r.stockDemo(), kStockDemo);
      expect(r.stockDemo().length, 11);
      // Order is the seed order (the surrogate ids were assigned in that order).
      expect(r.stockDemo().keys.toList(), kStockDemo.keys.toList());
    });

    test('doc-ids are STK-## surrogates; sku==id; `/`-name lives in field data',
        () {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      // toDoc over a seed item: id is STK-##, name (with `/`) is a FIELD.
      final slash = r.seed.firstWhere((it) => it.name.contains('/'));
      expect(slash.id, startsWith('STK-'));
      final doc = r.toDoc(slash);
      expect(doc['sku'], slash.id); // sku == id (the surrogate)
      expect(doc['name'], contains('/')); // `/` safe in field data, never the id
      expect(doc['location'], anyOf('warehouse', 'site'));
    });

    test('a snapshot REPLACES the cache (name→location), in seed order',
        () async {
      final src = _FakeSource();
      final r = repo(src)..attach();
      addTearDown(src.close);
      addTearDown(r.dispose);

      // Two docs in REVERSE doc-id order (Firestore returns doc-id order; the
      // base re-sorts) — assert they land sorted by STK-## (= seed order).
      src.emit([
        const RemoteDoc('STK-01', {
          'sku': 'STK-01',
          'name': 'פריט ב/x',
          'qty': 2,
          'location': 'site',
          'projectId': '',
        }),
        const RemoteDoc('STK-00', {
          'sku': 'STK-00',
          'name': 'פריט א',
          'qty': 1,
          'location': 'warehouse',
          'projectId': '',
        }),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(r.stockDemo(), {'פריט א': 'warehouse', 'פריט ב/x': 'site'});
      expect(r.stockDemo().keys.toList(), ['פריט א', 'פריט ב/x']); // STK-00 first
    });

    test('a corrupt doc is SKIPPED — never blanks the inventory', () async {
      final src = _FakeSource();
      final r = repo(src)..attach();
      addTearDown(src.close);
      addTearDown(r.dispose);

      // One good, one structurally-bad doc (missing `location`).
      src.emit([
        const RemoteDoc('STK-00', {
          'sku': 'STK-00',
          'name': 'תקין',
          'location': 'warehouse',
        }),
        const RemoteDoc('STK-01', {'sku': 'STK-01', 'name': 'חסר-מיקום'}),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(r.stockDemo(), {'תקין': 'warehouse'}); // bad doc skipped
    });

    test('optimistic move flips warehouse⇄site, visible SYNC + writes through',
        () async {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      // Pick a seeded warehouse item and a seeded site item.
      final whName =
          kStockDemo.entries.firstWhere((e) => e.value == 'warehouse').key;
      final siteName =
          kStockDemo.entries.firstWhere((e) => e.value == 'site').key;

      r.move(whName);
      expect(r.stockDemo()[whName], 'site'); // visible immediately (warehouse→site)
      r.move(siteName);
      expect(r.stockDemo()[siteName], 'warehouse'); // site→warehouse

      // move is in-place (replace-by-id) → row count + order unchanged.
      expect(r.stockDemo().length, 11);
      expect(r.stockDemo().keys.toList(), kStockDemo.keys.toList());

      await Future<void>.delayed(Duration.zero);
      // Both flips were written to the remote with mapped fields.
      final whId =
          r.seed.firstWhere((it) => it.name == whName).id; // STK-##
      final written = src.sets.lastWhere((e) => e.key == whId).value;
      expect(written['name'], whName);
      expect(written['location'], 'site');
    });

    test('move on an UNKNOWN name is a no-op (verbatim StockNotifier.move)',
        () async {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      final before = r.stockDemo();
      r.move('שם-שלא-קיים-במלאי');
      expect(r.stockDemo(), before); // unchanged
      await Future<void>.delayed(Duration.zero);
      expect(src.sets, isEmpty); // nothing written
    });

    test('a write FAILURE corrupts neither cache nor throws', () async {
      final src = _FakeSource()..failNextSet = true;
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      final name =
          kStockDemo.entries.firstWhere((e) => e.value == 'warehouse').key;
      r.move(name); // background set throws — must be swallowed
      expect(r.stockDemo()[name], 'site'); // optimistic cache intact
      await Future<void>.delayed(Duration.zero);
      expect(src.sets, isEmpty); // the failing set was NOT recorded
      expect(r.stockDemo()[name], 'site'); // still intact, nothing threw
    });

    test('first empty snapshot seeds the remote from the seed (STK-## ids)',
        () async {
      final src = _FakeSource();
      final r = repo(src)..attach();
      addTearDown(src.close);
      addTearDown(r.dispose);

      src.emit(const []); // fresh backend
      await Future<void>.delayed(Duration.zero);

      // Cache still shows the seed (not blanked) AND all 11 rows were pushed.
      expect(r.stockDemo().length, 11);
      expect(src.sets.length, 11);
      expect(
        src.sets.map((e) => e.key).toSet(),
        r.seed.map((it) => it.id).toSet(), // STK-00 … STK-10
      );
    });

    test('const-backed analytics reads are byte-identical to LocalStock', () {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      const local = LocalStockRepository();
      // STATIC reads (NOT Firestore) must match the local impl exactly.
      expect(r.totalProducts(), local.totalProducts());
      expect(r.catalogCount(), local.catalogCount());
      expect(r.accessoryCount(), local.accessoryCount());
      expect(r.availableCount(), local.availableCount());
      expect(r.categoryCounts(), local.categoryCounts());
      expect(r.activeStores(), local.activeStores());
      expect(r.stores(), local.stores());
      expect(r.supplierStores(), local.supplierStores());
      expect(r.haulTypes(), local.haulTypes());
    });
  });

  group('stockRepositoryProvider — Firebase-free path', () {
    test('resolves to the LOCAL impl when Firebase is not initialised', () {
      // The whole suite runs without Firebase.initializeApp → Firebase.apps is
      // empty → the provider must return the const-backed local repo (never
      // touch Firestore). This keeps every other test Firebase-free.
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final repo = c.read(stockRepositoryProvider);
      expect(repo, isA<LocalStockRepository>());
      // And it behaves: the const analytics + seed are reachable.
      expect((repo as LocalStockRepository).stockDemo().length, 11);
    });
  });
}
