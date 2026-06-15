// FIRESTORE CACHE-PATTERN (S3.C) — unit coverage for the Firestore-backed
// customers repo [FirebaseCustomersRepository] over the offline-first cache base.
//
// NO Firebase here: the Firestore seam ([RemoteCollectionSource]) is driven by a
// HAND-ROLLED fake ([_FakeSource]) — no fake_cloud_firestore, no new packages
// (the exact shape `firestore_cached_repo_test.dart` uses for the orders pilot).
// The fake captures every `set`/`delete` and lets a test push snapshot events, so
// the whole bridge (seed → snapshot → optimistic credit write → failure handling)
// is asserted deterministically.
//
// WHAT THIS DOMAIN IS: the 👥 לקוחות view is the buyer aggregates DERIVED from the
// orders engine (`ManagerCustomer{name, orderCount, totalSpend, creditLimit}`),
// mapped to the SSOT `customers/{id} {name, phone, creditLimit, used, balance,
// ownerId}` doc (totalSpend→used, balance derived). The interface
// ([CustomersRepository]) is a derived READ surface (`all`/`byName`/`creditLimit`)
// and carries NO writes; the base's optimistic `upsert` is exercised as the
// "credit-affecting write" the S3 contract pins (sync-visible, failure-safe).
//
// Pins (the S3.C slice of the contract S3 ×6 inherit):
//   • the cache is BORN seeded with the four seed customers (app non-empty);
//   • a snapshot REPLACES the cache (credit fields round-trip used⇄totalSpend);
//   • a corrupt doc is SKIPPED, never blanks the list;
//   • an optimistic credit-affecting write is visible SYNCHRONOUSLY + writes through;
//   • a write FAILURE corrupts neither cache nor throws;
//   • first-empty seeds the remote from the seed;
//   • sort is spend-desc; byName behaves; creditLimit returns ZERO on the live
//     backend — V1/P2: the fabricated hash ceiling is not shown to a real
//     signed-in user (the real path is computeCredit, unchanged);
//   • the provider resolves to the LOCAL impl when Firebase is uninitialised
//     (where creditLimit keeps its real deterministic local value).

import 'dart:async';

