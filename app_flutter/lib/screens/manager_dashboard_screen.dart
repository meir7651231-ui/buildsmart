import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/state/manager_dashboard_state.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 👔 מרכז השליטה — the manager-of-the-system role app (the "מנהל המערכת"
/// persona). Same full-role-app shell/style as the worker app
/// (`worker_app_screen.dart`): a LIGHT [Scaffold] (`bgLight`), a WHITE AppBar
/// (`cardLight`) with dark text, and a top segmented toggle that drives an
/// [IndexedStack] (the `updates_screen.dart` pattern).
///
/// M1 = SHELL ONLY. The four tabs (📊 לוח בקרה · 🚚 הזמנות · 👥 לקוחות ·
/// 🛠️ ניהול) are PLACEHOLDERS this wave — each shows a centred "בקרוב" note;
/// LATER waves (M2–M5) fill them with the real manager content (the live orders
/// engine derivations). Reached from the role picker ("מי אתה?" → מנהל המערכת),
/// which `Navigator.push`es this route instead of opening the old BS-dial drill.
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
                  // shared orders engine. The other three tabs (🚚/👥/🛠️) are
                  // still PLACEHOLDERS this wave (M3–M5 fill them).
                  for (var i = 0; i < _kManagerTabs.length; i++)
                    if (i == 0)
                      const _DashboardTab()
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
