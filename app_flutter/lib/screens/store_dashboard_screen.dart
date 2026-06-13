import 'dart:async';
import 'dart:convert';

import 'package:buildsmart/data/catalog.dart' show kCatalogCats;
import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/repositories/orders_local.dart'
    show visibleOrderIdsProvider;
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/persona_picking_sheet.dart';
import 'package:buildsmart/screens/persona_portal.dart';
import 'package:buildsmart/screens/store_profile_screen.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/screens/worker_notifs_sheet.dart'
    show workerNotifAgo;
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:buildsmart/state/store_profile_store.dart';
import 'package:buildsmart/state/store_stock.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🏪 חנות ספק — the supplier-store role app.
///
/// #77 — the tabs moved DOWN: a [BottomNavigationBar] (the courier-board
/// pattern, courier_dashboard_screen.dart) with 4 tabs.
/// #78 — re-organized: בית = the הזמנות pipeline (default, keeping the
/// action-first header on top); 'ניהול צי רכב' (local DEMO-SEED fleet sheet) +
/// 'עדכון מלאי' (jump to the מלאי tab) moved from the portal to the home
/// quick-actions; שיחות is its own tab (the shared cross-persona [ChatsScreen]
/// under audience 'store' — #83).
/// #80 — the מלאי tab carries a catalog-backed inventory (name+מק"ט+category,
/// merged with the live order-line products) behind one smart search field
/// matching name OR sku OR category.
/// #82 — the settings IconButton routes to the supplier-specific
/// [SupplierSettingsScreen] (business profile, persisted), and the AppBar
/// carries the per-username notifications bell (reusing
/// [workerNotifsProvider] — the same store the courier's 'שלח דוח-יומי לחנות'
/// writes into).
///
/// #87 — a fifth bottom tab 'אזור אישי' ([StoreProfileBody]) and the AppBar
/// person icon now route to the SUPPLIER'S OWN personal area
/// ([StoreProfileScreen]) — never the contractor's ProfileScreen (F-19); the
/// AppBar title reflects the live business-profile override
/// ([storeProfileProvider] — F-20).
///
/// Reached from the role picker ("מי אתה?" → חנות ספק). Orders are the shared
/// [sysOrdersProvider] state, so an order the store marks "מוכן" appears live
/// in the courier app. R8 — every string/number is verbatim from
/// `supplier_data.dart`.
class StoreDashboardScreen extends ConsumerStatefulWidget {
  const StoreDashboardScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const StoreDashboardScreen());

  @override
  ConsumerState<StoreDashboardScreen> createState() =>
      _StoreDashboardScreenState();
}

class _StoreDashboardScreenState extends ConsumerState<StoreDashboardScreen> {
  /// #77/#78 — 0 בית (the הזמנות pipeline, default) · 1 מלאי · 2 שיחות ·
  /// 3 פורטל · 4 אזור אישי (#87.5).
  int _tab = 0;
  String _orderFilter = 'active'; // active | new | preparing | ready | delivered
  String _stockFilter = 'all'; // all | in | out
  String _stockSearch = '';

  /// Demo/analytics seed only (kStores.first — F-20): the displayed identity
  /// comes from the business-profile override with this name as the LAST
  /// honest fallback; never real business data.
  StoreInfo get _store => kStores.first;

  /// Live trading inventory: unique product names across all order lines,
  /// enriched (#80) with the unified catalog's מק"ט + category when the name
  /// matches a real catalog product (no invented SKUs — a non-catalog line
  /// honestly shows 'ללא מק"ט'), UNIONED (#79) with the supplier-added
  /// products overlay ([storeProductsProvider] — the persisted 'הוסף מוצר'
  /// uploads, removable + tagged).
  /// A6 — apply the pool∪own scope to a SysOrder list when
  /// [visibleOrderIdsProvider] is active (flag ON + store uid). Returns the
  /// list unchanged otherwise (null id-set ⇒ today's full list).
  List<SysOrder> _scopeOrders(List<SysOrder> orders) {
    final ids = ref.watch(visibleOrderIdsProvider);
    if (ids == null) return orders;
    return orders.where((o) => ids.contains(o.id)).toList();
  }

