// FIRESTORE CACHE-PATTERN (S3.S) — unit coverage for [FirebaseSiteRepository],
// the Firestore-backed site repo COMPOSED from two cache repos (`tasks` +
// `siteStageProgress`) over the offline-first base [FirestoreCachedRepo].
//
// NO Firebase / no new packages here: each composed collection's Firestore seam
// ([RemoteCollectionSource]) is driven by a HAND-ROLLED fake ([_FakeSource]) —
// one per collection — and the orders bridge by a tiny fake [OrdersRepository]
// ([_SpyOrders]) that records the advanced id. The fakes capture every
// `set`/`delete` and let a test push snapshot events, so the whole bridge
// (seed → snapshot → optimistic write → failure handling → orders seam)
// asserts deterministically.
//
// Pins (the S3.S contract):
//   • the tasks cache is BORN seeded (kPersonaTasks) before snapshot 1;
//   • the stage cache is BORN EMPTY (a fresh user has marked nothing);
//   • a snapshot REPLACES the relevant cache;
//   • an optimistic write (submit/approve/reject/toggle) is sync-visible;
//   • a write FAILURE corrupts neither cache nor throws;
//   • approve of an order-bound task routes advance() through the ORDERS seam;
//   • the worker↔manager transitions are verbatim (guards honoured);
//   • `siteRepositoryProvider` resolves to the LOCAL impl without Firebase.

import 'dart:async';

import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/orders_repository.dart';
import 'package:buildsmart/data/repositories/site_firebase.dart';
import 'package:buildsmart/data/repositories/site_local.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A hand-rolled fake [RemoteCollectionSource] (one per composed collection).
/// Backs a cache base in tests with a broadcast stream we drive manually + an
/// in-memory record of writes/deletes.
class _FakeSource implements RemoteCollectionSource {
  final _controller = StreamController<List<RemoteDoc>>.broadcast();

  /// Captured `set` calls (id → last field-map written), in arrival order.
  final List<MapEntry<String, Map<String, dynamic>>> sets = [];

  /// Captured `delete` calls (ids).
  final List<String> deletes = [];

  /// When true, the next [set] throws — to exercise the guarded write path.
  bool failNextSet = false;

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

  @override
  bool get isScoped => false;

  Future<void> close() => _controller.close();
}

/// A tiny spy [OrdersRepository] — only records which order id `advance()` was
/// called with, so the approval→orders bridge can be asserted without a real
/// orders repo. Every other method is an unused stub.
class _SpyOrders implements OrdersRepository {
  final List<String> advanced = [];

  @override
  void advance(String orderId) => advanced.add(orderId);

  @override
  List<Order> all() => const [];
  @override
  Order? byId(String id) => null;
  @override
  List<Order> open() => const [];
  @override
  Order placeOrder({
    required String who,
    required String site,
    required int items,
    required int sum,
    String? id,
    DateTime? createdAt,
    List<OrderLineItem> lines = const [],
    String shipTo = '',
    String notes = '',
    String contractorUid = '',
    String customerPhone = '',
    String customerEmail = '',
  }) =>
      throw UnimplementedError();
  @override
  void setStage(String orderId, String stage) {}
  @override
  void claimStore(String orderId, String uid) {}
  @override
  void claimCourier(String orderId, String uid) {}
  @override
  void resetToSeed() {}
}

/// Build a [FirebaseSiteRepository] wired to fresh fakes (returned for asserts).
({
  FirebaseSiteRepository repo,
  _FakeSource tasks,
  _FakeSource stage,
  _SpyOrders orders,
}) _build() {
  final tasks = _FakeSource();
  final stage = _FakeSource();
  final orders = _SpyOrders();
  final repo = FirebaseSiteRepository(
    orders: orders,
    tasksSource: tasks,
    stageSource: stage,
  );
  addTearDown(tasks.close);
  addTearDown(stage.close);
  addTearDown(repo.dispose);
  return (repo: repo, tasks: tasks, stage: stage, orders: orders);
}

