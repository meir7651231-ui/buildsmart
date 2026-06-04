import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/data/sections.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/screens/regression_panel_screen.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/dial.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// BS dial — port of app/src/components/bs/bs-dial.tsx.
/// L1 = 5 personas. L2+ = walk active persona's section tree along
/// the drill path. Tapping a leaf with no children → toast, EXCEPT the
/// manager 📊 dashboard `md-*` leaves, which open a real metric panel inline
/// (R2 — dial-drill, no new screen; numbers derived in manager_dashboard.dart).
class BsDialWidget extends ConsumerWidget {
  const BsDialWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personaId = ref.watch(activePersonaProvider);

    // L1 — 5 personas.
    if (personaId == null) {
      return DialColumn(
        children: [
          for (final p in kPersonas)
            DialRow(
              label: p.title,
              emoji: p.emoji,
              icon: Icons.circle,
              onTap:
                  () => ref.read(activePersonaProvider.notifier).state = p.id,
            ),
        ],
      );
    }

    final persona = kPersonas.firstWhere((p) => p.id == personaId);
    final path = ref.watch(bsDrillPathProvider);
    final walked = walkBsDrill(personaId, path);
    final openMetric = ref.watch(bsMetricLeafProvider);
    final openOrder = ref.watch(bsOrderLeafProvider);
    final openCustomer = ref.watch(bsCustomerLeafProvider);
    final openManage = ref.watch(bsManageLeafProvider);
    final openStore = ref.watch(bsStoreLeafProvider);
    final openCourier = ref.watch(bsCourierLeafProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Inline metric panel for the open `md-*` leaf — rises above the dial,
        // stays within the dial overlay (no navigation).
        if (openMetric != null) ...[
          _ManagerMetricPanel(
            leafId: openMetric,
            onClose: () => ref.read(bsMetricLeafProvider.notifier).state = null,
          ),
          const SizedBox(height: BsTokens.space3),
        ],
        // Inline order-list panel for the open `mo-*` leaf — the REAL orders in
        // that one order-flow stage (M2). Same dial-overlay placement (R2).
        if (openOrder != null) ...[
          _ManagerOrderPanel(
            leafId: openOrder,
            onClose: () => ref.read(bsOrderLeafProvider.notifier).state = null,
          ),
          const SizedBox(height: BsTokens.space3),
        ],
        // Inline customer-list panel for the open `mc-*` leaf — the REAL
        // customers in that one status filter (M3). Same dial-overlay placement
        // (R2). Mutually exclusive with the metric & order panels.
        if (openCustomer != null) ...[
          _ManagerCustomerPanel(
            leafId: openCustomer,
            onClose:
                () => ref.read(bsCustomerLeafProvider.notifier).state = null,
          ),
          const SizedBox(height: BsTokens.space3),
        ],
        // Inline DATA panel for the open data-view `mm-*` leaf — the REAL
        // categories (`mm-cats`) or contractor-app config rows (`mm-settings`)
        // from the legacy `renderMgrManage` (M4). Same dial-overlay placement
        // (R2). Mutually exclusive with the metric / order / customer panels.
        if (openManage != null) ...[
          _ManagerManagePanel(
            leafId: openManage,
            onClose: () => ref.read(bsManageLeafProvider.notifier).state = null,
          ),
          const SizedBox(height: BsTokens.space3),
        ],
        // Inline LIVE order panel for the open 🏪 store leaf (`so-*`) — the REAL
        // orders at that stage off the SHARED engine + an advance button (W2).
        if (openStore != null) ...[
          _LiveStageOrderPanel(
            emoji: '🏪',
            stage: kStoreOrderLeafStage[openStore] ?? '',
            title: _leafTitle(personaId, path, openStore),
            onClose: () => ref.read(bsStoreLeafProvider.notifier).state = null,
          ),
          const SizedBox(height: BsTokens.space3),
        ],
        // Inline LIVE order panel for the open 🛵 courier leaf — the REAL orders
        // at that stage off the SHARED engine + an advance button (W2).
        if (openCourier != null) ...[
          _LiveStageOrderPanel(
            emoji: '🛵',
            stage: kCourierOrderLeafStage[openCourier] ?? '',
            title: _leafTitle(personaId, path, openCourier),
            onClose:
                () => ref.read(bsCourierLeafProvider.notifier).state = null,
          ),
          const SizedBox(height: BsTokens.space3),
        ],
        DialColumn(
          children: [
            // Persona anchor — tap to pop back to L1.
            DialRow(
              label: persona.title,
              emoji: persona.emoji,
              icon: Icons.circle,
              active: true,
              onTap: () {
                ref.read(activePersonaProvider.notifier).state = null;
                ref.read(bsDrillPathProvider.notifier).state = const [];
                ref.read(bsMetricLeafProvider.notifier).state = null;
                ref.read(bsOrderLeafProvider.notifier).state = null;
                ref.read(bsCustomerLeafProvider.notifier).state = null;
                ref.read(bsManageLeafProvider.notifier).state = null;
                ref.read(bsStoreLeafProvider.notifier).state = null;
                ref.read(bsCourierLeafProvider.notifier).state = null;
              },
            ),
            // One anchor per drill step — tap pops to that depth.
            for (var i = 0; i < walked.anchors.length; i++)
              DialRow(
                label: walked.anchors[i].title,
                emoji: walked.anchors[i].emoji,
                icon: Icons.circle,
                active: true,
                onTap: () {
                  ref.read(bsDrillPathProvider.notifier).state = path.sublist(
                    0,
                    i,
                  );
                  ref.read(bsMetricLeafProvider.notifier).state = null;
                  ref.read(bsOrderLeafProvider.notifier).state = null;
                  ref.read(bsCustomerLeafProvider.notifier).state = null;
                  ref.read(bsManageLeafProvider.notifier).state = null;
                  ref.read(bsStoreLeafProvider.notifier).state = null;
                  ref.read(bsCourierLeafProvider.notifier).state = null;
                },
              ),
            // Current items at this depth.
            for (final s in walked.current)
              DialRow(
                label: s.title,
                emoji: s.emoji,
                icon: Icons.circle,
                // Highlight the leaf whose inline panel (metric, order list,
                // customer list or manage data) is currently open.
                active:
                    s.id == openMetric ||
                    s.id == openOrder ||
                    s.id == openCustomer ||
                    s.id == openManage ||
                    s.id == openStore ||
                    s.id == openCourier,
                onTap: () => _onLeafTap(context, ref, s, path),
              ),
          ],
        ),
      ],
    );
  }

  /// Close every inline leaf panel (the M1–M4 manager panels + the W2 store /
  /// courier panels). Every leaf branch calls this first, then sets the ONE
  /// provider it owns — so at most one inline panel is ever open (R2; all panels
  /// mutually exclusive, including across personas).
  void _closeAllPanels(WidgetRef ref) {
    ref.read(bsMetricLeafProvider.notifier).state = null;
    ref.read(bsOrderLeafProvider.notifier).state = null;
    ref.read(bsCustomerLeafProvider.notifier).state = null;
    ref.read(bsManageLeafProvider.notifier).state = null;
    ref.read(bsStoreLeafProvider.notifier).state = null;
    ref.read(bsCourierLeafProvider.notifier).state = null;
  }

  void _onLeafTap(
    BuildContext context,
    WidgetRef ref,
    Section s,
    List<String> path,
  ) {
    if (s.hasChildren) {
      _closeAllPanels(ref);
      ref.read(bsDrillPathProvider.notifier).state = [...path, s.title];
    } else if (kManagerMetricLeafIds.contains(s.id)) {
      // M1 — toggle the inline metric panel for this dashboard leaf.
      final cur = ref.read(bsMetricLeafProvider);
      _closeAllPanels(ref);
      ref.read(bsMetricLeafProvider.notifier).state = cur == s.id ? null : s.id;
    } else if (kManagerOrderLeafIds.contains(s.id)) {
      // M2 — toggle the inline order-list panel for this `mo-*` stage leaf.
      final cur = ref.read(bsOrderLeafProvider);
      _closeAllPanels(ref);
      ref.read(bsOrderLeafProvider.notifier).state = cur == s.id ? null : s.id;
    } else if (kManagerCustomerLeafIds.contains(s.id)) {
      // M3 — toggle the inline customer-list panel for this `mc-*` status leaf.
      final cur = ref.read(bsCustomerLeafProvider);
      _closeAllPanels(ref);
      ref.read(bsCustomerLeafProvider.notifier).state =
          cur == s.id ? null : s.id;
    } else if (kManagerManageDataLeafIds.contains(s.id)) {
      // M4 — toggle the inline DATA panel for this `mm-*` data-view leaf
      // (`mm-cats` · `mm-settings`).
      final cur = ref.read(bsManageLeafProvider);
      _closeAllPanels(ref);
      ref.read(bsManageLeafProvider.notifier).state = cur == s.id ? null : s.id;
    } else if (kStoreOrderLeafIds.contains(s.id)) {
      // W2 — toggle the inline LIVE order panel for this 🏪 store stage leaf
      // (`so-new` · `so-prep` · `so-ready`). Reads the SHARED engine; its rows
      // carry an advance button that writes the same engine the manager reads.
      final cur = ref.read(bsStoreLeafProvider);
      _closeAllPanels(ref);
      ref.read(bsStoreLeafProvider.notifier).state = cur == s.id ? null : s.id;
    } else if (kCourierOrderLeafIds.contains(s.id)) {
      // W2 — toggle the inline LIVE order panel for this 🛵 courier stage leaf
      // (`pickup` · `ca-pickup` · `ca-transit` · `ca-delivered`). Same shared
      // engine + advance write the store uses, on the BACK of the flow.
      final cur = ref.read(bsCourierLeafProvider);
      _closeAllPanels(ref);
      ref.read(bsCourierLeafProvider.notifier).state =
          cur == s.id ? null : s.id;
    } else if (kManagerManageActionLeafIds.containsKey(s.id)) {
      // M4 — the action-only `mm-*` leaves (`mm-trees` · `mm-brands`). The
      // legacy body is a `prompt()`-driven server edit (add/edit/delete an
      // accessory or brand against a backend that does not exist in this port),
      // so — exactly as the app stubs other server calls — we fire a toast with
      // the leaf's REAL action label (the verbatim legacy section sub-title,
      // @index.html:16653/16687), NOT "בבנייה". No data view is invented.
      _closeAllPanels(ref);
      showToast(context, '${s.emoji} ${kManagerManageActionLeafIds[s.id]}');
    } else if (s.id == 'mm-regression') {
      ref.read(openDialProvider.notifier).state = OpenDial.none;
      Navigator.of(context).push(RegressionPanelScreen.route());
    } else {
      showToast(context, '${s.title} — בבנייה');
    }
  }
}