import 'package:buildsmart/data/repositories/customers_firebase.dart';
import 'package:buildsmart/data/repositories/customers_local.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A hand-rolled fake [RemoteCollectionSource]. Backs the cache base in tests
/// with a broadcast stream we drive manually + an in-memory record of writes.
/// (Identical contract to the fake in `firestore_cached_repo_test.dart`.)
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

  // The four seed customers (`mgrCustomerList()` over `kManagerOrderSeed`), sorted
  // by spend desc: משה אברהם(3150) · יוסי כהן(1240) · אבי מזרחי(680) · דוד לוי(420).
  final seedCustomers = mgrCustomerList();

  FirebaseCustomersRepository repo(_FakeSource src) =>
      FirebaseCustomersRepository(source: src);

  group('FirebaseCustomersRepository — seed · mapping · sort', () {
    test('cache born with the four seed customers (names/spend verbatim)', () {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      // Same list LocalCustomersRepository.all() returns on the seed engine,
      // spend-desc — app non-empty before snapshot 1.
      expect(r.all().length, seedCustomers.length); // 4 distinct buyers
      expect(
        r.all().map((c) => c.name).toList(),
        seedCustomers.map((c) => c.name).toList(),
      );
      expect(r.all().first.name, 'משה אברהם'); // top spender (3150)
      expect(r.all().first.totalSpend, 3150);
    });

    test('snapshot REPLACES the cache; credit fields round-trip used⇄totalSpend',
        () async {
      final src = _FakeSource();
      final r = repo(src)..attach();
      addTearDown(src.close);
      addTearDown(r.dispose);

      var notified = 0;
      r.addListener(() => notified++);

      // Two docs in doc-id (Firestore) order; the base re-sorts by spend desc.
      src.emit([
        const RemoteDoc('אבי מזרחי', {
          'name': 'אבי מזרחי',
          'used': 680,
          'creditLimit': 50000,
          'balance': 49320,
          'orderCount': 1,
        }),
        const RemoteDoc('משה אברהם', {
          'name': 'משה אברהם',
          'used': 3150,
          'creditLimit': 80000,
          'balance': 76850,
          'orderCount': 2,
        }),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(notified, 1);
      // Cache replaced + spend-desc: משה אברהם(3150) before אבי מזרחי(680).
      expect(r.all().map((c) => c.name).toList(), ['משה אברהם', 'אבי מזרחי']);
      final top = r.byName('משה אברהם')!;
      expect(top.totalSpend, 3150); // used → totalSpend
      expect(top.creditLimit, 80000); // creditLimit round-trips
      expect(top.orderCount, 2); // orderCount round-trips
    });

    test('toDoc maps totalSpend→used, derives balance, omits phone/ownerId', () {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      const c = ManagerCustomer(
        name: 'יוסי כהן',
        orderCount: 3,
        totalSpend: 1240,
        creditLimit: 50000,
      );
      final doc = r.toDoc(c);
      expect(doc['name'], 'יוסי כהן');
      expect(doc['used'], 1240); // totalSpend → used
      expect(doc['creditLimit'], 50000);
      expect(doc['balance'], 48760); // creditLimit - totalSpend, derived
      expect(doc['orderCount'], 3); // carried so all() needs no join
      // No model value for these schema fields → not written (tolerant round-trip).
      expect(doc.containsKey('phone'), isFalse);
      expect(doc.containsKey('ownerId'), isFalse);
    });

    test('a corrupt doc is SKIPPED — never blanks the list', () async {
      final src = _FakeSource();
      final r = repo(src)..attach();
      addTearDown(src.close);
      addTearDown(r.dispose);

      // One good doc, one structurally-bad (missing required `used`).
      src.emit([
        const RemoteDoc('דוד לוי', {
          'name': 'דוד לוי',
          'used': 420,
          'creditLimit': 30000,
          'orderCount': 1,
        }),
        const RemoteDoc('פגום', {'name': 'פגום'}), // no used/creditLimit
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(r.all().map((c) => c.name).toList(), ['דוד לוי']); // bad skipped
    });

    test('byName behaves; creditLimit is ZERO on the backend (no fake ceiling)',
        () {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      final top = r.all().first;
      expect(r.byName(top.name)?.name, top.name);
      expect(r.byName('לא-קיים'), isNull);
      // V1/P2: the sync creditLimit() ceiling is a FABRICATED hash, so on the
      // live backend it returns 0 — a real signed-in user is not shown an
      // invented credit line. (The REAL path is computeCredit, left unchanged;
      // contractorCredit stays its fallback there — referenced below so the
      // import remains exercised.)
      expect(r.creditLimit('יוסי כהן'), 0);
      expect(contractorCredit('יוסי כהן'), greaterThanOrEqualTo(30000));
    });
  });

  group('FirebaseCustomersRepository — optimistic writes (credit)', () {
    test('credit-affecting upsert is visible SYNCHRONOUSLY + writes through',
        () async {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      // A buyer's spend grows (e.g. a new order folded in) → higher used.
      const grown = ManagerCustomer(
        name: 'דוד לוי',
        orderCount: 2,
        totalSpend: 9420, // was 420 in the seed
        creditLimit: 30000,
      );
      r.upsert(grown);

      // Visible immediately (sync), replaced by name — and re-sorted to the top.
      expect(r.byName('דוד לוי')!.totalSpend, 9420);
      expect(r.all().first.name, 'דוד לוי'); // 9420 is now top spend

      await Future<void>.delayed(Duration.zero);
      // Written to remote with the SSOT credit field-map (used = new spend).
      final written = src.sets.firstWhere((e) => e.key == 'דוד לוי').value;
      expect(written['used'], 9420);
      expect(written['balance'], 30000 - 9420);
    });

    test('a write FAILURE corrupts neither cache nor throws', () async {
      final src = _FakeSource()..failNextSet = true;
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      const c = ManagerCustomer(
        name: 'משה אברהם',
        orderCount: 5,
        totalSpend: 99999,
        creditLimit: 80000,
      );
      r.upsert(c); // background set throws — must be swallowed by guardWrite.

      // Optimistic cache intact; nothing thrown.
      expect(r.byName('משה אברהם')!.totalSpend, 99999);
      await Future<void>.delayed(Duration.zero);
      expect(src.sets, isEmpty); // the failing set was NOT recorded
      expect(r.byName('משה אברהם')!.totalSpend, 99999); // still intact
    });

    test('first empty snapshot seeds the remote from the cache seed', () async {
      final src = _FakeSource();
      final r = repo(src)..attach();
      addTearDown(src.close);
      addTearDown(r.dispose);

      src.emit(const []); // fresh backend
      await Future<void>.delayed(Duration.zero);

      // Cache still shows the seed (not blanked) AND it was pushed to remote.
      expect(r.all().length, seedCustomers.length);
      expect(
        src.sets.map((e) => e.key).toSet(),
        containsAll(seedCustomers.map((c) => c.name)),
      );
    });
  });

  group('customersRepositoryProvider — Firebase-free path', () {
    test('resolves to the LOCAL impl when Firebase is not initialised', () {
      // The whole suite runs without Firebase.initializeApp → Firebase.apps is
      // empty → the provider must return the in-memory local repo (never touch
      // Firestore). This is what keeps every other test Firebase-free.
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final r = c.read(customersRepositoryProvider);
      expect(r, isA<LocalCustomersRepository>());
      // And it behaves: the seed aggregates are visible through the sync contract.
      expect(r.all().length, seedCustomers.length);
    });
  });
}
