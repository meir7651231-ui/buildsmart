import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/state/manager_dashboard_state.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 👔 מרכז השליטה — the manager-of-the-system role app (the "מנהל המערכת"
/// persona). Same full-role-app shell/style as the worker app
/// (`worker_app_screen.dart`): a LIGHT [Scaffold] (`bgLight`), a WHITE AppBar
/// (`cardLight`) with dark text, and a top segmented toggle that drives an
/// [IndexedStack] (the `updates_screen.dart` pattern).
///
/// Tabs filled so far: 📊 לוח בקרה (M2 — the live cockpit) and 🚚 הזמנות (M3 —
/// the live order list + the manager's god-mode stage-advance). 👥 לקוחות and
/// 🛠️ ניהול are still PLACEHOLDERS (a centred "בקרוב" note) until M4–M5 fill them
/// with the real manager content (the live orders engine derivations). Reached
/// from the role picker ("מי אתה?" → מנהל המערכת), which `Navigator.push`es this
/// route instead of opening the old BS-dial drill.
class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const ManagerDashboardScreen());

  /// Number of top tabs (📊 לוח בקרה · 🚚 הזמנות · 👥 לקוחות · 🛠️ ניהול);
  /// kept in lockstep with [_kManagerTabs] (asserted in the screen's test).
  static const int tabCount = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(managerTabProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: BsTokens.space4,
          title: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'מרכז השליטה',
                      style: TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'מנהל המערכת',
                      style: TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _LivePill(),
            ],
          ),
          actions: [
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
            _ManagerToggle(active: active),
            Expanded(
              child: IndexedStack(
                index: active,
                children: [
                  // 📊 לוח בקרה (M2) — the dashboard cockpit, live over the
                  // shared orders engine. 🚚 הזמנות (M3) — the live order list +
                  // the manager's god-mode stage-advance. 👥/🛠️ remain
                  // PLACEHOLDERS this wave (M4–M5 fill them).
                  for (var i = 0; i < _kManagerTabs.length; i++)
                    if (i == 0)
                      const _DashboardTab()
                    else if (i == 1)
                      const _OrdersTab()
                    else
                      _TabPlaceholder(
                        emoji: _kManagerTabs[i].emoji,
                        label: _kManagerTabs[i].label,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small green "חי" status pill in the AppBar — signals the dashboard is on
/// the LIVE shared data (the orders engine), mirroring the role drawer's tone.
class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: BsTokens.space3, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F6EC),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Dot(),
          SizedBox(width: 6),
          Text(
            'חי',
            style: TextStyle(
              color: Color(0xFF1B7A3D),
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF22A75A),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// The 4-tab segmented toggle — replicates `updates_screen`'s `seg()` helper,
/// but in the PILL style the manager shell uses: the selected pill is a
/// [BsTokens.brand] fill with white text, an unselected pill is a
/// [BsTokens.cardLight] fill with [BsTokens.inkLight] text; both are pill-radius
/// (icon-emoji + Hebrew label). Tapping a pill sets [managerTabProvider].
class _ManagerToggle extends ConsumerWidget {
  const _ManagerToggle({required this.active});

  final int active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget seg(int i, String emoji, String label) {
      final on = active == i;
      return Expanded(
        child: Padding(
          // Half-gap on each inner edge → an even gap between pills, none at the
          // row's outer edges. Directional (start/end) so RTL/LTR both lay out
          // correctly (gate 62 — no hard-coded edge inset).
          padding: EdgeInsetsDirectional.only(
            start: i == 0 ? 0 : BsTokens.space2 / 2,
            end: i == ManagerDashboardScreen.tabCount - 1
                ? 0
                : BsTokens.space2 / 2,
          ),
          child: Material(
            color: on ? BsTokens.brand : BsTokens.cardLight,
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            child: InkWell(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              onTap: () => ref.read(managerTabProvider.notifier).state = i,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: on ? Colors.white : BsTokens.inkLight,
                          fontSize: 13.5,
                          fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: BsTokens.cardLight,
      // Directional (start/top/end/bottom) so RTL/LTR both lay out correctly
      // (gate 62 — no hard-coded edge inset).
      padding: const EdgeInsetsDirectional.fromSTEB(
        BsTokens.space3,
        BsTokens.space2,
        BsTokens.space3,
        BsTokens.space3,
      ),
      child: Row(
        children: [
          for (var i = 0; i < _kManagerTabs.length; i++)
            seg(i, _kManagerTabs[i].emoji, _kManagerTabs[i].label),
        ],
      ),
    );
  }
}

/// A centred "בקרוב" placeholder for a tab whose real content is a LATER wave
/// (M2–M5). Names the tab so each of the four is visibly distinct.
class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.emoji, required this.label});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: BsTokens.space3),
          Text(
            label,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: BsTokens.space1),
          const Text(
            'בקרוב',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//  📊 לוח בקרה — the dashboard cockpit (M2)
// ───────────────────────────────────────────────────────────────────────────

/// The 📊 לוח בקרה tab body — a LIGHT scrollable cockpit over the LIVE shared
/// orders engine. A faithful port of the legacy `renderMgrDashboard`
/// (@index.html:12133) trimmed to this wave's two sections:
///   • the 5 `mdMetric` tiles (@index.html:12160-12164) — every number derived
///     by [managerAnalyticsProvider] over the engine's live orders, so they
///     stay live (e.g. 🚚 open-orders recounts when an order is placed/advanced);
///   • the order pipeline (@index.html:12177-12198) — a per-stage count across
///     the 6 [kManagerOrderFlow] stages, read straight off [ordersEngineProvider].
///
/// Reading the providers (not the static `managerAnalytics` const) is what makes
/// the tab LIVE: any role that mutates the engine reflows these numbers here.
class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(managerAnalyticsProvider);
    final orders = ref.watch(ordersEngineProvider);

    // Per-stage counts across the canonical 6-stage flow (live engine read).
    final byStage = <String, int>{
      for (final stage in kManagerOrderFlow)
        stage: orders.where((o) => o.stage == stage).length,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        _MetricGrid(analytics: analytics),
        const SizedBox(height: BsTokens.space5),
        _OrderPipeline(byStage: byStage),
      ],
    );
  }
}

/// The five `mdMetric` tiles (@index.html:12160-12164), laid out as a wrapping
/// grid of WHITE cards. Each shows the emoji, the LIVE number, and the Hebrew
/// label — labels VERBATIM from the legacy tiles (🚚 הזמנות פתוחות · 📦 מוצרים
/// בקטלוג · 🧰 אביזרים נלווים · ✅ זמינים כעת · 🏪 חנויות פעילות).
class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.analytics});

  final ManagerAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final tiles = <_MetricTile>[
      _MetricTile(
        emoji: '🚚',
        value: '${analytics.openOrders}',
        label: 'הזמנות פתוחות',
      ),
      _MetricTile(
        emoji: '📦',
        value: '${analytics.catalogCount}',
        label: 'מוצרים בקטלוג',
      ),
      _MetricTile(
        emoji: '🧰',
        value: '${analytics.accessoryCount}',
        label: 'אביזרים נלווים',
      ),
      _MetricTile(
        emoji: '✅',
        value: '${analytics.availableCount}',
        label: 'זמינים כעת',
      ),
      _MetricTile(
        emoji: '🏪',
        value: analytics.storesLabel,
        label: 'חנויות פעילות',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Two tiles per row (with the inter-tile gap removed from the width).
        const gap = BsTokens.space3;
        final tileW = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final t in tiles) SizedBox(width: tileW, child: t),
          ],
        );
      },
    );
  }
}

