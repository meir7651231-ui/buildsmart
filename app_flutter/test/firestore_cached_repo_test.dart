// FIRESTORE CACHE-PATTERN (S2.2/S2.3) — unit coverage for the offline-first
// cache base [FirestoreCachedRepo] and the orders pilot [FirebaseOrdersRepository].
//
// NO Firebase here: the Firestore seam ([RemoteCollectionSource]) is driven by a
// HAND-ROLLED fake ([_FakeSource]) — no fake_cloud_firestore, no new packages.
// The fake captures every `set`/`delete` and lets a test push snapshot events,
// so we can assert the whole bridge (seed → snapshot → optimistic write →
// failure handling) deterministically.
//
// Pins (the contract S3 ×6 inherit):
//   • the cache is BORN seeded (app non-empty before snapshot 1);
//   • a snapshot REPLACES the cache and notifies;
//   • a corrupt doc is SKIPPED, never blanks the list;
//   • an optimistic write is visible SYNCHRONOUSLY;
//   • S9.3 — a post-write snapshot RECONCILES the cache (LWW: the server echo
//     is canonical; a losing write converges, never resurrects);
//   • a write FAILURE corrupts neither cache nor throws;
//   • replaceAll / resetToSeed;
//   • first-empty (seed remote) ≠ a later-empty (honoured as empty);
//   • mapping + sort round-trip (who⇄contractorId, newest-first);
//   • the provider resolves to the LOCAL impl when Firebase is uninitialised.

import 'dart:async';

import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/orders_firebase.dart';
import 'package:buildsmart/data/repositories/orders_local.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/state/orders_engine.dart';
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

  /// Push a stream error (must never surface in the UI).
  void emitError(Object e) => _controller.addError(e);

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

  /// Test-settable scope flag — when true the base treats a first-empty snapshot
  /// as "this user genuinely has zero docs" (blank the seed) rather than a fresh
  /// backend (keep the seed + fire the remote-seed hook).
  bool scoped = false;

  @override
  bool get isScoped => scoped;

  Future<void> close() => _controller.close();
}

/// A minimal int-model used to exercise the GENERIC base in isolation (separate
/// from the orders specifics). Doc shape: `{id, v}`.
class _IntRepo extends FirestoreCachedRepo<int> {
  _IntRepo(super.source, {List<int> seed = const [1, 2, 3]}) : _seed = seed;

  final List<int> _seed;
  int firstEmptyCalls = 0;

  @override
  List<int> get seed => _seed;

  @override
  int fromDoc(RemoteDoc doc) {
    final v = doc.data['v'];
    if (v is! num) throw const FormatException('bad int doc');
    return v.toInt();
  }

  @override
  Map<String, dynamic> toDoc(int value) => {'v': value};

  @override
  String idOf(int value) => 'n$value';

  @override
  List<int> sortBy(List<int> items) => [...items]..sort();

  @override
  void onFirstSnapshotEmpty() => firstEmptyCalls++;
}

