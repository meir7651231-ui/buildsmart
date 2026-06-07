import 'package:buildsmart/data/contractor_seeds.dart'
    show ProductBrands, fMoney, kHomeProductBrands;
import 'package:buildsmart/data/phaseb_seeds.dart'
    show ReorderHistoryItem, kDemoHistory;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/home_content_order.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🏠 תוכן-בית — a self-contained, REORDERABLE home content surface (T3.I).
///
/// Proto §1 (view-home) renders the home content as a fixed top-to-bottom stack:
/// קטגוריות → עץ-התקנה (product row) → מסלול-עבודה → כלים-מהירים → הזמנה-חוזרת.
/// This widget renders the same sections but lets the contractor reorder them
/// (drag, or up/down), persisted via [homeContentOrderProvider]. It adds real
/// **product-cards** (recommended brand + price from the verbatim
/// [kHomeProductBrands]) with a working "הוסף לסל", and the reorder-history
/// block from [kDemoHistory] — both proto §1 data sources.
///
/// SELF-CONTAINED: no edits to home_shell/catalog_screen. It is a drop-in body
/// surface; see the WIRE note in the agent report for how to mount it (or open
/// it as a screen via [route]). Tapping a category / quick-tool switches
/// [mainTabProvider] (no shared-file edits needed).
class HomeContentReorder extends ConsumerWidget {
  const HomeContentReorder({super.key, this.showAppBar = false});

  /// When opened as a standalone screen we want a Scaffold + AppBar; when
  /// embedded inside the existing home tab we render just the body.
  final bool showAppBar;

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const HomeContentReorder(showAppBar: true),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const body = _Body();
    if (!showAppBar) return body;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: BsTokens.space4,
          title: const Text(
            '🏠 תוכן הבית',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('‹ חזרה',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 14)),
            ),
          ],
        ),
        body: body,
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body();

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(homeContentOrderProvider);
    final notifier = ref.read(homeContentOrderProvider.notifier);

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(
          BsTokens.space4, BsTokens.space4, BsTokens.space4, BsTokens.space2),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'מסך הבית שלי',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          if (_editing)
            TextButton(
              onPressed: () {
                notifier.reset();
                showToast(context, 'הסדר אופס לברירת מחדל');
              },
              child: const Text('איפוס',
                  style: TextStyle(color: BsTokens.mutedLight)),
            ),
          TextButton.icon(
            onPressed: () => setState(() => _editing = !_editing),
            icon: Icon(_editing ? Icons.check : Icons.swap_vert,
                size: 18, color: BsTokens.brandDark),
            label: Text(_editing ? 'סיום' : 'שנה סדר',
                style: const TextStyle(color: BsTokens.brandDark)),
          ),
        ],
      ),
    );

    final sections = <Widget>[
      for (var i = 0; i < order.length; i++)
        _SectionSlot(
          key: ValueKey(order[i]),
          index: i,
          total: order.length,
          section: order[i],
          editing: _editing,
          onUp: () => notifier.moveUp(order[i]),
          onDown: () => notifier.moveDown(order[i]),
        ),
    ];

    return ListView(
      padding: const EdgeInsets.only(bottom: BsTokens.space6),
      children: [
        header,
        if (_editing)
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorder: notifier.reorder,
            children: sections,
          )
        else
          ...sections,
      ],
    );
  }
}

/// One reorderable home section: a drag-handle header (in edit mode) + the
/// real section content.
class _SectionSlot extends ConsumerWidget {
  const _SectionSlot({
    required this.index,
    required this.total,
    required this.section,
    required this.editing,
    required this.onUp,
    required this.onDown,
    super.key,
  });

  final int index;
  final int total;
  final HomeSection section;
  final bool editing;
  final VoidCallback onUp;
  final VoidCallback onDown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = kHomeSectionMeta[section]!;
    final content = switch (section) {
      HomeSection.categories => const _Categories(),
      HomeSection.products => const _ProductCards(),
      HomeSection.workPath => const _WorkPath(),
      HomeSection.promise => const _Promise(),
      HomeSection.reorderHistory => const _ReorderHistory(),
    };

