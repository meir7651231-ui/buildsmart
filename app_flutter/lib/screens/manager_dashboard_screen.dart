import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/data/brands.dart';
import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
// A13 — the server-canonical credit seam: the repository provider + the
// neutral CreditResult the `computeCredit` callable resolves through.
import 'package:buildsmart/data/repositories/customers_local.dart'
    show customersRepositoryProvider;
import 'package:buildsmart/data/repositories/order_functions.dart'
    show CreditResult;
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/credit_explain_screen.dart'
    show CreditExplainScreen;
import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode, kbManagerDashboardNodes;
import 'package:buildsmart/screens/manager_copilot_screen.dart';
import 'package:buildsmart/screens/manager_profile_screen.dart';
import 'package:buildsmart/screens/manager_role_assign_sheet.dart';
import 'package:buildsmart/screens/regression_panel_screen.dart';
import 'package:buildsmart/screens/studio/studio_entry.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
// #85ב/#23 — the SHARED proof-photo renderer (one renderer for both sides
// of the approval: the worker sheet and this dashboard).
import 'package:buildsmart/screens/worker_task_detail_sheet.dart'
    show taskPhotoWidget;
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/catalog_settings.dart' show kVatRate;
import 'package:buildsmart/state/keyboard_overlay.dart' show kKbGlobal;
import 'package:buildsmart/state/keyboard_screen_tools.dart' show KbScreen;
import 'package:buildsmart/state/manager_dashboard_state.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/vacation_requests.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/state/worker_tasks_engine.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart' show cfgRadius;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/contact_actions.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/reject_reason_dialog.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 👔 מרכז השליטה — the manager-of-the-system role app (the "מנהל המערכת"
/// persona). Same full-role-app shell/style as the worker app
/// (`worker_app_screen.dart`): a LIGHT [Scaffold] (`bgLight`), a WHITE AppBar
/// (`cardLight`) with dark text, and a top segmented toggle that drives an
/// [IndexedStack] (the `updates_screen.dart` pattern).
///
/// All four tabs are live and complete: 📊 לוח בקרה (M2 — the live cockpit),
/// 🚚 הזמנות (M3 — the live order list + god-mode stage-advance), 👥 לקוחות
/// (M4 — live customer list with credit tracking), and 🛠️ ניהול (M5 — the
/// management accordion). Reached
/// from the role picker ("מי אתה?" → מנהל המערכת), which `Navigator.push`es this
/// route instead of opening the old BS-dial drill.
class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const ManagerDashboardScreen());

  static final List<KbToolNode> _kbNodes = kbManagerDashboardNodes();

  /// Number of top tabs (📊 לוח בקרה · 🚚 הזמנות · 👥 לקוחות · 🛠️ ניהול);
  /// kept in lockstep with [_kManagerTabs] (asserted in the screen's test).
  static const int tabCount = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // task #65 · חוק: מבחוץ לא רואים כלום — without a manager [BoardSession]
    // ONLY the gate (the registration screen in role mode) is built; a
    // successful login flips [boardAuthProvider] and this build swaps to the
    // real board in place. logout() swaps it back to the gate.
    if (ref.watch(boardAuthProvider)?.role != BoardRole.manager) {
      return WelcomeScreen(boardRole: BoardRole.manager);
    }
    final active = ref.watch(managerTabProvider);

    final Widget scaffold = Scaffold(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'מנהל המערכת',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
                  ),
                ],
              ),
            ),
            _LivePill(),
          ],
        ),
        actions: [
          // #31 — 💡 enters "מצב היכרות"; the wrapped controls then explain
          // themselves in a bubble (the 💡 + ✕ stay tappable to toggle/exit).
          // (The 🤖 Co-Pilot entry is the cockpit HERO card — not an AppBar
          // action — to keep the 5-action bar from overflowing on narrow widths.)
          const HelpToggleButton(),
          // Each persona reaches profile + settings from its OWN dashboard
          // (product-owner: separately per role). Three muted AppBar actions
          // sit before the '‹ יציאה' exit; tooltips double as Semantics
          // labels for a11y. RTL: actions lay out leading→trailing, so this
          // reads 💡 · 💬 שיחות · profile · settings · exit from the right.
          //
          // 🔒 ISOLATION (SPEC §2.5): the chat action ONLY pushes the manager's
          // standalone [ChatsScreen] (its own "שיחות" AppBar + back→pop) — back
          // returns to THIS manager dashboard; no route to home_shell, the role
          // picker, or any other persona's board.
          //
          // The default ('contractor') thread list admits worker-audience
          // threads the manager participates in (`_visibleToAudience`,
          // chats_screen.dart) — so 'th-worker-manager' (the worker's 'מנהל'
          // thread, rendered here as 'עובד — רן') is readable, not write-only.
          HelpTarget(
            title: 'שיחות',
            body:
                'פותח את מרכז השיחות של מנהל המערכת — קריאה ומענה לשרשורי '
                'הצ׳אט מול עובדים, קבלנים, חנויות ושליחים. נפתח כמסך עצמאי '
                'וחוזר אחורה ללוח; אינו מתנתק ואינו מחליף תפקיד.',
            child: IconButton(
              tooltip: 'שיחות',
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: BsTokens.mutedLight,
              ),
              onPressed:
                  () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder:
                          (_) => const ChatsScreen(persona: BsRole.manager),
                    ),
                  ),
            ),
          ),
          HelpTarget(
            title: 'אזור אישי',
            body:
                'פותח את האזור האישי של מנהל המערכת: פרטי החשבון, סטטיסטיקת '
                'הזמנות חיה, ומעבר להגדרות ולהחלפת תפקיד מוגנת בקוד.',
            child: IconButton(
              tooltip: 'פרופיל',
              icon: const Icon(
                Icons.person_outline,
                color: BsTokens.mutedLight,
              ),
              // #20 — the manager's OWN profile (session + role-switch +
              // logout), not the contractor's ProfileScreen.
              onPressed:
                  () =>
                      Navigator.of(context).push(ManagerProfileScreen.route()),
            ),
          ),
          HelpTarget(
            title: 'הגדרות הקטלוג',
            body:
                'פותח את הגדרות הקטלוג והאפליקציה — שליטת No-Code על '
                'הפרמטרים שכל הקבלנים רואים.',
            child: IconButton(
              tooltip: 'הגדרות',
              icon: const Icon(
                Icons.settings_outlined,
                color: BsTokens.mutedLight,
              ),
              onPressed:
                  () => Navigator.of(context).push(
                    // Manager = platform-admin: the No-Code catalog/app admin
                    // WITHOUT the contractor profile row (governance S0 fix).
                    CatalogSettingsScreen.route(showProfileRow: false),
                  ),
            ),
          ),
          // מנהל = חשבון הבעלים: אין התנתקות (דרישת מוצר — "המנהל לא מתנתק").
          // ה-session נשאר קבוע; אין כפתור logout. '‹ יציאה' למטה היא
          // ניווט-בלבד (Navigator.maybePop) — חוזרת אחורה בלי לנקות את ה-session.
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
              children: const [
                // The manager screen is now COMPLETE — every tab is real, NO
                // "בקרוב" placeholder remains. 📊 לוח בקרה (M2) — the dashboard
                // cockpit, live over the shared orders engine. 🚚 הזמנות (M3) —
                // the live order list + the manager's god-mode stage-advance.
                // 👥 לקוחות (M4) — the live customer list + credit. 🛠️ ניהול
                // (M5) — the 5 management tools (the FINAL tab).
                _DashboardTab(),
                _OrdersTab(),
                _CustomersTab(),
                _ManageTab(),
              ],
            ),
          ),
        ],
      ),
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: kKbGlobal ? KbScreen(tools: _kbNodes, child: scaffold) : scaffold,
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
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space3,
        vertical: 5,
      ),
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
            end:
                i == ManagerDashboardScreen.tabCount - 1
                    ? 0
                    : BsTokens.space2 / 2,
          ),
          // #31 — each tab wrapped in its OWN HelpTarget (orange ring + bubble
          // out of the tab); the four pills are built in this one seg() loop so
          // the per-index help text comes from [_kManagerTabHelp].
          child: HelpTarget(
            title: _kManagerTabHelp[i].$1,
            body: _kManagerTabHelp[i].$2,
            child: Material(
              color: on ? BsTokens.brand : BsTokens.cardLight,
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              child: InkWell(
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                onTap: () => ref.read(managerTabProvider.notifier).state = i,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 6,
                  ),
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
                            color: on ? bsOnAccent(context) : BsTokens.inkLight,
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

// ───────────────────────────────────────────────────────────────────────────
//  📊 לוח בקרה — the dashboard cockpit (M2)
// ───────────────────────────────────────────────────────────────────────────

/// The 📊 לוח בקרה tab body — a LIGHT scrollable cockpit over the LIVE shared
/// orders engine. A faithful port of the legacy `renderMgrDashboard`
/// (@index.html:12133) trimmed to this wave's two sections:
///   • the 5 `mdMetric` tiles (@index.html:12160-12164) — read via
///     [managerAnalyticsProvider]; 🚚 open-orders is engine-LIVE (recounts when an
///     order is placed/advanced), while 📦 catalog / 🧰 accessories / ✅ available /
///     🏪 stores are static-by-design ports of [kManagerCatalogCategories] /
///     [kManagerStores] (real numbers that don't mutate at runtime);
///   • the order pipeline (@index.html:12177-12198) — a per-stage count across
///     the 6 [kManagerOrderFlow] stages, read straight off [ordersEngineProvider].
///
/// Reading the providers (not the static `managerAnalytics` const) is what keeps
/// the LIVE figures — 🚚 open-orders + the pipeline — reflowing whenever any role
/// mutates the engine.
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
        const _CopilotHero(),
        const SizedBox(height: BsTokens.space4),
        // Owner-only Studio entry — SizedBox.shrink for everyone else, so the
        // cockpit is unchanged unless the signed-in owner-manager is looking.
        const StudioEntryCard(),
        _MetricGrid(analytics: analytics),
        const SizedBox(height: BsTokens.space5),
        _OrderPipeline(byStage: byStage),
      ],
    );
  }
}

