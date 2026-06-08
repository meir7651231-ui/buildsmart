import 'package:buildsmart/data/product_images.dart';
import 'package:buildsmart/data/repositories/catalog_local.dart'
    show catalogRepositoryProvider;
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/data/supplier_data.dart'
    show SysOrder, kOrderStageLabel;
import 'package:buildsmart/state/home_content_order.dart';
import 'package:buildsmart/screens/contractor_tools_sheets.dart'
    show openScanPlanSheet;
import 'package:buildsmart/screens/departments_screen.dart';
import 'package:buildsmart/screens/install_studio_screen.dart';
import 'package:buildsmart/screens/site_hub_screen.dart' show openSiteHub;
import 'package:buildsmart/screens/stock_screen.dart';
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/product_favorites.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🏠 גוף מסך-הבית החכם (task #32) — the "הכל" landing rebuilt in the
/// "תוכן הבית" tile layout, wired to real data + real navigation. Mounted by
/// catalog_screen's `_CatalogBody` for the 'הכל' section, so the real search
/// bar + section chips above it are preserved.
///
/// Sections: מחלקות (real, 2 rows + עוד) · 🌳 עץ חכם (kSmartProducts) ·
/// מסלול עבודה חכם · כלים מהירים (real tools) · תכנון חיבור (Install Studio) ·
/// מועדפים (productFavoritesProvider) · הזמנות אחרונות (sysOrdersProvider).
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

class SmartHomeBody extends ConsumerWidget {
  const SmartHomeBody({this.scrollCtrl, super.key});

  final ScrollController? scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The 5 reorderable sections follow the user's saved order (changed from
    // settings → "סידור מסך הבית"). תכנון חיבור + מועדפים are fixed extras.
    final order = ref.watch(homeContentOrderProvider);
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
        const _InstallStudioHero(),
        const SizedBox(height: BsTokens.space4),
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
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      );
}

/// A small white tile (icon + label) used by the department + "עוד" grid.
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
    return InkWell(
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      onTap: onTap,
      child: Opacity(
        opacity: dim ? 0.5 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: BsTokens.cardLight,
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
            border: Border.all(color: const Color(0xFFEEEEEE)),
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
                    style: const TextStyle(
                      color: BsTokens.inkLight,
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
                      style: const TextStyle(
                          color: BsTokens.mutedLight, fontSize: 9)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── מחלקות — real departments, exactly 2 rows (7 + "עוד") ───────────────────────
class _Departments extends ConsumerWidget {
  const _Departments();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depts = DepartmentsScreen.departments.take(7).toList();
    return _Pad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle('מחלקות'),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: BsTokens.space2,
            crossAxisSpacing: BsTokens.space2,
            childAspectRatio: 1.0,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Pad(child: _SectionTitle('🌳 עץ חכם — אינסטלציה')),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: BsTokens.space4),
            itemCount: kSmartProducts.length,
            separatorBuilder: (_, __) => const SizedBox(width: BsTokens.space3),
            itemBuilder: (_, i) => _SmartTreeCard(p: kSmartProducts[i]),
          ),
        ),
      ],
    );
  }
}

