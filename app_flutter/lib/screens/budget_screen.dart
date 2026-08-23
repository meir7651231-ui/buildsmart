// T3.C · תקציב — proto §3 [L7150-7301] (renderBudget / openBudgetDetail /
//   openBudgetEditor / openCategoryEditor / saveCategoryEdit / deleteCategory /
//   saveBudget / adjustBudget). Verbatim labels + math:
//     pct = round(spent/total*100)   (9840/15000 → 66%)
//     left = total - spent           (colour danger when < 0)
//     category share = amount / Σamounts
//   Seeds come from data/contractor_seeds.dart (kBudgetTotal/Spent/Categories);
//   the screen owns a tiny editable mirror so total/spent/categories can be
//   edited at runtime exactly like the prototype's `projectBudget` globals.
//
// Build entry: openBudget (route()). The menu leaf wires here (REPORT WIRE).
//
// ANTI-COLLISION: this is a NEW file (prefix budget_); no shared file edited.

import 'package:buildsmart/data/contractor_seeds.dart';
import 'package:buildsmart/data/repositories/backend.dart'
    show useFirebaseBackend;
import 'package:buildsmart/data/repositories/finance_local.dart' show financeRepo;
import 'package:buildsmart/data/repositories/finance_repository.dart'
    show FinanceRepository;
import 'package:buildsmart/data/repositories/site_local.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/state/orders_engine.dart'
    show ordersEngineProvider, Order;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── editable budget state (mirrors proto `projectBudget` + `budgetCategories`) ──

@immutable
class BudgetCat {
  const BudgetCat(this.name, this.ic, this.amount);
  final String name;
  final String ic;
  final int amount;

  BudgetCat copyWith({String? name, String? ic, int? amount}) =>
      BudgetCat(name ?? this.name, ic ?? this.ic, amount ?? this.amount);
}

@immutable
class BudgetState {
  const BudgetState({
    required this.total,
    required this.spent,
    required this.categories,
  });
  final int total;
  final int spent;
  final List<BudgetCat> categories;

  int get left => total - spent;

  /// round(spent/total*100) — proto renderBudget (:7162). 9840/15000 → 66.
  int get pct => total > 0 ? (spent / total * 100).round() : 0;

  BudgetState copyWith({int? total, int? spent, List<BudgetCat>? categories}) =>
      BudgetState(
        total: total ?? this.total,
        spent: spent ?? this.spent,
        categories: categories ?? this.categories,
      );
}

class BudgetNotifier extends StateNotifier<BudgetState> {
  /// Seeds from + persists through the finance [_repo] (T6.2 seam). Local → the
  /// const demo budget (byte-identical; `setBudget` is a no-op, so demo stays
  /// in-memory/ephemeral as it always was, and there's no listenable). Connected
  /// → the repo's HONEST reads, RE-SEEDED whenever `budgetListenable` fires (a
  /// snapshot landed), with every edit persisted via `repo.setBudget`. Mirrors
  /// the orders/projects repo-seam idiom.
  BudgetNotifier(this._repo) : super(_seedFrom(_repo)) {
    _changes = _repo.budgetListenable;
    _changes?.addListener(_syncFromRepo);
  }

  final FinanceRepository _repo;
  Listenable? _changes;

  /// Build a [BudgetState] from the repo's live reads — the single source of
  /// truth on the connected path (the const demo on local).
  static BudgetState _seedFrom(FinanceRepository r) => BudgetState(
        total: r.budgetTotal(),
        spent: r.budgetSpent(),
        categories: [
          for (final c in r.budgetCategories())
            BudgetCat(c.name, c.icon, c.amount),
        ],
      );

  /// A snapshot (or our own optimistic write) changed the persisted budget →
  /// re-seed from the live reads. Idempotent after our own writes (the cache
  /// already holds what we wrote). Never fires on local (no listenable).
  void _syncFromRepo() {
    if (!mounted) return;
    state = _seedFrom(_repo);
  }

  /// Persist the WHOLE budget after a local edit (a no-op on the local impl).
  void _persist() => _repo.setBudget(
        state.total,
        state.spent,
        [for (final c in state.categories) BudgetCategory(c.name, c.ic, c.amount)],
      );

