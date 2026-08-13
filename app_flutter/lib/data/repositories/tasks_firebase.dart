// ─────────────────────────────────────────────────────────────────────────────
// FirebaseTasksRepository (Wave T3 · FOUNDATION) — the Firestore-backed store for
// the unified §6 tasks engine (`state/tasks_engine.dart`), built on the same
// offline-first cache base ([FirestoreCachedRepo]) as the orders pilot. It is the
// DROP-IN the engine's `bindRemote(dynamic)` seam was designed for (Wave T1): the
// engine keeps ALL its state-machine logic + side-effects (rewards / worker bell /
// the W3 order-fold) and, when bound, routes each computed [TaskItem] through this
// repo's optimistic `upsert` — the snapshot reflects it back via `all()`.
//
// HOW THE BRIDGE IS HELD (identical to orders):
//   • reads (`all`) are SYNCHRONOUS, served from the in-memory cache the base
//     maintains from a Firestore `snapshots()` listener;
//   • writes (`upsert`/`removeById`/`replaceAll`, from the base) update the cache
//     OPTIMISTICALLY and fire the matching Firestore write in the background — a
//     write failure is logged, never thrown.
//
// FIELD MAPPING (`TaskItem` ⇄ Firestore doc) — REUSES the model's own tested
// serialization for byte-fidelity with the local overlay:
//   • toDoc = `TaskItem.toJson()` MINUS `id` (the int id is the doc-id, not a field);
//   • fromDoc = `TaskItem.tryFromJson({…doc.data, id: int.parse(doc.id)})` — the
//     doc-id is parsed back into the int `id`; a structurally-bad doc → throw (the
//     base catches per-doc and SKIPS it, never blanking the list).
// Field-economy (write-when-non-empty/non-default) rides along from `toJson`, so a
// seed/demo doc round-trips byte-identical to the SharedPreferences overlay.
//
// SEED CONTRACT (offline-first, fresh-backend-safe) — mirrors orders:
//   • the cache is BORN with [buildTasksSeed] (app non-empty before snapshot 1);
//   • a FIRST snapshot that arrives EMPTY (fresh Firestore) → [pushCacheToRemote]
//     seeds the backend from that seed (the five §6 tasks appear server-side).
//
// DORMANT until the Wave-T3 wiring increment binds it: no provider consumes this
// yet, so `kUserDataServer` OFF/ON are both byte-identical (the engine stays the
// local store). The class is proven in isolation by `tasks_firebase_test.dart`.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/auth_state.dart'
    show currentUidProvider, roleProvider;
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    show CollectionReference, Query;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Firestore document-id field-map mapper lives inline here (not on the model)
/// so the legacy [TaskItem] stays untouched — the drop-in is preserved.
class FirebaseTasksRepository extends FirestoreCachedRepo<TaskItem> {
  /// Constructs the repo over the `tasks` collection. The real Firestore instance
  /// is resolved LAZILY by [FirestoreCollectionSource] (never here), so
  /// construction does not require Firebase to be initialised. Pass [source] in
  /// tests to drive the cache with a fake.
  FirebaseTasksRepository({RemoteCollectionSource? source})
      : super(source ?? FirestoreCollectionSource('tasks'));

  // ── base contract: seed · mapping · ordering · fresh-backend hook ───────────

  /// The cache is born with the five verbatim §6 seeds so the app is non-empty
  /// before the first snapshot — identical genesis to the local engine.
  @override
  List<TaskItem> get seed => buildTasksSeed();

  /// doc-id = the int task id as a string (e.g. `'3'`). Runtime ids are `max+1`.
  @override
  String idOf(TaskItem value) => value.id.toString();

  /// `TaskItem` → Firestore doc: the model's own `toJson` MINUS `id` (the id is
  /// the doc-id, not a field). Field-economy (write-when-non-empty/non-default)
  /// is inherited from `toJson`, so a seed/demo task's doc is byte-identical to
  /// its SharedPreferences overlay entry.
  @override
  Map<String, dynamic> toDoc(TaskItem t) => t.toJson()..remove('id');

