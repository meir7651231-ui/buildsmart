// ─────────────────────────────────────────────────────────────────────────────
// FirebaseSiteRepository — the S3.S Firestore-backed implementation of
// [SiteRepository], built on the offline-first cache base
// ([FirestoreCachedRepo]). It is a DROP-IN for [LocalSiteRepository]: the
// `siteRepositoryProvider` + every on-site screen are unchanged — only which
// class the provider returns flips (see the switch in `site_local.dart`).
//
// WHY THIS REPO IS *COMPOSED* (two backing repos, not one):
//   The site interface holds TWO independent live lists plus several STATIC
//   surfaces. Per the SSOT (S3.S row: "If it holds several independent lists,
//   COMPOSE multiple FirestoreCachedRepo instances … document your choice"):
//     • worker tasks (worker↔manager flow)  → collection `tasks`
//       (one `FirestoreCachedRepo<PersonaTask>` — schema `tasks/{id}`).
//     • per-product install-stage progress    → collection `siteStageProgress`
//       (a site-prefixed `FirestoreCachedRepo<_StageFlag>`; each done-flag is one
//        doc keyed `"<productKey>#<idx>"` — there is no schema collection for this
//        client-only set, so it gets its own site-prefixed one, exactly as the
//        SSOT prescribes "a site-prefixed one for any stage/progress state").
//   The STATIC board surfaces (`projects` / `projectById` / `activeProjectId` /
//   `siteToolsTree` / `planTypes` / `safetyTips` / `budgetLevel`) stay CONST
//   pass-throughs — NOT Firestore. They are demo/board constants that never
//   mutate at runtime (the catalog-style rule: static data does not belong in
//   Firestore — zero DB cost, see SSOT §אזהרות). So `projects` is intentionally
//   NOT a third composed repo.
//
// HOW THE BRIDGE IS HELD (identical to the orders pilot):
//   • reads (`workerTasks`/`pendingApprovals`/`stageIsDone`/`stageDoneCount`) are
//     SYNCHRONOUS, served from the two in-memory caches each base maintains from
//     its Firestore `snapshots()` listener;
//   • writes (`submitForReview`/`approve`/`reject`/`toggleStage`) update the
//     matching cache OPTIMISTICALLY (instant for the UI) and fire the Firestore
//     write in the background — a write failure is logged, never thrown.
//
// WRITE SEMANTICS ARE VERBATIM PORTS of `WorkerTasksNotifier`
// (`state/worker_tasks_engine.dart`) and `StageProgressNotifier`
// (`state/stage_progress.dart`) so every status transition / done-flag stays
// byte-for-byte identical to the local path:
//   • `submitForReview` → only `active`/`rejected` → `review`, else no-op;
//   • `approve`         → only `review` → `done`; if the task carries an
//                          `orderId` it ALSO advances that order — and (per the
//                          SSOT seam rule) it routes that advance through the
//                          shared `ordersRepositoryProvider` so the order moves
//                          REMOTELY too (not just on the local engine);
//   • `reject`          → only `review` → `rejected`, else no-op;
//   • `toggleStage`     → flips the `"<productKey>#<idx>"` done-flag.
//
// SEED CONTRACT (offline-first, fresh-backend-safe), per base repo:
//   • the tasks cache is BORN with `kPersonaTasks`; a FIRST empty snapshot seeds
//     the remote from it (`pushCacheToRemote`, factored once via the private
//     seed-pushing subclass [_SeedingRepo]);
//   • the stage-progress cache is BORN EMPTY (the local set starts `const {}` —
//     a fresh user has marked nothing) so there is nothing to seed; a first
//     empty snapshot is therefore the honest steady state (no-op hook).
//
// Comment density/voice mirrors `orders_firebase.dart` — the S3 template.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/contractor_seeds.dart'
    show PlanType, kPlanTypes, kSafetyTips;
import 'package:buildsmart/data/persona_data.dart'
    show PersonaTask, kPersonaTasks;