  @override
  void dispose() {
    _changes?.removeListener(_syncFromRepo);
    super.dispose();
  }

  // saveBudget(:7281)
  void setTotals(int total, int spent) {
    state = state.copyWith(total: total, spent: spent);
    _persist();
  }

  // adjustBudget(dir) (:7291) — dir +1 add a cost, -1 remove one.
  // Math.max(0, spent + dir*amt) — never below zero.
  void adjustSpent(int dir, int amt) {
    final next = state.spent + dir * amt;
    state = state.copyWith(spent: next < 0 ? 0 : next);
    _persist();
  }

  // saveCategoryEdit(:7259) — edit existing or commit a freshly-added category.
  void saveCategory(int i, String name, int amount) {
    if (i < 0 || i >= state.categories.length) return;
    final next = [...state.categories];
    next[i] = next[i].copyWith(name: name, amount: amount);
    state = state.copyWith(categories: next);
    _persist();
  }

  // addBudgetCategory(:7254) — push a blank category, returns its index.
  int addCategory() {
    state = state
        .copyWith(categories: [...state.categories, const BudgetCat('', '📦', 0)]);
    _persist();
    return state.categories.length - 1;
  }

  // deleteCategory(:7273) — keep at least one.
  void deleteCategory(int i) {
    if (state.categories.length <= 1) return;
    final next = [...state.categories]..removeAt(i);
    state = state.copyWith(categories: next);
    _persist();
  }
}

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  // Seeds from + persists through the finance repo (T6.2 seam): local → the const
  // demo budget (byte-identical, ephemeral as always); connected → the HONEST
  // persisted budget — empty until the user sets one (no fabricated demo money),
  // round-tripped via `setBudget` and re-seeded when the snapshot lands. The
  // screen renders an empty budget gracefully (the `b.categories.isEmpty` branch).
  return BudgetNotifier(financeRepo());
});

// ─── helpers ──────────────────────────────────────────────────────────────────

/// #twin — Σ orders by `site` (the connected per-site spend). Pure → testable.
Map<String, int> budgetSpendBySite(List<Order> orders) {
  final m = <String, int>{};
  for (final o in orders) {
    m[o.site] = (m[o.site] ?? 0) + o.sum;
  }
  return m;
}

/// #twin — the demo/illustrative per-site weight (decreasing by index): the
/// verbatim shipped formula `spent*(count-index)/(count*(count+1)/2)`. Pure.
num illustrativeSiteSpend(num spent, int count, int index) =>
    count <= 0 ? 0 : spent * (count - index) / (count * (count + 1) / 2);

/// #twin — orders whose site matched NO project (the "אחר / ללא פרויקט" residual):
/// Σ all orders − Σ orders that landed on a known project name. Pure → testable;
/// the row only renders when this is `> 0`.
int budgetResidualSpend(Map<String, int> spendBySite, Iterable<String> projectNames) =>
    spendBySite.values.fold<int>(0, (s, v) => s + v) -
    projectNames.fold<int>(0, (s, n) => s + (spendBySite[n] ?? 0));

String _fmt(num n) {
  final r = n.round();
  // Sign before the ₪ symbol so a negative reads "-₪3,150", not "₪-3,150".
  return '${r < 0 ? '-' : ''}₪${_thousands(r.abs())}';
}

String _thousands(int n) {
  final neg = n < 0;
  var s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return (neg ? '-' : '') + buf.toString();
}

const _ink = BsTokens.inkLight;
const _muted = Color(0xFF888888);
const _ok = Color(0xFF2E9E5B);
const _danger = Color(0xFFE03131);

// ─── screen: budget box → detail (openBudgetDetail :7189) ──────────────────────