  List<_InvItem> get _inventory {
    final seen = <String>{};
    final out = <_InvItem>[];
    for (final o in _scopeOrders(ref.watch(sysOrdersProvider))) {
      for (final l in o.lines) {
        if (seen.add(l.name)) {
          final p = _catalogByName[l.name];
          out.add(
            _InvItem(name: l.name, sku: p?.sku, category: p?.categoryHe),
          );
        }
      }
    }
    for (final p in ref.watch(storeProductsProvider)) {
      if (seen.add(p.name)) {
        out.add(
          _InvItem(
            name: p.name,
            sku: p.sku,
            category: p.category,
            overlayId: p.id,
          ),
        );
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    // task #65 · חוק: מבחוץ לא רואים כלום — without a store [BoardSession]
    // ONLY the gate (the registration screen in role mode) is built; a
    // successful login flips [boardAuthProvider] and this build swaps to the
    // real board in place. logout() swaps it back to the gate.
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.store) {
      return const WelcomeScreen(boardRole: BoardRole.store);
    }
    // F-44 — sysOrdersProvider is deliberately NOT watched here: the
    // order-reading tabs watch it themselves (_homeTab/_stockTab), so an
    // order mutation no longer rebuilds the whole Scaffold while the
    // שיחות/פורטל/אזור-אישי tabs are showing.
    //
    // #87.1 (F-20) — the board identity reflects the business-profile
    // override. Honest fallback chain: businessName → session.displayName →
    // the kStores demo seed (a documented seed, not real business data).
    final businessName = ref.watch(
      storeProfileProvider.select(
        (m) => (m[session.username]?.businessName ?? '').trim(),
      ),
    );
    final storeName = businessName.isNotEmpty
        ? businessName
        : (session.displayName.trim().isNotEmpty
              ? session.displayName.trim()
              : _store.name);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: BsTokens.space4,
          // F-20/F-41 — the live business name; bounded so a long override
          // ellipsizes instead of blowing the AppBar. 🏪 stays the supplier's
          // identity emoji (parallel to 🛵 courier / 🦺 worker).
          title: Text(
            '🏪 $storeName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          actions: [
            // #82 — the supplier bell: per-username runtime notifications off
            // the shared [workerNotifsProvider] (the courier's daily report +
            // future order events land here — every write has a reader).
            _StoreNotifsBell(username: session.username),
            // #87.5 (F-19) — the person icon opens the SUPPLIER'S OWN gated
            // personal area (StoreProfileScreen), NOT the contractor's
            // ProfileScreen (which leaked the contractor identity into the
            // store board and bypassed the role-switch code-gate).
            IconButton(
              tooltip: 'אזור אישי',
              icon: const Icon(Icons.person_outline, color: BsTokens.mutedLight),
              onPressed: () =>
                  Navigator.of(context).push(StoreProfileScreen.route()),
            ),
            // #82 — supplier-specific settings (business profile), NOT the
            // contractor's CatalogSettingsScreen.
            IconButton(
              tooltip: 'הגדרות',
              icon:
                  const Icon(Icons.settings_outlined, color: BsTokens.mutedLight),
              onPressed: () =>
                  Navigator.of(context).push(SupplierSettingsScreen.route()),
            ),
            // #21 — a REAL logout next to the navigation-only '‹ יציאה':
            // confirmDestructive → boardAuthProvider.logout(); the gate
            // (WelcomeScreen in role mode) swaps in place — task #65 rule 4.
            IconButton(
              tooltip: 'התנתקות מהחשבון',
              icon: const Icon(Icons.logout, color: BsTokens.mutedLight),
              onPressed: _logout,
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
        body: _body(storeName),
        // #77 — the tabs moved to the BOTTOM (the courier-board pattern).
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFFFFFFF),
          selectedItemColor: BsTokens.brand,
          unselectedItemColor: const Color(0xFF888888),
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'בית',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'מלאי',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'שיחות',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'פורטל'),
            // #87.5 — the personal area as a REAL labeled tab (not only an
            // AppBar icon); `type: fixed` keeps the label always visible.
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'אזור אישי',
            ),
          ],
        ),
      ),
    );
  }

  /// #21 — explicit board logout (the '‹ יציאה' TextButton only pops the
  /// route). Confirm first (destructive-confirm rule #57); on confirm the
  /// session clears and this screen rebuilds into the registration gate.
  Future<void> _logout() async {
    final ok = await confirmDestructive(
      context,
      title: 'התנתקות מהחשבון?',
      message: 'תנותק מלוח חנות הספק ותחזור למסך הרישום.',
      confirmLabel: 'התנתק',
    );
    if (!ok || !mounted) return;
    ref.read(boardAuthProvider.notifier).logout();
    showToast(context, 'התנתקת מלוח חנות הספק');
  }

  Widget _body(String storeName) {
    switch (_tab) {
      case 1:
        return _stockTab();
      case 2:
        // #83 — the store's own שיחות tab: the shared cross-persona engine
        // under the 'store' audience (threads where the 🏪 store participates;
        // the bot thread is shared). Both-side visibility for the role-specific
        // chip set requires the chats_screen audience extension (see
        // NEEDS-CROSS-FILE in the task report) — the embed itself is real and
        // engine-backed today.
        return const ChatsScreen(
          persona: BsRole.store,
          audience: 'store',
          embedded: true,
        );
      case 3:
        return _portalTab();
      case 4:
        // #87.5 — the supplier's personal area body (store_profile_screen.dart);
        // it gates itself on session+role like every personal screen.
        return const StoreProfileBody();
      default:
        return _homeTab(storeName);
    }
  }

  // ── Tab 0 · בית — action-first header + the הזמנות pipeline (#78) ──────────
  Widget _homeTab(String storeName) {
    // F-44 — the orders watch lives HERE (tab-scoped), not in the main build:
    // while another tab is showing, this method never runs, so the dependency
    // is dropped and order mutations don't rebuild the Scaffold.
    // A6 — when `kUidScopedQueries` is ON + a store uid is known, restrict the
    // store board to its pool∪own slice ([visibleOrderIdsProvider]); the
    // provider returns null OFF/signed-out so this is a no-op today (the list
    // is unchanged — zero regression).
    final orders = _scopeOrders(ref.watch(sysOrdersProvider));
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
        // F-20 — the SAME live identity as the AppBar title (profile override
        // → displayName → demo seed); F-41 — bounded against a long override.
        Text(
          '🏪 $storeName — מה שצריך טיפול עכשיו',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
        const SizedBox(height: BsTokens.space4),

        // Primary action card — jumps the pipeline below to the 'new' filter.
        if (toApprove > 0)
          _ActionCard(
            color: BsTokens.brand,
            badge: '$toApprove',
            title: 'הזמנות ממתינות לאישור',
            sub: 'הקש כדי לאשר ולהתחיל הכנה',
            onTap: () => setState(() => _orderFilter = 'new'),
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
        const SizedBox(height: BsTokens.space2),
        // #87.2 (F-23) — the completed side of the pipeline next to the
        // active one, derived live from sysOrdersProvider (deliveredRevenue,
        // supplier_data.dart — Σ של o.sum בלבד, אפס מספרים קשיחים).
        // by-design: ללוח החנות הסטטיסטיקה כלל-חנותית — כל ההזמנות שייכות
        // לחנות אחת (kStores.first); אין כאן צורך בסינון per-username
        // (להבדיל מפרופיל-השליח, ראה Fulfillment.courierUser).
        Row(
          children: [
            _Stat(
              value: '${orders.countAt(OrderStage.delivered)}',
              label: 'נמסרו ✓',
            ),
            _Stat(
              value: fMoney(orders.deliveredRevenue),
              label: 'מחזור שנמסר 💰',
            ),
          ],
        ),
        const SizedBox(height: BsTokens.space3),

        // Stock alert.
        InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          onTap: () => setState(() => _tab = 1),
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

        // #78 — quick actions moved here FROM the portal: fleet (local
        // DEMO-SEED sheet — the kFleet rows) + stock-update (jump to מלאי).
        Row(
          children: [
            Expanded(
              child: _BigButton(
                label: '🚛 ניהול צי רכב',
                onTap: () => showPortalSheet(
                  context,
                  kStorePortalTiles
                      .firstWhere((t) => t.kind == PortalKind.fleet),
                ),
              ),
            ),
            const SizedBox(width: BsTokens.space2),
            Expanded(
              child: _BigButton(
                label: '🔄 עדכון מלאי',
                onTap: () => setState(() => _tab = 1),
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
        const SizedBox(height: BsTokens.space4),

        // ── #78 · the הזמנות pipeline IS the home (default) tab ──────────────
        const Text(
          '📥 הזמנות',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: BsTokens.space2),
        ..._pipeline(orders),
      ],
    );
  }

  /// The order work-queue: filter chips (incl. the delivered surface — COURIER
  /// v2(a): the POD lands where the STORE can see it) + the order cards.
  List<Widget> _pipeline(List<SysOrder> orders) {
    bool match(SysOrder o) {
      switch (_orderFilter) {
        case 'new':
          return o.stage == OrderStage.newOrder;
        case 'preparing':
          return o.stage == OrderStage.preparing;
        case 'ready':
          return o.stage == OrderStage.ready;
        case 'delivered':
          return o.stage == OrderStage.delivered;
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
    final fulfillment = ref.watch(fulfillmentProvider);

    return [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final f in const [
              ('active', 'פעילות'),
              ('new', 'לאישור'),
              ('preparing', 'בהכנה'),
              ('ready', 'מוכנות'),
              ('delivered', 'נמסרו'),
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
      ),
      const SizedBox(height: BsTokens.space3),
      if (shown.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: BsTokens.space4),
          child: Center(
            child: Text(
              'אין הזמנות בקטגוריה זו ✓',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
            ),
          ),
        )
      else
        for (final o in shown)
          if (o.stage == OrderStage.delivered)
            _DeliveredCard(
              order: o,
              fulfillment: fulfillment[o.id] ?? const Fulfillment(),
              onTap: () => showPickingSheet(context, o.id),
            )
          else
            _StoreOrderCard(
              order: o,
              fulfillment: fulfillment[o.id] ?? const Fulfillment(),
              onAdvance: _advance,
              onOpenPick: () => showPickingSheet(context, o.id),
            ),
    ];
  }

  void _advance(SysOrder o) {
    // The store now owns the hand-off too (ready→pickup, "מסור לשליח"); the
    // courier takes over from `pickup` (two-step hand-off).
    ref.read(sysOrdersProvider.notifier).storeAdvance(o.id);
    showToast(context, 'ההזמנה ${o.id} עודכנה — מסונכרן עם השליח והמנהל ✓');
  }

  // ── Tab 1 · מלאי (stock management, #79/#80) ────────────────────────────────
  Widget _stockTab() {
    final oos = ref.watch(storeOosProvider);
    final oosNotifier = ref.read(storeOosProvider.notifier);
    final base = _inventory;
    final total = base.length;
    final outN = oos.length;
    final inN = base.where((i) => !oos.contains(i.name)).length;
    final q = _stockSearch;

    bool textMatch(_InvItem i) {
      if (q.isEmpty) return true;
      return i.name.contains(q) ||
          (i.sku?.contains(q) ?? false) ||
          (i.category?.contains(q) ?? false);
    }

    bool statusMatch(_InvItem i) {
      switch (_stockFilter) {
        case 'in':
          return !oos.contains(i.name);
        case 'out':
          return oos.contains(i.name);
        default:
          return true;
      }
    }

    // #80 — pro search: the live trading inventory first; a non-empty query
    // ALSO searches the FULL unified catalog (name + מק"ט + category) so the
    // supplier can find and toggle any real catalog product.
    final matched = <_InvItem>[...base.where(textMatch)];
    final baseMatchedCount = matched.length;
    var catalogMatchTotal = 0;
    if (q.isNotEmpty) {
      final names = {for (final i in matched) i.name};
      for (final p in kCatalogProducts) {
        if (names.contains(p.nameHe)) continue;
        if (p.nameHe.contains(q) ||
            p.sku.contains(q) ||
            p.categoryHe.contains(q)) {
          catalogMatchTotal++;
          if (matched.length < _kStockShownCap) {
            names.add(p.nameHe);
            matched.add(
              _InvItem(name: p.nameHe, sku: p.sku, category: p.categoryHe),
            );
          }
        }
      }
    }
    final filtered = matched.where(statusMatch).toList();
    final shown = filtered.take(_kStockShownCap).toList();
    // Honest "more results exist" count: catalog matches that were not added
    // (beyond the cap) + matched rows truncated by the cap after filtering.
    final hiddenCount = (filtered.length - shown.length) +
        (catalogMatchTotal - (matched.length - baseMatchedCount));

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
        // #79 — upload a NEW product (persisted overlay; appears in this list
        // tagged + joins the contractor catalog/search via the shared state).
        FilledButton(
          onPressed: () => _showAddProductSheet(context),
          style: FilledButton.styleFrom(
            backgroundColor: BsTokens.brand,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            ),
          ),
          child: const Text(
            '➕ הוסף מוצר חדש',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
        const SizedBox(height: BsTokens.space3),
        TextField(
          textDirection: TextDirection.rtl,
          onChanged: (v) => setState(() => _stockSearch = v.trim()),
          decoration: InputDecoration(
            // #80 — one smart field: name OR מק"ט OR category.
            hintText: 'חיפוש לפי שם, מק"ט או קטגוריה...',
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
        else ...[
          for (final item in shown)
            _StockRow(
              item: item,
              available: !oos.contains(item.name),
              onToggle: () {
                if (oos.contains(item.name)) {
                  oosNotifier.markAvailable(item.name);
                  showToast(context, 'סומן כזמין במלאי');
                } else {
                  oosNotifier.markOos(item.name);
                  showToast(context, 'סומן כאזל במלאי');
                }
              },
              // #79 — only supplier-added overlay products are removable; the
              // const catalog + order lines are untouchable by design.
              onRemove: item.overlayId == null
                  ? null
                  : () async {
                      final ok = await confirmDestructive(
                        context,
                        title: 'להסיר את המוצר?',
                        message:
                            '"${item.name}" יוסר מהמלאי ומהקטלוג — פעולה בלתי הפיכה.',
                        confirmLabel: 'הסר',
                      );
                      if (!ok || !mounted) return;
                      ref
                          .read(storeProductsProvider.notifier)
                          .remove(item.overlayId!);
                      // Drop a stale אזל flag so a future same-name product
                      // starts clean.
                      oosNotifier.markAvailable(item.name);
                      showToast(context, 'המוצר הוסר');
                    },
            ),
          if (hiddenCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: BsTokens.space2),
              child: Text(
                'מוצגות ${shown.length} תוצאות ראשונות (עוד $hiddenCount בקטלוג) — דייקו את החיפוש',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
              ),
            ),
        ],
      ],
    );
  }

  // ── Tab 3 · פורטל (supplier portal — fleet/stock-update moved home, #78) ────
  Widget _portalTab() {
    // #78 — 'ניהול צי רכב' + 'עדכון מלאי' are home quick-actions now; the
    // portal keeps the remaining 6 tiles.
    final tiles = kStorePortalTiles
        .where(
          (t) => t.kind != PortalKind.fleet && t.kind != PortalKind.autoStock,
        )
        .toList();
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(BsTokens.space4),
      mainAxisSpacing: BsTokens.space3,
      crossAxisSpacing: BsTokens.space3,
      childAspectRatio: 1.5,
      children: [
        for (final t in tiles)
          PortalTileButton(
            title: t.title,
            sub: t.sub,
            onTap: () => showPortalSheet(context, t),
          ),
      ],
    );
  }
}

/// Cap on rendered stock rows — the unified catalog holds thousands of
/// products, so a search renders the first N with an honest "more in the
/// catalog" note instead of an unbounded list.
const int _kStockShownCap = 40;

/// One inventory row (#80): a product name + its catalog מק"ט/category when
/// the name maps to a real unified-catalog product (null = honestly absent).
/// A non-null [overlayId] marks a supplier-added (#79) product — removable,
/// tagged with [kSupplierAddedTag].
class _InvItem {
  const _InvItem({required this.name, this.sku, this.category, this.overlayId});
  final String name;
  final String? sku;
  final String? category;
  final String? overlayId;
}

/// nameHe → catalog product over the unified catalog (Lipskey + Polyroll +
/// Huliot) — built once; used to enrich the order-line inventory with real
/// מק"ט + category (אין המצאות).
final Map<String, LipskeyCatalogProduct> _catalogByName = {
  for (final p in kCatalogProducts) p.nameHe: p,
};

// ─────────────────────────────────────────────────────────────────────────────
// #79 · "הוסף מוצר" — the supplier-added products form (writes the persisted
// storeProductsProvider overlay; the inventory list + contractor catalog read)
// ─────────────────────────────────────────────────────────────────────────────

/// Opens the add-product form (#79) as a bottom sheet.
void _showAddProductSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BsTokens.cardLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const Directionality(
      textDirection: TextDirection.rtl,
      child: _AddProductSheet(),
    ),
  );
}

/// The #79 add-product form, per the catalog schema axes (name + מק"ט +
/// category off the real `kCatalogCats` titles). Validation is honest and
/// live: required fields, duplicate name/מק"ט against the overlay
/// ([StoreProductsNotifier.nameTaken]/[StoreProductsNotifier.skuTaken]) AND a
/// name collision with the const catalog — never a silent fake-add.
class _AddProductSheet extends ConsumerStatefulWidget {
  const _AddProductSheet();

  @override
  ConsumerState<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends ConsumerState<_AddProductSheet> {
  final _name = TextEditingController();
  final _sku = TextEditingController();
  int? _catIdx;
  bool _triedSubmit = false;

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    super.dispose();
  }

  String? get _nameError {
    final n = _name.text.trim();
    if (n.isEmpty) return _triedSubmit ? 'חובה להזין שם מוצר' : null;
    if (_catalogByName.containsKey(n)) {
      return 'מוצר בשם הזה כבר קיים בקטלוג';
    }
    if (ref.read(storeProductsProvider.notifier).nameTaken(n)) {
      return 'מוצר בשם הזה כבר נוסף';
    }
    return null;
  }

  String? get _skuError {
    final s = _sku.text.trim();
    if (s.isEmpty) return _triedSubmit ? 'חובה להזין מק"ט' : null;
    if (ref.read(storeProductsProvider.notifier).skuTaken(s)) {
      return 'המק"ט כבר בשימוש';
    }
    return null;
  }

  void _submit() {
    setState(() => _triedSubmit = true);
    if (_nameError != null || _skuError != null || _catIdx == null) {
      if (_catIdx == null) {
        showToast(context, 'בחרו קטגוריה למוצר');
      }
      return;
    }
    final cat = kCatalogCats[_catIdx!];
    final p = ref.read(storeProductsProvider.notifier).add(
          name: _name.text,
          sku: _sku.text,
          category: cat.title,
          categoryEmoji: cat.emoji,
        );
    if (p == null) {
      // Race-safe double-check (the notifier re-validates) — show honestly.
      showToast(context, 'לא ניתן להוסיף — בדקו את השדות');
      return;
    }
    Navigator.of(context).pop();
    showToast(context, 'המוצר "${p.name}" נוסף למלאי ✓');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Keep the form above the keyboard.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          BsTokens.space4,
          BsTokens.space3,
          BsTokens.space4,
          BsTokens.space5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8D8D8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: BsTokens.space3),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '➕ הוסף מוצר חדש',
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'סגירה',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: BsTokens.mutedLight),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'המוצר יישמר, יופיע ברשימת המלאי ויסומן בקטלוג כ"$kSupplierAddedTag"',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
            ),
            const SizedBox(height: BsTokens.space3),
            TextField(
              controller: _name,
              textDirection: TextDirection.rtl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'שם המוצר',
                hintText: 'לדוגמה: ברז גן 1/2"...',
                errorText: _nameError,
                isDense: true,
                filled: true,
                fillColor: BsTokens.bgLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
            ),
            const SizedBox(height: BsTokens.space3),
            TextField(
              controller: _sku,
              textDirection: TextDirection.rtl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'מק"ט',
                hintText: 'קוד המוצר אצלכם...',
                errorText: _skuError,
                isDense: true,
                filled: true,
                fillColor: BsTokens.bgLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
            ),
            const SizedBox(height: BsTokens.space3),
            const Text(
              'קטגוריה',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: BsTokens.space2),
            Wrap(
              spacing: BsTokens.space2,
              runSpacing: BsTokens.space2,
              children: [
                for (var i = 0; i < kCatalogCats.length; i++)
                  _Chip(
                    label:
                        '${kCatalogCats[i].emoji} ${kCatalogCats[i].title}',
                    on: _catIdx == i,
                    onTap: () => setState(() => _catIdx = i),
                  ),
              ],
            ),
            const SizedBox(height: BsTokens.space4),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: BsTokens.brand,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
              ),
              child: const Text(
                '➕ הוסף מוצר',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// #82 · LEGACY supplier settings record (bs.supplier-settings.v1) — F-18: the
// business profile moved to the per-username state/store_profile_store.dart
// (bs.store-profile.v1, the [storeProfileProvider] map). This GLOBAL record
// remains ONLY as (a) the honest one-time migration seed (StoreProfileStore
// reads it on first load; the old key is NOT deleted) and (b) the single
// owner of the שעות-פעילות field, which is outside the StoreProfile
// cross-file contract. Do not add new readers/writers for the other fields.
// ─────────────────────────────────────────────────────────────────────────────

/// The supplier's business profile (#82, LEGACY — see the section note):
/// שם-עסק / ח.פ. / טלפון / כתובת / שעות-פעילות / לוגו (a REAL captured
/// data-URL via [pickTaskPhoto], or null).
class SupplierProfile {
  const SupplierProfile({
    this.businessName = '',
    this.businessId = '',
    this.phone = '',
    this.address = '',
    this.hours = '',
    this.logo,
  });

  factory SupplierProfile.fromJson(Map<String, dynamic> j) => SupplierProfile(
    businessName: j['name'] as String? ?? '',
    businessId: j['bid'] as String? ?? '',
    phone: j['phone'] as String? ?? '',
    address: j['address'] as String? ?? '',
    hours: j['hours'] as String? ?? '',
    logo: j['logo'] as String?,
  );

  final String businessName;
  final String businessId;
  final String phone;
  final String address;
  final String hours;

  /// Logo as a data-URL (`data:image/...;base64,...`) — null = none set.
  final String? logo;

  SupplierProfile copyWith({
    String? businessName,
    String? businessId,
    String? phone,
    String? address,
    String? hours,
    String? Function()? logo,
  }) => SupplierProfile(
    businessName: businessName ?? this.businessName,
    businessId: businessId ?? this.businessId,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    hours: hours ?? this.hours,
    logo: logo != null ? logo() : this.logo,
  );

  Map<String, dynamic> toJson() => {
    'name': businessName,
    'bid': businessId,
    'phone': phone,
    'address': address,
    'hours': hours,
    if (logo != null) 'logo': logo,
  };
}

/// Versioned prefs key (the `bs.*.v1` convention).
const String kSupplierSettingsKey = 'bs.supplier-settings.v1';

/// Persisted supplier profile with the board_auth `_userTouched` load-guard
/// idiom: a user edit made before the async load resolves wins; the late load
/// is dropped. Survives F5 (SharedPreferences = localStorage on web).
class SupplierSettingsNotifier extends StateNotifier<SupplierProfile> {
  SupplierSettingsNotifier({this.persist = true})
      // Default business name = the seeded demo store (verbatim kStores[0]) —
      // no invented business details.
      : super(SupplierProfile(businessName: kStores.first.name)) {
    if (persist) unawaited(_load());
  }

  /// When false (tests) skip SharedPreferences entirely.
  final bool persist;
  bool _userTouched = false;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kSupplierSettingsKey);
      if (raw == null || raw.isEmpty || _userTouched) return;
      final loaded =
          SupplierProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (_userTouched) return;
      state = loaded;
    } on Object catch (_) {
      // Corrupt payload — keep the defaults.
    }
  }

  Future<void> _persist() async {
    if (!persist) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kSupplierSettingsKey, jsonEncode(state.toJson()));
    } on Object catch (_) {/* best-effort */}
  }

  /// Apply a user edit (flags the load-guard) and persist.
  void update(SupplierProfile Function(SupplierProfile) f) {
    _userTouched = true;
    state = f(state);
    unawaited(_persist());
  }
}

