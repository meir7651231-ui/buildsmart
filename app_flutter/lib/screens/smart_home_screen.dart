import 'package:buildsmart/data/product_images.dart';
import 'package:buildsmart/data/repositories/catalog_local.dart'
    show catalogRepositoryProvider;
import 'package:buildsmart/logic/money_format.dart' show groupThousands;
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/data/supplier_data.dart'
    show SysOrder, kOrderStageLabel;
import 'package:buildsmart/screens/contractor_tools_sheets.dart'
    show openScanPlanSheet;
import 'package:buildsmart/screens/departments_screen.dart';
import 'package:buildsmart/screens/install_studio_screen.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart'
    show showLipskeyProductSheet;
import 'package:buildsmart/screens/site_hub_screen.dart' show openSiteHub;
import 'package:buildsmart/screens/stock_screen.dart';
import 'package:buildsmart/state/app_profile.dart' show kProfileRawShell;
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/home_content_order.dart';
import 'package:buildsmart/state/org_gates.dart' show featOn, modOn;
import 'package:buildsmart/state/product_favorites.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/theme/config_theme.dart' show cfgRadius;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ════════════════════════════════════════════════════════════════════════════
// Settings-synced smart-home (#32). The home honours the display settings the
// rest of the catalog does:
//   • ערכת נושא (light/dark) + ניגודיות גבוהה → via Theme.of(context) colours.
//   • גודל טקסט → global MediaQuery textScaler; tile/row heights grow with it
//     so text never clips.
//   • מצב קומפקטי + גודל תמונות → a size factor on cards/images.
//   • עמודות בתצוגת רשת (gridColumns) → grid crossAxisCount.
//   • הנפשות מופחתות → the home has no animations (nothing to reduce).
// ════════════════════════════════════════════════════════════════════════════

/// Theme-resolved palette (carries light/dark + high-contrast from [ThemeData]).
typedef _Pal = ({Color card, Color ink, Color muted, Color border, Color box});

_Pal _pal(BuildContext c) {
  final cs = Theme.of(c).colorScheme;
  final dark = Theme.of(c).brightness == Brightness.dark;
  return (
    card: cs.surface,
    ink: cs.onSurface,
    muted: cs.onSurface.withOpacity(0.62),
    border: cs.onSurface.withOpacity(dark ? 0.18 : 0.10),
    box: cs.onSurface.withOpacity(0.06),
  );
}

/// Size metrics resolved from the catalog display settings + text scaler.
class _Metrics {
  _Metrics(BuildContext c, CatalogSettings s)
      : cols = s.gridColumns.clamp(2, 6),
        compact = s.compactMode,
        _img = switch (s.imageSize) {
          CatalogImageSize.small => 0.85,
          CatalogImageSize.medium => 1.0,
          CatalogImageSize.large => 1.18,
        },
        ts = MediaQuery.textScalerOf(c).scale(1.0).clamp(1.0, 1.4);

  final int cols;
  final bool compact;
  final double _img;
  final double ts;

  double get _base => compact ? 0.82 : 1.0;

  /// Card width for the horizontal rows (עץ חכם / orders).
  double cardW(double base) => base * _base * _img;

  /// Row height — grows with text scale so labels never clip.
  double rowH(double base) => base * _base * _img * ts;

  /// Fixed grid-tile height (independent of column count) — grows with text so
  /// labels never clip, shrinks in compact mode.
  double get tileH => (compact ? 86.0 : 104.0) * ts;
}

_Metrics _metrics(BuildContext c, WidgetRef ref) =>
    _Metrics(c, ref.watch(catalogSettingsProvider));

/// Builds the wired smart-home section widget for a reorderable [HomeSection].
/// Shared by [SmartHomeBody] (the live home) AND the reorder-preview screen
/// (home_content_reorder.dart), so the reorder UI previews the REAL sections.
Widget smartHomeSectionFor(HomeSection s) => switch (s) {
      HomeSection.categories => const _Departments(),
      HomeSection.products => const _SmartTreeRow(),
      HomeSection.workPath => const _WorkPath(),
      HomeSection.promise => const _QuickTools(),
      HomeSection.reorderHistory => const _RecentOrders(),
    };

/// 🏠 גוף מסך-הבית החכם (task #32) — the 'בית' landing in the "תוכן הבית" tile
/// layout, wired to real data + real navigation, and synced to the display
/// settings (theme/contrast/text-size/compact/image-size/grid-columns).
class SmartHomeBody extends ConsumerWidget {
  const SmartHomeBody({this.scrollCtrl, super.key});