/// The seed task BS-1040-bound install (id 3) is in `review` → the manager can
/// approve it. id 1 is `active` (worker can submit), id 4 is `done`.
RemoteDoc _taskDoc(int id, String status, {String? orderId}) => RemoteDoc(
      '$id',
      {
        'title': 'task $id',
        'status': status,
        'worker': 0,
        'days': 1,
        'steps': 4,
        if (orderId != null) 'orderId': orderId,
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseSiteRepository — tasks cache (seed · snapshot · transitions)',
      () {
    test('tasks cache is BORN seeded with kPersonaTasks (ids verbatim)', () {
      final f = _build();
      expect(
        f.repo.workerTasks().map((t) => t.id).toList(),
        kPersonaTasks.map((t) => t.id).toList(),
      );
      // The seed has exactly one task in `review` (id 3) — the manager's queue.
      expect(f.repo.pendingApprovals().map((t) => t.id).toList(), [3]);
    });

    test('a snapshot REPLACES the tasks cache (id-ordered)', () async {
      final f = _build();
      f.repo.attach();

      // Docs in doc-id string order would put '10' before '2'; sortBy fixes it.
      f.tasks.emit([
        _taskDoc(10, 'active'),
        _taskDoc(2, 'review'),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(f.repo.workerTasks().map((t) => t.id).toList(), [2, 10]);
      expect(f.repo.pendingApprovals().map((t) => t.id).toList(), [2]);
    });

    test('submitForReview: active→review (sync) + writes through; guards', () async {
      final f = _build();
      // Seed id 1 is `active`.
      f.repo.submitForReview(1);
      expect(f.repo.workerTasks().firstWhere((t) => t.id == 1).status, 'review');

      await Future<void>.delayed(Duration.zero);
      final written = f.tasks.sets.firstWhere((e) => e.key == '1').value;
      expect(written['status'], 'review');

      // id 4 is `done` (not worker-owned) → no-op.
      f.repo.submitForReview(4);
      expect(f.repo.workerTasks().firstWhere((t) => t.id == 4).status, 'done');
      // Unknown id → no-op (no throw).
      f.repo.submitForReview(999);
    });

    test('approve: review→done AND advances the bound order via ORDERS seam', () async {
      final f = _build();
      // Seed id 3 is `review` and bound to BS-1040.
      f.repo.approve(3);

      expect(f.repo.workerTasks().firstWhere((t) => t.id == 3).status, 'done');
      // The bridge routed advance() through the shared orders seam (remote too).
      expect(f.orders.advanced, ['BS-1040']);

      await Future<void>.delayed(Duration.zero);
      expect(f.tasks.sets.firstWhere((e) => e.key == '3').value['status'], 'done');
    });

    test('approve: unbound review task advances NO order; non-review is no-op', () {
      final f = _build();
      f.repo.attach();
      // An unbound review task (id 7, no orderId).
      f.tasks.emit([_taskDoc(7, 'review')]);
      return Future<void>.delayed(Duration.zero, () {
        f.repo.approve(7);
        expect(f.repo.workerTasks().firstWhere((t) => t.id == 7).status, 'done');
        expect(f.orders.advanced, isEmpty); // no orderId → no advance

        // id 1 (active, not review) → no-op, no advance.
        f.repo.approve(1);
        expect(f.orders.advanced, isEmpty);
      });
    });

    test('reject: review→rejected (sync); non-review is no-op', () {
      final f = _build();
      // id 3 is `review`.
      f.repo.reject(3);
      expect(
        f.repo.workerTasks().firstWhere((t) => t.id == 3).status,
        'rejected',
      );
      // id 4 (done) → no-op.
      f.repo.reject(4);
      expect(f.repo.workerTasks().firstWhere((t) => t.id == 4).status, 'done');
    });

    test('a write FAILURE on submit corrupts neither cache nor throws', () async {
      final f = _build();
      f.tasks.failNextSet = true;

      f.repo.submitForReview(1); // optimistic cache update; background set throws
      expect(f.repo.workerTasks().firstWhere((t) => t.id == 1).status, 'review');
      await Future<void>.delayed(Duration.zero);
      expect(f.tasks.sets, isEmpty); // the failing set was swallowed
      expect(f.repo.workerTasks().firstWhere((t) => t.id == 1).status, 'review');
    });

    test('first empty tasks snapshot seeds the remote from the seed', () async {
      final f = _build();
      f.repo.attach();

      f.tasks.emit(const []); // fresh backend
      await Future<void>.delayed(Duration.zero);

      // Cache still shows the seed AND it was pushed to remote.
      expect(f.repo.workerTasks().length, kPersonaTasks.length);
      expect(
        f.tasks.sets.map((e) => e.key).toSet(),
        containsAll(kPersonaTasks.map((t) => '${t.id}')),
      );
    });
  });

  group('FirebaseSiteRepository — stage-progress cache', () {
    test('stage cache is BORN EMPTY (nothing done; no seed pushed)', () async {
      final f = _build();
      f.repo.attach();
      expect(f.repo.stageIsDone('huliot-pex', 0), isFalse);
      expect(f.repo.stageDoneCount('huliot-pex', 4), 0);

      // First empty snapshot must NOT push a seed (born empty).
      f.stage.emit(const []);
      await Future<void>.delayed(Duration.zero);
      expect(f.stage.sets, isEmpty);
    });

    test('toggleStage on/off: sync-visible + writes then deletes the flag', () async {
      final f = _build();

      f.repo.toggleStage('huliot-pex', 2); // mark done
      expect(f.repo.stageIsDone('huliot-pex', 2), isTrue);
      expect(f.repo.stageDoneCount('huliot-pex', 4), 1);
      await Future<void>.delayed(Duration.zero);
      expect(f.stage.sets.map((e) => e.key), contains('huliot-pex#2'));

      f.repo.toggleStage('huliot-pex', 2); // undo
      expect(f.repo.stageIsDone('huliot-pex', 2), isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(f.stage.deletes, contains('huliot-pex#2'));
    });

    test('a stage snapshot REPLACES the done-set (doc existence = done)', () async {
      final f = _build();
      f.repo.attach();

      f.stage.emit([
        const RemoteDoc('huliot-pex#0', {'key': 'huliot-pex#0'}),
        const RemoteDoc('huliot-pex#1', {'key': 'huliot-pex#1'}),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(f.repo.stageDoneCount('huliot-pex', 4), 2);
      expect(f.repo.stageIsDone('huliot-pex', 0), isTrue);
      expect(f.repo.stageIsDone('huliot-pex', 3), isFalse);
    });
  });

  group('projects DATA empty on the backend; static UI scaffolding kept', () {
    test('projects/projectById/activeProjectId are EMPTY on the backend', () {
      // V1/P2: the project list is real user DATA with no real source on the
      // live Firebase backend yet, so the const demo projects must NOT be shown
      // to a real signed-in user as if they were theirs — empty list / null / ''.
      final f = _build();
      expect(f.repo.projects(), isEmpty);
      expect(f.repo.projectById('NO-SUCH'), isNull);
      expect(f.repo.projectById('p1'), isNull); // no project resolves on backend
      expect(f.repo.activeProjectId(), isEmpty);
    });

    test('static UI scaffolding stays non-empty (siteTools/plan/safety/budget)',
        () {
      // KEPT: demo-neutral structure, not fabricated data.
      final f = _build();
      expect(f.repo.siteToolsTree(), isNotEmpty);
      expect(f.repo.planTypes(), isNotEmpty);
      expect(f.repo.safetyTips(), isNotEmpty);
      // budget bands resolve a label without touching any cache (pure function).
      expect(f.repo.budgetLevel(100).label, isNotEmpty);
    });
  });

  group('siteRepositoryProvider — Firebase-free path', () {
    test('resolves to the LOCAL impl when Firebase is not initialised', () {
      // The whole suite runs without Firebase.initializeApp → Firebase.apps is
      // empty → the provider must return the in-memory local repo (never touch
      // Firestore). This is what keeps every other test Firebase-free.
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final repo = c.read(siteRepositoryProvider);
      expect(repo, isA<LocalSiteRepository>());
      // And it behaves: seed projects visible through the sync contract.
      expect(repo.projects(), isNotEmpty);
    });
  });
}