/// 🤖 Co-Pilot hero — the cockpit's headline gateway into "שאל את העסק שלך".
/// A brand-gradient card at the very top of 📊 לוח בקרה → pushes the co-pilot.
class _CopilotHero extends ConsumerWidget {
  const _CopilotHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(claudeGatewayProvider) != null;
    return Semantics(
      button: true,
      label: 'קו-פיילוט — שאל את העסק שלך',
      child: InkWell(
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        onTap: () =>
            Navigator.of(context).push(ManagerCopilotScreen.route()),
        child: Container(
          padding: const EdgeInsets.all(BsTokens.space4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [BsTokens.brand, BsTokens.brandDark],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(cfgRadius(context)),
          ),
          child: Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 34)),
              const SizedBox(width: BsTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CfgText(
                      'manager.cockpit.copilot.title',
                      'שאל את העסק שלך',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      live
                          ? 'מה בוער? מי הלקוח הכי שווה? — אני עונה מהנתונים החיים'
                          : 'מודיעין-עסקי AI · דורש חיבור לשרת',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                      ), // full white — white70 on brand failed contrast
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: Colors.white),
            ],
          ),
        ),
      ),
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
        cfgId: 'manager.cockpit.kpi.openOrders',
      ),
      _MetricTile(
        emoji: '📦',
        value: '${analytics.catalogCount}',
        label: 'מוצרים בקטלוג',
        cfgId: 'manager.cockpit.kpi.products',
      ),
      _MetricTile(
        emoji: '🧰',
        value: '${analytics.accessoryCount}',
        label: 'אביזרים נלווים',
        cfgId: 'manager.cockpit.kpi.accessories',
      ),
      _MetricTile(
        emoji: '✅',
        value: '${analytics.availableCount}',
        label: 'זמינים כעת',
        cfgId: 'manager.cockpit.kpi.available',
      ),
      _MetricTile(
        emoji: '🏪',
        value: analytics.storesLabel,
        label: 'חנויות פעילות',
        cfgId: 'manager.cockpit.kpi.stores',
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
          children: [for (final t in tiles) SizedBox(width: tileW, child: t)],
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
    required this.cfgId,
  });

  final String emoji;
  final String value;
  final String label;

  /// Studio element id for the editable label (step 14 pilot).
  final String cfgId;

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
          borderRadius: BorderRadius.circular(cfgRadius(context)),
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
            // Step-14 pilot: the KPI label is studio-editable. Empty doc ⇒ the
            // literal `label` verbatim with this exact style ⇒ golden-identical.
            CfgText(
              cfgId,
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
        borderRadius: BorderRadius.circular(cfgRadius(context)),
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
      for (final st in kManagerOrderFlow)
        st: all.where((o) => o.stage == st).length,
    };

    // If the active filter's stage has emptied out (e.g. its last order was
    // advanced away), fall back to `הכל` so the user is never stranded on a chip
    // that no longer renders (the legacy chip simply vanishes; this keeps the
    // list visible rather than wedged on a missing filter).
    final effectiveFilter =
        _filter == 'all' || (counts[_filter] ?? 0) > 0 ? _filter : 'all';

    // Filtered list (@index.html:16974-16982) — by stage only (the legacy free-
    // text search is not part of this wave).
    final list =
        effectiveFilter == 'all'
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
    if (cur < 0) return; // unknown stage — don't silently wrap to index 0
    ref.read(ordersEngineProvider.notifier).advance(o.id);
    // Re-read the live order after advancing so the toast labels the NEW stage
    // (not the stale snapshot stage the caller captured before the write).
    final live = ref
        .read(ordersEngineProvider)
        .firstWhere((x) => x.id == o.id, orElse: () => o);
    showToast(
      context,
      'הזמנה ${o.id} → ${_kOrderStageLabel[live.stage] ?? live.stage}',
    );
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(BsTokens.radiusCard),
        ),
      ),
      builder:
          (sheetCtx) => Directionality(
            textDirection: TextDirection.rtl,
            child: _OrderDetailSheet(
              orderId: o.id,
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
        borderRadius: BorderRadius.circular(cfgRadius(context)),
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
    // #31 — each stage chip is wrapped in a HelpTarget (one bubble text for the
    // whole filter row); in help mode it rings + explains, otherwise unchanged.
    Widget chip(String key, String label, int count) {
      final on = active == key;
      return HelpTarget(
        title: 'סינון לפי שלב',
        body:
            'מסנן את רשימת ההזמנות לשלב שנבחר; ׳הכל׳ מציג את כולן. רק שלבים '
            'שיש בהם הזמנות מופיעים. סינון תצוגה בלבד — אינו משנה דאטה.',
        child: Material(
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
                  color: on ? bsOnAccent(context) : BsTokens.inkLight,
                  fontSize: 13,
                  fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                ),
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
      // #31 — tapping the card opens the order-detail sheet; in help mode the
      // HelpTarget rings the whole card and explains it instead.
      child: HelpTarget(
        title: 'פרטי הזמנה',
        body:
            'פותח את גיליון פרטי ההזמנה: מעקב 6 שלבים, פריטים/סכום, '
            'קבלן/אתר/סטטוס ופעולת קידום שלב.',
        child: Material(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          child: InkWell(
            borderRadius: BorderRadius.circular(cfgRadius(context)),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(BsTokens.space4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cfgRadius(context)),
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
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 13,
                    ),
                  ),
                  // 📞/💬 — call / WhatsApp the contractor who placed the order
                  // (hidden when the order carries no phone — seed/legacy).
                  ContactActions(phone: order.customerPhone, compact: true),
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
                        // #31 — the god-mode stage-advance; in help mode the
                        // HelpTarget rings + explains it instead of advancing.
                        HelpTarget(
                          title: 'קדם שלב להזמנה',
                          body:
                              'מקדם את ההזמנה לשלב הבא בצינור '
                              '(התקבלה→בהכנה→מוכן→נאסף→בדרך→נמסר). עקיפת-מנהל '
                              'המעדכנת מיד את כל הלוחות. הזמנה שנמסרה אינה ניתנת '
                              'לקידום.',
                          child: _AdvanceButton(onPressed: onAdvance),
                        )
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            'קדם שלב ›',
            style: TextStyle(
              color: bsOnAccent(context),
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
///
/// Watches [ordersEngineProvider] directly (NEW-A) so stage/timeline/advance-
/// label follow live advances: tapping "קדם" from the list while the sheet is
/// open causes the sheet to reflect the new stage without reopening it, and the
/// advance button hides automatically once the order reaches `delivered`.
class _OrderDetailSheet extends ConsumerWidget {
  const _OrderDetailSheet({required this.orderId, required this.onAdvance});

  final String orderId;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Look up the LIVE order by id — falls back to null if somehow removed.
    final allOrders = ref.watch(ordersEngineProvider);
    Order? order;
    for (final o in allOrders) {
      if (o.id == orderId) {
        order = o;
        break;
      }
    }

    // If the order is gone (edge-case), close the sheet gracefully.
    if (order == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Navigator.of(context, rootNavigator: false).maybePop(),
      );
      return const SizedBox.shrink();
    }

    final stageIdx = kManagerOrderFlow.indexOf(order.stage);
    final stageLabel = _kOrderStageLabel[order.stage] ?? order.stage;
    // L7: guard stageIdx >= 0 to avoid index crash on unknown/corrupt stage.
    final next =
        (stageIdx >= 0 && order.isOpen)
            ? kManagerOrderFlow[stageIdx + 1]
            : null;

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
            const Text(
              '📦',
              style: TextStyle(fontSize: 34),
              textAlign: TextAlign.center,
            ),
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
            // 📞/💬 — call / WhatsApp the contractor (hidden when no phone).
            Center(child: ContactActions(phone: order.customerPhone)),
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
    // #31 — the detail-sheet stage-advance; in help mode the HelpTarget rings +
    // explains it instead of advancing.
    return HelpTarget(
      title: 'קדם לשלב הבא',
      body:
          'מקדם את ההזמנה לשלב הבא ישירות מתוך גיליון הפרטים. אותה עקיפת-מנהל '
          'כמו ׳קדם שלב׳ ברשימה; השלב מתעדכן בכל הלוחות.',
      child: Material(
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

// ───────────────────────────────────────────────────────────────────────────
//  👥 לקוחות — the live customer list + credit (M4)
// ───────────────────────────────────────────────────────────────────────────

/// The Hebrew status label per customer status — VERBATIM from the legacy
/// `renderMgrCustomers` (@index.html:16592:
/// `c.status==='low'?'אשראי גבוה':c.status==='off'?'לא פעיל':'פעיל'`). The
/// detail-sheet tag uses the longer legacy forms (@index.html:16616).
const Map<String, String> _kCustomerStatusLabel = {
  'live': 'פעיל',
  'low': '⚠️ אשראי גבוה',
  'off': 'לא פעיל',
};

/// The per-status accent colour — green for an active contractor (`live`),
/// amber for a high-credit one (`low`, the legacy `hot` class @index.html:16601),
/// grey for an inactive one (`off`). LIGHT-safe (the dashboard's own greens/amber,
/// never a dark token).
const Map<String, Color> _kCustomerStatusColor = {
  'live': Color(0xFF1F8A4C),
  'low': Color(0xFFF2A516),
  'off': Color(0xFF8B8D8F),
};

/// One customer's full view-model — the [ManagerCustomer] aggregate (name /
/// orderCount / totalSpend / creditLimit) PLUS the two derived fields the legacy
/// `mc-card` renders that are NOT on the aggregate: `pct` (credit-utilisation %)
/// and `sites` (distinct build-site count). Both are computed exactly as the
/// legacy `mgrCustomerList` does over the LIVE orders (@index.html:16554,
/// 16559-16562) — `pct = min(100, round(spent/credit*100))`, `sites` = the size
/// of the per-buyer site set.
@immutable
class _CustomerView {
  const _CustomerView({
    required this.customer,
    required this.pct,
    required this.sites,
  });

  final ManagerCustomer customer;
  final int pct;
  final int sites;

  /// @legacy index.html:16562 — `pct>=90?'low':pct>0?'live':'off'`.
  String get status => pct >= 90 ? 'low' : (pct > 0 ? 'live' : 'off');
}

/// PERF-M2: top-level Riverpod provider for the LIVE customer view-models.
///
/// Watches [managerCustomersProvider] for the sorted buyer list (sort order is
/// spend-desc, the legacy `mgrCustomerList` order @index.html:16554 — keeping
/// it as the primary watch preserves stable ordering across engine ticks) AND
/// [ordersEngineProvider] for the raw orders needed to derive `pct` / `sites`.
/// Extracted from the former free-function `_liveCustomerViews` so the O(N)
/// derivation runs once per engine tick, not once per build call, and eliminates
/// the double-subscription that the old call inside `build()` caused.
final _customerViewsProvider = Provider<List<_CustomerView>>((ref) {
  final customers = ref.watch(managerCustomersProvider);
  final orders = ref.watch(ordersEngineProvider);

  // Distinct build sites per buyer (legacy `byName[nm].sites` set @16554) —
  // a non-empty `o.site` is added to that buyer's set; its size is `c.sites`.
  final sitesByBuyer = <String, Set<String>>{};
  for (final o in orders) {
    if (o.site.isEmpty) continue;
    (sitesByBuyer[o.who] ??= <String>{}).add(o.site);
  }

  return [
    for (final c in customers)
      _CustomerView(
        customer: c,
        // @legacy index.html:16559 — `min(100, round(spent/credit*100))`.
        pct:
            c.creditLimit == 0
                ? 0
                : ((c.totalSpend / c.creditLimit) * 100).round().clamp(0, 100),
        sites: sitesByBuyer[c.name]?.length ?? 0,
      ),
  ];
});

/// A13 (launch server-connect) — the server-canonical credit AGGREGATE for one
/// contractor, routed through `CustomersRepository.computeCredit(name)` (the
/// `computeCredit` callable). THIS is the consumer that finally reaches the A13
/// `computeCredit` seam — previously fully built end-to-end but UNCALLED, so
/// credit never routed through the server even with the flag on.
///
/// ZERO-REGRESSION: the repo's `computeCredit` gates INTERNALLY on
/// `kServerCallables` — OFF (default / the whole demo + test suite) it returns
/// the SAME local derivation the dashboard derives synchronously today
/// (`creditLimit == contractorCredit(name)`), with NO network; ON + a bound
/// gateway it returns the server-canonical figures, falling back to the same
/// local derivation on a callable failure (never a faked success). So the
/// figure this resolves to is BYTE-IDENTICAL to the sync `creditLimit` when OFF.
///
/// The detail sheet shows the sync `c.creditLimit` immediately and refines to
/// this once it resolves — OFF the two are equal, so the displayed number never
/// changes (no jarring flicker); ON it upgrades to the server-canonical value.
final customerCreditProvider = FutureProvider.family<CreditResult, String>((
  ref,
  name,
) async {
  return ref.read(customersRepositoryProvider).computeCredit(name);
});

/// The fleet-wide credit ceiling — Σ of the LIVE `computeCredit` ceiling across
/// all customers, so the manager's "ניצול אשראי %" summary stops aggregating the
/// fabricated seed ceiling. OFF (demo/tests): each `computeCredit` returns
/// `contractorCredit(name) == c.creditLimit`, so the sum is byte-identical to the
/// old `Σ c.creditLimit`; ON it sums the server-canonical ceilings. The summary
/// falls back to the seed sum while this resolves, so the number never flickers.
final fleetCreditProvider = FutureProvider<int>((ref) async {
  final customers = ref.watch(managerCustomersProvider);
  var total = 0;
  for (final c in customers) {
    final r = await ref.watch(customerCreditProvider(c.name).future);
    total += r.creditLimit;
  }
  return total;
});

/// The 👥 לקוחות tab body — the manager's LIVE customer list, a faithful port of
/// the legacy `renderMgrCustomers` (@index.html:16566-16607). Each contractor is
/// derived from the shared [ordersEngineProvider] (grouped by `who` via
/// [managerCustomersProvider]), so the list is always live: a new contractor
/// order (placed via the engine by any role) adds or updates a customer card here.
///
/// Sections (top→bottom): a 3-stat summary (קבלנים / סך רכש / ניצול אשראי), a
/// status filter chip row (`הכל` + פעיל / אשראי גבוה when populated), and the
/// filtered customer list. Each `_CustomerCard` mirrors the legacy `mc-card`:
/// `👷 name`, `N הזמנות · M אתרים`, a credit-utilisation bar + the line
/// `ניצול אשראי: ₪used / ₪limit (pct%)`, and a פעיל / ⚠️ אשראי גבוה status pill.
/// Tapping a card opens the `mgrCustomerDetail` bottom sheet. LIGHT only — white
/// `cardLight` cards on `bgLight`, `inkLight`/`mutedLight` text, `brand` accents,
/// green for active / amber for high-credit.
class _CustomersTab extends ConsumerStatefulWidget {
  const _CustomersTab();

  @override
  ConsumerState<_CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends ConsumerState<_CustomersTab> {
  /// The active status filter — `'all'` or one of `live` / `low` (the two the
  /// legacy `mc-pill` surfaces). Local widget state; no engine/global write.
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    // PERF-M2: single ref.watch on the pre-computed provider — O(N) derivation
    // runs once per engine tick in the provider, not on every build call.
    final views = ref.watch(_customerViewsProvider);

    // Summary (@index.html:16570-16578): contractor count, total spend
    // (Σ used), and the fleet credit-utilisation % (Σ used / Σ limit).
    final totalUsed = views.fold<int>(0, (s, v) => s + v.customer.totalSpend);
    // S-connect: the fleet ceiling is the LIVE computeCredit sum (byte-identical
    // OFF == Σ c.creditLimit, the proven invariant); fall back to the seed sum
    // while it resolves so the % never flickers.
    final totalCredit =
        ref.watch(fleetCreditProvider).valueOrNull ??
        views.fold<int>(0, (s, v) => s + v.customer.creditLimit);
    final fleetPct =
        totalCredit == 0
            ? 0
            : ((totalUsed / totalCredit) * 100).round().clamp(0, 100);

    // Per-status counts for the chips (only live/low are user-facing).
    final counts = <String, int>{
      for (final st in const ['live', 'low'])
        st: views.where((v) => v.status == st).length,
    };

    // If the active filter's status has emptied out, fall back to הכל so the
    // user is never stranded on a chip that no longer renders.
    final effectiveFilter =
        _filter == 'all' || (counts[_filter] ?? 0) > 0 ? _filter : 'all';

    final list =
        effectiveFilter == 'all'
            ? views
            : views.where((v) => v.status == effectiveFilter).toList();

    return ListView(
      // Directional (start/top/end/bottom) so RTL/LTR both lay out correctly
      // (gate 62 — no hard-coded left/right edge inset).
      padding: const EdgeInsetsDirectional.fromSTEB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        _CustomerSummary(
          contractors: views.length,
          totalUsed: totalUsed,
          fleetPct: fleetPct,
        ),
        const SizedBox(height: BsTokens.space4),
        _CustomerStatusChips(
          active: effectiveFilter,
          allCount: views.length,
          counts: counts,
          onSelect: (st) => setState(() => _filter = st),
        ),
        const SizedBox(height: BsTokens.space4),
        if (list.isEmpty)
          // The legacy empty line (@index.html:16586 `md-empty`).
          const Padding(
            padding: EdgeInsets.symmetric(vertical: BsTokens.space5),
            child: Text(
              'לא נמצאו קבלנים תואמים.',
              textAlign: TextAlign.center,
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
            ),
          )
        else
          for (final v in list)
            Padding(
              padding: const EdgeInsets.only(bottom: BsTokens.space3),
              child: _CustomerCard(view: v, onTap: () => _openDetail(v)),
            ),
      ],
    );
  }

  /// The customer-detail bottom sheet — the legacy `mgrCustomerDetail`
  /// (@index.html:16609-16643): the 👷 avatar, the name + a status tag, an
  /// orders/spend/pct grid, the credit rows (limit / used / balance / sites),
  /// and the contractor's own orders. Read-only (the legacy sheet has no action).
  void _openDetail(_CustomerView view) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: BsTokens.cardLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(BsTokens.radiusCard),
        ),
      ),
      builder:
          (sheetCtx) => Directionality(
            textDirection: TextDirection.rtl,
            child: _CustomerDetailSheet(view: view),
          ),
    );
  }
}

/// The 3-stat customer summary (@index.html:16574-16578) — `mo-summary`:
/// contractor count / total spend / fleet credit-utilisation %. A WHITE strip.
class _CustomerSummary extends StatelessWidget {
  const _CustomerSummary({
    required this.contractors,
    required this.totalUsed,
    required this.fleetPct,
  });

  final int contractors;
  final int totalUsed;
  final int fleetPct;

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
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        children: [
          stat('$contractors', 'קבלנים'),
          stat('₪${_grouped(totalUsed)}', 'סך רכש'),
          stat('$fleetPct%', 'ניצול אשראי'),
        ],
      ),
    );
  }
}