final supplierSettingsProvider =
    StateNotifierProvider<SupplierSettingsNotifier, SupplierProfile>(
  (_) => SupplierSettingsNotifier(),
);

/// #82/#87.1 — the supplier-specific settings screen: the business profile,
/// re-wired (F-18) from the legacy GLOBAL record onto the per-username
/// [storeProfileProvider] (`bs.store-profile.v1`; the store seeds itself once
/// from the legacy `bs.supplier-settings.v1` payload — an honest one-time
/// migration that keeps the old key). Gated on a live store session (F-22).
/// The fields are collected locally and committed in ONE awaited save (the
/// worker edit-sheet pattern — no persist-per-keystroke, honest
/// success/failure toasts; the store rolls back on a quota failure). Format
/// validation per task #64 ([validBusinessId] / [validIsraeliMobile]) and a
/// REAL logo capture through the single camera seam ([pickTaskPhoto] —
/// webcam dialog on desktop web, never a bare picker label). Distinct from
/// the contractor's StoreSettingsScreen (a different audience).
class SupplierSettingsScreen extends ConsumerStatefulWidget {
  const SupplierSettingsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const SupplierSettingsScreen());

  @override
  ConsumerState<SupplierSettingsScreen> createState() =>
      _SupplierSettingsScreenState();
}