    if (!editing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: BsTokens.space2),
        child: content,
      );
    }

    // Edit mode — compact handle row (drag + up/down) over a dimmed preview.
    return Container(
      margin: const EdgeInsets.fromLTRB(
          BsTokens.space4, BsTokens.space1, BsTokens.space4, BsTokens.space1),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.all(BsTokens.space3),
                  child: Icon(Icons.drag_indicator, color: BsTokens.mutedLight),
                ),
              ),
              Text(meta.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(meta.title,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    )),
              ),
              IconButton(
                onPressed: index == 0 ? null : onUp,
                icon: const Icon(Icons.keyboard_arrow_up),
                color: BsTokens.brandDark,
                tooltip: 'הזז למעלה',
              ),
              IconButton(
                onPressed: index == total - 1 ? null : onDown,
                icon: const Icon(Icons.keyboard_arrow_down),
                color: BsTokens.brandDark,
                tooltip: 'הזז למטה',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Section content widgets — proto §1 (verbatim copy/data).
// ════════════════════════════════════════════════════════════════════════════

/// קטגוריות — the 8-tile grid (proto cat-grid @4444-4453). Tapping → catalog.
class _Categories extends ConsumerWidget {
  const _Categories();

  static const List<({String ic, String cn})> _cats = [
    (ic: '🔧', cn: 'כלי עבודה'),
    (ic: '🚿', cn: 'אינסטלציה'),
    (ic: '⚡', cn: 'חשמל'),
    (ic: '🧱', cn: 'בנייה'),
    (ic: '🎨', cn: 'גמר וצבע'),
    (ic: '🔩', cn: 'חיבורים'),
    (ic: '🦺', cn: 'בטיחות'),
    (ic: '➕', cn: 'הכל'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Pad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle('קטגוריות'),
          const SizedBox(height: BsTokens.space2),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: BsTokens.space2,
            crossAxisSpacing: BsTokens.space2,
            childAspectRatio: 0.95,
            children: [
              for (final c in _cats)
                InkWell(
                  borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                  onTap: () => ref.read(mainTabProvider.notifier).state = 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: BsTokens.cardLight,
                      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(c.ic, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(c.cn,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: BsTokens.inkLight, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// עץ התקנה חכם — a horizontal row of real **product-cards** (recommended brand
/// + price from [kHomeProductBrands]) with a working add-to-cart. proto §1
/// homeProductRow (@4462) + HOME_PRODUCTS data.
class _ProductCards extends ConsumerWidget {
  const _ProductCards();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Pad(
          child: _SectionTitle('עץ התקנה חכם — אינסטלציה'),
        ),
        SizedBox(
          height: 188,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: BsTokens.space4),
            itemCount: kHomeProductBrands.length,
            separatorBuilder: (_, __) => const SizedBox(width: BsTokens.space3),
            itemBuilder: (_, i) => _ProductCard(pb: kHomeProductBrands[i]),
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.pb});

  final ProductBrands pb;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The recommended tier (proto HOME_PRODUCTS rec flag).
    var rec = pb.tiers.first;
    for (final t in pb.tiers) {
      if (t.rec) {
        rec = t;
        break;
      }
    }
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
          Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(BsTokens.radiusCard),
            ),
            child: const Text('🚿', style: TextStyle(fontSize: 30)),
          ),
          const SizedBox(height: 8),
          Text(pb.product,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              )),
          const SizedBox(height: 2),
          Text(rec.brand,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 11)),
          const SizedBox(height: 4),
          Text(fMoney(rec.price),
              style: const TextStyle(
                color: BsTokens.brandDark,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              )),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: FilledButton(
              onPressed: () {
                ref.read(smartCartProvider.notifier).add(
                      SmartCartLine(
                        productKey: 'home:${pb.product}',
                        productName: pb.product,
                        productEmoji: '🚿',
                        brandName: rec.brand,
                        brandPrice: rec.price,
                        productQty: 1,
                        accessories: const [],
                      ),
                    );
                showToast(context, '${pb.product} נוסף לסל');
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
                      fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

/// מסלול עבודה חכם — the project hero (proto project-hero @4468-4476).
class _WorkPath extends ConsumerWidget {
  const _WorkPath();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Pad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle('מסלול עבודה חכם'),
          const SizedBox(height: BsTokens.space2),
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
                const _Tag('🛁 חדש — מאפס עד גמר'),
                const SizedBox(height: 6),
                const Text('גמר אמבטיה — מלווה אותך שלב-שלב',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    )),
                const SizedBox(height: 4),
                const Text(
                  '4 שלבים בסדר הנכון. כל שלב: עץ מוצרים + חלון "סדר הרכבה" שמראה מה לפני מה.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  child: const LinearProgressIndicator(
                    value: 0.38,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(BsTokens.brand),
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

/// כלים מהירים — the 3 promise cards (proto promise @4479-4508).
class _Promise extends ConsumerWidget {
  const _Promise();

  static const List<({String pt, String ps})> _rows = [
    (pt: '📐 סרוק תוכנית עבודה', ps: 'צלם שרטוט אינסטלציה — נזהה מה צריך להזמין'),
    (pt: '📦 המלאי שלי', ps: 'מה כבר יש לך — במחסן ובאתר'),
    (pt: '📋 משימות העבודה', ps: 'חלק משימות לעובדים ועקוב אחרי הביצוע'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Pad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final r in _rows)
            Container(
              margin: const EdgeInsets.only(bottom: BsTokens.space2),
              padding: const EdgeInsets.all(BsTokens.space3),
              decoration: BoxDecoration(
                color: BsTokens.cardLight,
                borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.pt,
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      )),
                  const SizedBox(height: 2),
                  Text(r.ps,
                      style: const TextStyle(
                          color: BsTokens.mutedLight, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// הזמנה חוזרת לאתר זה — the reorder-history list (proto renderReorderHistory
/// @7017 + DEMO_HISTORY). Tapping a row adds it back to the cart.
class _ReorderHistory extends ConsumerWidget {
  const _ReorderHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Pad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle('הזמנה חוזרת לאתר זה'),
          const SizedBox(height: BsTokens.space2),
          if (kDemoHistory.isEmpty)
            const Text(
              'עדיין אין הזמנות קודמות — לאחר ההזמנה הראשונה היא תופיע כאן.',
              textAlign: TextAlign.center,
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            )
          else
            for (final it in kDemoHistory) _ReorderRow(item: it),
        ],
      ),
    );
  }
}

class _ReorderRow extends ConsumerWidget {
  const _ReorderRow({required this.item});

  final ReorderHistoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void add() {
      ref.read(smartCartProvider.notifier).add(
            SmartCartLine(
              productKey: 'reorder:${item.name}',
              productName: item.name,
              productEmoji: item.icon,
              brandName: item.cat,
              brandPrice: item.price,
              productQty: 1,
              accessories: const [],
            ),
          );
      showToast(context, '${item.name} נוסף לסל');
    }

    return InkWell(
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      onTap: add,
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
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(BsTokens.radiusCard),
              ),
              child: Text(item.icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: BsTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      )),
                  const SizedBox(height: 2),
                  Text('${item.cat} · ${item.ago}',
                      style: const TextStyle(
                          color: BsTokens.mutedLight, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(fMoney(item.price),
                      style: const TextStyle(
                        color: BsTokens.brandDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      )),
                ],
              ),
            ),
            IconButton(
              onPressed: add,
              icon: const Icon(Icons.add_circle, color: BsTokens.brand),
              tooltip: 'הוסף לסל',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── tiny shared bits ─────────────────────────────────────────────────────────
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
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: BsTokens.inkLight,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      );
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12)),
      );
}