/// Resolve a leaf's verbatim Hebrew title from its persona's section tree by id,
/// searching the whole tree (the open leaf always belongs to it). Falls back to
/// the id if not found. Used so the W2 store/courier panels show the leaf's
/// canonical title (the verbatim `kStoreSections`/`kCourierSections` string)
/// rather than re-deriving it. [path] is accepted for symmetry with the call
/// site but the recursive search makes it unnecessary.
String _leafTitle(String persona, List<String> path, String leafId) {
  String? search(List<Section> nodes) {
    for (final s in nodes) {
      if (s.id == leafId) return s.title;
      final hit = search(s.children);
      if (hit != null) return hit;
    }
    return null;
  }

  return search(kPersonaSections[persona] ?? const <Section>[]) ?? leafId;
}

/// The five 📊 dashboard leaves wired to real derived numbers (M1).
const Set<String> kManagerMetricLeafIds = {
  'md-open-orders',
  'md-catalog',
  'md-accessories',
  'md-available',
  'md-stores',
};

/// The six 📦 הזמנות leaves (M2) — each maps to ONE order-flow stage. Tapping a
/// leaf opens that stage's REAL orders inline (an order-list panel; R2). The
/// stage strings are exactly [kManagerOrderFlow] (@index.html:16943); the leaf
/// ids + their Hebrew labels are `kManagerSections` → `m-orders` in
/// sections.dart, themselves verbatim from the legacy `ORDER_STAGE` map
/// (@index.html:12041-12048: new=התקבלה · preparing=בהכנה · ready=מוכן לאיסוף ·
/// pickup=נאסף · transit=בדרך לאתר · delivered=נמסר ✓).
const Map<String, String> kManagerOrderLeafStage = {
  'mo-new': 'new',
  'mo-preparing': 'preparing',
  'mo-ready': 'ready',
  'mo-pickup': 'pickup',
  'mo-transit': 'transit',
  'mo-delivered': 'delivered',
};