import 'package:buildsmart/data/projects.dart' show Project;
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/orders_repository.dart';
import 'package:buildsmart/data/repositories/site_local.dart'
    show budgetLevelFor, kSiteToolsTree;
import 'package:buildsmart/data/repositories/site_repository.dart';
import 'package:buildsmart/data/sections.dart' show Section;

/// A seed-pushing [FirestoreCachedRepo] subclass: factors the fresh-backend hook
/// ONCE (the SSOT asks for a private seed-pushing subclass that factors
/// `onFirstSnapshotEmpty` once). Any composed repo that should seed a fresh
/// remote from its local seed extends this instead of overriding the hook by
/// hand.
abstract class _SeedingRepo<T> extends FirestoreCachedRepo<T> {
  _SeedingRepo(super.source);

  /// Fresh backend (first snapshot empty) → seed the remote from the local seed
  /// the cache was born with.
  @override
  void onFirstSnapshotEmpty() => pushCacheToRemote();
}

// ─── worker tasks · collection `tasks` ───────────────────────────────────────

/// The Firestore-backed worker-task cache (collection `tasks`). Verbatim port of
/// the `WorkerTasksNotifier` transitions; only `status` ever changes at runtime,
/// so `toDoc` round-trips the whole task and `fromDoc` is tolerant of the seed
/// shape. Doc-id = the task's int id as a string (`'3'`).
class _TasksRepo extends _SeedingRepo<PersonaTask> {
  _TasksRepo({RemoteCollectionSource? source})
      : super(source ?? FirestoreCollectionSource('tasks'));

  /// The cache is born with the verbatim worker-task seed so the app is
  /// non-empty before the first snapshot — identical genesis to the local engine.
  @override
  List<PersonaTask> get seed => kPersonaTasks;

  /// doc-id = the task id as a string (`PersonaTask.id` is an int).
  @override
  String idOf(PersonaTask value) => '${value.id}';

  /// `PersonaTask` → Firestore doc. `status` is the only field that mutates;
  /// the rest round-trip so a fresh backend reseeds the full task. Maps to the
  /// schema `tasks/{id}` field names where they line up (`title`, `status`),
  /// keeping the client-only fields (`worker`/`days`/`steps`/`note`/`orderId`)
  /// under their own keys so the round-trip is loss-free.
  @override
  Map<String, dynamic> toDoc(PersonaTask t) => {
        'title': t.name,
        'status': t.status,
        'worker': t.worker,
        'days': t.days,
        'steps': t.steps,
        if (t.note.isNotEmpty) 'note': t.note,
        if (t.orderId != null) 'orderId': t.orderId,
      };

  /// Firestore doc → `PersonaTask`. Inverse of [toDoc]: the doc-id becomes the
  /// int `id`. Tolerant of the legacy `name` key as well as the schema `title`.
  /// THROWS on a structurally-bad doc (the base catches+skips it per-doc).
  @override
  PersonaTask fromDoc(RemoteDoc doc) {
    final j = doc.data;
    return PersonaTask(
      id: int.parse(doc.id),
      name: (j['title'] ?? j['name']) as String,
      worker: (j['worker'] as num).toInt(),
      status: j['status'] as String,
      days: (j['days'] as num).toInt(),
      steps: (j['steps'] as num).toInt(),
      note: (j['note'] as String?) ?? '',
      orderId: j['orderId'] as String?,
    );
  }

  /// Restore the seed's id order (Firestore returns docs in doc-id *string*
  /// order, which sorts '10' before '2'); the worker/manager lists read tasks
  /// in ascending numeric id, so sort by the int id.
  @override
  List<PersonaTask> sortBy(List<PersonaTask> items) =>
      List<PersonaTask>.of(items)..sort((a, b) => a.id.compareTo(b.id));
}

// ─── install-stage progress · collection `siteStageProgress` ─────────────────

