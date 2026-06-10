import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/screens/persona_picking_sheet.dart';
import 'package:buildsmart/screens/persona_portal.dart';
import 'package:buildsmart/screens/profile_screen.dart';
import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:buildsmart/state/store_stock.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🏪 חנות ספק — the supplier-store role app. Same shell/style as the
/// contractor app (white AppBar + segmented tabs + card lists); a faithful port
/// of the prototype `screen-store` (proto 06 §2 / preact 03 §1): action-first
/// home, the order work-queue with the real new→preparing→ready advance, stock
/// availability toggles, and the 8-tile supplier portal.
///
/// Reached from the role picker ("מי אתה?" → חנות ספק). Orders are the shared
/// [sysOrdersProvider] state, so an order the store marks "מוכן" appears live in
/// the courier app. R8 — every string/number is verbatim from [supplier_data].
///
/// Deferred (proto "adds beyond"/heavier infra): the per-store login routing,
/// the picking sheet + missing-item hold loop, split shipments, the printed
/// delivery note, and localStorage persistence.
class StoreDashboardScreen extends ConsumerStatefulWidget {
  const StoreDashboardScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const StoreDashboardScreen());

  @override
  ConsumerState<StoreDashboardScreen> createState() =>
      _StoreDashboardScreenState();
}

class _StoreDashboardScreenState extends ConsumerState<StoreDashboardScreen> {
  int _tab = 0; // 0 בית · 1 הזמנות · 2 מלאי · 3 פורטל
  String _orderFilter = 'active'; // active | new | preparing | ready
  String _stockFilter = 'all'; // all | in | out
  String _stockSearch = '';

  StoreInfo get _store => kStores.first;