/// The set of order-status leaf ids (M2) — the keys of [kManagerOrderLeafStage].
final Set<String> kManagerOrderLeafIds = kManagerOrderLeafStage.keys.toSet();

/// The two 👥 לקוחות leaves (M3) — each maps to ONE customer status filter
/// (the legacy `status` field @index.html:16562: `pct>=90?'low':pct>0?'live'`).
/// Tapping a leaf opens an INLINE customer-list panel (R2) listing the REAL
/// customers in that status from `mgrCustomerList` (manager_dashboard.dart). The
/// leaf ids + Hebrew labels are `kManagerSections` → `m-customers` in
/// sections.dart, themselves verbatim from the legacy `mc-pill` labels
/// (@index.html:16592: live=פעיל · low=אשראי גבוה).
const Map<String, String> kManagerCustomerLeafStatus = {
  'mc-live': 'live',
  'mc-low': 'low',
};

/// The set of customer-status leaf ids (M3) — keys of
/// [kManagerCustomerLeafStatus].
final Set<String> kManagerCustomerLeafIds =
    kManagerCustomerLeafStatus.keys.toSet();

/// The two 🛠️ ניהול DATA-VIEW leaves (M4). Each opens an INLINE panel showing
/// the REAL data the legacy `renderMgrManage` renders for that accordion
/// section (no `prompt()` editor — those are server actions; see
/// [kManagerManageActionLeafIds]):
///   • `mm-cats`     → SECTION 3 (@index.html:16715-16730): the catalog
///     categories + each one's product count, from [kManagerCatalogCategories].
///   • `mm-settings` → SECTION 4 (@index.html:16733-16740): the three
///     contractor-app config rows (express surcharge / credit ceiling / VAT).
/// The leaf ids + Hebrew labels are `kManagerSections` → `m-manage` in
/// sections.dart, verbatim from the legacy `mmSection` calls.
const Set<String> kManagerManageDataLeafIds = {'mm-cats', 'mm-settings'};