  /// Firestore doc → `TaskItem`: inject the parsed doc-id as `id` and defer to the
  /// model's defensive `tryFromJson`. A non-numeric doc-id or a structurally-bad
  /// doc → THROW (the base catches per-doc and skips it — it never blanks the
  /// list).
  @override
  TaskItem fromDoc(RemoteDoc doc) {
    final id = int.tryParse(doc.id);
    if (id == null) {
      throw FormatException('tasks doc-id is not an int', doc.id);
    }
    final t = TaskItem.tryFromJson(<String, dynamic>{...doc.data, 'id': id});
    if (t == null) {
      throw const FormatException('tasks doc failed TaskItem.tryFromJson');
    }
    return t;
  }

  /// Restore the engine's ordering: seed ids 1..5 first, then runtime ids (6+),
  /// which is plain ASCENDING id order (the worker/manager views re-sort by id
  /// anyway, so this only fixes the doc-id-string ordering Firestore returns —
  /// `'10' < '2'` lexically — back to numeric).
  @override
  List<TaskItem> sortBy(List<TaskItem> items) =>
      List<TaskItem>.of(items)..sort((a, b) => a.id.compareTo(b.id));

  /// Fresh backend (first snapshot empty) → seed the remote from the local seed
  /// the cache was born with, so the five §6 tasks exist server-side.
  @override
  void onFirstSnapshotEmpty() => pushCacheToRemote();

  // ── reads (SYNCHRONOUS — served from the cache) ─────────────────────────────

  /// The whole task list, newest-numeric-last — what `_refreshFromRemote`'s
  /// `state = _remote.all()` copies into the engine (mirrors `orders.all()`).
  List<TaskItem> all() => cached();
}

/// The §6 tasks repository — ROLE-SCOPED so each party's Firestore listen matches
/// exactly what the security rules prove (mirrors `ordersRepositoryProvider`):
///   • WORKER board session → `assignedWorkerUid == uid` (their own tasks);
///   • MANAGER (a real manager role) → UNSCOPED, the god view;
///   • CONTRACTOR (main app, `roleProvider` null) with a real uid →
///     `employerId == uid` (the tasks they employ);
///   • store / courier / demo / no-uid → null → the engine stays the LOCAL store.
///
/// GATED + DORMANT: returns null unless `kTasksServer && useFirebaseBackend`, so
/// with the flag OFF (the default) the Firestore branch is dead code (tree-shaken)
/// and `TasksNotifier.bindRemote` is never called — the int-worker demo path,
/// byte-identical. `tasksProvider` (tasks_engine.dart) watches this and binds.
final tasksRepositoryProvider = Provider<FirebaseTasksRepository?>((ref) {
  if (!(kTasksServer && useFirebaseBackend)) return null;

  FirebaseTasksRepository build(
    Query<Map<String, dynamic>> Function(
            CollectionReference<Map<String, dynamic>>)?
        scope,
  ) {
    final repo = FirebaseTasksRepository(
      source: FirestoreCollectionSource('tasks', scope: scope),
    )..attach();
    ref.onDispose(repo.dispose);
    return repo;
  }

  // WORKER board session → their own assigned tasks. board.uid IS the Firebase
  // Auth uid (board_auth.dart) — a demo/seed session (uid '') stays local.
  final board = ref.watch(boardAuthProvider);
  if (board != null &&
      board.role == BoardRole.worker &&
      !board.demo &&
      board.uid.isNotEmpty) {
    final wuid = board.uid;
    return build((c) => c.where('assignedWorkerUid', isEqualTo: wuid));
  }

  // MANAGER → the unscoped god view (the rules gate the whole-collection read on
  // the manager claim); CONTRACTOR → their own employed tasks.
  final role = ref.watch(roleProvider); // null = contractor / main app
  if (role == 'manager') return build(null);
  final uid = ref.watch(currentUidProvider);
  if (role == null && uid != null && uid.isNotEmpty) {
    return build((c) => c.where('employerId', isEqualTo: uid));
  }

  return null; // store / courier / demo / no-uid → local store
});