/// The status-filter chip row — `הכל (N)` plus a פעיל / אשראי גבוה chip per
/// status that has at least one contractor. The active chip is a `brand` fill;
/// the rest are light outlines. (The legacy `renderMgrCustomers` filters by a
/// free-text search box; this wave swaps that for the status filter the task
/// asks for, reusing the legacy `mc-pill` status labels @index.html:16592.)
class _CustomerStatusChips extends StatelessWidget {
  const _CustomerStatusChips({
    required this.active,
    required this.allCount,
    required this.counts,
    required this.onSelect,
  });

  final String active;
  final int allCount;
  final Map<String, int> counts;
  final ValueChanged<String> onSelect;

  /// The short chip label per status (no ⚠️ glyph — that is reserved for the
  /// card pill / detail tag). פעיל / אשראי גבוה, verbatim @index.html:16592.
  static const Map<String, String> _chipLabel = {
    'live': 'פעיל',
    'low': 'אשראי גבוה',
  };

  @override
  Widget build(BuildContext context) {
    // #31 — each status chip is wrapped in a HelpTarget (one bubble text for
    // the whole filter row); help mode rings + explains, otherwise unchanged.
    Widget chip(String key, String label, int count) {
      final on = active == key;
      return HelpTarget(
        title: 'סינון קבלנים',
        body:
            'מסנן את רשימת הקבלנים לפי סטטוס אשראי (פעיל / אשראי גבוה); '
            '׳הכל׳ מציג את כולם. סינון תצוגה בלבד.',
        child: Material(
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
                  color: on ? bsOnAccent(context) : BsTokens.inkLight,
                  fontSize: 13,
                  fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                ),
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
        for (final st in const ['live', 'low'])
          if ((counts[st] ?? 0) > 0)
            chip(st, _chipLabel[st] ?? st, counts[st] ?? 0),
      ],
    );
  }
}