/// The two 🛠️ ניהול ACTION-ONLY leaves (M4) → their REAL action label. The
/// legacy body of each is a `prompt()`-driven server edit (add/edit/delete an
/// accessory or a brand, then re-render — a backend mutation with no equivalent
/// in this port), so tapping the leaf fires a toast with this verbatim label
/// (the legacy `mmSection` sub-title) instead of opening a (necessarily
/// invented) data view. `mm-regression` is NOT here — it routes to its screen.
/// Labels are VERBATIM from the legacy (@index.html:16653 / :16687).
const Map<String, String> kManagerManageActionLeafIds = {
  'mm-trees': 'עריכת האביזרים המשלימים של כל מוצר',
  'mm-brands': 'עריכת המותגים והמחירים של כל מוצר',
};

// ───────────────────────────────────────────────────────────────────────────
//  CROSS-PERSONA WIRING W2 — 🏪 חנות ספק (store) order-stage leaves.
//  The store owns the FRONT of the flow (new → preparing → ready). Its
//  📥 הזמנות leaves open an INLINE order panel over the SHARED
//  `ordersEngineProvider` with an advance button that drives `.advance(id)` on
//  the same engine the manager reads — so a store approve/pick/ready reflows the
//  manager's live counts + the order's stage everywhere (no manual refresh).
// ───────────────────────────────────────────────────────────────────────────

/// The three 🏪 חנות ספק → 📥 הזמנות leaves (W2) the STORE acts on, each mapped
/// to ONE order-flow stage the store owns. The leaf ids + their Hebrew titles
/// are `kStoreSections` → `s-orders` in sections.dart (verbatim `soChip`
/// filters @index.html:17310-17313); the stages are exactly the first three of
/// [kManagerOrderFlow]:
///   • `so-new`   (לאישור)  → stage `new`       — approve → preparing.
///   • `so-prep`  (בהכנה)   → stage `preparing` — pick    → ready.
///   • `so-ready` (מוכנות)  → stage `ready`     — hand off → pickup (to courier).
const Map<String, String> kStoreOrderLeafStage = {
  'so-new': 'new',
  'so-prep': 'preparing',
  'so-ready': 'ready',
};

/// The set of store order-stage leaf ids (W2) — keys of [kStoreOrderLeafStage].
final Set<String> kStoreOrderLeafIds = kStoreOrderLeafStage.keys.toSet();

/// The 🛵 שליח (courier) leaves (W2) the COURIER acts on, each mapped to ONE
/// order-flow stage the courier owns (the BACK of the flow:
/// ready → pickup → transit → delivered). The leaf ids + Hebrew titles are
/// `kCourierSections` in sections.dart (verbatim):
///   • `pickup`       (משלוחים ממתינים לאיסוף) → stage `ready`   — pick up → pickup.
///   • `ca-pickup`    (אספתי מהחנות)           → stage `pickup`  — depart  → transit.
///   • `ca-transit`   (יצאתי לדרך)             → stage `transit` — deliver → delivered.
///   • `ca-delivered` (נמסר ללקוח)            → stage `delivered` — terminal (no advance).
/// `pickup` (stage `ready`) is the live HANDOFF point: the store's `so-ready`
/// leaf shows the same `ready` orders, so a store "מסור לשליח" advance makes the
/// order appear under the courier's pickup leaf — and the manager sees it all.
const Map<String, String> kCourierOrderLeafStage = {
  'pickup': 'ready',
  'ca-pickup': 'pickup',
  'ca-transit': 'transit',
  'ca-delivered': 'delivered',
};

/// The set of courier order-stage leaf ids (W2) — keys of
/// [kCourierOrderLeafStage].
final Set<String> kCourierOrderLeafIds = kCourierOrderLeafStage.keys.toSet();

/// The advance-button label per order-flow stage, from the ACTING role's point
/// of view (the verb that moves an order OUT of this stage). Used by the store
/// and courier live panels; `delivered` has no entry (terminal — the panel shows
/// the "✓ נמסר" completed note instead of a button).
///   new→אשר הזמנה · preparing→סמן מוכן · ready→מסור לשליח · pickup→יצאתי לדרך ·
///   transit→סמן נמסר.
const Map<String, String> kStageAdvanceLabel = {
  'new': 'אשר הזמנה',
  'preparing': 'סמן מוכן',
  'ready': 'מסור לשליח',
  'pickup': 'יצאתי לדרך',
  'transit': 'סמן נמסר',
};

/// Inline panel that shows a manager dashboard leaf's REAL derived number plus
/// a one-line note of what it counts. Pure presentation over [managerAnalytics]
/// (manager_dashboard.dart) — every figure is verbatim-derived from index.html.
class _ManagerMetricPanel extends StatelessWidget {
  const _ManagerMetricPanel({required this.leafId, required this.onClose});

  final String leafId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final m = _metricFor(leafId);
    final theme = Theme.of(context);