class _SmartTreeCard extends ConsumerWidget {
  const _SmartTreeCard({required this.p});
  final SmartProduct p;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rec = p.brands.firstWhere((b) => b.rec, orElse: () => p.brands.first);
    final priceLabel = rec.price == null ? 'מחיר לפי ספק' : '₪${rec.price}';
    return Container(
      width: 150,
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: const Color(0xFFEEEEEE)),
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
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(BsTokens.radiusCard),
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
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              )),
          Text(p.cat,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 10)),
          const SizedBox(height: 2),
          Text(priceLabel,
              style: const TextStyle(
                color: BsTokens.brandDark,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              )),
          const SizedBox(height: 6),
          SizedBox(
            height: 30,
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
              child: const Text('הוסף לסל',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── מסלול עבודה חכם (project hero) ──────────────────────────────────────────────
class _WorkPath extends ConsumerWidget {
  const _WorkPath();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              borderRadius: BorderRadius.circular(BsTokens.radiusCard),
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
                  child: const Text('🛁 חדש — מאפס עד גמר',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
                const SizedBox(height: 6),
                const Text('גמר אמבטיה — מלווה אותך שלב-שלב',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17)),
                const SizedBox(height: 4),
                const Text(
                  '4 שלבים בסדר הנכון. כל שלב: עץ מוצרים + חלון "סדר הרכבה".',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  child: const LinearProgressIndicator(
                    value: 0.38,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(BsTokens.brand),
                  ),
                ),
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
    final rows = <({String emoji, String title, String sub, VoidCallback tap})>[
      (
        emoji: '📐',
        title: 'סרוק תוכנית עבודה',
        sub: 'צלם שרטוט אינסטלציה — נזהה מה צריך להזמין',
        tap: () => openScanPlanSheet(context),
      ),
      (
        emoji: '📦',
        title: 'המלאי שלי',
        sub: 'מה כבר יש לך — במחסן ובאתר',
        tap: () => Navigator.of(context).push(StockScreen.route()),
      ),
      (
        emoji: '📋',
        title: 'משימות העבודה',
        sub: 'חלק משימות לעובדים ועקוב אחרי הביצוע',
        tap: () => openSiteHub(context),
      ),
    ];
    return _Pad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle('כלים מהירים'),
          for (final r in rows)
            InkWell(
              borderRadius: BorderRadius.circular(BsTokens.radiusCard),
              onTap: r.tap,
              child: Container(
                margin: const EdgeInsets.only(bottom: BsTokens.space2),
                padding: const EdgeInsets.all(BsTokens.space3),
                decoration: BoxDecoration(
                  color: BsTokens.cardLight,
                  borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
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
                              style: const TextStyle(
                                color: BsTokens.inkLight,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              )),
                          const SizedBox(height: 2),
                          Text(r.sub,
                              style: const TextStyle(
                                  color: BsTokens.mutedLight, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
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
    return _Pad(
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const InstallStudioScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(BsTokens.space4),
          decoration: BoxDecoration(
            color: const Color(0x1AFF7A18),
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
            border: Border.all(color: const Color(0x33FF7A18)),
          ),
          child: Row(
            children: const [
              Icon(Icons.account_tree, color: BsTokens.brandDark, size: 32),
              SizedBox(width: BsTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('תכנון חיבור',
                        style: TextStyle(
                          color: BsTokens.inkLight,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        )),
                    SizedBox(height: 2),
                    Text('בחר מה לחבר — נכין רשימת קנייה תקנית ונבדוק את החיבור',
                        style:
                            TextStyle(color: BsTokens.mutedLight, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: BsTokens.brandDark),
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
            _EmptyCard(
              'עדיין אין מועדפים — סמן ☆ על מוצר והוא יופיע כאן.',
            )
          else
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: BsTokens.space2,
              crossAxisSpacing: BsTokens.space2,
              childAspectRatio: 1.0,
              children: [
                for (final p in products)
                  _MiniTile(
                    icon: Icons.star,
                    label: p.nameHe,
                    onTap: () {},
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
    final orders = ref.watch(sysOrdersProvider);
    if (orders.isEmpty) {
      return _Pad(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionTitle('הזמנות אחרונות לאתר'),
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
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: BsTokens.space4),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(width: BsTokens.space3),
            itemBuilder: (_, i) => _OrderCard(order: orders[i]),
          ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final SysOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(order.id,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
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
              style: const TextStyle(color: BsTokens.inkLight, fontSize: 12)),
          const SizedBox(height: 2),
          Text('${order.items} פריטים',
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 11)),
          const SizedBox(height: 2),
          Text('₪${order.sum}',
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(BsTokens.space4),
        decoration: BoxDecoration(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
      );
}
