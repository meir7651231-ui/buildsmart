import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/repositories/catalog_local.dart';
import 'package:buildsmart/logic/category_division.dart';
import 'package:buildsmart/logic/system_division.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which live department is open inside the departments home (null = show the
/// grid). It lives in the shell's first tab so the chrome (AppBar + bottom nav)
/// stays put; tapping the מחלקות tab resets it.
final homeDepartmentProvider = StateProvider<String?>((_) => null);

/// Build a drill path for a tool department straight from its leaf `categoryHe`
/// names — a synthetic node tree, so the department gathers categories that live
/// in different branches (e.g. כלי עבודה + חותך צינורות). One category drills
/// straight to its products; several show a row each, then drill to products.
/// `_TreeDrill` only needs `lipskeyCategory` (leaf) / `children` (branch).
List<CatalogNode> _toolDeptPath(String name, List<String> cats) {
  CatalogNode leaf(String c) =>
      CatalogNode(id: 'dept-cat.$c', title: c, emoji: '🧰', lipskeyCategory: c);
  if (cats.length == 1) return [leaf(cats.first)];
  return [
    CatalogNode(
      id: 'dept.$name',
      title: name,
      emoji: '🧰',
      children: [for (final c in cats) leaf(c)],
    ),
  ];
}

/// Benzi #5 — when true, the open department shows ALL its products in one flat
/// list ("ברצף, ללא קשר לקטלוג") instead of the catalog tree/finder navigation.
final deptFlatProductsProvider = StateProvider<bool>((_) => false);

/// Every product in a department's scope, flat: a tool department = its
/// `toolCats`; a catalog department (ברזים/אינסטלציה) = the union of all its
/// heading categories; a water department = its in-system products.
List<LipskeyCatalogProduct> departmentProducts(
    {String? name, WaterSystem? system, List<String>? toolCats}) {
  // T6.3: route through the catalog repository (same const `kCatalogProducts`).
  if (toolCats != null) {
    return catalogRepo()
        .allProducts()
        .where((p) => toolCats.contains(p.categoryHe))
        .toList();
  }
  if (name != null && isCatalogDept(name)) {
    final cats = <String>{};
    void collect(CatalogNode n) {
      if (n.isLeaf) {
        final l = n.lipskeyCategory;
        if (l != null) cats.add(l);
      } else {
        for (final c in n.children) {
          collect(c);
        }
      }
    }

    for (final h in kDeptCatHeadings[name]!) {
      for (final title in h.titles) {
        final node = resolveCatTitle(title);
        if (node != null) collect(node);
      }
    }
    return catalogRepo()
        .allProducts()
        .where((p) => cats.contains(p.categoryHe))
        .toList();
  }
  if (system != null) return filterBySystem(catalogRepo().allProducts(), system);
  return const [];
}

/// Departments home (Benzi #2/#3) — the app's landing: a grid of departments.
/// The two live departments ARE the clean-water/sewage division (Benzi #1,
/// option 2): each opens the catalog's **finder (בית)** scoped to its
/// `WaterSystem`, so every browse section (finder / categories / tree / search)
/// shows only that system's products. The rest are placeholders until their
/// catalog data exists (R8 — no data, no invention).
class DepartmentsScreen extends ConsumerWidget {
  const DepartmentsScreen({super.key});