    return Semantics(
      label: '${m.emoji} ${m.title}: ${m.value}',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space4,
          vertical: BsTokens.space3,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          boxShadow: BsTokens.circleShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(m.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: Text(
                    m.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(BsTokens.radiusCircle),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: BsTokens.mutedLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: BsTokens.space2),
            Text(
              m.value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: BsTokens.brand,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              m.note,
              style: theme.textTheme.bodySmall?.copyWith(
                color: BsTokens.mutedLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _Metric _metricFor(String id) {
    const a = managerAnalytics;
    switch (id) {
      case 'md-open-orders':
        return _Metric(
          emoji: '🚚',
          title: 'הזמנות פתוחות',
          value: '${a.openOrders}',
          note: 'הזמנות שטרם נמסרו (מתוך ${a.orders.length})',
        );
      case 'md-catalog':
        return _Metric(
          emoji: '📦',
          title: 'מוצרים בקטלוג',
          value: '${a.catalogCount}',
          note: 'מוצרים שאינם אביזרים נלווים',
        );
      case 'md-accessories':
        return _Metric(
          emoji: '🧰',
          title: 'אביזרים נלווים',
          value: '${a.accessoryCount}',
          note: 'מוצרי אביזרים נלווים בקטלוג',
        );
      case 'md-available':
        return _Metric(
          emoji: '✅',
          title: 'זמינים כעת',
          value: '${a.availableCount}',
          note: 'מוצרים זמינים במלאי מתוך ${a.totalProducts}',
        );
      case 'md-stores':
        return _Metric(
          emoji: '🏪',
          title: 'חנויות פעילות',
          value: a.storesLabel,
          note: 'חנויות פעילות מתוך סך החנויות',
        );
      default:
        return const _Metric(emoji: '📊', title: '', value: '', note: '');
    }
  }
}

class _Metric {
  const _Metric({
    required this.emoji,
    required this.title,
    required this.value,
    required this.note,
  });
  final String emoji;
  final String title;
  final String value;
  final String note;
}

/// The Hebrew display-name per order-flow stage — VERBATIM from the legacy
/// `ORDER_STAGE` map (@index.html:12041-12048; `ORDER_STAGE[st].label`). Same
/// strings as the `mo-*` leaf titles in sections.dart, kept here so the panel
/// header reads the canonical stage label.
const Map<String, String> _kOrderStageLabel = {
  'new': 'התקבלה',
  'preparing': 'בהכנה',
  'ready': 'מוכן לאיסוף',
  'pickup': 'נאסף',
  'transit': 'בדרך לאתר',
  'delivered': 'נמסר ✓',
};

/// Inline panel that lists the REAL orders in ONE order-flow stage (M2). The
/// leaf's stage is [kManagerOrderLeafStage]; the orders come from
/// [kManagerOrderSeed] filtered to that stage (every datum verbatim from
/// index.html). Each row shows id / who · site / items · sum, mirroring the
/// legacy `mo-card` (@index.html:17001-17014). When the stage has no orders
/// (pickup · delivered in the seed) it shows the legacy empty text
/// `לא נמצאו הזמנות תואמות.` (@index.html:16986, the `md-empty` line).
class _ManagerOrderPanel extends StatelessWidget {
  const _ManagerOrderPanel({required this.leafId, required this.onClose});

  final String leafId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stage = kManagerOrderLeafStage[leafId] ?? '';
    final label = _kOrderStageLabel[stage] ?? stage;
    final orders = kManagerOrderSeed
        .where((o) => o.stage == stage)
        .toList(growable: false);

    return Semantics(
      label: '📦 $label: ${orders.length} הזמנות',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space4,
          vertical: BsTokens.space3,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          boxShadow: BsTokens.circleShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📦', style: TextStyle(fontSize: 20)),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                // The stage's order count.
                Text(
                  '${orders.length}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: BsTokens.brand,
                  ),
                ),
                const SizedBox(width: BsTokens.space2),
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(BsTokens.radiusCircle),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: BsTokens.mutedLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: BsTokens.space2),
            if (orders.isEmpty)
              Text(
                'לא נמצאו הזמנות תואמות.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: BsTokens.mutedLight,
                ),
              )
            else
              for (final o in orders) ...[
                _OrderRow(order: o),
                if (o != orders.last) const SizedBox(height: BsTokens.space2),
              ],
          ],
        ),
      ),
    );
  }
}

/// One order row inside [_ManagerOrderPanel] — `📦 id` / `who · site` /
/// `items פריטים · ₪sum`, mirroring the legacy `mo-card` body
/// (@index.html:17003-17009).
class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});

  final ManagerOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📦 ${order.id}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          '${order.who} · ${order.site}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          '${order.items} פריטים · ₪${order.sum}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: BsTokens.mutedLight,
          ),
        ),
      ],
    );
  }
}

/// Group an integer with comma thousands-separators — mirrors the legacy
/// `Number.toLocaleString()` (en) used in the customer cards
/// (@index.html:16602: `₪'+c.spent.toLocaleString()`), so `3150 → 3,150`.
String _grouped(int n) {
  final s = n.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return n < 0 ? '-$b' : b.toString();
}

