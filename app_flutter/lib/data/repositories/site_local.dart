// ─────────────────────────────────────────────────────────────────────────────
// LocalSiteRepository — the T6.2 local implementation of [SiteRepository].
//
// SERVER-READY FOUNDATION (Track T6.2 + T6.3). This wraps the EXISTING on-site
// const seeds + the two live engines that already back the site workspace — it
// adds NO new data and changes NO value. Every const read returns exactly the
// const it mirrors (kProjects / kActiveProjectId / kHomeTree `home-tasks` /
// kPlanTypes / kSafetyTips / budgetLevel), byte-for-byte; every stage/worker
// read & write delegates verbatim to `stageProgressProvider` /
// `workerTasksProvider` (the same notifiers the screens use today). The site
// hub's verified leaves (gantt 6/span27, the 3 floors, the 80/90/100 bands, …)
// are unaffected. When the site workspace moves to a real field-ops backend,
// only THIS class swaps (the providers + UI stay unchanged).
//
// The project SEED + active id are exposed via the extra concrete [seed] /
// [activeId] accessors so the projects engine can obtain its genesis list
// THROUGH this repository (T6.3) — const-only accessors that do NOT read the
// engine, keeping the engine↔repository wiring acyclic (the orders_local idiom).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:buildsmart/data/contractor_seeds.dart'
    show PlanType, budgetLevel, kPlanTypes, kSafetyTips;
import 'package:buildsmart/data/menu_trees.dart' show kHomeTree;
import 'package:buildsmart/data/persona_data.dart' show PersonaTask;
import 'package:buildsmart/data/projects.dart'
    show Project, kActiveProjectId, kProjects;
import 'package:buildsmart/data/repositories/site_repository.dart';
import 'package:buildsmart/data/sections.dart' show Section;
import 'package:buildsmart/state/stage_progress.dart';
import 'package:buildsmart/state/worker_tasks_engine.dart';

/// The `home-tasks` site-tools children of [kHomeTree] — the 📋 משימות העבודה
/// tree the Home dial opens. Resolved const-only (a `firstWhere` over the const
/// tree), so reading it never touches an engine (T6.3-safe); falls back to an
/// empty list if the id is ever renamed.
final List<Section> kSiteToolsTree = kHomeTree
    .firstWhere(
      (s) => s.id == 'home-tasks',
      orElse: () => const Section(id: 'home-tasks', emoji: '📋', title: ''),
    )
    .children;

/// The local (const + engine-backed) implementation of [SiteRepository]. Holds a
/// [Ref] so the install-stage + worker-task reads/writes flow through the single
/// shared `stageProgress` / `workerTasks` engines — there is exactly one live
/// progress set and one live task list, and this is the contract the contractor
/// + worker screens read & mutate through. Const reads return their mirrored
/// const directly.
class LocalSiteRepository implements SiteRepository {
  const LocalSiteRepository(this._ref);

  final Ref _ref;

  StageProgressNotifier get _stage =>
      _ref.read(stageProgressProvider.notifier);
  WorkerTasksNotifier get _tasks => _ref.read(workerTasksProvider.notifier);

  // ── projects ───────────────────────────────────────────────────────────────

  /// The verbatim project seed — the genesis list the projects engine starts
  /// from. Const-only ([kProjects]), so reading it never touches the engine
  /// (T6.3-safe), mirroring `LocalOrdersRepository.seed()`.
  List<Project> seed() => kProjects;

  /// The verbatim active-project id the projects engine seeds with. Const-only
  /// ([kActiveProjectId]); never reads the engine (T6.3-safe).
  String seedActiveId() => kActiveProjectId;

  @override
  List<Project> projects() => kProjects;

  @override
  Project? projectById(String id) {
    for (final p in kProjects) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  String activeProjectId() => kActiveProjectId;

  // ── site-tool trees ────────────────────────────────────────────────────────

  @override
  List<Section> siteToolsTree() => kSiteToolsTree;

  // ── plan-scan ──────────────────────────────────────────────────────────────

  @override
  List<PlanType> planTypes() => kPlanTypes;

  // ── budget alerts + safety tip ─────────────────────────────────────────────

  @override
  List<String> safetyTips() => kSafetyTips;

  @override
  ({String label, String cls}) budgetLevel(int pct) => budgetLevelFor(pct);

  // ── install-stage progress (per product) ───────────────────────────────────

  @override
  bool stageIsDone(String productKey, int stageIndex) =>
      _stage.isDone(productKey, stageIndex);

  @override
  int stageDoneCount(String productKey, int stageCount) =>
      _stage.doneCount(productKey, stageCount);

  @override
  void toggleStage(String productKey, int stageIndex) =>
      _stage.toggle(productKey, stageIndex);

  // ── worker tasks (worker ↔ manager flow) ───────────────────────────────────

  @override
  List<PersonaTask> workerTasks() => _ref.read(workerTasksProvider);

  @override
  List<PersonaTask> pendingApprovals() =>
      _ref.read(pendingApprovalTasksProvider);

  @override
  void submitForReview(int id) => _tasks.submitForReview(id);

  @override
  void approve(int id) => _tasks.approve(id);

  @override
  void reject(int id) => _tasks.reject(id);
}

/// Module-level pass-through to the [budgetLevel] const helper — the interface
/// method shadows its name, so the const helper is reached through this thin
/// alias (no value changes), mirroring `finance_local.dart`'s `budgetLevelFor`.
({String label, String cls}) budgetLevelFor(int pct) => budgetLevel(pct);

/// The site repository provider — the server-ready seam the on-site screens read
/// through (T6.3) and the projects engine sources its seed through; a future
/// field-ops backend swaps in behind it. Constructing it is cheap (just stores
/// the [Ref]); live reads resolve the engines lazily.
final siteRepositoryProvider =
    Provider<SiteRepository>((ref) => LocalSiteRepository(ref));