/// Build entry `openBudget` — the project/site budget box + tappable detail.
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const BudgetScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(budgetProvider);
    final over = b.left < 0;
    final catTotal =
        b.categories.fold<int>(0, (s, c) => s + c.amount).clamp(1, 1 << 30);
    // T6.3 — the "הוצאות לפי אתר" rows iterate the project list through the
    // server-ready site repository instead of the `kProjects` const directly.
    // The local impl returns kProjects verbatim, so the rows + their weighted
    // amounts are byte-identical; a future field-ops backend swaps in behind it.
    final projects = ref.watch(siteRepositoryProvider).projects();

    // #twin — "הוצאות לפי אתר": on the CONNECTED backend, sum the REAL orders by
    // their site (orders stamp `site = active project name` at checkout, so they
    // match the project rows). Demo/tests keep the illustrative weighting below
    // (byte-identical — no real backend to fold), fulfilling the on-screen
    // disclaimer's "full version uses real orders" promise.
    final spendBySite = useFirebaseBackend
        ? budgetSpendBySite(ref.watch(ordersEngineProvider))
        : const <String, int>{};
    // Orders whose site isn't a project (e.g. 'ללא פרויקט') would otherwise
    // vanish from the per-site rows, making them sum to less than the real
    // total with no hint — surface them as one residual "אחר" row.
    final residualSpend = useFirebaseBackend
        ? budgetResidualSpend(spendBySite, projects.map((p) => p.name))
        : 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        title: const CfgText('budget_screen.title', 'תקציב הפרויקט',
            style: TextStyle(color: _ink, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // headline — tap to edit (bd-headline)
          _Tappable(
            onTap: () => _openEditor(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                color: over
                    ? const Color(0xFFFFF0F0)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: over ? const Color(0xFFFFD0D0) : const Color(0xFFEAEAEA)),
              ),
              child: Column(
                children: [
                  Text('${b.pct}%',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: over ? _danger : _ink)),
                  const SizedBox(height: 2),
                  Text(
                      (over ? 'חריגה מהתקציב' : 'מהתקציב נוצל') + ' · הקש לעריכה',
                      style: const TextStyle(fontSize: 12, color: _muted)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // progress bar (bgBar/sbBar — width = min(100,pct)%)
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (b.pct.clamp(0, 100)) / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFFE9ECF2),
              valueColor:
                  AlwaysStoppedAnimation(over ? _danger : BsTokens.brand),
            ),
          ),
          const SizedBox(height: 12),
          // three numbers — each taps into the editor (bd-nums)
          Row(
            children: [
              _NumBox(
                  value: _fmt(b.total),
                  label: 'תקציב כולל',
                  onTap: () => _openEditor(context, ref)),
              _NumBox(
                  value: _fmt(b.spent),
                  label: 'הוצא',
                  onTap: () => _openEditor(context, ref)),
              _NumBox(
                  value: _fmt(b.left),
                  label: 'נשאר',
                  color: over ? _danger : _ok,
                  onTap: () => _openEditor(context, ref)),
            ],
          ),
          if (over) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD0D0)),
              ),
              child: Text(
                  '⚠️ ההוצאות חרגו מהתקציב ב-${_fmt(-b.left)}. כדאי לעדכן את התקציב או לבדוק הוצאות.',
                  style: const TextStyle(fontSize: 13, color: _danger)),
            ),
          ],
          const SizedBox(height: 20),
          // spend by category — each row taps the category editor (bd-cat)
          Row(
            children: [
              const Expanded(
                child: CfgText('budget_screen.cat_header', 'פירוט הוצאות לפי קטגוריה',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
              ),
              _Tappable(
                onTap: () {
                  final i = ref.read(budgetProvider.notifier).addCategory();
                  _openCategoryEditor(context, ref, i);
                },
                child: const CfgText('budget_screen.add', '＋ הוסף',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: BsTokens.brand)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (b.categories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CfgText(
                'budget_screen.no_cats',
                'אין קטגוריות עדיין — הקש "＋ הוסף" כדי להוסיף קטגוריה',
                style: TextStyle(fontSize: 13, color: _muted),
              ),
            )
          else
            for (var i = 0; i < b.categories.length; i++)
              _CategoryRow(
                cat: b.categories[i],
                share: b.categories[i].amount / catTotal,
                onTap: () => _openCategoryEditor(context, ref, i),
              ),
          const SizedBox(height: 20),
          // spend by site — tap a site (bd-site). weight = (n-i)/(n*(n+1)/2)
          const CfgText('budget_screen.site_header', 'הוצאות לפי אתר',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
          const SizedBox(height: 8),
          if (projects.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CfgText(
                'budget_screen.no_sites',
                'אין אתרים פעילים — הוסיפו פרויקט במסך הפרויקטים',
                style: TextStyle(fontSize: 13, color: _muted),
              ),
            )
          else ...[
            for (var i = 0; i < projects.length; i++)
              _SiteRow(
                name: projects[i].name,
                value: useFirebaseBackend
                    ? _fmt(spendBySite[projects[i].name] ?? 0)
                    : _fmt(illustrativeSiteSpend(b.spent, projects.length, i)),
              ),
            if (useFirebaseBackend && residualSpend > 0)
              _SiteRow(name: 'אחר / ללא פרויקט', value: _fmt(residualSpend)),
          ],
          const SizedBox(height: 12),
          Text(
              useFirebaseBackend
                  ? 'מבוסס על ההזמנות בפועל לפי אתר.'
                  : '* הנתונים להמחשה — בגרסה המלאה יתבססו על ההזמנות וההוצאות בפועל של הלקוח.',
              style: const TextStyle(fontSize: 11, color: Color(0xFF9AA3B2))),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _ok),
              onPressed: () => _openEditor(context, ref),
              child: const CfgText('budget_screen.edit_budget_btn', '✏️ עריכת התקציב'),
            ),
          ),
        ],
      ),
    );
  }

  // openBudgetEditor (:7180) — total / spent + add/remove a single cost.
  void _openEditor(BuildContext context, WidgetRef ref) {
    final b = ref.read(budgetProvider);
    final totalCtl = TextEditingController(text: b.total.toString());
    final spentCtl = TextEditingController(text: b.spent.toString());
    final costCtl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CfgText('budget_screen.editor_title', 'עריכת תקציב',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: _ink)),
            const SizedBox(height: 14),
            _Field(
              label: 'תקציב כולל',
              controller: totalCtl,
              validator: _amountFormatError,
            ),
            const SizedBox(height: 10),
            _Field(
              label: 'הוצא עד כה',
              controller: spentCtl,
              validator: _amountFormatError,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: BsTokens.brand),
                onPressed: () {
                  final total = int.tryParse(totalCtl.text.trim());
                  final spent = int.tryParse(spentCtl.text.trim());
                  if (total == null || spent == null || total < 0 || spent < 0) {
                    showToast(ctx, 'יש להזין מספרים תקינים');
                    return;
                  }
                  ref.read(budgetProvider.notifier).setTotals(total, spent);
                  Navigator.pop(ctx);
                  showToast(context, 'התקציב עודכן');
                },
                child: const CfgText('budget_screen.save', 'שמירה'),
              ),
            ),
            const Divider(height: 28),
            _Field(
              label: 'הוספת / הסרת הוצאה (₪)',
              controller: costCtl,
              validator: _positiveAmountError,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _adjust(context, ctx, ref, costCtl.text, -1),
                    child: const CfgText('budget_screen.remove_expense', '− הסר הוצאה'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: _ok),
                    onPressed: () =>
                        _adjust(context, ctx, ref, costCtl.text, 1),
                    child: const CfgText('budget_screen.add_expense', '＋ הוסף הוצאה'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      totalCtl.dispose();
      spentCtl.dispose();
      costCtl.dispose();
    });
  }

  void _adjust(BuildContext root, BuildContext sheet, WidgetRef ref,
      String raw, int dir) {
    final amt = int.tryParse(raw.trim());
    if (amt == null || amt <= 0) {
      showToast(sheet, 'יש להזין סכום');
      return;
    }
    ref.read(budgetProvider.notifier).adjustSpent(dir, amt);
    Navigator.pop(sheet);
    showToast(
        root,
        dir > 0
            ? 'נוספה הוצאה: ₪${_thousands(amt)}'
            : 'הוסרה הוצאה: ₪${_thousands(amt)}');
  }

  // openCategoryEditor (:7242) / saveCategoryEdit (:7259) / deleteCategory.
  void _openCategoryEditor(BuildContext context, WidgetRef ref, int i) {
    final cats = ref.read(budgetProvider).categories;
    final exists = i >= 0 && i < cats.length;
    final c = exists ? cats[i] : const BudgetCat('', '📦', 0);
    final nameCtl = TextEditingController(text: c.name);
    final amtCtl =
        TextEditingController(text: c.amount == 0 ? '' : c.amount.toString());
    final canDelete = exists && cats.length > 1;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(c.name.isEmpty ? 'קטגוריה חדשה' : 'עריכת קטגוריה',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: _ink)),
            const SizedBox(height: 14),
            _Field(label: 'שם הקטגוריה', controller: nameCtl, number: false),
            const SizedBox(height: 10),
            _Field(label: 'סכום (₪)', controller: amtCtl),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: BsTokens.brand),
                onPressed: () {
                  final name = nameCtl.text.trim();
                  final amt = int.tryParse(amtCtl.text.trim());
                  if (name.isEmpty) {
                    showToast(ctx, 'יש להזין שם קטגוריה');
                    return;
                  }
                  if (amt == null || amt < 0) {
                    showToast(ctx, 'יש להזין סכום תקין');
                    return;
                  }
                  ref.read(budgetProvider.notifier).saveCategory(i, name, amt);
                  Navigator.pop(ctx);
                  showToast(context, 'הקטגוריה נשמרה');
                },
                child: const CfgText('budget_screen.save_cat', 'שמירה'),
              ),
            ),
            if (canDelete) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    final ok = await confirmDestructive(
                      ctx,
                      title: 'מחיקת קטגוריה?',
                      message: 'הקטגוריה תימחק מהתקציב לצמיתות.',
                      confirmLabel: 'מחק',
                    );
                    if (!ok || !ctx.mounted) return;
                    ref.read(budgetProvider.notifier).deleteCategory(i);
                    Navigator.pop(ctx);
                    showToast(context, 'הקטגוריה נמחקה');
                  },
                  child: const CfgText('budget_screen.delete_cat', '🗑️ מחיקת קטגוריה',
                      style: TextStyle(color: _danger)),
                ),
              ),
            ],
          ],
        ),
      ),
    ).whenComplete(() {
      nameCtl.dispose();
      amtCtl.dispose();
    });
  }
}