/// The Hebrew pill label per customer status — VERBATIM from the legacy
/// `renderMgrCustomers` (@index.html:16592:
/// `c.status==='low'?'אשראי גבוה':c.status==='off'?'לא פעיל':'פעיל'`). Same
/// strings as the `mc-*` leaf titles in sections.dart, kept here so the panel
/// header reads the canonical status label.
const Map<String, String> _kCustomerStatusLabel = {
  'live': 'פעיל',
  'low': 'אשראי גבוה',
  'off': 'לא פעיל',
};

/// One customer's view-model — the [ManagerCustomer] aggregate plus the two
/// derived fields the legacy card renders that are NOT on the aggregate:
/// `pct` (credit-utilisation %) and `sites` (distinct build-site count), both
/// computed exactly as the legacy `mgrCustomerList` does (@index.html:16559-16562).
class _CustomerView {
  const _CustomerView({required this.customer, required this.pct, required this.sites});

  final ManagerCustomer customer;
  final int pct;
  final int sites;

  /// @legacy index.html:16562 — `pct>=90?'low':pct>0?'live':'off'`.
  String get status => pct >= 90 ? 'low' : (pct > 0 ? 'live' : 'off');
}

/// Build the customer view-models for ONE status filter, sorted by spend desc
/// (the order [mgrCustomerList] already returns). `pct` is
/// `min(100, round(spent/credit*100))` and `sites` is the distinct-site count
/// per buyer in [kManagerOrderSeed] — both verbatim from the legacy derivation
/// (@index.html:16554,16559-16560).
List<_CustomerView> _customersForStatus(String status) {
  // Distinct build sites per buyer (legacy `byName[nm].sites` set @16554).
  final sitesByBuyer = <String, Set<String>>{};
  for (final o in kManagerOrderSeed) {
    (sitesByBuyer[o.who] ??= <String>{}).add(o.site);
  }
  final out = <_CustomerView>[];
  for (final c in mgrCustomerList()) {
    final pct = c.creditLimit == 0
        ? 0
        : ((c.totalSpend / c.creditLimit) * 100).round().clamp(0, 100);
    final view = _CustomerView(
      customer: c,
      pct: pct,
      sites: sitesByBuyer[c.name]?.length ?? 0,
    );
    if (view.status == status) out.add(view);
  }
  return out;
}

/// Inline panel that lists the REAL customers in ONE status filter (M3). The
/// leaf's status is [kManagerCustomerLeafStatus]; the customers come from
/// [mgrCustomerList] (manager_dashboard.dart — itself grouping index.html's
/// SYS_ORDERS_SEED by buyer) filtered to that status. Each row mirrors the
/// legacy `mc-card` (@index.html:16593-16604): `👷 name`, `orders הזמנות ·
/// sites אתרים`, the status pill, and the credit line `ניצול אשראי: ₪spent /
/// ₪credit (pct%)`. When the status has no customers it shows the legacy empty
/// text `לא נמצאו קבלנים תואמים.` (@index.html:16586).
class _ManagerCustomerPanel extends StatelessWidget {
  const _ManagerCustomerPanel({required this.leafId, required this.onClose});

  final String leafId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = kManagerCustomerLeafStatus[leafId] ?? '';
    final label = _kCustomerStatusLabel[status] ?? status;
    final customers = _customersForStatus(status);

    return Semantics(
      label: '👥 $label: ${customers.length} קבלנים',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space4,
          vertical: BsTokens.space3,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          boxShadow: BsTokens.circleShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('👥', style: TextStyle(fontSize: 20)),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                // The status's customer count.
                Text(
                  '${customers.length}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: BsTokens.brand,
                  ),
                ),
                const SizedBox(width: BsTokens.space2),
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(BsTokens.radiusCircle),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: BsTokens.mutedLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: BsTokens.space2),
            if (customers.isEmpty)
              Text(
                'לא נמצאו קבלנים תואמים.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: BsTokens.mutedLight,
                ),
              )
            else
              for (final v in customers) ...[
                _CustomerRow(view: v),
                if (v != customers.last) const SizedBox(height: BsTokens.space3),
              ],
          ],
        ),
      ),
    );
  }
}