/// One metric tile — a WHITE card (`cardLight`) with the emoji, the big
/// `brand`-orange number, and the `mutedLight` Hebrew label.
class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.emoji,
    required this.value,
    required this.label,
  });

  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$emoji $label: $value',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space4,
          vertical: BsTokens.space4,
        ),
        decoration: BoxDecoration(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          border: Border.all(color: const Color(0xFFEDEDED)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: BsTokens.space2),
            Text(
              value,
              style: const TextStyle(
                color: BsTokens.brand,
                fontWeight: FontWeight.w800,
                fontSize: 26,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: BsTokens.mutedLight,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The order-pipeline section (@index.html:12177-12198) — a WHITE card listing
/// every [kManagerOrderFlow] stage with its LIVE count and a proportional bar.
/// Labels are the short pipeline forms the legacy `md-pipe` uses (התקבלה ·
/// בהכנה · מוכן · בדרך · נמסר), plus נאסף for the pickup stage — all six stages.
class _OrderPipeline extends StatelessWidget {
  const _OrderPipeline({required this.byStage});

  final Map<String, int> byStage;

  /// The short Hebrew pipeline label per stage. Verbatim from the legacy
  /// `md-pipe` stages array (@index.html:12181-12187: new=התקבלה · preparing=
  /// בהכנה · ready=מוכן · transit=בדרך · delivered=נמסר); pickup=נאסף (the
  /// 6th stage the dashboard pipeline omits but the flow carries, @index.html:
  /// 12044 `ORDER_STAGE.pickup.label`).
  static const Map<String, String> _stageLabel = {
    'new': 'התקבלה',
    'preparing': 'בהכנה',
    'ready': 'מוכן',
    'pickup': 'נאסף',
    'transit': 'בדרך',
    'delivered': 'נמסר',
  };

  /// The per-stage accent colours, verbatim from the legacy pipeline
  /// (@index.html:12181-12187). pickup reuses the `ready` green (it has no
  /// legacy colour, sitting between ready and transit in the flow).
  static const Map<String, Color> _stageColor = {
    'new': Color(0xFF1F6F6B),
    'preparing': Color(0xFFF2A516),
    'ready': Color(0xFF1F8A4C),
    'pickup': Color(0xFF1F8A4C),
    'transit': Color(0xFF2B7DB8),
    'delivered': Color(0xFF8B8D8F),
  };

  @override
  Widget build(BuildContext context) {
    // The legacy `maxStage=Math.max(1, …)` denominator for the bar widths.
    final maxStage = byStage.values.fold<int>(1, (m, n) => n > m ? n : m);

    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'צינור ההזמנות',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          for (final stage in kManagerOrderFlow)
            _PipelineRow(
              label: _stageLabel[stage] ?? stage,
              count: byStage[stage] ?? 0,
              max: maxStage,
              color: _stageColor[stage] ?? BsTokens.brand,
            ),
        ],
      ),
    );
  }
}