/// One customer card (@index.html:16593-16604 `mc-card`) — `👷 name` + the
/// `N הזמנות · M אתרים` sub-line + a status pill on top, then the credit block:
/// a utilisation bar (green, or amber `hot` at pct≥90) and the line
/// `ניצול אשראי: ₪used / ₪limit (pct%)`. A WHITE card; tapping it opens the
/// detail sheet.
class _CustomerCard extends ConsumerWidget {
  const _CustomerCard({required this.view, required this.onTap});

  final _CustomerView view;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = view.customer;
    // S-connect: resolve the LIVE credit ceiling via computeCredit (the same
    // seam the detail sheet uses). OFF → byte-identical to c.creditLimit (the
    // provider returns contractorCredit(name) with no network); ON → the
    // gateway-bound server figure. The list card showed the fabricated seed
    // ceiling before — only the detail sheet was wired (C1/A13).
    final liveLimit =
        ref.watch(customerCreditProvider(c.name)).valueOrNull?.creditLimit ??
        c.creditLimit;
    final pct =
        liveLimit == 0
            ? 0
            : ((c.totalSpend / liveLimit) * 100).round().clamp(0, 100);
    final status = pct >= 90 ? 'low' : (pct > 0 ? 'live' : 'off');
    final statusLabel = _kCustomerStatusLabel[status] ?? status;
    final statusColor = _kCustomerStatusColor[status] ?? BsTokens.brand;