/// One install-stage done-flag — the model the stage-progress cache holds. The
/// `StageProgressNotifier` state is a `Set<String>` of `"<productKey>#<idx>"`
/// keys; here each present key is ONE doc (doc-id = the key). A doc's existence
/// means "done"; toggling off deletes it.
class _StageFlag {
  const _StageFlag(this.key);
  final String key;
}

/// The Firestore-backed install-stage cache (collection `siteStageProgress`).
/// Born EMPTY (the local set starts `const {}`), so there is nothing to seed —
/// the default no-op `onFirstSnapshotEmpty` is correct (a fresh user has marked
/// nothing done). Verbatim port of `StageProgressNotifier`'s key scheme +
/// `isDone`/`doneCount`/`toggle`.
class _StageRepo extends FirestoreCachedRepo<_StageFlag> {
  _StageRepo({RemoteCollectionSource? source})
      : super(source ?? FirestoreCollectionSource('siteStageProgress'));

  /// Verbatim port of `StageProgressNotifier.keyFor`.
  static String keyFor(String productKey, int stageIndex) =>
      '$productKey#$stageIndex';

  /// Born empty — a fresh user has marked nothing done (mirrors `const {}`).
  @override
  List<_StageFlag> get seed => const [];

  /// doc-id = the `"<productKey>#<idx>"` key itself.
  @override
  String idOf(_StageFlag value) => value.key;

  /// The doc only needs to EXIST to mean "done"; store the key for clarity.
  @override
  Map<String, dynamic> toDoc(_StageFlag v) => {'key': v.key};

  /// The doc-id IS the key (the field is redundant but tolerated).
  @override
  _StageFlag fromDoc(RemoteDoc doc) => _StageFlag(doc.id);

  /// True iff the `"<productKey>#<idx>"` flag is present in the cache. Verbatim
  /// port of `StageProgressNotifier.isDone`.
  bool isDone(String productKey, int stageIndex) {
    final k = keyFor(productKey, stageIndex);
    for (final f in cached()) {
      if (f.key == k) return true;
    }
    return false;
  }

  /// How many of [stageCount] stages are done for [productKey]. Verbatim port of
  /// `StageProgressNotifier.doneCount`.
  int doneCount(String productKey, int stageCount) {
    var n = 0;
    for (var i = 0; i < stageCount; i++) {
      if (isDone(productKey, i)) n++;
    }
    return n;
  }

  /// Toggle the `"<productKey>#<idx>"` flag: present → delete (undone), absent →
  /// upsert (done). Verbatim port of `StageProgressNotifier.toggle`'s set move,
  /// expressed as an optimistic doc create/delete on the base.
  void toggle(String productKey, int stageIndex) {
    final k = keyFor(productKey, stageIndex);
    if (isDone(productKey, stageIndex)) {
      removeById(k);
    } else {
      upsert(_StageFlag(k));
    }
  }
}

// ─── the composed repository ─────────────────────────────────────────────────

/// The Firestore-backed [SiteRepository]. COMPOSES the two cache repos above and
/// holds the [OrdersRepository] seam so an approved task's order advances
/// REMOTELY (not just on the local engine). Static board surfaces are const
/// pass-throughs (the `LocalSiteRepository` idiom, value-identical).
class FirebaseSiteRepository implements SiteRepository {
  /// Constructs over the `tasks` + `siteStageProgress` collections. The two
  /// underlying repos resolve `FirebaseFirestore.instance` LAZILY (never here),
  /// so construction needs no initialised Firebase. [orders] is the shared
  /// orders seam an approval bridges through; in tests pass fakes for all three.
  FirebaseSiteRepository({
    required OrdersRepository orders,
    RemoteCollectionSource? tasksSource,
    RemoteCollectionSource? stageSource,
  })  : _orders = orders,
        _tasks = _TasksRepo(source: tasksSource),
        _stage = _StageRepo(source: stageSource);

  final OrdersRepository _orders;
  final _TasksRepo _tasks;
  final _StageRepo _stage;

  /// Subscribe BOTH composed caches to their live streams. Called by the
  /// provider switch right after construction (the `..attach()` idiom).
  void attach() {
    _tasks.attach();
    _stage.attach();
  }