  /// Unique product names across all order lines — the stock catalog stand-in.
  List<String> get _stockNames {
    final seen = <String>{};
    final out = <String>[];
    for (final o in ref.watch(sysOrdersProvider)) {
      for (final l in o.lines) {
        if (seen.add(l.name)) out.add(l.name);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(sysOrdersProvider);
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
            '🏪 חנות ספק',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          actions: [
            // Each persona reaches profile + settings from its own dashboard.
            IconButton(
              tooltip: 'פרופיל',
              icon: const Icon(Icons.person_outline, color: BsTokens.mutedLight),
              onPressed: () =>
                  Navigator.of(context).push(ProfileScreen.route()),
            ),
            IconButton(
              tooltip: 'הגדרות',
              icon:
                  const Icon(Icons.settings_outlined, color: BsTokens.mutedLight),
              onPressed: () =>
                  Navigator.of(context).push(CatalogSettingsScreen.route()),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text(
                '‹ יציאה',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _StoreTabs(active: _tab, onSelect: (i) => setState(() => _tab = i)),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEDEDED)),
            Expanded(child: _body(orders)),
          ],
        ),
      ),
    );
  }

  Widget _body(List<SysOrder> orders) {
    switch (_tab) {
      case 1:
        return _ordersTab(orders);
      case 2:
        return _stockTab();
      case 3:
        return _portalTab();
      default:
        return _homeTab(orders);
    }
  }

  // ── Tab 1 · בית (action-first home) ────────────────────────────────────────
  Widget _homeTab(List<SysOrder> orders) {
    final toApprove = orders.countAt(OrderStage.newOrder);
    final inPrep = orders.countAt(OrderStage.preparing);
    final ready = orders.countAt(OrderStage.ready);
    final revenue = orders.todayRevenue;
    final outCount =
        ref.watch(storeOosProvider.select((oos) => oos.length));
    final fulfillment = ref.watch(fulfillmentProvider);
    // Orders held for a missing-item decision (proto §2.2 "held" card).
    final held = orders.where((o) {
      final f = fulfillment[o.id];
      return f != null && f.heldForMissing;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        const Text(
          'שלום 👋',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '🏪 ${_store.name} — מה שצריך טיפול עכשיו',
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
        const SizedBox(height: BsTokens.space4),

        // Primary action card.
        if (toApprove > 0)
          _ActionCard(
            color: BsTokens.brand,
            badge: '$toApprove',
            title: 'הזמנות ממתינות לאישור',
            sub: 'הקש כדי לאשר ולהתחיל הכנה',
            onTap: () => setState(() {
              _tab = 1;
              _orderFilter = 'new';
            }),
          )
        else
          _FlatCard(
            child: Text(
              '✓ אין הזמנות שממתינות לאישור',
              style: TextStyle(
                color: BsTokens.inkLight.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        const SizedBox(height: BsTokens.space3),

        // Held-for-missing card (proto §2.2 [L17116]).
        if (held.isNotEmpty) ...[
          _ActionCard(
            color: const Color(0xFFE08A00),
            badge: '${held.length}',
            title: 'הזמנות ממתינות לבחירת הקבלן',
            sub: 'פריט חסר — ממתין להחלטה (החלפה / ביטול)',
            onTap: () => showPickingSheet(context, held.first.id),
          ),
          const SizedBox(height: BsTokens.space3),
        ],

        // Quick stats (3).
        Row(
          children: [
            _Stat(value: '$inPrep', label: 'בהכנה 🔧'),
            _Stat(value: '$ready', label: 'מוכן לאיסוף 📦'),
            _Stat(value: fMoney(revenue), label: 'מחזור פעיל 💰'),
          ],
        ),
        const SizedBox(height: BsTokens.space3),

        // Stock alert.
        InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          onTap: () => setState(() => _tab = 2),
          child: _FlatCard(
            child: Text(
              outCount > 0
                  ? '⚠️ $outCount מוצרים אזלו מהמלאי — הקש לעדכון'
                  : '✓ כל המוצרים זמינים במלאי',
              style: TextStyle(
                color: outCount > 0
                    ? BsTokens.brandDark
                    : BsTokens.inkLight.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: BsTokens.space4),

        // Quick actions.
        Row(
          children: [
            Expanded(
              child: _BigButton(
                label: '📥 הזמנות',
                onTap: () => setState(() => _tab = 1),
              ),
            ),
            const SizedBox(width: BsTokens.space2),
            Expanded(
              child: _BigButton(
                label: '📦 מלאי',
                onTap: () => setState(() => _tab = 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: BsTokens.space3),

        // Demo tool.
        OutlinedButton(
          onPressed: () {
            final id = ref
                .read(sysOrdersProvider.notifier)
                .simulateIncomingOrder();
            showToast(context, 'הזמנת הדגמה $id נוצרה — נכנסה לתור ✓');
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Color(0xFFE0E0E0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(BsTokens.radiusCard),
            ),
          ),
          child: const Text(
            '➕ סימולציית הזמנה נכנסת (כלי הדגמה)',
            style: TextStyle(
              color: BsTokens.mutedLight,
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── Tab 2 · הזמנות (work queue) ─────────────────────────────────────────────
  Widget _ordersTab(List<SysOrder> orders) {
    bool match(SysOrder o) {
      switch (_orderFilter) {
        case 'new':
          return o.stage == OrderStage.newOrder;
        case 'preparing':
          return o.stage == OrderStage.preparing;
        case 'ready':
          return o.stage == OrderStage.ready;
        default: // active = new|preparing|ready
          return o.stage == OrderStage.newOrder ||
              o.stage == OrderStage.preparing ||
              o.stage == OrderStage.ready;
      }
    }

    final shown = orders.where(match).toList()
      ..sort(
        (a, b) =>
            kOrderFlow.indexOf(a.stage).compareTo(kOrderFlow.indexOf(b.stage)),
      );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space3,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        Row(
          children: [
            for (final f in const [
              ('active', 'פעילות'),
              ('new', 'לאישור'),
              ('preparing', 'בהכנה'),
              ('ready', 'מוכנות'),
            ]) ...[
              _Chip(
                label: f.$2,
                on: _orderFilter == f.$1,
                onTap: () => setState(() => _orderFilter = f.$1),
              ),
              const SizedBox(width: BsTokens.space2),
            ],
          ],
        ),
        const SizedBox(height: BsTokens.space3),
        if (shown.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: BsTokens.space5),
            child: Center(
              child: Text(
                'אין הזמנות בקטגוריה זו ✓',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
              ),
            ),
          )
        else
          for (final o in shown)
            _StoreOrderCard(
              order: o,
              fulfillment:
                  ref.watch(fulfillmentProvider)[o.id] ?? const Fulfillment(),
              onAdvance: _advance,
              onOpenPick: () => showPickingSheet(context, o.id),
            ),
      ],
    );
  }

  void _advance(SysOrder o) {
    // The store now owns the hand-off too (ready→pickup, "מסור לשליח"); the
    // courier takes over from `pickup` (two-step hand-off).
    ref.read(sysOrdersProvider.notifier).storeAdvance(o.id);
    showToast(context, 'ההזמנה ${o.id} עודכנה — מסונכרן עם השליח והמנהל ✓');
  }

  // ── Tab 3 · מלאי (stock management) ─────────────────────────────────────────
  Widget _stockTab() {
    final oos = ref.watch(storeOosProvider);
    final oosNotifier = ref.read(storeOosProvider.notifier);
    final all = _stockNames;
    final total = all.length;
    final outN = oos.length;
    final inN = total - outN;

    bool match(String name) {
      if (_stockSearch.isNotEmpty && !name.contains(_stockSearch)) return false;
      switch (_stockFilter) {
        case 'in':
          return !oos.contains(name);
        case 'out':
          return oos.contains(name);
        default:
          return true;
      }
    }

    final shown = all.where(match).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space3,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        Row(
          children: [
            _Stat(value: '$total', label: 'מוצרים'),
            _Stat(value: '$inN', label: 'זמינים'),
            _Stat(value: '$outN', label: 'אזלו'),
          ],
        ),
        const SizedBox(height: BsTokens.space3),
        TextField(
          textDirection: TextDirection.rtl,
          onChanged: (v) => setState(() => _stockSearch = v.trim()),
          decoration: InputDecoration(
            hintText: 'חיפוש מוצר...',
            isDense: true,
            filled: true,
            fillColor: BsTokens.cardLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
        ),
        const SizedBox(height: BsTokens.space3),
        Row(
          children: [
            for (final f in const [
              ('all', 'הכל'),
              ('in', 'זמינים'),
              ('out', 'אזלו'),
            ]) ...[
              _Chip(
                label: f.$2,
                on: _stockFilter == f.$1,
                onTap: () => setState(() => _stockFilter = f.$1),
              ),
              const SizedBox(width: BsTokens.space2),
            ],
          ],
        ),
        const SizedBox(height: BsTokens.space3),
        if (shown.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: BsTokens.space5),
            child: Center(
              child: Text(
                'לא נמצאו מוצרים תואמים.',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
              ),
            ),
          )
        else
          for (final name in shown)
            _StockRow(
              name: name,
              available: !oos.contains(name),
              onToggle: () {
                if (oos.contains(name)) {
                  oosNotifier.markAvailable(name);
                  showToast(context, 'סומן כזמין במלאי');
                } else {
                  oosNotifier.markOos(name);
                  showToast(context, 'סומן כאזל במלאי');
                }
              },
            ),
      ],
    );
  }

  // ── Tab 4 · פורטל (supplier portal, 8 tiles) ────────────────────────────────
  Widget _portalTab() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(BsTokens.space4),
      mainAxisSpacing: BsTokens.space3,
      crossAxisSpacing: BsTokens.space3,
      childAspectRatio: 1.5,
      children: [
        for (final t in kStorePortalTiles)
          PortalTileButton(
            title: t.title,
            sub: t.sub,
            onTap: () => showPortalSheet(context, t),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// 4-tab segmented control (underline style, matching `updates_screen`).
class _StoreTabs extends StatelessWidget {
  const _StoreTabs({required this.active, required this.onSelect});

  final int active;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    Widget seg(int i, String label) {
      final on = active == i;
      final color = on ? BsTokens.brand : const Color(0xFF888888);
      return Expanded(
        child: InkWell(
          onTap: () => onSelect(i),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: on ? BsTokens.brand : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 13.5,
                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.white,
      child: Row(
        children: [
          seg(0, '🏠 בית'),
          seg(1, '📥 הזמנות'),
          seg(2, '📦 מלאי'),
          seg(3, '🧰 פורטל'),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.color,
    required this.badge,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  final Color color;
  final String badge;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(BsTokens.space4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: BsTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: bsOnAccent(context),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: TextStyle(
                        color: bsOnAccent(context),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: bsOnAccent(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlatCard extends StatelessWidget {
  const _FlatCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: BsTokens.space3),
        decoration: BoxDecoration(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF0E3),
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: BsTokens.space4),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: BsTokens.brandDark,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: on ? BsTokens.brand : BsTokens.cardLight,
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: on ? bsOnAccent(context) : BsTokens.inkLight,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// Stage pill colours for the store work-queue (`new`→לאישור, `preparing`→בהכנה,
/// `ready`→מוכן).
({String label, Color bg, Color fg}) _storePill(OrderStage s) => switch (s) {
  OrderStage.newOrder => (
    label: 'לאישור',
    bg: const Color(0xFFFFF4D6),
    fg: const Color(0xFF8A6D00),
  ),
  OrderStage.preparing => (
    label: 'בהכנה',
    bg: const Color(0xFFDCEBFF),
    fg: const Color(0xFF2B6CB0),
  ),
  _ => (
    label: 'מוכן',
    bg: const Color(0xFFD7F5DF),
    fg: const Color(0xFF1F8A4C),
  ),
};

class _StoreOrderCard extends StatelessWidget {
  const _StoreOrderCard({
    required this.order,
    required this.fulfillment,
    required this.onAdvance,
    required this.onOpenPick,
  });
  final SysOrder order;
  final Fulfillment fulfillment;
  final void Function(SysOrder) onAdvance;
  final VoidCallback onOpenPick;

  @override
  Widget build(BuildContext context) {
    final held = fulfillment.heldForMissing;
    final pill = held
        ? (
            label: 'פריט חסר',
            bg: const Color(0xFFFFF4D6),
            fg: const Color(0xFF8A6D00),
          )
        : _storePill(order.stage);

    // proto §2.4 per-card button logic (held → wait; missingResolved → fix done;
    // else the stage action), with the live two-step ready→pickup hand-off.
    final (String label, bool active) = held
        ? ('⏳ פריט חסר — אנא המתן להחלטת הקבלן', false)
        : switch (order.stage) {
            OrderStage.newOrder => ('✓ אשר וקבל להכנה', true),
            OrderStage.preparing => ('📦 סמן כמוכן — העבר לשליח', true),
            OrderStage.ready => ('🛵 מסור לשליח', true),
            _ => ('✓ נמסר לשליח', false),
          };
    final splitTag =
        fulfillment.splitInto > 1 ? ' · 🚚 הוכן ב-${fulfillment.splitInto} חבילות' : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space3),
      child: Material(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        elevation: 1,
        shadowColor: Colors.black26,
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          onTap: onOpenPick,
          child: Padding(
            padding: const EdgeInsets.all(BsTokens.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            '📦 ${order.id}',
                            style: const TextStyle(
                              color: BsTokens.inkLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          if (fulfillment.splitInto > 1) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F0FF),
                                borderRadius: BorderRadius.circular(
                                  BsTokens.radiusPill,
                                ),
                              ),
                              child: Text(
                                '🚚×${fulfillment.splitInto}',
                                style: const TextStyle(
                                  color: Color(0xFF2B6CB0),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: pill.bg,
                        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                      ),
                      child: Text(
                        pill.label,
                        style: TextStyle(
                          color: pill.fg,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.who} · ${order.site}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '🕒 נדרש: בתיאום',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.items} פריטים · ${fMoney(order.sum)} · הקש לתעודת ליקוט$splitTag',
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 12.5,
                  ),
                ),
                if (!held && fulfillment.missingResolved) ...[
                  const SizedBox(height: 2),
                  const Text(
                    '✓ תיקון בוצע — בדוק שינויים',
                    style: TextStyle(
                      color: Color(0xFF1F8A4C),
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ],
                const SizedBox(height: BsTokens.space3),
                if (active)
                  FilledButton(
                    onPressed: () async {
                      // ready→pickup hand-off is final — confirm first.
                      if (order.stage == OrderStage.ready) {
                        final ok = await confirmDestructive(
                          context,
                          title: 'מסירה לשליח?',
                          message:
                              'ההזמנה ${order.id} תימסר לשליח — פעולה סופית.',
                          confirmLabel: 'מסור',
                          confirmColor: const Color(0xFF1F8A4C),
                        );
                        if (!ok || !context.mounted) return;
                      }
                      onAdvance(order);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: order.stage == OrderStage.preparing
                          ? BsTokens.brand
                          : const Color(0xFF1F8A4C),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                      ),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: held
                          ? const Color(0xFFFFF4D6)
                          : const Color(0xFFF2F3F5),
                      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: held
                            ? const Color(0xFF8A6D00)
                            : BsTokens.mutedLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
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

class _StockRow extends StatelessWidget {
  const _StockRow({
    required this.name,
    required this.available,
    required this.onToggle,
  });
  final String name;
  final bool available;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space4,
          vertical: BsTokens.space3,
        ),
        decoration: BoxDecoration(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    available ? '✅ זמין במלאי' : '❌ אזל מהמלאי',
                    style: TextStyle(
                      color: available
                          ? const Color(0xFF1F8A4C)
                          : BsTokens.brandDark,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: available,
              activeColor: BsTokens.brand,
              onChanged: (_) => onToggle(),
            ),
          ],
        ),
      ),
    );
  }
}
