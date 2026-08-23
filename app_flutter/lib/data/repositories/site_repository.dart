// ─────────────────────────────────────────────────────────────────────────────
// SiteRepository — the read/write surface for the on-site workspace: the
// contractor's projects + 📋 site-tools, the 📐 plan-scan, the budget alert
// thresholds + 🦺 safety tips, per-product install-stage progress, and the
// 🦺 worker task flow (worker submit ↔ manager approve/reject).
//
// SERVER-READY FOUNDATION (Track T6.1). This is the ABSTRACT interface only;
// the local implementation (T6.2) and the provider refactor (T6.3) come later.
// When the site workspace moves to a real backend (a project/field-ops API) the
// only thing that swaps is the implementation behind this contract — the
// providers + UI stay unchanged.
//
// CURRENT BACKING (what T6.2's local impl will wrap):
//   • `kProjects` (`data/projects.dart`) — the 3 demo projects + active id.
//   • `kHomeTree` site-tools sections (`data/menu_trees.dart`).
//   • `kPlanTypes` (`data/contractor_seeds.dart`) — the 4 📐 plan-scan types.
//   • `kSafetyTips` + `kBudgetThresholds` / `budgetLevel`
//     (`data/contractor_seeds.dart`) — the rotating 🦺 tip + the alert bands.
//   • the per-product install-stage progress in `state/stage_progress.dart`
//     (`stageProgressProvider` / `StageProgressNotifier`).
//   • the shared worker-tasks engine in `state/worker_tasks_engine.dart`
//     (`workerTasksProvider` / `WorkerTasksNotifier`), seeded from
//     `kPersonaTasks` (`data/persona_data.dart`); the approval bridge advances
//     a bound order on the shared orders engine.
// A future field-ops backend drops in behind this contract (swap-impl-only).
//
// Method surface mirrors the on-site reads/writes the contractor + worker
// screens use today: project list, site-tool trees, plan-scan, budget alerts +
// safety tip, install progress, and the worker submit / manager approve flow.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/contractor_seeds.dart' show PlanType;
import 'package:buildsmart/data/persona_data.dart' show PersonaTask;
import 'package:buildsmart/data/projects.dart' show Project;
import 'package:buildsmart/data/sections.dart' show Section;

/// Server-ready contract over the on-site workspace (projects · site-tools ·
/// plan-scan · budget alerts · install progress · worker tasks). The current
/// backing is the contractor/worker const seeds + the `stageProgress` and
/// `workerTasks` engines; a future field-ops backend swaps in behind it.
abstract class SiteRepository {
  // ── projects ───────────────────────────────────────────────────────────────

  /// Every project on the contractor's board. Mirrors `kProjects`.
  List<Project> projects();

  /// The project with [id], or null when unknown. Mirrors a `kProjects` lookup.
  Project? projectById(String id);

  /// The active project's id (the board's current default). Mirrors
  /// `kActiveProjectId` (`data/projects.dart`).
  String activeProjectId();

  // ── site-tool trees ────────────────────────────────────────────────────────

  /// The 📋 משימות העבודה site-tools tree (gantt · snag · attendance · …) the
  /// Home dial opens. Mirrors the `home-tasks` children in `kHomeTree`.
  List<Section> siteToolsTree();

  // ── plan-scan ──────────────────────────────────────────────────────────────

  /// The 📐 plan-scan types (plumbing · electrical · architectural · finishing),
  /// each with its zones + per-item store offers. Mirrors `kPlanTypes`.
  List<PlanType> planTypes();

  // ── budget alerts + safety tip ─────────────────────────────────────────────

  /// The 🦺 safety tips list (rotated daily by the caller as `tips[day % len]`).
  /// Mirrors `kSafetyTips` (`data/contractor_seeds.dart`).
  List<String> safetyTips();

  /// The budget-alert level label + css-class for [pct] (תקין / התראת חריגה /
  /// חריגה קריטית). Mirrors `budgetLevel(pct)` (`data/contractor_seeds.dart`).
  ({String label, String cls}) budgetLevel(int pct);

  // ── install-stage progress (per product) ───────────────────────────────────

  /// Whether the install stage at [stageIndex] of [productKey] is marked done.
  /// Mirrors `StageProgressNotifier.isDone`.
  bool stageIsDone(String productKey, int stageIndex);

  /// How many of [stageCount] install stages are done for [productKey].
  /// Mirrors `StageProgressNotifier.doneCount`.
  int stageDoneCount(String productKey, int stageCount);

  /// Toggle the install stage at [stageIndex] of [productKey] done/undone.
  /// Mirrors `StageProgressNotifier.toggle`.
  void toggleStage(String productKey, int stageIndex);

  // ── worker tasks (worker ↔ manager flow) ───────────────────────────────────

  /// The full live worker-task list both the worker and the manager read.
  /// Mirrors `ref.watch(workerTasksProvider)`.
  List<PersonaTask> workerTasks();

  /// The tasks awaiting the manager's approval (status `review`), id-ordered —
  /// the manager's "אישורי עובדים" queue. Mirrors `pendingApprovalTasksProvider`.
  List<PersonaTask> pendingApprovals();

  /// WORKER — submit task [id] for approval (`active`/`rejected` → `review`).
  /// Mirrors `WorkerTasksNotifier.submitForReview`.
  void submitForReview(int id);

  /// MANAGER — approve task [id] (`review` → `done`); if the task is bound to an
  /// order it also advances that order on the shared engine. Mirrors
  /// `WorkerTasksNotifier.approve`.
  void approve(int id);

  /// MANAGER — reject task [id] (`review` → `rejected`, back to the worker).
  /// Mirrors `WorkerTasksNotifier.reject`.
  void reject(int id);
}