// ─── small widgets ──────────────────────────────────────────────────────────

class _Tappable extends StatelessWidget {
  const _Tappable({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: child,
      );
}

class _NumBox extends StatelessWidget {
  const _NumBox(
      {required this.value,
      required this.label,
      required this.onTap,
      this.color = _ink});
  final String value;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              child: Column(
                children: [
                  Text(value,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  const SizedBox(height: 2),
                  Text(label,
                      style: const TextStyle(fontSize: 11, color: _muted)),
                ],
              ),
            ),
          ),
        ),
      );
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow(
      {required this.cat, required this.share, required this.onTap});
  final BudgetCat cat;
  final double share;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: Text('${cat.ic} ${cat.name}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: _ink)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: share.clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE9ECF2),
                    valueColor:
                        const AlwaysStoppedAnimation(BsTokens.brand),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${_fmt(cat.amount)} ›',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
            ],
          ),
        ),
      );
}

class _SiteRow extends StatelessWidget {
  const _SiteRow({required this.name, required this.value});
  final String name;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
                child: Text('🏗️ $name',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: _ink))),
            Text('$value ›',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
          ],
        ),
      );
}

// task #64: inline format errors for the budget-editor fields. Empty input
// shows no error (matches the welcome-form pattern); the existing submit
// guards still block bad input with a toast.
String? _amountFormatError(String v) {
  final t = v.trim();
  if (t.isEmpty) return null;
  final n = int.tryParse(t);
  return (n == null || n < 0) ? 'סכום לא תקין' : null;
}

String? _positiveAmountError(String v) {
  final t = v.trim();
  if (t.isEmpty) return null;
  return validPositiveAmount(int.tryParse(t)) ? null : 'סכום לא תקין';
}

class _Field extends StatelessWidget {
  const _Field(
      {required this.label,
      required this.controller,
      this.number = true,
      this.validator});
  final String label;
  final TextEditingController controller;
  final bool number;

  /// task #64: optional live format check — short Hebrew error or null.
  final String? Function(String value)? validator;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => TextField(
          controller: controller,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: _ink),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: _muted),
            errorText: validator?.call(value.text),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
      );
}