  final ScrollController? scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(homeContentOrderProvider);
    // Org gate: the תכנון-חיבור hero is the 'compat' module's home entry —
    // orgs that switch the module off lose it (demo org: all-on, identical).
    final compatOn = modOn(ref, 'compat');
    return ListView(
      controller: scrollCtrl,
      key: const Key('catalog-list'),
      padding: const EdgeInsets.only(bottom: BsTokens.space6),
      children: [
        const SizedBox(height: BsTokens.space2),
        for (final s in order) ...[
          smartHomeSectionFor(s),
          const SizedBox(height: BsTokens.space4),
        ],
        if (compatOn) ...[
          const _InstallStudioHero(),
          const SizedBox(height: BsTokens.space4),
        ],
        const _Favorites(),
      ],
    );
  }
}

// ─── shared bits ──────────────────────────────────────────────────────────────
class _Pad extends StatelessWidget {
  const _Pad({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: BsTokens.space4),
        child: child,
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: BsTokens.space2),
        child: Text(
          text,
          style: TextStyle(
            color: _pal(context).ink,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      );
}

/// A small tile (icon + label) used by the department + favourites grids.
class _MiniTile extends StatelessWidget {
  const _MiniTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.dim = false,
    this.note,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool dim;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final pal = _pal(context);
    return InkWell(
      borderRadius: BorderRadius.circular(cfgRadius(context)),
      onTap: onTap,
      child: Semantics(
        button: true,
        label: note == null ? label : '$label — $note',
        child: Opacity(
          opacity: dim ? 0.5 : 1,
          child: Container(
            decoration: BoxDecoration(
              color: pal.card,
              borderRadius: BorderRadius.circular(cfgRadius(context)),
              border: Border.all(color: pal.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: BsTokens.brand, size: 22),
                const SizedBox(height: 4),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: pal.ink,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (note != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(note!,
                        style: TextStyle(color: pal.muted, fontSize: 9)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── מחלקות — FIXED 2-col nav grid, 2 rows (3 depts + "עוד"); DECOUPLED ───────────
// Departments are a stable navigation grid: a fixed 2 columns, ~2 rows (3
// departments + the "עוד" tile = 4 cells in 2×2), independent of the gridColumns
// display setting (which still drives the PRODUCT/מועדפים grids via m.cols).
class _Departments extends ConsumerWidget {
  const _Departments();

  /// Fixed column count for the department nav grid (NOT m.cols).
  static const int _deptCols = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Raw shell: the const department names are BuildSmart content — the
    // departments TAB carries the derived (imported-catalog) grid instead.
    if (kProfileRawShell) return const SizedBox.shrink();
    final m = _metrics(context, ref);
    // 3 departments + the "עוד" tile = 4 cells fill a stable 2×2.
    // Only live departments render (owner decision — hide, not dim+"בקרוב");
    // non-live rows stay in `departments` for a one-line `live: true` re-enable.
    final depts = DepartmentsScreen.departments
        .where((d) => d.live)
        .take(_deptCols * 2 - 1)
        .toList();
    return _Pad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle('מחלקות'),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _deptCols,
              mainAxisSpacing: BsTokens.space2,
              crossAxisSpacing: BsTokens.space2,
              mainAxisExtent: m.tileH,
            ),
            children: [
              for (final d in depts)
                _MiniTile(
                  icon: d.icon,
                  label: d.name,
                  dim: !d.live,
                  note: d.live ? null : 'בקרוב',
                  onTap: d.live
                      ? () {
                          ref.read(homeDepartmentProvider.notifier).state =
                              d.name;
                          ref.read(mainTabProvider.notifier).state = 1;
                        }
                      : null,
                ),
              _MiniTile(
                icon: Icons.more_horiz,
                label: 'עוד',
                onTap: () => ref.read(mainTabProvider.notifier).state = 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 🌳 עץ חכם — אינסטלציה (real kSmartProducts) ─────────────────────────────────
class _SmartTreeRow extends ConsumerWidget {
  const _SmartTreeRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Clean shell: no smart products → no row (a title over an empty 192px
    // strip would lie about content that isn't there).
    if (kSmartProducts.isEmpty) return const SizedBox.shrink();
    final m = _metrics(context, ref);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Pad(child: _SectionTitle('🌳 עץ חכם — אינסטלציה')),
        SizedBox(
          height: m.rowH(192),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: BsTokens.space4),
            itemCount: kSmartProducts.length,
            separatorBuilder: (_, __) => const SizedBox(width: BsTokens.space3),
            itemBuilder: (_, i) =>
                _SmartTreeCard(p: kSmartProducts[i], width: m.cardW(150)),
          ),
        ),
      ],
    );
  }
}

class _SmartTreeCard extends ConsumerWidget {
  const _SmartTreeCard({required this.p, required this.width});
  final SmartProduct p;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pal = _pal(context);
    final rec = p.brands.firstWhere((b) => b.rec, orElse: () => p.brands.first);
    final priceLabel =
        rec.price == null ? 'מחיר לפי ספק' : '₪${groupThousands(rec.price!)}';
    return Container(
      width: width,
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: pal.card,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: pal.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: pal.box,
                borderRadius: BorderRadius.circular(cfgRadius(context)),
              ),
              child: rec.imageAsset != null
                  ? productImage(
                      rec.imageAsset!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Text(p.emoji, style: const TextStyle(fontSize: 28)),
                    )
                  : Text(p.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 6),
          Text(p.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: pal.ink,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              )),
          Text(p.cat,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: pal.muted, fontSize: 10)),
          const SizedBox(height: 2),
          Text(priceLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: BsTokens.brandDark,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              )),
          const SizedBox(height: 6),
          SizedBox(
            height: 30,
            // composite-hide: whole הוסף-לסל button gone when the org hides
            // this element (add-to-cart action → critical:false).
            child: CfgVisible(
              'smart_home_screen.add_to_cart',
              child: FilledButton(
              onPressed: () {
                ref.read(smartCartProvider.notifier).add(
                      SmartCartLine(
                        productKey: rec.sku ?? 'smart:${p.key}',
                        productName: p.name,
                        productEmoji: p.emoji,
                        brandName: rec.name,
                        brandPrice: rec.price ?? 0,
                        productQty: 1,
                        accessories: const [],
                      ),
                    );
                showToast(context, '${p.name} נוסף לסל');
              },
              style: FilledButton.styleFrom(
                backgroundColor: BsTokens.brand,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
              ),
              child: CfgText('smart_home_screen.add_to_cart', 'הוסף לסל',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── מסלול עבודה חכם (project hero — coloured, fine in both themes) ───────────────
class _WorkPath extends ConsumerWidget {
  const _WorkPath();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Raw shell: the גמר-אמבטיה path is BuildSmart recipe content — hidden
    // even after a catalog import.
    if (kProfileRawShell) return const SizedBox.shrink();
    return _Pad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle('מסלול עבודה חכם'),
          Container(
            padding: const EdgeInsets.all(BsTokens.space4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1F6F6B), Color(0xFF155350)],
              ),
              borderRadius: BorderRadius.circular(cfgRadius(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  ),
                  child: CfgText('smart_home_screen.workpath_badge', '🛁 חדש — מאפס עד גמר',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
                const SizedBox(height: 6),
                CfgText('smart_home_screen.workpath_title', 'גמר אמבטיה — מלווה אותך שלב-שלב',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17)),
                const SizedBox(height: 4),
                CfgText(
                  'smart_home_screen.workpath_sub',
                  '4 שלבים בסדר הנכון. כל שלב: עץ מוצרים + חלון "סדר הרכבה".',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                // fake-data-sweep H1: removed the hardcoded 38% progress bar — there
                // is no real progress source and no 4-stage sub-tree to wire it to,
                // so a fabricated percentage is dishonest. The card stays as an
                // honest "coming soon" teaser (badge + title + sub-text).
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── כלים מהירים (real tools) ────────────────────────────────────────────────────
class _QuickTools extends ConsumerWidget {
  const _QuickTools();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pal = _pal(context);
    // Org gates: משימות העבודה rides the 'site' module; המלאי שלי is its
    // 'stock' feature (demo org: all-on → rows render identical).
    final siteOn = modOn(ref, 'site');
    final stockOn = featOn(ref, 'site', 'stock');
    final rows = <({String emoji, String title, String sub, VoidCallback tap})>[
      // Raw shell: the scan sheet narrates a fabricated work plan — drop it.
      if (!kProfileRawShell)
        (
          emoji: '📐',
          title: 'סרוק תוכנית עבודה',
          sub: 'צלם שרטוט אינסטלציה — נזהה מה צריך להזמין',
          tap: () => openScanPlanSheet(context),
        ),
      if (stockOn)
        (
          emoji: '📦',
          title: 'המלאי שלי',
          sub: 'מה כבר יש לך — במחסן ובאתר',
          tap: () => Navigator.of(context).push(StockScreen.route()),
        ),
      if (siteOn)
        (
          emoji: '📋',
          title: 'משימות העבודה',
          sub: 'חלק משימות לעובדים ועקוב אחרי הביצוע',
          tap: () => openSiteHub(context),
        ),
    ];
    // Raw shell + org gates can empty the list — then drop the whole section;
    // a 'כלים מהירים' title over nothing would lie about tools that aren't
    // there (same rule as the empty עץ-חכם strip above).
    if (rows.isEmpty) return const SizedBox.shrink();
    return _Pad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle('כלים מהירים'),
          for (final r in rows)
            InkWell(
              borderRadius: BorderRadius.circular(cfgRadius(context)),
              onTap: r.tap,
              child: Container(
                margin: const EdgeInsets.only(bottom: BsTokens.space2),
                padding: const EdgeInsets.all(BsTokens.space3),
                decoration: BoxDecoration(
                  color: pal.card,
                  borderRadius: BorderRadius.circular(cfgRadius(context)),
                  border: Border.all(color: pal.border),
                ),
                child: Row(
                  children: [
                    Text(r.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: BsTokens.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title,
                              style: TextStyle(
                                color: pal.ink,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              )),
                          const SizedBox(height: 2),
                          Text(r.sub,
                              style: TextStyle(color: pal.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_left, color: pal.muted),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── תכנון חיבור (Install Studio) ────────────────────────────────────────────────
class _InstallStudioHero extends ConsumerWidget {
  const _InstallStudioHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pal = _pal(context);
    return _Pad(
      child: InkWell(
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const InstallStudioScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(BsTokens.space4),
          decoration: BoxDecoration(
            color: const Color(0x1AFF7A18),
            borderRadius: BorderRadius.circular(cfgRadius(context)),
            border: Border.all(color: const Color(0x33FF7A18)),
          ),
          child: Row(
            children: [
              const Icon(Icons.account_tree, color: BsTokens.brandDark, size: 32),
              const SizedBox(width: BsTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CfgText('smart_home_screen.install_title', 'תכנון חיבור',
                        style: TextStyle(
                          color: pal.ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        )),
                    const SizedBox(height: 2),
                    CfgText('smart_home_screen.install_sub', 'בחר מה לחבר — נכין רשימת קנייה תקנית ונבדוק את החיבור',
                        style: TextStyle(color: pal.muted, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: BsTokens.brandDark),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── מועדפים (real productFavoritesProvider) ─────────────────────────────────────
class _Favorites extends ConsumerWidget {
  const _Favorites();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = _metrics(context, ref);
    final favSkus = ref.watch(productFavoritesProvider);
    final products = ref
        .watch(catalogRepositoryProvider)
        .allProducts()
        .where((p) => favSkus.contains(p.sku))
        .toList();
    return _Pad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle('מועדפים'),
          if (products.isEmpty)
            const _EmptyCard(
              'עדיין אין מועדפים — סמן ☆ על מוצר והוא יופיע כאן.',
            )
          else
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: m.cols,
                mainAxisSpacing: BsTokens.space2,
                crossAxisSpacing: BsTokens.space2,
                mainAxisExtent: m.tileH,
              ),
              children: [
                for (final p in products)
                  _MiniTile(
                    icon: Icons.star,
                    label: p.nameHe,
                    // Open the product sheet exactly like the catalog's own
                    // favorites row (_FavProductRow) — siblings scoped to the
                    // same category.
                    onTap: () => showLipskeyProductSheet(
                      context,
                      p,
                      ref
                          .read(catalogRepositoryProvider)
                          .allProducts()
                          .where((q) => q.categoryHe == p.categoryHe)
                          .toList(),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── הזמנות אחרונות — same card style as עץ חכם ───────────────────────────────────
class _RecentOrders extends ConsumerWidget {
  const _RecentOrders();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = _metrics(context, ref);
    final orders = ref.watch(sysOrdersProvider);
    if (orders.isEmpty) {
      return _Pad(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _SectionTitle('הזמנות אחרונות לאתר'),
            _EmptyCard('עדיין אין הזמנות — לאחר הראשונה היא תופיע כאן.'),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Pad(child: _SectionTitle('הזמנות אחרונות לאתר')),
        SizedBox(
          height: m.rowH(150),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: BsTokens.space4),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(width: BsTokens.space3),
            itemBuilder: (_, i) =>
                _OrderCard(order: orders[i], width: m.cardW(160)),
          ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.width});
  final SysOrder order;
  final double width;

  @override
  Widget build(BuildContext context) {
    final pal = _pal(context);
    return Container(
      width: width,
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: pal.card,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: pal.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(order.id,
                  style: TextStyle(
                    color: pal.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  )),
              const Spacer(),
              const Text('📦', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Text(order.site,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: pal.ink, fontSize: 12)),
          const SizedBox(height: 2),
          Text('${order.items} פריטים',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: pal.muted, fontSize: 11)),
          const SizedBox(height: 2),
          Text('₪${groupThousands(order.sum)}',
              style: const TextStyle(
                color: BsTokens.brandDark,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              )),
          const Spacer(),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x1AFF7A18),
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            ),
            child: Text(kOrderStageLabel[order.stage] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: BsTokens.brandDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final pal = _pal(context);
    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: pal.card,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: pal.border),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: pal.muted, fontSize: 13),
      ),
    );
  }
}