  /// Dispose BOTH composed caches (cancel their subscriptions). Wired to
  /// `ref.onDispose` by the provider switch.
  void dispose() {
    _tasks.dispose();
    _stage.dispose();
  }

  // ── projects DATA (no real source yet → EMPTY on the live backend) ──────────
  // The project list is real user DATA, but there is NO real source for it on
  // the live Firebase backend yet — so the const demo projects MUST NOT be shown
  // to a real signed-in user as if they were their own. This repo runs ONLY when
  // the backend is ON (the provider routes here only when `useFirebaseBackend`
  // is true), so returning an empty list / null / '' unconditionally is correct
  // — a real user sees an honest empty board, not three fabricated projects.
  // (The static UI scaffolding below — siteToolsTree / planTypes / safetyTips /
  // budgetLevel — is KEPT: it is demo-neutral structure, not fabricated data.)

  @override
  List<Project> projects() => const [];

  @override
  Project? projectById(String id) => null;

  @override
  String activeProjectId() => '';

  // ── site-tool trees / plan-scan / safety / budget (STATIC) ──────────────────

  @override
  List<Section> siteToolsTree() => kSiteToolsTree;

  @override
  List<PlanType> planTypes() => kPlanTypes;

  @override
  List<String> safetyTips() => kSafetyTips;

  @override
  ({String label, String cls}) budgetLevel(int pct) => budgetLevelFor(pct);

  // ── install-stage progress (LIVE — `siteStageProgress` cache) ───────────────

  @override
  bool stageIsDone(String productKey, int stageIndex) =>
      _stage.isDone(productKey, stageIndex);

  @override
  int stageDoneCount(String productKey, int stageCount) =>
      _stage.doneCount(productKey, stageCount);

  @override
  void toggleStage(String productKey, int stageIndex) =>
      _stage.toggle(productKey, stageIndex);

  // ── worker tasks (LIVE — `tasks` cache; approve bridges to orders) ──────────

  @override
  List<PersonaTask> workerTasks() => _tasks.cached();

  /// The tasks awaiting approval (`review`), id-ordered — verbatim port of
  /// `pendingApprovalTasksProvider` over the cache.
  @override
  List<PersonaTask> pendingApprovals() =>
      _tasks.cached().where((t) => t.status == 'review').toList()
        ..sort((a, b) => a.id.compareTo(b.id));

  PersonaTask? _taskById(int id) {
    for (final t in _tasks.cached()) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// WORKER — submit task [id] for approval (`active`/`rejected` → `review`),
  /// else no-op. Verbatim port of `WorkerTasksNotifier.submitForReview`,
  /// expressed as an optimistic upsert on the tasks cache.
  @override
  void submitForReview(int id) {
    final t = _taskById(id);
    if (t == null) return;
    if (t.status != 'active' && t.status != 'rejected') return;
    _tasks.upsert(t.copyWith(status: 'review'), prepend: false);
  }

  /// MANAGER — approve task [id] (`review` → `done`), else no-op. If the task is
  /// bound to an order, ALSO advance that order — routed through the shared
  /// [OrdersRepository] seam so it advances REMOTELY too (the SSOT bridge rule),
  /// exactly as the local engine advances it on the shared orders engine.
  @override
  void approve(int id) {
    final t = _taskById(id);
    if (t == null || t.status != 'review') return;
    _tasks.upsert(t.copyWith(status: 'done'), prepend: false);
    final orderId = t.orderId;
    if (orderId != null) _orders.advance(orderId);
  }

  /// MANAGER — reject task [id] (`review` → `rejected`, back to the worker),
  /// else no-op. Verbatim port of `WorkerTasksNotifier.reject`.
  @override
  void reject(int id) {
    final t = _taskById(id);
    if (t == null || t.status != 'review') return;
    _tasks.upsert(t.copyWith(status: 'rejected'), prepend: false);
  }
}