/// One customer row inside [_ManagerCustomerPanel] — mirrors the legacy
/// `mc-card` body (@index.html:16593-16604): `👷 name` + `orders הזמנות ·
/// sites אתרים` + the status pill on the top line, then the credit line
/// `ניצול אשראי: ₪spent / ₪credit (pct%)`.
class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.view});

  final _CustomerView view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = view.customer;
    final statusLabel = _kCustomerStatusLabel[view.status] ?? view.status;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('👷', style: TextStyle(fontSize: 18)),
            const SizedBox(width: BsTokens.space2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${c.orderCount} הזמנות · ${view.sites} אתרים',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: BsTokens.mutedLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: BsTokens.space2),
            Text(
              statusLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: BsTokens.brand,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'ניצול אשראי: ₪${_grouped(c.totalSpend)} / ₪${_grouped(c.creditLimit)} (${view.pct}%)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: BsTokens.mutedLight,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//  M4 — 🛠️ ניהול data-view leaves (mm-cats · mm-settings).
// ───────────────────────────────────────────────────────────────────────────

/// The contractor-app config constants the legacy 🛠️ ניהול → ⚙️ הגדרות
/// אפליקציה section (`mmSection('settings',…)`, @index.html:16733-16740) shows.
/// VERBATIM from index.html: `EXPRESS_FEE=80` (@11961) · `creditLimit=50000`
/// (@11963) · `VAT_RATE=0.18` (@11941). They are the legacy editable globals;
/// the panel renders them read-only (the legacy `prompt()` editors are server
/// actions with no equivalent here — R8: no invented mutation).
const int _kExpressFee = 80;
const int _kCreditLimit = 50000;
const double _kVatRate = 0.18;

/// One static config row inside the ⚙️ הגדרות אפליקציה panel — mirrors the
/// legacy `mmSettingRow(label,val)` (@index.html:16758-16763): a label on the
/// start edge, the value on the end edge.
class _ManageSettingRow {
  const _ManageSettingRow(this.label, this.value);
  final String label;
  final String value;
}

/// Inline panel for a 🛠️ ניהול DATA-VIEW leaf (M4) — `mm-cats` or
/// `mm-settings`. Pure presentation over data ported verbatim from the legacy
/// `renderMgrManage` (@index.html:16645-16743); NO datum is invented and the
/// legacy `prompt()` editors (server actions) are intentionally NOT reproduced.
///   • `mm-cats`     → the catalog categories + each one's product count, from
///     [kManagerCatalogCategories] (the same TREES-by-`cat` tally the legacy
///     SECTION 3 builds @16716-16728), with the header `קטגוריות פעילות (N)`
///     and the legacy hint line.
///   • `mm-settings` → the three contractor-app config rows (express surcharge /
///     credit ceiling / VAT) from the legacy constants, with the legacy hint.
class _ManagerManagePanel extends StatelessWidget {
  const _ManagerManagePanel({required this.leafId, required this.onClose});

  final String leafId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCats = leafId == 'mm-cats';

    // Header emoji + title + (for cats) the live category count, all verbatim
    // from the legacy `mmSection` call for this section.
    final emoji = isCats ? '🗂️' : '⚙️';
    final title = isCats ? 'קטגוריות' : 'הגדרות אפליקציה';
    final headerCount = isCats ? '${kManagerCatalogCategories.length}' : null;

    return Semantics(
      label:
          '$emoji $title${headerCount != null ? ': $headerCount' : ''}',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space4,
          vertical: BsTokens.space3,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          boxShadow: BsTokens.circleShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (headerCount != null) ...[
                  Text(
                    headerCount,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: BsTokens.brand,
                    ),
                  ),
                  const SizedBox(width: BsTokens.space2),
                ],
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(BsTokens.radiusCircle),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: BsTokens.mutedLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: BsTokens.space2),
            if (isCats) ..._catsBody(theme) else ..._settingsBody(theme),
          ],
        ),
      ),
    );
  }

  /// SECTION 3 body — `קטגוריות פעילות (N)` then one row per category
  /// (`name` + `N מוצרים`), then the legacy hint. Counts are the real ported
  /// tally [kManagerCatalogCategories] (@index.html:16716-16728).
  List<Widget> _catsBody(ThemeData theme) {
    final entries = kManagerCatalogCategories.entries.toList(growable: false);
    return [
      Text(
        'קטגוריות פעילות (${entries.length})',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: BsTokens.space2),
      for (final e in entries) ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                e.key,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: BsTokens.space2),
            Text(
              '${e.value} מוצרים',
              style: theme.textTheme.bodySmall?.copyWith(
                color: BsTokens.mutedLight,
              ),
            ),
          ],
        ),
        if (e != entries.last) const SizedBox(height: 2),
      ],
      const SizedBox(height: BsTokens.space2),
      Text(
        'שינוי שם קטגוריה מעדכן את כל המוצרים שבה.',
        style: theme.textTheme.bodySmall?.copyWith(color: BsTokens.mutedLight),
      ),
    ];
  }

  /// SECTION 4 body — the three config rows then the legacy hint. Values are
  /// verbatim legacy constants; the credit line uses comma grouping to mirror
  /// the legacy `creditLimit.toLocaleString()` (@index.html:16736).
  List<Widget> _settingsBody(ThemeData theme) {
    final rows = <_ManageSettingRow>[
      const _ManageSettingRow('תוספת משלוח אקספרס', '₪$_kExpressFee'),
      _ManageSettingRow('מסגרת אשראי לקבלן', '₪${_grouped(_kCreditLimit)}'),
      _ManageSettingRow('שיעור מע״מ', '${(_kVatRate * 100).round()}%'),
    ];
    return [
      for (final r in rows) ...[
        Row(
          children: [
            Expanded(
              child: Text(
                r.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: BsTokens.space2),
            Text(
              r.value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: BsTokens.brand,
              ),
            ),
          ],
        ),
        if (r != rows.last) const SizedBox(height: BsTokens.space2),
      ],
      const SizedBox(height: BsTokens.space2),
      Text(
        'המע״מ קבוע לפי חוק (18%). תוספת האקספרס והאשראי נראים מיד בעגלת הקבלן.',
        style: theme.textTheme.bodySmall?.copyWith(color: BsTokens.mutedLight),
      ),
    ];
  }
}