class _SupplierSettingsScreenState
    extends ConsumerState<SupplierSettingsScreen> {
  // Draft field values — committed in ONE awaited save (F-18 perf: typing
  // only mutates this local state; nothing serializes per keystroke).
  String _businessName = '';
  String _businessId = '';
  String _phone = '';
  String _address = '';

  /// שעות-פעילות is NOT part of the cross-file [StoreProfile] contract
  /// (businessName/phone/address/businessId/logo) — it stays on the legacy
  /// [supplierSettingsProvider] seam as its single remaining owner, and is
  /// committed once on save (so the legacy record — which may still hold the
  /// pre-migration logo bytes — is never re-serialized per keystroke).
  String _hours = '';

  /// #24 idiom — once the user typed, the async-loaded record may no longer
  /// re-seed the drafts (a late load can't clobber fresh input).
  bool _touched = false;

  /// In-flight guard (the F-38 pattern) — no double-save / double-toast.
  bool _saving = false;

  void _draft(VoidCallback apply) {
    _touched = true;
    setState(apply);
  }

  Future<void> _save() async {
    if (_saving) return;
    final session = ref.read(boardAuthProvider);
    if (session == null || session.role != BoardRole.store) return;
    final bid = _businessId.trim();
    final phone = _phone.trim();
    // task #64 — format-only validation; empty fields are honestly optional.
    if (bid.isNotEmpty && !validBusinessId(bid)) {
      showToast(context, 'ח.פ. חייב להכיל 9 ספרות');
      return;
    }
    if (phone.isNotEmpty && !validIsraeliMobile(phone)) {
      showToast(context, 'נייד ישראלי: 10 ספרות שמתחילות ב-05');
      return;
    }
    setState(() => _saving = true);
    final current =
        ref.read(storeProfileProvider)[session.username] ??
            const StoreProfile();
    // ONE awaited commit (F-18) — the store rolls back and returns false on
    // a persist failure (web localStorage quota), so '✓' is never faked.
    final ok = await ref.read(storeProfileProvider.notifier).save(
          session.username,
          StoreProfile(
            businessName: _businessName.trim(),
            businessId: bid,
            phone: phone,
            address: _address.trim(),
            logo: current.logo,
          ),
        );
    // Legacy hours seam — a tiny string, committed once (not per keystroke);
    // the legacy notifier persists best-effort behind its own try/catch.
    ref
        .read(supplierSettingsProvider.notifier)
        .update((s) => s.copyWith(hours: _hours.trim()));
    if (!mounted) return;
    setState(() => _saving = false);
    showToast(
      context,
      ok ? '✓ הפרופיל נשמר' : 'השמירה נכשלה — ייתכן שהלוגו גדול מדי',
    );
  }

  Future<void> _captureLogo() async {
    if (_saving) return;
    final session = ref.read(boardAuthProvider);
    if (session == null || session.role != BoardRole.store) return;
    // REAL capture — webcam dialog on desktop web / camera on mobile,
    // file-picker fallback only on a camera ERROR (services/task_photo.dart).
    // Null = honest cancel, no change.
    final shot = await pickTaskPhoto(context);
    if (shot == null || !mounted) return;
    setState(() => _saving = true);
    final current =
        ref.read(storeProfileProvider)[session.username] ??
            const StoreProfile();
    // F-18 — the heavy field is AWAITED: a quota failure rolls back in the
    // store and reports honestly (no fake 'הלוגו נשמר ✓' that vanishes on F5).
    final ok = await ref.read(storeProfileProvider.notifier).save(
          session.username,
          StoreProfile(
            businessName: current.businessName,
            businessId: current.businessId,
            phone: current.phone,
            address: current.address,
            logo: shot,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    showToast(context, ok ? 'הלוגו נשמר ✓' : 'התמונה גדולה מדי — לא נשמרה');
  }

  Future<void> _removeLogo() async {
    if (_saving) return;
    final session = ref.read(boardAuthProvider);
    if (session == null || session.role != BoardRole.store) return;
    final confirmed = await confirmDestructive(
      context,
      title: 'להסיר את הלוגו?',
      message: 'הלוגו השמור יימחק — ניתן לצלם חדש בכל רגע.',
      confirmLabel: 'הסר',
    );
    if (!confirmed || !mounted) return;
    setState(() => _saving = true);
    final current =
        ref.read(storeProfileProvider)[session.username] ??
            const StoreProfile();
    final ok = await ref.read(storeProfileProvider.notifier).save(
          session.username,
          StoreProfile(
            businessName: current.businessName,
            businessId: current.businessId,
            phone: current.phone,
            address: current.address,
            logo: null,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    showToast(context, ok ? 'הלוגו הוסר' : 'ההסרה נכשלה — נסו שוב');
  }

  @override
  Widget build(BuildContext context) {
    // F-22 · חוק "מבחוץ לא רואים כלום" — gate on a live store session; after
    // logout a stacked instance rebuilds straight into the registration gate.
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.store) {
      return const WelcomeScreen(boardRole: BoardRole.store);
    }
    final username = session.username;
    // F-18 — read ONLY the logged-in username's record off the per-username
    // store; another account's profile is never shown here, and logout never
    // touches another username's data.
    final profile =
        ref.watch(storeProfileProvider.select((m) => m[username])) ??
            const StoreProfile();
    final legacyHours =
        ref.watch(supplierSettingsProvider.select((p) => p.hours));
    // Seed/re-seed the drafts from the persisted record until the user types
    // (#24 — the async load lands after the first build; _ProfileField syncs
    // its controller from `value` while unfocused).
    if (!_touched) {
      _businessName = profile.businessName;
      _businessId = profile.businessId;
      _phone = profile.phone;
      _address = profile.address;
      _hours = legacyHours;
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          leading: IconButton(
            tooltip: 'חזרה',
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            '🏪 הגדרות ספק',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(BsTokens.space4),
          children: [
            const Text(
              'פרופיל עסקי',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            // F-18 — honest copy: an explicit one-commit save replaced the
            // silent best-effort persist-per-keystroke, scoped per-username.
            Text(
              'הפרטים נשמרים לחשבון @$username בלבד — בלחיצת שמירה',
              style:
                  const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
            ),
            const SizedBox(height: BsTokens.space3),
            _ProfileField(
              label: 'שם העסק',
              hint: 'שם העסק...',
              value: _businessName,
              // F-41 — bounded: the override lands in the board AppBar title.
              maxLength: 40,
              onChanged: (v) => _draft(() => _businessName = v),
            ),
            _ProfileField(
              label: 'ח.פ. / ע.מ.',
              hint: '9 ספרות...',
              value: _businessId,
              keyboardType: TextInputType.number,
              // task #64: format-only check — uniqueness deferred to Firebase.
              errorText: _businessId.trim().isEmpty ||
                      validBusinessId(_businessId)
                  ? null
                  : 'ח.פ. חייב להכיל 9 ספרות',
              onChanged: (v) => _draft(() => _businessId = v),
            ),
            _ProfileField(
              label: 'טלפון',
              hint: '05X-XXXXXXX',
              value: _phone,
              keyboardType: TextInputType.phone,
              errorText: _phone.trim().isEmpty || validIsraeliMobile(_phone)
                  ? null
                  : 'נייד ישראלי: 10 ספרות שמתחילות ב-05',
              onChanged: (v) => _draft(() => _phone = v),
            ),
            _ProfileField(
              label: 'כתובת',
              hint: 'רחוב, מספר, עיר...',
              value: _address,
              onChanged: (v) => _draft(() => _address = v),
            ),
            _ProfileField(
              label: 'שעות פעילות',
              hint: 'א׳-ה׳ 07:00-17:00...',
              value: _hours,
              onChanged: (v) => _draft(() => _hours = v),
            ),
            const SizedBox(height: BsTokens.space2),
            // ONE awaited commit (F-18) — honest result toast; the store
            // rolls back on a persist failure. In-flight guard per F-38.
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: BsTokens.brand,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
              ),
              child: Text(
                _saving ? 'שומר…' : '💾 שמור פרופיל',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: BsTokens.space3),

            // ── logo ──
            const Text(
              'לוגו העסק',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: BsTokens.space2),
            _LogoPreview(username: username),
            const SizedBox(height: BsTokens.space2),
            FilledButton(
              // F-18 — awaited capture+persist with rollback; the toast tells
              // the truth (see _captureLogo).
              onPressed: _saving ? null : _captureLogo,
              style: FilledButton.styleFrom(
                backgroundColor: BsTokens.brand,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
              ),
              child: const Text(
                '📷 צלם / העלה לוגו',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
            if (profile.logo != null) ...[
              const SizedBox(height: BsTokens.space2),
              OutlinedButton(
                onPressed: _saving ? null : _removeLogo,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  ),
                ),
                child: const Text(
                  '🗑️ הסר לוגו',
                  style: TextStyle(
                    color: BsTokens.danger,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: BsTokens.space5),
          ],
        ),
      ),
    );
  }
}

/// One persisted profile text field — its controller syncs from the provider
/// when the async load lands (and the field is not being edited), so a value
/// restored from prefs appears without clobbering live typing.
class _ProfileField extends StatefulWidget {
  const _ProfileField({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.keyboardType,
    this.maxLength,
  });

  final String label;
  final String hint;
  final String value;
  final String? errorText;
  final TextInputType? keyboardType;

  /// F-41 — hard input bound (enforced by a [LengthLimitingTextInputFormatter]
  /// too); null = unbounded (the legacy behavior).
  final int? maxLength;
  final ValueChanged<String> onChanged;

  @override
  State<_ProfileField> createState() => _ProfileFieldState();
}

class _ProfileFieldState extends State<_ProfileField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);
  final FocusNode _focus = FocusNode();

  @override
  void didUpdateWidget(covariant _ProfileField old) {
    super.didUpdateWidget(old);
    // External change (the persisted profile loaded) while not editing → sync.
    if (!_focus.hasFocus && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space3),
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        keyboardType: widget.keyboardType,
        textDirection: TextDirection.rtl,
        onChanged: widget.onChanged,
        maxLength: widget.maxLength,
        inputFormatters: widget.maxLength != null
            ? [LengthLimitingTextInputFormatter(widget.maxLength)]
            : null,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          errorText: widget.errorText,
          // Keep the dense layout — the length limit still applies (F-41).
          counterText: '',
          isDense: true,
          filled: true,
          fillColor: BsTokens.cardLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
      ),
    );
  }
}

/// The logged-in username's saved logo (decoded from its data-URL via the
/// shared [decodeDataUrlPhoto] seam) or an honest empty placeholder.
///
/// F-18 perf — a ConsumerWidget with a NARROW `select` on the logo string
/// only (typing in the profile fields no longer re-decodes the logo), and the
/// decode is downscaled (`cacheHeight`) to the 120px preview, not full-res.
class _LogoPreview extends ConsumerWidget {
  const _LogoPreview({required this.username});
  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataUrl =
        ref.watch(storeProfileProvider.select((m) => m[username]?.logo));
    final bytes = decodeDataUrlPhoto(dataUrl);
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: bytes != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(BsTokens.radiusCard),
              child: Image.memory(
                bytes,
                height: 120,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                cacheHeight:
                    (120 * MediaQuery.devicePixelRatioOf(context)).round(),
              ),
            )
          : const Text(
              'אין לוגו עדיין — צלמו או העלו אחד',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// #82 · Supplier notifications bell — per-username, reusing workerNotifsProvider
// ─────────────────────────────────────────────────────────────────────────────

/// The store AppBar bell: unread badge over the logged store account's own
/// per-username feed (the SAME [workerNotifsProvider] store the courier's
/// 'שלח דוח-יומי לחנות' writes into — the write now has its reader).
class _StoreNotifsBell extends ConsumerWidget {
  const _StoreNotifsBell({required this.username});
  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(
      workerNotifsProvider.select((m) => m[username] ?? const <WorkerNotif>[]),
    );
    final unread = notifs.where((n) => !n.read).length;
    return IconButton(
      tooltip: 'התראות',
      onPressed: () => _showStoreNotifsSheet(context, username),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined, color: BsTokens.mutedLight),
          if (unread > 0)
            PositionedDirectional(
              start: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: BoxDecoration(
                  color: BsTokens.danger,
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
                alignment: Alignment.center,
                child: Text(
                  unread > 9 ? '9+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The store notifications sheet — list · mark-all-read · clear (confirmed) ·
/// X close (the worker-board sheet pattern, ≥48dp rows).
Future<void> _showStoreNotifsSheet(BuildContext context, String username) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _StoreNotifsSheet(username: username),
  );
}

class _StoreNotifsSheet extends ConsumerWidget {
  const _StoreNotifsSheet({required this.username});
  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(
      workerNotifsProvider.select((m) => m[username] ?? const <WorkerNotif>[]),
    );
    final unread = notifs.where((n) => !n.read).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scroll) => Container(
          decoration: const BoxDecoration(
            color: BsTokens.cardLight,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(BsTokens.radiusCard),
            ),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.all(BsTokens.space4),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: BsTokens.space3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '🔔 התראות',
                      style: TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'סגירה',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: BsTokens.mutedLight),
                  ),
                ],
              ),
              const SizedBox(height: BsTokens.space2),
              if (notifs.isEmpty)
                // Honest empty state — the feed fills only from real events
                // (דוח יומי מהשליח, עדכוני משלוחים).
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: BsTokens.space5),
                  child: Text(
                    'אין התראות עדיין.\nדוחות מהשליח ועדכוני משלוחים יופיעו כאן.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: BsTokens.mutedLight, fontSize: 13.5),
                  ),
                )
              else ...[
                Row(
                  children: [
                    if (unread > 0)
                      TextButton(
                        onPressed: () => ref
                            .read(workerNotifsProvider.notifier)
                            .markAllRead(username),
                        child: const Text(
                          'סמן הכל כנקרא',
                          style: TextStyle(
                            color: BsTokens.brandDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final ok = await confirmDestructive(
                          context,
                          title: 'לנקות את כל ההתראות?',
                          message: 'כל ההתראות יימחקו — פעולה בלתי הפיכה.',
                          confirmLabel: 'נקה',
                        );
                        if (!ok) return;
                        ref
                            .read(workerNotifsProvider.notifier)
                            .clear(username);
                      },
                      child: const Text(
                        'נקה הכל',
                        style: TextStyle(
                          color: BsTokens.danger,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BsTokens.space1),
                for (final n in notifs)
                  _StoreNotifRow(
                    notif: n,
                    onTap: n.read
                        ? null
                        : () => ref
                            .read(workerNotifsProvider.notifier)
                            .markRead(username, n.id),
                  ),
              ],
              const SizedBox(height: BsTokens.space4),
            ],
          ),
        ),
      ),
    );
  }
}