  // Names verbatim from Benzi's spec (#2). Two are the clean-water/sewage
  // division (`system`); two more (כלי עבודה) gather EVERY real tool category in
  // the catalog (`toolCats` — leaf `categoryHe` names; a full audit of all 99
  // categories found these are the only genuine tools). The rest stay
  // placeholders until their catalog data exists (R8 — no data, no invention).
  static const List<
      ({
        String name,
        IconData icon,
        bool live,
        WaterSystem? system,
        List<String>? toolCats,
      })> departments = [
    (name: 'אינסטלציה', icon: Icons.plumbing, live: true, system: WaterSystem.drainage, toolCats: null),
    (name: 'ברזים וסניטריים', icon: Icons.water_drop, live: true, system: WaterSystem.supply, toolCats: null),
    (name: 'חשמל', icon: Icons.electrical_services, live: false, system: null, toolCats: null),
    (name: 'חומרי בניין', icon: Icons.foundation, live: false, system: null, toolCats: null),
    (name: 'כלי עבודה ידני', icon: Icons.handyman, live: true, system: null, toolCats: ['כלי עבודה', 'חותך צינורות']),
    (name: 'כלי עבודה חשמלי', icon: Icons.construction, live: true, system: null, toolCats: ['כלי ריתוך PPR']),
    (name: 'צבע וכלים לצבע', icon: Icons.format_paint, live: false, system: null, toolCats: null),
    (name: 'גבס ופרופילים', icon: Icons.view_column, live: false, system: null, toolCats: null),
    (name: 'אספקה טכנית', icon: Icons.settings_input_component, live: false, system: null, toolCats: null),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A live department selected → a scope bar (department · system + clear) over
    // the catalog finder, all scoped to its water system (shell chrome stays).
    final active = ref.watch(homeDepartmentProvider);
    if (active != null) {
      final dept = departments.firstWhere((d) => d.name == active,
          orElse: () => departments.first);
      final catalogDept = isCatalogDept(dept.name);
      // Benzi #5 — "כל המוצרים ברצף": a flat list of the whole department,
      // bypassing the catalog tree/finder, toggled from the scope bar.
      final flat = ref.watch(deptFlatProductsProvider);
      // Benzi #1 (reframed): ברזים/אינסטלציה show small headings + category rows
      // (`_DeptCatGroups`); tapping a row drills via `catalogTreePathProvider`.
      final drilling =
          ref.watch(catalogTreePathProvider.select((p) => p.isNotEmpty));
      final Widget body;
      if (flat) {
        body = LipskeyProductsList(
            products: departmentProducts(
                name: dept.name, system: dept.system, toolCats: dept.toolCats));
      } else if (catalogDept && !drilling) {
        body = _DeptCatGroups(deptName: dept.name);
      } else {
        body = const CatalogScreen();
      }
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            _DeptScopeBar(
                name: dept.name, system: catalogDept ? null : dept.system),
            Expanded(child: body),
          ],
        ),
      );
    }

    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(BsTokens.space4, BsTokens.space4,
                  BsTokens.space4, BsTokens.space2),
              child: Text(
                'מחלקות',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.fromLTRB(
                    BsTokens.space4, 0, BsTokens.space4, BsTokens.space5),
                mainAxisSpacing: BsTokens.space3,
                crossAxisSpacing: BsTokens.space3,
                childAspectRatio: 1.15,
                // Only live departments render (owner decision — hide, not
                // "בקרוב"). Non-live rows stay in `departments` so re-enabling
                // later is a one-line flip of `live: true`.
                children: [
                  for (final d in departments.where((d) => d.live))
                    _DeptTile(dept: d),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeptTile extends ConsumerWidget {
  const _DeptTile({required this.dept});

  final ({
    String name,
    IconData icon,
    bool live,
    WaterSystem? system,
    List<String>? toolCats,
  }) dept;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fg = dept.live ? BsTokens.brand : BsTokens.mutedLight;
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      elevation: 1,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        onTap: () {
          if (!dept.live) {
            showToast(context, 'בקרוב');
            return;
          }
          final toolCats = dept.toolCats;
          if (toolCats != null) {
            // Tool department (כלי עבודה) → drill into ALL its real tool
            // categories; no water-system scope (it isn't a plumbing system).
            ref.read(catalogSystemFilterProvider.notifier).state = null;
            ref.read(catalogTreePathProvider.notifier).state =
                _toolDeptPath(dept.name, toolCats);
          } else {
            // Catalog department (ברזים/אינסטלציה — Benzi #1 reframed) → open the
            // grouped headings (no water-system scope; clear any drill).
            ref.read(catalogSystemFilterProvider.notifier).state = null;
            ref.read(catalogTreePathProvider.notifier).state = const [];
          }
          ref.read(deptFlatProductsProvider.notifier).state = false;
          ref.read(homeDepartmentProvider.notifier).state = dept.name;
        },
        child: Semantics(
          label: dept.live ? dept.name : '${dept.name} — בקרוב',
          button: true,
          child: Padding(
            padding: const EdgeInsets.all(BsTokens.space4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(dept.icon, size: 40, color: fg),
                const SizedBox(height: BsTokens.space3),
                Text(
                  dept.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: dept.live ? theme.colorScheme.onSurface : fg,
                  ),
                ),
                if (!dept.live) ...[
                  const SizedBox(height: BsTokens.space1),
                  Text('בקרוב',
                      style: theme.textTheme.labelSmall?.copyWith(color: fg)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Context bar shown above the catalog while a department is open: names the
/// active department + water-system scope, and clears back to the grid. Makes
/// the clean-water/sewage division visible (Benzi #1) instead of silent.
class _DeptScopeBar extends ConsumerWidget {
  const _DeptScopeBar({required this.name, required this.system});

  final String name;
  final WaterSystem? system;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sysLabel = switch (system) {
      WaterSystem.supply => 'מים נקיים',
      WaterSystem.drainage => 'שפכים',
      null => null,
    };
    final flat = ref.watch(deptFlatProductsProvider);
    return Material(
      color: BsTokens.brand.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: BsTokens.space4, vertical: BsTokens.space2),
        child: Row(
          children: [
            const Icon(Icons.tune, size: 18, color: BsTokens.brand),
            const SizedBox(width: BsTokens.space2),
            Expanded(
              child: Text(
                sysLabel == null ? name : '$name · $sysLabel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700, color: BsTokens.brand),
              ),
            ),
            // Benzi #5 — toggle the flat "all products" list ↔ catalog view.
            InkWell(
              onTap: () =>
                  ref.read(deptFlatProductsProvider.notifier).state = !flat,
              borderRadius: BorderRadius.circular(BsTokens.radiusCard),
              // ≥48dp tap target (a11y) — the visible label is unchanged.
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(BsTokens.space1),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            flat
                                ? Icons.account_tree_outlined
                                : Icons.view_list,
                            size: 16,
                            color: BsTokens.brand),
                        const SizedBox(width: 2),
                        Text(flat ? 'קטלוג' : 'כל המוצרים',
                            style: const TextStyle(
                                color: BsTokens.brand,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: BsTokens.space3),
            InkWell(
              onTap: () {
                ref.read(deptFlatProductsProvider.notifier).state = false;
                ref.read(homeDepartmentProvider.notifier).state = null;
                ref.read(catalogSystemFilterProvider.notifier).state = null;
                ref.read(catalogTreePathProvider.notifier).state = const [];
              },
              borderRadius: BorderRadius.circular(BsTokens.radiusCard),
              // ≥48dp tap target (a11y) — the visible label is unchanged.
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(minWidth: 48, minHeight: 48),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(BsTokens.space1),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('כל המחלקות',
                            style: TextStyle(
                                color: BsTokens.brand,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        SizedBox(width: 2),
                        Icon(Icons.close, size: 16, color: BsTokens.brand),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Benzi #1 (reframed) — the heading + category-rows layout for ברזים/אינסטלציה.
/// Small headings (כלים לבנים / גמר · 💧 מים / 🟤 שפכים), each followed by its
/// category rows; tapping a row drills into that category via the tree path.
class _DeptCatGroups extends ConsumerWidget {
  const _DeptCatGroups({required this.deptName});

  final String deptName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final headings = kDeptCatHeadings[deptName] ?? const [];
    if (headings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🗂️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'אין קטגוריות במחלקה זו',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'הקטגוריות יופיעו כאן כשיתווסף קטלוג למחלקה',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          BsTokens.space3, BsTokens.space3, BsTokens.space3, BsTokens.space5),
      children: [
        for (final h in headings) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(BsTokens.space2, BsTokens.space3,
                BsTokens.space2, BsTokens.space2),
            child: Row(
              children: [
                Text(h.emoji, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(
                  h.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800, color: BsTokens.brand),
                ),
              ],
            ),
          ),
          for (final title in h.titles)
            if (resolveCatTitle(title) case final node?) _CatGroupRow(node: node),
        ],
      ],
    );
  }
}

class _CatGroupRow extends ConsumerWidget {
  const _CatGroupRow({required this.node});

  final CatalogNode node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final count = catNodeProductCount(node);
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        elevation: 1,
        shadowColor: Colors.black26,
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          onTap: () =>
              ref.read(catalogTreePathProvider.notifier).state = [node],
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: BsTokens.space4, vertical: BsTokens.space3),
            child: Row(
              children: [
                Text(node.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: BsTokens.space3),
                Expanded(
                  child: Text(
                    node.title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (count > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: BsTokens.brand,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                          color: bsOnAccent(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