/// One pipeline row — the stage label, its LIVE count, and a proportional bar
/// (`count / max`) in the stage colour, on a light track.
class _PipelineRow extends StatelessWidget {
  const _PipelineRow({
    required this.label,
    required this.count,
    required this.max,
    required this.color,
  });

  final String label;
  final int count;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = max <= 0 ? 0.0 : (count / max).clamp(0.0, 1.0);
    return Semantics(
      label: '$label: $count',
      child: Padding(
        padding: const EdgeInsets.only(bottom: BsTokens.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$count',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 7,
                backgroundColor: const Color(0xFFF0F0F0),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//  🚚 הזמנות — the live order control center (M3)
// ───────────────────────────────────────────────────────────────────────────

/// The full stage label per [kManagerOrderFlow] stage — VERBATIM from the legacy
/// `ORDER_STAGE` map (@index.html:12041-12048). These are the strings the legacy
/// status-filter chips, the order-row pill, and the detail sheet all render
/// (`ORDER_STAGE[st].label`). Distinct from the SHORT pipeline labels the 📊
/// dashboard uses (התקבלה/בהכנה/מוכן/…) so the two tabs never collide.
const Map<String, String> _kOrderStageLabel = {
  'new': 'התקבלה',
  'preparing': 'בהכנה',
  'ready': 'מוכן לאיסוף',
  'pickup': 'נאסף',
  'transit': 'בדרך לאתר',
  'delivered': 'נמסר ✓',
};

/// The per-stage pill accent — the legacy `ORDER_STAGE[st].cls` mapped to the
/// pipeline hex palette (@index.html:12181-12187): new→teal, preparing→amber,
/// ready/pickup/transit→green (the legacy bundles them under `cls:'ready'`),
/// delivered→grey (`cls:'done'`). Used only as a small pill tint, LIGHT-safe.
const Map<String, Color> _kOrderStageColor = {
  'new': Color(0xFF1F6F6B),
  'preparing': Color(0xFFF2A516),
  'ready': Color(0xFF1F8A4C),
  'pickup': Color(0xFF1F8A4C),
  'transit': Color(0xFF1F8A4C),
  'delivered': Color(0xFF8B8D8F),
};

/// The 🚚 הזמנות tab body — the manager's LIVE order control center, a faithful
/// port of the legacy `renderMgrOrders` (@index.html:16939-17075). Reads the
/// shared [ordersEngineProvider] so the list is always live; the per-order
/// "קדם שלב ›" button calls `ordersEngineProvider.notifier.advance(id)` (the
/// god-mode stage-advance — verbatim `mgrAdvanceOrder` @index.html:17022). Because
/// the engine is SHARED, advancing here also reflows the 📊 dashboard's 🚚 tile +
/// pipeline + counts LIVE (proven in `manager_dashboard_screen_test`).
///
/// Sections (top→bottom): a 3-stat summary (הזמנות / פתוחות / מחזור), a stage
/// filter chip row (`הכל` + one chip per non-empty stage, verbatim labels +
/// counts), and the filtered order list. LIGHT only — white `cardLight` rows on
/// `bgLight`, `inkLight`/`mutedLight` text, `brand` accents.
class _OrdersTab extends ConsumerStatefulWidget {
  const _OrdersTab();

  @override
  ConsumerState<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends ConsumerState<_OrdersTab> {
  /// The active stage filter — `'all'` (the legacy `mgrOrderFilter` default) or
  /// one of [kManagerOrderFlow]. Local widget state (the legacy module-scoped
  /// `let mgrOrderFilter='all'`); no engine/global state is touched.
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(ordersEngineProvider);

    // Summary (@index.html:16953-16962): total / open(stage!=='delivered') /
    // revenue(Σsum).
    final open = all.where((o) => o.isOpen).length;
    final revenue = all.fold<int>(0, (s, o) => s + o.sum);

    // Per-stage counts for the chips (@index.html:16965-16966).
    final counts = <String, int>{
      for (final st in kManagerOrderFlow) st: all.where((o) => o.stage == st).length,
    };

    // If the active filter's stage has emptied out (e.g. its last order was
    // advanced away), fall back to `הכל` so the user is never stranded on a chip
    // that no longer renders (the legacy chip simply vanishes; this keeps the
    // list visible rather than wedged on a missing filter).
    final effectiveFilter =
        _filter == 'all' || (counts[_filter] ?? 0) > 0 ? _filter : 'all';

    // Filtered list (@index.html:16974-16982) — by stage only (the legacy free-
    // text search is not part of this wave).
    final list = effectiveFilter == 'all'
        ? all
        : all.where((o) => o.stage == effectiveFilter).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        _OrderSummary(total: all.length, open: open, revenue: revenue),
        const SizedBox(height: BsTokens.space4),
        _OrderStageChips(
          active: effectiveFilter,
          allCount: all.length,
          counts: counts,
          onSelect: (st) => setState(() => _filter = st),
        ),
        const SizedBox(height: BsTokens.space4),
        if (list.isEmpty)
          // The legacy empty line (@index.html:16983 `md-empty`).
          const Padding(
            padding: EdgeInsets.symmetric(vertical: BsTokens.space5),
            child: Text(
              'לא נמצאו הזמנות תואמות.',
              textAlign: TextAlign.center,
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
            ),
          )
        else
          for (final o in list)
            Padding(
              padding: const EdgeInsets.only(bottom: BsTokens.space3),
              child: _OrderRow(
                order: o,
                onAdvance: () => _advance(o),
                onTap: () => _openDetail(o),
              ),
            ),
      ],
    );
  }

  /// God-mode stage-advance — the keystone manager WRITE. Verbatim behavior of
  /// `mgrAdvanceOrder` (@index.html:17022-17032): a `delivered` order is already
  /// complete → toast "ההזמנה כבר הושלמה"; otherwise advance one stage on the
  /// SHARED engine and toast "הזמנה `id` → `next-label`". The engine write
  /// reflows the 📊 dashboard (🚚 tile + pipeline) live because they read the
  /// same provider.
  void _advance(Order o) {
    if (!o.isOpen) {
      showToast(context, 'ההזמנה כבר הושלמה');
      return;
    }
    final cur = kManagerOrderFlow.indexOf(o.stage);
    final next = kManagerOrderFlow[cur + 1];
    ref.read(ordersEngineProvider.notifier).advance(o.id);
    showToast(context, 'הזמנה ${o.id} → ${_kOrderStageLabel[next] ?? next}');
  }

  /// The order-detail bottom sheet — the legacy `mgrOrderDetail`
  /// (@index.html:17037-17075): a 6-step progress tracker, an items/sum/step
  /// grid, the קבלן/אתר/סטטוס rows, and the `קדם ל"…"` action (or a
  /// completed note). Advancing from the sheet routes through [_advance], so it
  /// is the same shared-engine write.
  void _openDetail(Order o) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: BsTokens.cardLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(BsTokens.radiusCard)),
      ),
      builder: (sheetCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: _OrderDetailSheet(
          order: o,
          onAdvance: () {
            Navigator.of(sheetCtx).pop();
            _advance(o);
          },
        ),
      ),
    );
  }
}

