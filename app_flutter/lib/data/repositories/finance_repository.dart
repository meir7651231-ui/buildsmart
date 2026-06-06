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
}