// ───────────────────────────────────────────────────────────────────────────
//  W2 — the LIVE store/courier order panel + its advancing row.
// ───────────────────────────────────────────────────────────────────────────

/// Inline panel that lists the LIVE orders in ONE order-flow stage and lets the
/// acting role advance each one (W2). Unlike the manager's static-seed
/// [_ManagerOrderPanel], this watches the SHARED [ordersEngineProvider], so the
/// list reflows the instant ANY role mutates the engine; and each open row's
/// advance button calls `ordersEngineProvider.notifier.advance(id)` — the SAME
/// write the manager's god-step uses — so a store/courier advance immediately
/// changes the manager's live counts/pipeline and the order's stage everywhere.
///
/// Used for both the store leaves (`so-*`, [kStoreOrderLeafStage]) and the
/// courier leaves ([kCourierOrderLeafStage]); the only difference is the [emoji]
/// the header shows (🏪 / 🛵). The advance label is [kStageAdvanceLabel] for the
/// stage; the terminal `delivered` stage shows a "✓ נמסר" note instead of a
/// button. An empty stage shows the legacy `לא נמצאו הזמנות תואמות.` line.
class _LiveStageOrderPanel extends ConsumerWidget {
  const _LiveStageOrderPanel({
    required this.emoji,
    required this.stage,
    required this.title,
    required this.onClose,
  });

  /// The header emoji of the acting role (🏪 store / 🛵 courier).
  final String emoji;

  /// The order-flow stage this panel filters the live engine to.
  final String stage;

  /// The leaf's verbatim Hebrew title (the panel header label).
  final String title;

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // LIVE read — the panel reflows whenever the shared engine changes.
    final orders = ref
        .watch(ordersEngineProvider)
        .where((o) => o.stage == stage)
        .toList(growable: false);
    final advanceLabel = kStageAdvanceLabel[stage];

    return Semantics(
      label: '$emoji $title: ${orders.length} הזמנות',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space4,
          vertical: BsTokens.space3,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          boxShadow: BsTokens.circleShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                // The stage's live order count.
                Text(
                  '${orders.length}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: BsTokens.brand,
                  ),
                ),
                const SizedBox(width: BsTokens.space2),
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(BsTokens.radiusCircle),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: BsTokens.mutedLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: BsTokens.space2),
            if (orders.isEmpty)
              Text(
                'לא נמצאו הזמנות תואמות.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: BsTokens.mutedLight,
                ),
              )
            else
              for (final o in orders) ...[
                _LiveOrderRow(
                  order: o,
                  advanceLabel: advanceLabel,
                  onAdvance: () => ref
                      .read(ordersEngineProvider.notifier)
                      .advance(o.id),
                ),
                if (o != orders.last) const SizedBox(height: BsTokens.space3),
              ],
          ],
        ),
      ),
    );
  }
}

/// One order row inside [_LiveStageOrderPanel] — `📦 id` / `who · site` /
/// `items פריטים · ₪sum` (mirroring the manager's [_OrderRow]) PLUS the W2
/// advance affordance: a `brand` pill carrying [advanceLabel] that drives
/// [onAdvance] (the shared-engine `.advance(id)`). When [advanceLabel] is null
/// (the terminal `delivered` stage) the row shows a "✓ נמסר" completed note
/// instead of a button.
class _LiveOrderRow extends StatelessWidget {
  const _LiveOrderRow({
    required this.order,
    required this.advanceLabel,
    required this.onAdvance,
  });

  final Order order;
  final String? advanceLabel;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📦 ${order.id}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          '${order.who} · ${order.site}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: Text(
                '${order.items} פריטים · ₪${_grouped(order.sum)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: BsTokens.mutedLight,
                ),
              ),
            ),
            const SizedBox(width: BsTokens.space2),
            if (advanceLabel != null)
              Material(
                // Keyed by order id so the advance affordance is uniquely
                // targetable even when a stage holds several orders (each row
                // shows the same verb label) — used by the W2 widget tests.
                key: ValueKey('advance-${order.id}'),
                color: BsTokens.brand,
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                child: InkWell(
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  onTap: onAdvance,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: BsTokens.space3,
                      vertical: 6,
                    ),
                    child: Text(
                      advanceLabel!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              )
            else
              Text(
                '✓ נמסר',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF1B7A3D),
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