/// One notification row — unread shows a brand dot; tapping marks it read.
/// Min height keeps the ≥48dp target.
class _StoreNotifRow extends StatelessWidget {
  const _StoreNotifRow({required this.notif, this.onTap});

  final WorkerNotif notif;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notif.read ? BsTokens.cardLight : const Color(0xFFFFF8F2),
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: BsTokens.space3,
            vertical: BsTokens.space2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notif.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: BsTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.title,
                      style: TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight:
                            notif.read ? FontWeight.w600 : FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    if (notif.body.isNotEmpty)
                      Text(
                        notif.body,
                        style: const TextStyle(
                          color: BsTokens.mutedLight,
                          fontSize: 12.5,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      workerNotifAgo(notif.ts),
                      style: const TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notif.read)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: BsTokens.space2,
                    top: 6,
                  ),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: BsTokens.brand,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

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

/// COURIER v2(a) — the store-side delivered card behind the 'נמסרו' filter:
/// the completed order + the REAL POD off the shared fulfillment side-car
/// ([Fulfillment.podPhoto] — the data-URL the courier's אישור-מסירה sheet
/// captures through the camera seam). A real photo renders as a ≥48dp
/// tappable thumbnail (full-screen [showFullPhotoDialog] with an explicit X);
/// no photo keeps the honest 'ללא POD' line — nothing fake is rendered.
class _DeliveredCard extends StatelessWidget {
  const _DeliveredCard({
    required this.order,
    required this.fulfillment,
    required this.onTap,
  });
  final SysOrder order;
  final Fulfillment fulfillment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasPod = fulfillment.podCaptured;
    final signed = fulfillment.podSigned;
    // The REAL captured proof (data-URL → bytes via the shared viewer seam);
    // null for a legacy/corrupt payload — the status pill stays text-only.
    final podBytes = decodeDataUrlPhoto(fulfillment.podPhoto);
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space3),
      child: Material(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        elevation: 1,
        shadowColor: Colors.black26,
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(BsTokens.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '📦 ${order.id}',
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7F5DF),
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill),
                      ),
                      child: const Text(
                        'נמסר ✓',
                        style: TextStyle(
                          color: Color(0xFF1F8A4C),
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
                Text(
                  '${order.items} פריטים · ${fMoney(order.sum)} · הקש לתעודת ליקוט',
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: BsTokens.space3),
                // POD — honest: the REAL captured photo as a tappable thumb
                // (tap → full-screen viewer with an explicit X close), or an
                // explicit 'ללא POD' line (never a faked thumbnail).
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BsTokens.space3,
                    vertical: BsTokens.space2,
                  ),
                  decoration: BoxDecoration(
                    color: hasPod
                        ? const Color(0xFFEAF6EE)
                        : const Color(0xFFF2F3F5),
                    borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                    border: Border.all(
                      color: hasPod
                          ? const Color(0xFF1F8A4C)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (podBytes != null) ...[
                        Semantics(
                          button: true,
                          label: 'הצג אישור מסירה במסך מלא',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => showFullPhotoDialog(
                              context,
                              podBytes,
                              label: '📦 ${order.id} — אישור מסירה',
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                podBytes,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                                // Corrupt payload → honest placeholder, no crash.
                                errorBuilder: (_, __, ___) => Container(
                                  width: 56,
                                  height: 56,
                                  alignment: Alignment.center,
                                  color: const Color(0xFFF2F3F5),
                                  child: const Text(
                                    '📷',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: BsTokens.mutedLight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: BsTokens.space3),
                      ],
                      Expanded(
                        child: Text(
                          hasPod
                              ? '📸 אישור מסירה נשמר ✓${signed ? ' · ✍️ נחתם' : ''}${podBytes != null ? '\nהקש על התמונה לצפייה מלאה' : ''}'
                              : 'ללא POD — לא צולם אישור מסירה',
                          style: TextStyle(
                            color: hasPod
                                ? const Color(0xFF1F8A4C)
                                : BsTokens.mutedLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
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
    required this.item,
    required this.available,
    required this.onToggle,
    this.onRemove,
  });
  final _InvItem item;
  final bool available;
  final VoidCallback onToggle;

  /// Non-null only for a supplier-added overlay product (#79) — removable.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    // #80 — surface the real catalog identity; an unmapped (order-line-only)
    // product honestly shows 'ללא מק"ט' instead of an invented code.
    final idLine = item.sku != null
        ? '🏷️ מק"ט ${item.sku}${item.category != null ? ' · ${item.category}' : ''}'
        : 'ללא מק"ט בקטלוג';
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
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (item.overlayId != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0E3),
                            borderRadius:
                                BorderRadius.circular(BsTokens.radiusPill),
                          ),
                          // The shared overlay tag — the contractor catalog
                          // shows the SAME token on these products.
                          child: const Text(
                            kSupplierAddedTag,
                            style: TextStyle(
                              color: BsTokens.brandDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    idLine,
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 11.5,
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
            if (onRemove != null)
              IconButton(
                tooltip: 'הסר מוצר',
                onPressed: onRemove,
                icon: const Icon(
                  Icons.delete_outline,
                  color: BsTokens.mutedLight,
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