RemoteDoc _intDoc(int v) => RemoteDoc('n$v', {'v': v});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirestoreCachedRepo<T> — generic base', () {
    test('cache is BORN seeded (non-empty before snapshot 1)', () {
      final src = _FakeSource();
      final repo = _IntRepo(src);
      addTearDown(src.close);
      addTearDown(repo.dispose);
      expect(repo.cached(), [1, 2, 3]);
    });

    test('a snapshot REPLACES the cache and notifies', () async {
      final src = _FakeSource();
      final repo = _IntRepo(src)..attach();
      addTearDown(src.close);
      addTearDown(repo.dispose);

      var notified = 0;
      repo.addListener(() => notified++);

      src.emit([_intDoc(10), _intDoc(5)]);
      await Future<void>.delayed(Duration.zero);

      expect(repo.cached(), [5, 10]); // sorted by base
      expect(notified, 1);
    });

    test('a corrupt doc is SKIPPED — never blanks the list', () async {
      final src = _FakeSource();
      final repo = _IntRepo(src)..attach();
      addTearDown(src.close);
      addTearDown(repo.dispose);

      // One good, one structurally-bad doc.
      src.emit([_intDoc(7), const RemoteDoc('bad', {'v': 'not-a-number'})]);
      await Future<void>.delayed(Duration.zero);

      expect(repo.cached(), [7]); // bad doc skipped, good one kept
    });

    test('a stream error never throws (last good cache retained)', () async {
      final src = _FakeSource();
      final repo = _IntRepo(src)..attach();
      addTearDown(src.close);
      addTearDown(repo.dispose);

      src.emit([_intDoc(9)]);
      await Future<void>.delayed(Duration.zero);
      expect(repo.cached(), [9]);

      // Must not throw / crash the zone.
      src.emitError(StateError('stream boom'));
      await Future<void>.delayed(Duration.zero);
      expect(repo.cached(), [9]); // unchanged
    });

    test('optimistic upsert is visible SYNCHRONOUSLY + writes through', () async {
      final src = _FakeSource();
      final repo = _IntRepo(src);
      addTearDown(src.close);
      addTearDown(repo.dispose);

      repo.upsert(99);
      expect(repo.cached(), [1, 2, 3, 99]); // visible immediately (sorted)

      await Future<void>.delayed(Duration.zero);
      expect(src.sets.map((e) => e.key), contains('n99'));
    });

    test(
        'S9.3 — a post-write snapshot RECONCILES the optimistic cache '
        '(last-write-wins: the server echo is canonical, no merge)', () async {
      final src = _FakeSource();
      final repo = _IntRepo(src)..attach();
      addTearDown(src.close);
      addTearDown(repo.dispose);

      // Optimistic write lands synchronously…
      repo.upsert(99);
      expect(repo.cached(), [1, 2, 3, 99]);

      // …the server ECHOES it back (the write won) → cache == server state.
      src.emit([_intDoc(1), _intDoc(2), _intDoc(3), _intDoc(99)]);
      await Future<void>.delayed(Duration.zero);
      expect(repo.cached(), [1, 2, 3, 99]);

      // A LATER snapshot WITHOUT 99 (another writer won / the write lost the
      // LWW race) must converge to the server truth — the snapshot REPLACES
      // the cache wholesale, never merges, never resurrects the loser.
      src.emit([_intDoc(1), _intDoc(2), _intDoc(3)]);
      await Future<void>.delayed(Duration.zero);
      expect(repo.cached(), [1, 2, 3]); // converged: no phantom 99
    });

    test('a write FAILURE corrupts neither cache nor throws', () async {
      final src = _FakeSource()..failNextSet = true;
      final repo = _IntRepo(src);
      addTearDown(src.close);
      addTearDown(repo.dispose);

      // upsert whose background set throws — must be swallowed.
      repo.upsert(42);
      expect(repo.cached(), [1, 2, 3, 42]); // optimistic cache intact
      await Future<void>.delayed(Duration.zero);
      // The failing set was NOT recorded, and nothing threw.
      expect(src.sets, isEmpty);
      expect(repo.cached(), [1, 2, 3, 42]); // still intact
    });

    test('replaceAll swaps the whole cache + writes each', () async {
      final src = _FakeSource();
      final repo = _IntRepo(src);
      addTearDown(src.close);
      addTearDown(repo.dispose);

      repo.replaceAll([8, 6, 7]);
      expect(repo.cached(), [6, 7, 8]);
      await Future<void>.delayed(Duration.zero);
      expect(src.sets.map((e) => e.key).toSet(), {'n8', 'n6', 'n7'});
    });

    test('removeById drops from cache + deletes remotely', () async {
      final src = _FakeSource();
      final repo = _IntRepo(src);
      addTearDown(src.close);
      addTearDown(repo.dispose);

      repo.removeById('n2');
      expect(repo.cached(), [1, 3]);
      await Future<void>.delayed(Duration.zero);
      expect(src.deletes, ['n2']);
    });

    test('first-empty snapshot fires the hook; a LATER empty is honoured',
        () async {
      final src = _FakeSource();
      final repo = _IntRepo(src)..attach();
      addTearDown(src.close);
      addTearDown(repo.dispose);

      // FIRST snapshot empty → hook fires once, cache keeps the seed.
      src.emit(const []);
      await Future<void>.delayed(Duration.zero);
      expect(repo.firstEmptyCalls, 1);
      expect(repo.cached(), [1, 2, 3]); // still seeded (not blanked)

      // A real snapshot arrives.
      src.emit([_intDoc(4)]);
      await Future<void>.delayed(Duration.zero);
      expect(repo.cached(), [4]);

      // A LATER empty snapshot is a genuine "now empty" → cache empties, no hook.
      src.emit(const []);
      await Future<void>.delayed(Duration.zero);
      expect(repo.firstEmptyCalls, 1); // not called again
      expect(repo.cached(), isEmpty);
    });

    test('SCOPED first-empty BLANKS the seed to honest-empty (no seed-hook)',
        () async {
      // A uid-SCOPED source returning empty = THIS user genuinely has zero docs,
      // so the demo seed (another persona's data) must NOT be shown as the user's
      // own — the base blanks it. (Latent bug fixed: once kUidScopedQueries is ON
      // a brand-new user would otherwise see the seed orders as live data.)
      final src = _FakeSource()..scoped = true;
      final repo = _IntRepo(src)..attach();
      addTearDown(src.close);
      addTearDown(repo.dispose);

      expect(repo.cached(), [1, 2, 3]); // born seeded
      src.emit(const []); // first snapshot empty, but the source is SCOPED
      await Future<void>.delayed(Duration.zero);
      expect(repo.cached(), isEmpty); // blanked to honest-empty (not the seed)
      expect(repo.firstEmptyCalls, 0); // remote-seed hook NOT fired for scoped-empty
    });

    test('pushCacheToRemote writes every cached item without mutating cache',
        () async {
      final src = _FakeSource();
      final repo = _IntRepo(src);
      addTearDown(src.close);
      addTearDown(repo.dispose);

      repo.pushCacheToRemote();
      expect(repo.cached(), [1, 2, 3]); // unchanged
      await Future<void>.delayed(Duration.zero);
      expect(src.sets.map((e) => e.key).toSet(), {'n1', 'n2', 'n3'});
    });
  });

  group('FirebaseOrdersRepository — pilot (mapping · sort · write semantics)',
      () {
    FirebaseOrdersRepository repo(_FakeSource src) =>
        FirebaseOrdersRepository(source: src);

    test('cache born with the four seed orders (ids/stages verbatim)', () {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);
      expect(
        r.all().map((o) => o.id).toList(),
        kManagerOrderSeed.map((o) => o.id).toList(), // BS-1042..BS-1039
      );
      expect(r.open().length, 4); // none delivered
    });

    test('mapping + sort round-trip via a snapshot (who⇄contractorId, ts)',
        () async {
      final src = _FakeSource();
      final r = repo(src)..attach();
      addTearDown(src.close);
      addTearDown(r.dispose);

      // Two docs in doc-id order (Firestore order); one timestamped, one seed-like.
      src.emit([
        const RemoteDoc('BS-2000', {
          'contractorId': 'יוסי כהן',
          'siteAddress': 'מגדל הרצליה',
          'items': 7,
          'sum': 1240,
          'stage': 'new',
          'ts': '2026-06-10T09:00:00.000',
        }),
        const RemoteDoc('BS-1039', {
          'contractorId': 'דוד לוי',
          'siteAddress': 'משרדים — תל אביב',
          'items': 3,
          'sum': 420,
          'stage': 'transit',
        }),
      ]);
      await Future<void>.delayed(Duration.zero);

      // Timestamped order sorts to the FRONT (newest-first), seed (null ts) after.
      expect(r.all().map((o) => o.id).toList(), ['BS-2000', 'BS-1039']);
      final first = r.byId('BS-2000')!;
      expect(first.who, 'יוסי כהן'); // contractorId → who
      expect(first.site, 'מגדל הרצליה'); // siteAddress → site
      expect(first.createdAt, isNotNull); // ts → createdAt
      expect(r.byId('BS-1039')!.createdAt, isNull); // no ts → null
    });

    test('toDoc maps who→contractorId, site→siteAddress, createdAt→ts ISO', () {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      final o = Order(
        id: 'BS-5',
        who: 'אבי',
        site: 'אתר',
        items: 2,
        sum: 300,
        stage: 'new',
        createdAt: DateTime.parse('2026-06-10T08:30:00.000'),
      );
      final doc = r.toDoc(o);
      expect(doc['contractorId'], 'אבי');
      expect(doc['siteAddress'], 'אתר');
      expect(doc['ts'], '2026-06-10T08:30:00.000');
      expect(doc.containsKey('id'), isFalse); // id is the doc-id, not a field
      expect(doc.containsKey('who'), isFalse); // legacy names not written
    });

    test('placeOrder: new order at stage `new`, prepended, next BS-####',
        () async {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      final o = r.placeOrder(who: 'קבלן', site: 'אתר', items: 5, sum: 900);
      expect(o.stage, 'new');
      expect(o.id, 'BS-1043'); // seed max BS-1042 → next
      expect(r.all().first.id, 'BS-1043'); // prepended (newest-first)
      expect(o.createdAt, isNotNull);

      await Future<void>.delayed(Duration.zero);
      // Written to remote with mapped fields.
      final written = src.sets.firstWhere((e) => e.key == 'BS-1043').value;
      expect(written['contractorId'], 'קבלן');
      expect(written['stage'], 'new');
    });

    test('advance: walks the flow then stops at delivered (no-op at end)', () {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      // BS-1042 is `new` → drive it through the whole flow.
      const rest = ['preparing', 'ready', 'pickup', 'transit', 'delivered'];
      for (final want in rest) {
        r.advance('BS-1042');
        expect(r.byId('BS-1042')!.stage, want);
      }
      r.advance('BS-1042'); // already delivered → no-op
      expect(r.byId('BS-1042')!.stage, 'delivered');
    });

    test('advance: unknown id is a no-op', () {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);
      final before = r.all().map((o) => o.stage).toList();
      r.advance('NOPE');
      expect(r.all().map((o) => o.stage).toList(), before);
    });

    test('setStage: god-step to any stage; ignores unknown stage/id/no-op', () {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      r.setStage('BS-1042', 'delivered');
      expect(r.byId('BS-1042')!.stage, 'delivered');
      expect(r.open().length, 3); // dropped from open

      r.setStage('BS-1042', 'banana'); // unknown stage → ignored
      expect(r.byId('BS-1042')!.stage, 'delivered');

      final before = r.all().map((o) => o.stage).toList();
      r.setStage('NOPE', 'ready'); // unknown id → ignored
      expect(r.all().map((o) => o.stage).toList(), before);
    });

    test('resetToSeed restores the four seed orders + re-writes them', () async {
      final src = _FakeSource();
      final r = repo(src);
      addTearDown(src.close);
      addTearDown(r.dispose);

      r
        ..placeOrder(who: 'x', site: 's', items: 1, sum: 1)
        ..advance('BS-1041')
        ..resetToSeed();
      expect(
        r.all().map((o) => o.id).toList(),
        kManagerOrderSeed.map((o) => o.id).toList(),
      );
      expect(r.byId('BS-1041')!.stage, 'preparing'); // back to seed stage

      await Future<void>.delayed(Duration.zero);
      // The seed was pushed to the remote.
      expect(
        src.sets.map((e) => e.key).toSet(),
        containsAll(kManagerOrderSeed.map((o) => o.id)),
      );
    });

    test('first empty snapshot seeds the remote from the cache seed', () async {
      final src = _FakeSource();
      final r = repo(src)..attach();
      addTearDown(src.close);
      addTearDown(r.dispose);

      src.emit(const []); // fresh backend
      await Future<void>.delayed(Duration.zero);

      // Cache still shows the seed (not blanked) AND it was pushed to remote.
      expect(r.all().length, 4);
      expect(
        src.sets.map((e) => e.key).toSet(),
        containsAll(kManagerOrderSeed.map((o) => o.id)),
      );
    });
  });

  group('ordersRepositoryProvider — Firebase-free path', () {
    test('resolves to the LOCAL impl when Firebase is not initialised', () {
      // The whole suite runs without Firebase.initializeApp → Firebase.apps is
      // empty → the provider must return the in-memory local repo (never touch
      // Firestore). This is what keeps every other test Firebase-free.
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final repo = c.read(ordersRepositoryProvider);
      expect(repo, isA<LocalOrdersRepository>());
      // And it behaves: seed visible through the sync contract.
      expect(repo.all().length, kManagerOrderSeed.length);
    });
  });
}
