// ─────────────────────────────────────────────────────────────────────────────
// FinanceRepository — the read surface for the 📊 מרכז פיננסים hub + the
// contractor project budget.
//
// SERVER-READY FOUNDATION (Track T6.1). ABSTRACT interface only; local impl
// (T6.2) + provider refactor (T6.3) come later.
//
// CURRENT BACKING (what T6.2's local impl will wrap): the const project-budget
// seeds in `data/contractor_seeds.dart` (`kBudgetTotal`, `kBudgetSpent`,
// `kBudgetCategories`, `kBudgetThresholds`, `budgetLevel`) and the finance-hub
// section list in `data/menu_trees.dart` (`kFinanceHub`). Revenue figures are
// derived from the shared orders engine via the manager analytics
// (`managerAnalyticsProvider`). A future accounting backend drops in behind
// this contract (swap-implementation-only).
//
// Method surface mirrors what the budget box / detail + finance hub read today.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/contractor_seeds.dart' show BudgetCategory;
import 'package:buildsmart/data/sections.dart' show Section;
import 'package:buildsmart/state/finance_hub_state.dart' show FinanceApproval;
import 'package:flutter/foundation.dart' show Listenable;

/// Server-ready contract over the project budget + finance hub. The current
/// backing is `data/contractor_seeds.dart` (budget seeds) + `data/menu_trees.dart`
/// (`kFinanceHub`); a future accounting backend swaps in behind it.
abstract class FinanceRepository {
  /// Total project budget in ₪. Mirrors `kBudgetTotal`.
  int budgetTotal();

  /// Amount spent so far in ₪ (== Σ of [budgetCategories]). Mirrors `kBudgetSpent`.
  int budgetSpent();

  /// The four spend categories (name · icon · amount). Mirrors `kBudgetCategories`.
  List<BudgetCategory> budgetCategories();

  /// Spend as a whole-percent of [budgetTotal] (`round(spent/total*100)`), the
  /// value the threshold alerts compare against (`finThresholds`).
  int budgetPct();

  /// The budget level label + css-class for [pct] (תקין / התראת חריגה /
  /// חריגה קריטית). Mirrors `budgetLevel(pct)`.
  ({String label, String cls}) budgetLevel(int pct);

  /// The 📊 מרכז פיננסים hub tiles (10 leaves — index/payterms/subs/…).
  /// Mirrors `kFinanceHub` (`data/menu_trees.dart`).
  List<Section> financeHub();

  /// Active revenue (Σ sum of open orders) in ₪ — the manager's 💰 figure,
  /// derived from the shared orders engine's live analytics.
  int activeRevenue();

  // ── budget WRITES (server-connect: persist the editable project budget) ──────

  /// Persist the WHOLE editable project budget (total + spent + categories) — the
  /// single source the budget editor commits on every change. The local impl is a
  /// no-op (the demo budget is the in-memory `budgetProvider`, ephemeral as it has
  /// always been); the Firebase impl upserts the single `financeBudget/active` doc.
  void setBudget(int total, int spent, List<BudgetCategory> categories);

  /// A [Listenable] that fires when the persisted budget changes — a snapshot
  /// arrived OR our own optimistic write landed — so the budget editor can re-seed
  /// from the live reads. Null on the const-backed local impl (nothing streams).
  Listenable? get budgetListenable;

  // ── purchase-approval queue (server-connect: the persisted approval list) ────

  /// The live purchase-approval queue. The const-backed local impl returns the
  /// demo seed (`kApprovalQueue`); the Firebase impl returns the persisted
  /// Firestore list — so on the connected build the manager sees REAL approvals,
  /// not the AP-201/202 demo seed.
  List<FinanceApproval> approvals();

  /// Set request [id]'s decision — `ok` → 'אושר', else 'נדחה'. The const-backed
  /// local impl is a no-op (the demo flip lives in the notifier); the Firebase
  /// impl persists it.
  void decide(String id, bool ok);

  /// A [Listenable] that fires when the persisted approvals change (a snapshot
  /// arrived / our own write landed) so the approval-queue notifier re-seeds.
  /// Null on the const-backed local impl (nothing streams).
  Listenable? get approvalsListenable;
}