    return Semantics(
      button: true,
      label: '👷 ${c.name} · $statusLabel',
      // #31 — tapping the card opens the contractor-detail sheet; in help mode
      // the HelpTarget rings the whole card and explains it instead.
      child: HelpTarget(
        title: 'פרטי קבלן',
        body:
            'פותח את גיליון פרטי הקבלן: מסגרת אשראי, נוצל, יתרה זמינה, אתרי '
            'בנייה ורשימת ההזמנות שלו. תצוגה בלבד.',
        child: Material(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          child: InkWell(
            borderRadius: BorderRadius.circular(cfgRadius(context)),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(BsTokens.space4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cfgRadius(context)),
                border: Border.all(color: const Color(0xFFEDEDED)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('👷', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: BsTokens.space2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: const TextStyle(
                                color: BsTokens.inkLight,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${c.orderCount} הזמנות · ${view.sites} אתרים',
                              style: const TextStyle(
                                color: BsTokens.mutedLight,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: BsTokens.space2),
                      _StagePill(label: statusLabel, color: statusColor),
                    ],
                  ),
                  const SizedBox(height: BsTokens.space3),
                  _CreditBar(pct: pct, color: statusColor),
                  const SizedBox(height: 6),
                  Text(
                    'ניצול אשראי: ₪${_grouped(c.totalSpend)} / ₪${_grouped(liveLimit)} ($pct%)',
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 12.5,
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
}

/// The credit-utilisation bar (@index.html:16601 `mc-credit-bar`) — a light
/// track with a `pct`-wide fill in the status colour (green normally, amber at
/// pct≥90). LIGHT-safe.
class _CreditBar extends StatelessWidget {
  const _CreditBar({required this.pct, required this.color});

  final int pct;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ניצול אשראי $pct%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: LinearProgressIndicator(
          value: (pct / 100).clamp(0.0, 1.0),
          minHeight: 8,
          backgroundColor: const Color(0xFFF0F0F0),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}

/// The customer-detail bottom sheet body (@index.html:16609-16643
/// `mgrCustomerDetail`) — the 👷 avatar, the name, a status tag (🟢 קבלן פעיל /
/// ⚠️ ניצול אשראי גבוה / לא פעיל), an orders/spend/pct grid, the credit rows
/// (מסגרת אשראי / נוצל / יתרה זמינה / אתרי בנייה), and the contractor's own
/// orders. Read-only. LIGHT.
///
/// Watches [ordersEngineProvider] directly so the contractor's order list stays
/// live while the sheet is open (orders placed while open appear immediately
/// without reopening the sheet).
class _CustomerDetailSheet extends ConsumerWidget {
  const _CustomerDetailSheet({required this.view});

  final _CustomerView view;

  /// The detail-sheet status TAG — the longer legacy forms (@index.html:16616:
  /// `low`→⚠️ ניצול אשראי גבוה · `off`→לא פעיל · else 🟢 קבלן פעיל).
  static const Map<String, String> _tagLabel = {
    'live': '🟢 קבלן פעיל',
    'low': '⚠️ ניצול אשראי גבוה',
    'off': 'לא פעיל',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = view.customer;
    final tag = _tagLabel[view.status] ?? view.status;
    // Watch live so orders placed while the sheet is open appear immediately
    // (@index.html:16612-16613 `SYS_ORDERS.filter(o=>o.who===name)`).
    final orders =
        ref.watch(ordersEngineProvider).where((o) => o.who == c.name).toList();

    // M4: recompute header stats from the LIVE orders so they stay in sync
    // with the order list below (the frozen aggregate snapshot on `c` lags
    // until the CustomerProvider re-emits, which may be a frame behind).
    final liveOrderCount = orders.length;
    final liveTotalSpend = orders.fold<int>(0, (s, o) => s + o.sum);

    // A13 — the credit ceiling routed through the `computeCredit` callable seam
    // (`customerCreditProvider`). The sync `c.creditLimit` is shown IMMEDIATELY
    // (the loading/error fallback), then refined to the resolved figure. OFF
    // (default) the callable returns the SAME local derivation, so
    // `creditLimit == c.creditLimit` → the displayed number never changes
    // (byte-identical, no flicker); ON it upgrades to the server-canonical value.
    final creditLimit =
        ref.watch(customerCreditProvider(c.name)).valueOrNull?.creditLimit ??
        c.creditLimit;

    final livePct =
        creditLimit == 0
            ? 0
            : ((liveTotalSpend / creditLimit) * 100).round().clamp(0, 100);
    final liveSites =
        orders.map((o) => o.site).where((s) => s.isNotEmpty).toSet().length;
    final balance = (creditLimit - liveTotalSpend).clamp(
      0,
      creditLimit,
    ); // יתרה ≥ 0

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
      child: SingleChildScrollView(
        // Directional (start/top/end/bottom) so RTL/LTR both lay out correctly
        // (gate 62 — no hard-coded left/right edge inset).
        padding: const EdgeInsetsDirectional.fromSTEB(
          BsTokens.space4,
          BsTokens.space4,
          BsTokens.space4,
          BsTokens.space5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '👷',
              style: TextStyle(fontSize: 34),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: BsTokens.space2),
            Text(
              c.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tag,
              textAlign: TextAlign.center,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            ),
            const SizedBox(height: BsTokens.space4),
            Row(
              children: [
                tile('$liveOrderCount', 'הזמנות'),
                tile('₪${_grouped(liveTotalSpend)}', 'סך רכש'),
                tile('$livePct%', 'אשראי'),
              ],
            ),
            const SizedBox(height: BsTokens.space4),
            row('מסגרת אשראי', '₪${_grouped(creditLimit)}'),
            row('נוצל', '₪${_grouped(liveTotalSpend)}'),
            row('יתרה זמינה', '₪${_grouped(balance)}'),
            row('אתרי בנייה', '$liveSites'),
            // #ai-credit-explain — when AI is live, explain what this utilisation
            // means before approving the next order. gateway null (demo) → not in
            // the tree → the detail sheet is byte-identical.
            if (ref.watch(claudeGatewayProvider) != null) ...[
              const SizedBox(height: BsTokens.space3),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                      () => Navigator.of(context).push(
                        CreditExplainScreen.route(
                          name: c.name,
                          creditLimit: creditLimit,
                          used: liveTotalSpend,
                          balance: balance,
                          pct: livePct,
                        ),
                      ),
                  icon: const Text('💳'),
                  label: const Text('הסבר אשראי'),
                ),
              ),
            ],
            if (orders.isNotEmpty) ...[
              const SizedBox(height: BsTokens.space4),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'ההזמנות של ${c.name}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: BsTokens.space2),
              for (final o in orders)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '📦 ${o.id}',
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '₪${_grouped(o.sum)}',
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: BsTokens.space3),
                      _StagePill(
                        label: _kOrderStageLabel[o.stage] ?? o.stage,
                        color: _kOrderStageColor[o.stage] ?? BsTokens.brand,
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//  🛠️ ניהול — the 5 management tools (M5, the FINAL tab → screen COMPLETE)
// ───────────────────────────────────────────────────────────────────────────

/// The 🛠️ ניהול tab body — the manager's management center, the FINAL manager
/// wave. A faithful port of the legacy `renderMgrManage` (@index.html:16645-16890),
/// an accordion of 5 management tools. Only ONE section is open at a time
/// (mirroring the legacy module-scoped `mgrManageOpen`); tapping a header toggles
/// it. The tools (verbatim legacy emoji + title + sub-title @16653/16687/16715/
/// 16733):
///   1. 🗂️ קטגוריות — the LIVE catalog category list + per-category counts (the
///      `managerAnalyticsProvider.catalogCategories` map — the same TREES-by-`cat`
///      tally the legacy SECTION 3 builds @16716), header `קטגוריות פעילות (N)` +
///      the verbatim hint.
///   2. ⚙️ הגדרות אפליקציה — the contractor-app config rows VERBATIM from the
///      legacy constants (SECTION 4 @16733): תוספת משלוח אקספרס=₪120 (`EXPRESS_FEE`
///      corrected to 120 to match `deliveryFeeFor(CartDelivery.express)`) ·
///      מסגרת אשראי לקבלן=₪50,000 (`creditLimit` @11963) · שיעור מע״מ=18%
///      (`VAT_RATE` @11941) + the verbatim hint.
///   3. 🌳 עץ המוצרים — an inline summary of the catalog product-tree (the legacy
///      SECTION 1 manages the per-product accessory tree; the inline summary names
///      the verbatim sub-title + the live product/category totals).
///   4. 🏷️ מותגים ומחירים — the brands list from `lib/data/brands.dart` (`kBrands`)
///      — `emoji name` + tagline + product count.
///   5. 🔬 בדיקות רגרסיה — routes to the existing `RegressionPanelScreen` (the same
///      target the old manager dial used).
///
/// LIGHT only — white `cardLight` cards on `bgLight`, `inkLight`/`mutedLight` text,
/// `brand` accents. NO dark tokens.
class _ManageTab extends ConsumerStatefulWidget {
  const _ManageTab();

  @override
  ConsumerState<_ManageTab> createState() => _ManageTabState();
}

class _ManageTabState extends ConsumerState<_ManageTab> {
  /// The currently-open accordion section key, or `''` when all are collapsed
  /// (the legacy module-scoped `let mgrManageOpen=''`). Local widget state; no
  /// engine/global write.
  String _open = '';

  void _toggle(String key) => setState(() => _open = _open == key ? '' : key);

  /// cluster #85ח — decide a vacation request. Writes the SHARED
  /// [vacationRequestsProvider] (the requester's own בקשות list reflects the
  /// decision live), drops the decision onto the requester's 🔔 bell feed
  /// ([workerNotifsProvider], #18 — the request carries the exact login
  /// username, so no worker-index fan-out is needed), and — for a WORKER's
  /// request only (F-26) — additionally posts it into the existing
  /// worker↔manager chat thread (`th-worker-manager`, sys_chat — the worker
  /// sees it in שיחות → מנהל) plus a manager-side toast. A courier's request
  /// (#86.3) gets the bell only — see the inline comment below.
  void _decideVacation(VacationRequest r, {required bool approve}) {
    final notifier = ref.read(vacationRequestsProvider.notifier);
    if (approve) {
      notifier.approve(r.id);
    } else {
      notifier.reject(r.id);
    }
    // 🔔 #18 — the decision lands on the requester's bell (per-username, so
    // it is correct for a worker AND a courier alike).
    ref
        .read(workerNotifsProvider.notifier)
        .addNotification(
          username: r.username,
          emoji: approve ? '✅' : '❌',
          title: approve ? 'בקשת החופשה אושרה' : 'בקשת החופשה נדחתה',
          body: r.range,
        );
    // F-26 · the chat line goes to 'th-worker-manager' — a WORKER-audience
    // thread a courier never sees, and the text is second-person. So it is
    // sent ONLY for a worker's request: a courier requester gets the 🔔 bell
    // above (already per-username and correct), and no personal decision is
    // broadcast into the shared couriers group nor faked into a channel that
    // doesn't exist in the courier's chat list.
    if (!_isCourierVacationRequest(r)) {
      ref
          .read(chatEngineProvider.notifier)
          .send(
            'th-worker-manager',
            BsRole.manager,
            approve
                ? '✅ בקשת החופשה שלך (${r.range}) אושרה'
                : '❌ בקשת החופשה שלך (${r.range}) נדחתה',
          );
    }
    showToast(
      context,
      approve
          ? '✅ אושרה חופשה: ${r.workerName} · ${r.range}'
          : '❌ נדחתה חופשה: ${r.workerName} · ${r.range}',
    );
  }

  @override
  Widget build(BuildContext context) {
    // The LIVE catalog category distribution (cat → product count) — the same
    // map the 📊 dashboard reads, off the shared engine's analytics. Sorted by
    // count desc so the biggest categories read first (a stable display order).
    final cats = ref.watch(
      managerAnalyticsProvider.select((a) => a.catalogCategories),
    );
    final catEntries =
        cats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final totalProducts = cats.values.fold<int>(0, (s, n) => s + n);

    // The LIVE worker-approval queue — tasks the worker submitted (status
    // `review`), read off the SHARED worker-tasks engine. A worker "שלח לאישור"
    // surfaces here with no refresh; approving/rejecting writes back live.
    final pending = ref.watch(pendingApprovalTasksProvider);

    // cluster #85ח — the LIVE vacation-request queue (bs.vacation-requests.v1):
    // requests the worker filed from the worker board's טפסים → בקשת חופשה.
    final vacations = ref.watch(vacationRequestsProvider);
    final pendingVacations =
        vacations.where((v) => v.status == kVacationPending).length;

    return ListView(
      // Directional (start/top/end/bottom) so RTL/LTR both lay out correctly
      // (gate 62 — no hard-coded left/right edge inset).
      padding: const EdgeInsetsDirectional.fromSTEB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        // The legacy intro line (@index.html:16650 `mm-intro`).
        const _ManageIntro(),
        const SizedBox(height: BsTokens.space4),

        // 0. 👷 אישורי עובדים — the LIVE cross-persona link (W3): the worker's
        // submitted tasks, approve/reject straight onto the shared engine. A
        // count badge in the header surfaces how many are waiting.
        _ManageSection(
          sectionKey: 'approvals',
          emoji: '👷',
          title: 'אישורי עובדים',
          sub: 'משימות שעובדים שלחו לאישור',
          open: _open == 'approvals',
          onTap: () => _toggle('approvals'),
          badge: pending.length,
          child: _ApprovalsBody(
            pending: pending,
            onApprove: (t) {
              // 🪙 #22 — coins + the worker's ✅ bell fire AT DECISION TIME on
              // the single unified engine (Wave T1): approve runs its
              // review→done side-effects once, guarded by the `review` status
              // (no double award).
              ref.read(tasksProvider.notifier).approve(t.id);
              showToast(context, '✅ אושר: ${t.name}');
            },
            onReject: (t) async {
              // 📝 #12 — optional rejection reason (promptRejectReason):
              // null = cancelled (no reject); the reason rides the unified
              // engine's reject (side-map + the worker's 🔁 bell), Wave T1's
              // single source of truth.
              final why = await promptRejectReason(context);
              if (why == null || !context.mounted) return;
              ref.read(tasksProvider.notifier).reject(t.id, reason: why);
              showToast(context, '↩️ נדחה: ${t.name}');
            },
          ),
        ),
        const SizedBox(height: BsTokens.space3),

        // 0.5 🏖️ בקשות חופשה (cluster #85ח) — vacation requests the worker
        // filed from the worker board's טפסים screen, decided here LIVE on the
        // shared [vacationRequestsProvider]; the worker's own בקשות list flips
        // through the same provider, and a chat line lands in his מנהל thread.
        _ManageSection(
          sectionKey: 'vacations',
          emoji: '🏖️',
          title: 'בקשות חופשה',
          sub: 'בקשות חופשה שעובדים ושליחים הגישו',
          open: _open == 'vacations',
          onTap: () => _toggle('vacations'),
          badge: pendingVacations,
          child: _VacationsBody(
            requests: vacations,
            onApprove: (r) => _decideVacation(r, approve: true),
            onReject: (r) => _decideVacation(r, approve: false),
          ),
        ),
        const SizedBox(height: BsTokens.space3),

        // 1. 🗂️ קטגוריות — the LIVE category list.
        _ManageSection(
          sectionKey: 'cats',
          emoji: '🗂️',
          title: 'קטגוריות',
          sub: 'ניהול קטגוריות הקטלוג',
          open: _open == 'cats',
          onTap: () => _toggle('cats'),
          child: _CategoriesBody(entries: catEntries),
        ),
        const SizedBox(height: BsTokens.space3),

        // 2. ⚙️ הגדרות אפליקציה — the verbatim config rows.
        _ManageSection(
          sectionKey: 'settings',
          emoji: '⚙️',
          title: 'הגדרות אפליקציה',
          sub: 'פרמטרים שהקבלן רואה',
          open: _open == 'settings',
          onTap: () => _toggle('settings'),
          child: const _AppSettingsBody(),
        ),
        const SizedBox(height: BsTokens.space3),

        // 3. 🌳 עץ המוצרים — an inline summary of the catalog tree.
        _ManageSection(
          sectionKey: 'trees',
          emoji: '🌳',
          title: 'עץ המוצרים',
          sub: 'עריכת האביזרים המשלימים של כל מוצר',
          open: _open == 'trees',
          onTap: () => _toggle('trees'),
          child: _ProductTreeBody(
            categoryCount: cats.length,
            productCount: totalProducts,
          ),
        ),
        const SizedBox(height: BsTokens.space3),

        // 4. 🏷️ מותגים ומחירים — the brands list.
        _ManageSection(
          sectionKey: 'brands',
          emoji: '🏷️',
          title: 'מותגים ומחירים',
          sub: 'עריכת המותגים והמחירים של כל מוצר',
          open: _open == 'brands',
          onTap: () => _toggle('brands'),
          child: const _BrandsBody(),
        ),
        const SizedBox(height: BsTokens.space3),

        // 5. 🔬 בדיקות רגרסיה — DEV-ONLY internal tooling (#6). Gated to debug
        // builds so the test_harness runner never reaches an end user who selects
        // the manager persona in a shipped release (mirrors BackendDebugBadge's
        // kDebugMode gate). The screen + runner stay in code (reversible); a
        // release build tree-shakes the unreachable panel out.
        if (kDebugMode) ...[
          _ManageSection(
            sectionKey: 'regression',
            emoji: '🔬',
            title: 'בדיקות רגרסיה',
            sub: 'הרצת חבילת הבדיקות המלאה של האפליקציה',
            open: _open == 'regression',
            onTap: () => _toggle('regression'),
            child: _RegressionBody(
              onOpen:
                  () =>
                      Navigator.of(context).push(RegressionPanelScreen.route()),
            ),
          ),
          const SizedBox(height: BsTokens.space3),
        ],

        // 6. 🔑 שיוך תפקידים (A12 — launch Phase A) — the manager assigns a role
        // to a user via the `setRole` callable seam. SELF-CONTAINED in
        // manager_role_assign_sheet.dart; this is just the mount hook (one
        // button → the sheet). Gracefully disabled with a clear message when no
        // live backend (the sheet gates on authGatewayProvider).
        _ManageSection(
          sectionKey: 'roles',
          emoji: '🔑',
          title: 'שיוך תפקידים',
          sub: 'הקצאת תפקיד (חנות / שליח / עובד / מנהל) למשתמש',
          open: _open == 'roles',
          onTap: () => _toggle('roles'),
          child: _RoleAssignBody(
            onOpen: () => showManagerRoleAssignSheet(context),
          ),
        ),
      ],
    );
  }
}

/// The 🛠️ tab intro line (@index.html:16650 `mm-intro`) — a soft `brand`-tinted
/// banner with the verbatim copy.
class _ManageIntro extends StatelessWidget {
  const _ManageIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space4,
        vertical: BsTokens.space3,
      ),
      decoration: BoxDecoration(
        color: BsTokens.brand.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(cfgRadius(context)),
      ),
      child: const Text(
        '🛠️ שליטה מלאה על אפליקציית הקבלן — כל שינוי מתעדכן מיידית.',
        style: TextStyle(
          color: BsTokens.inkLight,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    );
  }
}

/// One accordion section (@index.html:16855 `mmSection`) — a WHITE card with a
/// tappable header (the `emoji` icon, the `title` + `sub` two-line label, and a
/// ▾/‹ chevron) that reveals the [child] body when [open]. Tapping the header
/// calls [onTap] (the parent toggles which one is open).
class _ManageSection extends StatelessWidget {
  const _ManageSection({
    required this.sectionKey,
    required this.emoji,
    required this.title,
    required this.sub,
    required this.open,
    required this.onTap,
    required this.child,
    this.badge = 0,
  });

  final String sectionKey;
  final String emoji;
  final String title;
  final String sub;
  final bool open;
  final VoidCallback onTap;
  final Widget child;

  /// Optional count badge next to the title (0 = no badge) — used by the
  /// 👷 אישורי עובדים section to surface how many tasks are awaiting approval.
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            label: '$emoji $title',
            // #31 — the shared accordion-section header (opens/closes a No-Code
            // management section); in help mode the HelpTarget rings + explains
            // it. One wrapper covers every section instance of _ManageSection.
            child: HelpTarget(
              title: 'מקטע ניהול',
              body:
                  'פותח/סוגר מקטע ניהול באקורדיון (מקטע אחד פתוח בכל רגע). '
                  'חל על כל המקטעים: אישורי עובדים, בקשות חופשה, קטגוריות, '
                  'הגדרות אפליקציה, עץ מוצרים, מותגים, בדיקות רגרסיה ושיוך '
                  'תפקידים.',
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(cfgRadius(context)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(cfgRadius(context)),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(BsTokens.space4),
                    child: Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: BsTokens.space3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        color: BsTokens.inkLight,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (badge > 0) ...[
                                    const SizedBox(width: BsTokens.space2),
                                    _CountBadge(count: badge),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sub,
                                style: const TextStyle(
                                  color: BsTokens.mutedLight,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: BsTokens.space2),
                        Text(
                          open ? '▾' : '‹',
                          style: const TextStyle(
                            color: BsTokens.mutedLight,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (open)
            Padding(
              // Directional (start/top/end/bottom) so RTL/LTR both lay out
              // correctly (gate 62 — no hard-coded left/right edge inset).
              padding: const EdgeInsetsDirectional.fromSTEB(
                BsTokens.space4,
                0,
                BsTokens.space4,
                BsTokens.space4,
              ),
              child: child,
            ),
        ],
      ),
    );
  }
}

/// A small `brand`-fill count badge for a section header (the 👷 אישורי עובדים
/// pending count). White number on `brand`; LIGHT-safe.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ממתינים לאישור: $count',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        constraints: const BoxConstraints(minWidth: 22),
        decoration: BoxDecoration(
          color: BsTokens.brand,
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        ),
        child: Text(
          '$count',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: bsOnAccent(context),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// The 👷 אישורי עובדים body — the manager's LIVE worker-approval queue. Lists
/// every task the worker submitted (`pending`, status `review`), each with the
/// worker name, the `🕒 days · steps` line, the worker's note, and two actions:
/// ✅ אשר (review → done, ✅ אושר) and ↩️ דחה (review → rejected, back to the
/// worker). Both write the SHARED unified [tasksProvider], so the worker's own
/// screen reflects the decision live. An empty queue shows a calm note.
class _ApprovalsBody extends StatelessWidget {
  const _ApprovalsBody({
    required this.pending,
    required this.onApprove,
    required this.onReject,
  });

  final List<PersonaTask> pending;
  final void Function(PersonaTask) onApprove;
  final void Function(PersonaTask) onReject;

  @override
  Widget build(BuildContext context) {
    if (pending.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: BsTokens.space2),
        child: Text(
          '🎉 אין משימות הממתינות לאישור.',
          style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final t in pending)
          Padding(
            padding: const EdgeInsets.only(bottom: BsTokens.space2),
            child: _ApprovalRow(
              task: t,
              onApprove: () => onApprove(t),
              onReject: () => onReject(t),
            ),
          ),
      ],
    );
  }
}

/// One pending-approval row — a soft `bgLight` panel with the task name, the
/// `🦺 worker · 🕒 days · steps` meta, the worker's PROOF PHOTO (#85ב), the
/// note, and the ✅ אשר / ↩️ דחה buttons.
/// The buttons are keyed `approve-<id>` / `reject-<id>` so the W3 test can tap a
/// specific task's decision.
class _ApprovalRow extends ConsumerWidget {
  const _ApprovalRow({
    required this.task,
    required this.onApprove,
    required this.onReject,
  });

  final PersonaTask task;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // #85ב — the submitted proof photo lives on the RICH tasks engine (the
    // legacy PersonaTask carries no photo field); ids are shared across both
    // engines (the W3 bridge), so this lookup surfaces the worker's actual
    // capture next to the decision buttons.
    final richMatch =
        ref.watch(tasksProvider).where((x) => x.id == task.id).toList();
    final photo = richMatch.isEmpty ? null : richMatch.first.photo;
    // #5 — the worker's LIVE submit note also rides the rich engine (the
    // legacy PersonaTask.note never changes after the seed); prefer it when
    // non-empty so the manager reads what the worker actually wrote.
    final note =
        richMatch.isNotEmpty && richMatch.first.note.isNotEmpty
            ? richMatch.first.note
            : task.note;
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.bgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.name,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '🦺 ${kWorkers[(task.worker >= 0 && task.worker < kWorkers.length) ? task.worker : 0]} · 🕒 ${task.days} ימים · ${task.steps} שלבים',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
          ),
          if (photo != null) ...[
            const SizedBox(height: BsTokens.space2),
            // #85ב — the manager SEES the worker's proof before deciding:
            // the SHARED [taskPhotoWidget] (worker_task_detail_sheet.dart) —
            // a real Image.memory for a data-URL, the honest placeholder for
            // the legacy 'demo' seeds — both sides render the same proof.
            taskPhotoWidget(photo, height: 120),
          ],
          if (note.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              note,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
          ],
          const SizedBox(height: BsTokens.space3),
          Row(
            children: [
              Expanded(
                // #31 — help mode rings + explains; otherwise approves the task.
                child: HelpTarget(
                  title: 'אשר משימה',
                  body:
                      'מאשר משימה שעובד שלח לאישור: המשימה עוברת ל׳בוצע׳, מזכה '
                      'מטבעות ושולחת התראת ✅ לעובד. כתיבה למנוע המשותף — '
                      'נראית מיד בלוח העובד.',
                  child: _ApprovalButton(
                    key: ValueKey('approve-${task.id}'),
                    label: '✅ אשר',
                    color: const Color(0xFF1F8A4C),
                    onPressed: onApprove,
                  ),
                ),
              ),
              const SizedBox(width: BsTokens.space2),
              Expanded(
                // #31 — help mode rings + explains; otherwise rejects the task.
                child: HelpTarget(
                  title: 'דחה משימה',
                  body:
                      'דוחה משימה שנשלחה לאישור ומחזיר אותה לעובד עם סיבת '
                      'דחייה. הסיבה והסטטוס מתעדכנים מיד בלוח העובד.',
                  child: _ApprovalButton(
                    key: ValueKey('reject-${task.id}'),
                    label: '↩️ דחה',
                    color: BsTokens.cardLight,
                    textColor: BsTokens.inkLight,
                    bordered: true,
                    onPressed: onReject,
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

/// A pill action button used by an approval row — a `color` fill with [textColor]
/// text (or a bordered light outline when [bordered]). White text by default.
class _ApprovalButton extends StatelessWidget {
  const _ApprovalButton({
    required this.label,
    required this.color,
    required this.onPressed,
    super.key,
    this.textColor = Colors.white,
    this.bordered = false,
  });

  final String label;
  final Color color;
  final Color textColor;
  final bool bordered;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            border:
                bordered ? Border.all(color: const Color(0xFFE2E2E2)) : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// The 🏖️ בקשות חופשה body (cluster #85ח) — pending requests first (each with
/// ✅ אשר / ❌ דחה), then the decided history with read-only status pills. An
/// empty queue shows a calm note. Decision buttons reuse [_ApprovalButton] and
/// are keyed `vac-approve-<id>` / `vac-reject-<id>` so tests can tap a
/// specific request's decision.
class _VacationsBody extends StatelessWidget {
  const _VacationsBody({
    required this.requests,
    required this.onApprove,
    required this.onReject,
  });

  final List<VacationRequest> requests;
  final void Function(VacationRequest) onApprove;
  final void Function(VacationRequest) onReject;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: BsTokens.space2),
        child: Text(
          'אין בקשות חופשה.',
          style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
      );
    }
    final pending =
        requests.where((r) => r.status == kVacationPending).toList();
    final decided =
        requests.where((r) => r.status != kVacationPending).toList()..sort(
          (a, b) => (b.decidedTs ?? b.createdTs).compareTo(
            a.decidedTs ?? a.createdTs,
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final r in pending)
          Padding(
            padding: const EdgeInsets.only(bottom: BsTokens.space2),
            child: _VacationRequestRow(
              request: r,
              onApprove: () => onApprove(r),
              onReject: () => onReject(r),
            ),
          ),
        for (final r in decided)
          Padding(
            padding: const EdgeInsets.only(bottom: BsTokens.space2),
            child: _VacationRequestRow(request: r),
          ),
      ],
    );
  }
}

/// F-26/F-27 · is this vacation request a courier's? [VacationRequest.role]
/// is authoritative for new records ('courier' is written by the courier
/// board's forms screen). Legacy records persisted before the role field all
/// load with the back-compat default 'worker' — for those, a lookup in the
/// seeded [kBoardAccounts] by username keeps an old courier request honest
/// (the shared 'demo' username is in no seeded account → treated as worker,
/// the pre-F-26 behavior).
bool _isCourierVacationRequest(VacationRequest r) {
  if (r.role == 'courier') return true;
  if (r.role != 'worker') return false;
  return kBoardAccounts.any(
    (a) => a.username == r.username && a.role == BoardRole.courier,
  );
}

/// One vacation-request row — `🛵/🦺 requester · range` (the icon follows the
/// requester's board role, F-27) + the reason, and (while pending) the
/// ✅ אשר / ❌ דחה buttons; a decided row carries a read-only status pill
/// ([_StagePill]) instead.
class _VacationRequestRow extends StatelessWidget {
  const _VacationRequestRow({
    required this.request,
    this.onApprove,
    this.onReject,
  });

  final VacationRequest request;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final pending = request.status == kVacationPending;
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.bgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  // F-27: 🛵 for a courier's request, 🦺 for a worker's — the
                  // manager can tell the boards apart in the shared queue.
                  '${_isCourierVacationRequest(request) ? '🛵' : '🦺'} ${request.workerName} · ${request.range}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              if (!pending)
                _StagePill(
                  label:
                      request.status == kVacationApproved ? 'אושרה' : 'נדחתה',
                  color:
                      request.status == kVacationApproved
                          ? const Color(0xFF1F8A4C)
                          : BsTokens.danger,
                ),
            ],
          ),
          if (request.reason.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              request.reason,
              style: const TextStyle(
                color: BsTokens.mutedLight,
                fontSize: 12.5,
              ),
            ),
          ],
          if (pending) ...[
            const SizedBox(height: BsTokens.space3),
            Row(
              children: [
                Expanded(
                  // #31 — help mode rings + explains; otherwise approves leave.
                  child: HelpTarget(
                    title: 'אשר בקשת חופשה',
                    body:
                        'מאשר בקשת חופשה שעובד/שליח הגיש: מעדכן את רשימת '
                        'הבקשות שלו ושולח התראה. הסטטוס מתעדכן מיד אצל המבקש.',
                    child: _ApprovalButton(
                      key: ValueKey('vac-approve-${request.id}'),
                      label: '✅ אשר',
                      color: const Color(0xFF1F8A4C),
                      onPressed: onApprove ?? () {},
                    ),
                  ),
                ),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  // #31 — help mode rings + explains; otherwise rejects leave.
                  child: HelpTarget(
                    title: 'דחה בקשת חופשה',
                    body:
                        'דוחה את בקשת החופשה ומעדכן את המבקש בהתראה. הסטטוס '
                        'מתעדכן מיד אצל העובד/שליח.',
                    child: _ApprovalButton(
                      key: ValueKey('vac-reject-${request.id}'),
                      label: '❌ דחה',
                      color: BsTokens.cardLight,
                      textColor: BsTokens.inkLight,
                      bordered: true,
                      onPressed: onReject ?? () {},
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A small label→value row inside a management section (the legacy `mm-acc` /
/// `mm-set` row) — the `label` on the start, the `value` on the end.
class _ManageRow extends StatelessWidget {
  const _ManageRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(width: BsTokens.space3),
          Text(
            value,
            style: const TextStyle(
              color: BsTokens.mutedLight,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// A `mutedLight` hint line at the foot of a management section (the legacy
/// `mm-hint`).
class _ManageHint extends StatelessWidget {
  const _ManageHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: BsTokens.space2),
      child: Text(
        text,
        style: const TextStyle(
          color: BsTokens.mutedLight,
          fontSize: 12,
          height: 1.3,
        ),
      ),
    );
  }
}

/// The 🗂️ קטגוריות body (@index.html:16715-16729 SECTION 3) — the LIVE catalog
/// category list: a `קטגוריות פעילות (N)` header, then one row per category with
/// its product count (`<count> מוצרים`), and the verbatim hint. Counts come from
/// the live `managerAnalyticsProvider` map, so they track the catalog.
class _CategoriesBody extends StatelessWidget {
  const _CategoriesBody({required this.entries});

  final List<MapEntry<String, int>> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'קטגוריות פעילות (${entries.length})',
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: BsTokens.space2),
        for (final e in entries)
          _ManageRow(label: e.key, value: '${e.value} מוצרים'),
        const _ManageHint('שינוי שם קטגוריה מעדכן את כל המוצרים שבה.'),
      ],
    );
  }
}

/// The ⚙️ הגדרות אפליקציה body (@index.html:16733-16740 SECTION 4) — the three
/// contractor-app config rows, VERBATIM values from the legacy constants, plus
/// the verbatim hint. Display-only (the legacy `prompt()`-edit has no backend
/// here; the values are the source of truth the contractor cart already reads).
class _AppSettingsBody extends StatelessWidget {
  const _AppSettingsBody();

  /// @legacy index.html:11961 `let EXPRESS_FEE=80;` — corrected to 120 to
  /// match `deliveryFeeFor(CartDelivery.express)` in store_screen.dart.
  static const int _expressFee = 120;

  /// @legacy index.html:11963 `let creditLimit=50000;` (rendered toLocaleString).
  static const int _creditLimit = 50000;

  /// @legacy index.html:11941 `const VAT_RATE = 0.18;` → 18%. Derived from the
  /// single-source [kVatRate] so the manager's displayed rate can't drift from
  /// the catalog browse price / cart charge.
  static int get _vatPercent => (kVatRate * 100).round();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _ManageRow(label: 'תוספת משלוח אקספרס', value: '₪$_expressFee'),
        _ManageRow(
          label: 'מסגרת אשראי לקבלן',
          value: '₪${_grouped(_creditLimit)}',
        ),
        _ManageRow(label: 'שיעור מע״מ', value: '$_vatPercent%'),
        _ManageHint(
          'המע״מ קבוע לפי חוק ($_vatPercent%). תוספת האקספרס והאשראי נראים מיד בעגלת הקבלן.',
        ),
      ],
    );
  }
}

/// The 🌳 עץ המוצרים body (@index.html:16652-16685 SECTION 1) — the legacy section
/// manages the per-product accessory tree via a product-picker + `prompt()`-driven
/// add/edit/delete of complementary accessories against a backend. With no such
/// backend here, this renders an inline SUMMARY of the catalog tree: the verbatim
/// section purpose + the live tree size (categories × products). NO invented edit.
class _ProductTreeBody extends StatelessWidget {
  const _ProductTreeBody({
    required this.categoryCount,
    required this.productCount,
  });

  final int categoryCount;
  final int productCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'עריכת האביזרים המשלימים של כל מוצר — בחירת מוצר חושפת את עץ האביזרים שלו.',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: BsTokens.space2),
        _ManageRow(label: 'מוצרים בעץ', value: '$productCount'),
        _ManageRow(label: 'קטגוריות', value: '$categoryCount'),
        const _ManageHint(
          'כל מוצר נושא עץ אביזרים משלימים (חובה / אופציונלי).',
        ),
      ],
    );
  }
}

/// The 🏷️ מותגים ומחירים body (@index.html:16687-16713 SECTION 2) — the brands
/// list. The legacy section edits per-product brand+price rows; here we surface
/// the catalog's REAL brand roster from `lib/data/brands.dart` (`kBrands`): each
/// brand's `emoji name`, its tagline, and its product count (when known).
class _BrandsBody extends StatelessWidget {
  const _BrandsBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'מותגים (${kBrands.length})',
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: BsTokens.space2),
        for (final b in kBrands)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.name,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (b.tagline.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          b.tagline,
                          style: const TextStyle(
                            color: BsTokens.mutedLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (b.productCount > 0) ...[
                  const SizedBox(width: BsTokens.space2),
                  Text(
                    '${b.productCount} מוצרים',
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// The 🔬 בדיקות רגרסיה body — a short note + a `brand` action button that opens
/// the existing `RegressionPanelScreen` (the same target the old manager dial
/// used). [onOpen] performs the `Navigator.push`.
class _RegressionBody extends StatelessWidget {
  const _RegressionBody({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'הרצת חבילת בדיקות הרגרסיה המלאה (קטלוג · מאתר · מנוע תאימות · state · '
          'ניווט) על המכשיר.',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: BsTokens.space3),
        // #31 — help mode rings + explains; this whole body sits inside the
        // kDebugMode gate, so the HelpTarget is dormant in release just like
        // the button itself.
        HelpTarget(
          title: 'בדיקות רגרסיה',
          body: 'פותח את מרכז בדיקות הרגרסיה (כלי פיתוח). קיים רק בבילד debug.',
          child: Material(
            color: BsTokens.brand,
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            child: InkWell(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              onTap: onOpen,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '🔬 פתח מרכז בדיקות רגרסיה',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: bsOnAccent(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The 🔑 שיוך תפקידים body (A12) — a short note + a `brand` action button that
/// opens the self-contained [ManagerRoleAssignSheet] (manager_role_assign_sheet
/// .dart). The sheet owns ALL the logic (phone→uid lookup, the assignRole call,
/// the no-backend gating); this is purely the mount hook. [onOpen] performs the
/// `showModalBottomSheet`. Keyed `open-role-assign` so a test can tap it.
class _RoleAssignBody extends StatelessWidget {
  const _RoleAssignBody({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'הקצאת תפקיד למשתמש לפי טלפון או מזהה (uid). השיוך מופעל ע״י השרת '
          'של בעל המערכת ומשפיע על המשתמש בהתחברות הבאה.',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: BsTokens.space3),
        // #31 — help mode rings + explains; otherwise opens the role-assign
        // sheet.
        HelpTarget(
          title: 'שיוך תפקידים',
          body:
              'פותח את גיליון שיוך התפקידים: הקצאת תפקיד (חנות/שליח/עובד/מנהל) '
              'למשתמש לפי טלפון או מזהה. השיוך מבוצע דרך השרת של בעל המערכת.',
          child: Material(
            color: BsTokens.brand,
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            child: InkWell(
              key: const ValueKey('open-role-assign'),
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              onTap: onOpen,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '🔑 פתח שיוך תפקידים',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: bsOnAccent(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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

/// #31 — the per-tab "מצב היכרות" (title, body) explanations, indexed in
/// lockstep with [_kManagerTabs]. The four pills are built in one seg() loop
/// (`_ManagerToggle`), so each pill's HelpTarget reads its text from here by
/// index — one bubble per tab.
const List<(String, String)> _kManagerTabHelp = [
  (
    'לוח בקרה',
    'מציג את לוח הבקרה החי: אריחי מדדים (הזמנות פתוחות, מוצרים, חנויות) '
        'וצינור ההזמנות לפי שלב.',
  ),
  (
    'הזמנות',
    'פותח את מרכז ניהול ההזמנות החי — רשימת ההזמנות, סינון לפי שלב וקידום '
        'שלב (עקיפת-מנהל).',
  ),
  (
    'לקוחות',
    'מציג את רשימת הקבלנים-הלקוחות החיה: ניצול אשראי, מספר אתרים והזמנות '
        'לכל קבלן.',
  ),
  (
    'ניהול',
    'פותח את מרכז הניהול (No-Code): אישורי משימות, בקשות חופשה, קטגוריות, '
        'הגדרות אפליקציה, עץ מוצרים, מותגים ושיוך תפקידים.',
  ),
];