/// The 3-stat order summary (@index.html:16953-16962) — `mo-summary`: total
/// orders / open orders / revenue (₪, grouped). A WHITE `cardLight` strip.
class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.total,
    required this.open,
    required this.revenue,
  });

  final int total;
  final int open;
  final int revenue;

  @override
  Widget build(BuildContext context) {
    Widget stat(String value, String label) => Expanded(
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space4,
        vertical: BsTokens.space4,
      ),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        children: [
          stat('$total', 'הזמנות'),
          stat('$open', 'פתוחות'),
          stat('₪${_grouped(revenue)}', 'מחזור'),
        ],
      ),
    );
  }
}

/// The status-filter chip row (@index.html:16967-16973) — `הכל (N)` plus one
/// chip per stage that has at least one order (verbatim `ORDER_STAGE[st].label`
/// + count). The active chip is a `brand` fill; the rest are light outlines.
class _OrderStageChips extends StatelessWidget {
  const _OrderStageChips({
    required this.active,
    required this.allCount,
    required this.counts,
    required this.onSelect,
  });

  final String active;
  final int allCount;
  final Map<String, int> counts;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    Widget chip(String key, String label, int count) {
      final on = active == key;
      return Material(
        color: on ? BsTokens.brand : BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: () => onSelect(key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              border: on ? null : Border.all(color: const Color(0xFFE2E2E2)),
            ),
            child: Text(
              '$label ($count)',
              style: TextStyle(
                color: on ? Colors.white : BsTokens.inkLight,
                fontSize: 13,
                fontWeight: on ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: BsTokens.space2,
      runSpacing: BsTokens.space2,
      children: [
        chip('all', 'הכל', allCount),
        for (final st in kManagerOrderFlow)
          if ((counts[st] ?? 0) > 0)
            chip(st, _kOrderStageLabel[st] ?? st, counts[st] ?? 0),
      ],
    );
  }
}

/// One order row (@index.html:16998-17017) — `mo-card`: the `📦 id` + a stage
/// pill on top, the `who · site` line, a 6-step mini tracker, then a footer of
/// `items פריטים · ₪sum` and the "קדם שלב ›" advance button (or a "✓ הושלם"
/// badge once delivered). A WHITE `cardLight` card; tapping it opens the detail
/// sheet (the advance button stops propagation so it never also opens the sheet).
class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.order,
    required this.onAdvance,
    required this.onTap,
  });

  final Order order;
  final VoidCallback onAdvance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stageLabel = _kOrderStageLabel[order.stage] ?? order.stage;
    final stageColor = _kOrderStageColor[order.stage] ?? BsTokens.brand;
    final stageIdx = kManagerOrderFlow.indexOf(order.stage);

    return Semantics(
      button: true,
      label: '📦 ${order.id} · ${order.who} · $stageLabel',
      child: Material(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(BsTokens.space4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BsTokens.radiusCard),
              border: Border.all(color: const Color(0xFFEDEDED)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '📦 ${order.id}',
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    _StagePill(label: stageLabel, color: stageColor),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${order.who} · ${order.site}',
                  style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
                ),
                const SizedBox(height: BsTokens.space3),
                _MiniTracker(stageIdx: stageIdx),
                const SizedBox(height: BsTokens.space3),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${order.items} פריטים · ₪${_grouped(order.sum)}',
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (order.isOpen)
                      _AdvanceButton(onPressed: onAdvance)
                    else
                      const Text(
                        '✓ הושלם',
                        style: TextStyle(
                          color: Color(0xFF1B7A3D),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The small status pill on an order row — a tinted capsule in the stage colour
/// (the legacy `adm-pill <cls>`). A 12% colour wash with the full-colour text,
/// LIGHT-safe (never a dark surface).
class _StagePill extends StatelessWidget {
  const _StagePill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// The 6-step mini progress tracker (@index.html:16992-16996 `mo-track`) — one
/// segment per [kManagerOrderFlow] stage; segments up to & including the current
/// stage are `brand`-filled, the rest are a light track.
class _MiniTracker extends StatelessWidget {
  const _MiniTracker({required this.stageIdx});

  final int stageIdx;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < kManagerOrderFlow.length; i++) ...[
          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: i <= stageIdx ? BsTokens.brand : const Color(0xFFEDEDED),
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              ),
            ),
          ),
          if (i < kManagerOrderFlow.length - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }
}

/// The "קדם שלב ›" advance button (@index.html:17013-17014 `mo-adv`) — a `brand`
/// pill that drives the god-mode stage-advance. White text on `brand`.
class _AdvanceButton extends StatelessWidget {
  const _AdvanceButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BsTokens.brand,
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            'קדם שלב ›',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// The order-detail bottom sheet body (@index.html:17037-17075 `mgrOrderDetail`)
/// — `📦`, the id, the `status · who` tag, a full 6-step labelled tracker, an
/// items/sum/step grid, the קבלן/אתר/סטטוס rows, and the action: either
/// `קדם ל"…"` (open order) or a "✓ ההזמנה הושלמה ונמסרה" note. LIGHT.
class _OrderDetailSheet extends StatelessWidget {
  const _OrderDetailSheet({required this.order, required this.onAdvance});

  final Order order;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final stageIdx = kManagerOrderFlow.indexOf(order.stage);
    final stageLabel = _kOrderStageLabel[order.stage] ?? order.stage;
    final next = order.isOpen ? kManagerOrderFlow[stageIdx + 1] : null;

    Widget tile(String value, String label) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: BsTokens.space3),
            decoration: BoxDecoration(
              color: BsTokens.bgLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDEDED)),
            ),
            child: Column(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
                ),
              ],
            ),
          ),
        );

    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          BsTokens.space4,
          BsTokens.space4,
          BsTokens.space4,
          BsTokens.space5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('📦', style: TextStyle(fontSize: 34), textAlign: TextAlign.center),
            const SizedBox(height: BsTokens.space2),
            Text(
              order.id,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$stageLabel · ${order.who}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            ),
            const SizedBox(height: BsTokens.space4),
            _MiniTracker(stageIdx: stageIdx),
            const SizedBox(height: BsTokens.space4),
            Row(
              children: [
                tile('${order.items}', 'פריטים'),
                tile('₪${_grouped(order.sum)}', 'סכום'),
                tile('${stageIdx + 1}/${kManagerOrderFlow.length}', 'שלב'),
              ],
            ),
            const SizedBox(height: BsTokens.space4),
            row('קבלן', order.who),
            row('אתר', order.site),
            row('סטטוס', stageLabel),
            const SizedBox(height: BsTokens.space4),
            if (next != null)
              _SheetAdvanceButton(
                label: 'קדם ל"${_kOrderStageLabel[next] ?? next}"',
                onPressed: onAdvance,
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(vertical: BsTokens.space3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F6EC),
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
                child: const Text(
                  '✓ ההזמנה הושלמה ונמסרה',
                  style: TextStyle(
                    color: Color(0xFF1B7A3D),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The sheet's full-width green advance button (the legacy `btn btn-green`).
class _SheetAdvanceButton extends StatelessWidget {
  const _SheetAdvanceButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1F8A4C),
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// Thousands-grouped integer (the legacy `Number.toLocaleString()` for the ₪
/// sums) — e.g. 3150 → "3,150". Pure, no locale dependency.
String _grouped(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return n < 0 ? '-$buf' : buf.toString();
}

/// One manager tab descriptor — emoji icon + Hebrew label.
class _ManagerTab {
  const _ManagerTab({required this.emoji, required this.label});

  final String emoji;
  final String label;
}

/// The four manager tabs — emoji + Hebrew label, verbatim from the legacy
/// manager sections (📊 לוח בקרה · 🚚 הזמנות · 👥 לקוחות · 🛠️ ניהול). Private so
/// the screen exposes only [ManagerDashboardScreen.tabCount] publicly.
const List<_ManagerTab> _kManagerTabs = [
  _ManagerTab(emoji: '📊', label: 'לוח בקרה'),
  _ManagerTab(emoji: '🚚', label: 'הזמנות'),
  _ManagerTab(emoji: '👥', label: 'לקוחות'),
  _ManagerTab(emoji: '🛠️', label: 'ניהול'),
];
