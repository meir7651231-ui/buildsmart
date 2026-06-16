import 'dart:convert';

import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/repositories/orders_local.dart'
    show visibleOrderIdsProvider;
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/courier_delivery_detail_sheet.dart';
import 'package:buildsmart/screens/courier_portal_tab.dart';
import 'package:buildsmart/screens/courier_profile_screen.dart';
import 'package:buildsmart/screens/courier_reports_tab.dart';
import 'package:buildsmart/screens/courier_settings_screen.dart';
import 'package:buildsmart/screens/docs_readiness_gate.dart';
import 'package:buildsmart/screens/persona_pod_sheet.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/screens/worker_notifs_sheet.dart'
    show workerNotifAgo;
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/courier_clock.dart';
import 'package:buildsmart/state/courier_profile_store.dart';
import 'package:buildsmart/state/docs_readiness.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:buildsmart/state/rewards_state.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/contact_actions.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🪙 DEMO-SEED: coins credited to the courier's rewards balance per DELIVERED
/// shipment (COURIER v2 ב — awardCoins on delivered + bell). A fixed demo
/// tariff mirroring `kTaskApprovalCoins` (tasks_engine.dart) — the real
/// per-delivery value comes with the server; NEVER derived from the order sum.
const int kCourierDeliveryCoins = 20;

/// SharedPreferences key (versioned `bs.*.v1`) — per-username set of order ids
/// whose hand-off bell notification ('משלוח חדש') was already emitted, so a
/// reload (F5) or re-login never re-notifies the same real hand-off. אין
/// המצאות: notifications derive only from actual engine stages (pickup/transit
/// = the store really handed the shipment to the courier).
const String kCourierHandoffSeenKey = 'bs.courier-handoff-seen.v1';

/// #31 — "מצב היכרות" copy for the courier's 4 bottom-nav tabs, in order
/// (משלוחים · פורטל · דוחות · אזור אישי). The tabs sit in the nav bar, so a
/// help-mode tap pops [showHelpInfo] with the matching entry rather than
/// switching tab.
const List<(String, String)> _kCourierTabHelp = [
  (
    'משלוחים',
    'הבית שלך — המשלוחים להיום לפי הרכב שבחרת, עם קידום כל משלוח מאיסוף עד מסירה.',
  ),
  (
    'פורטל',
    'מרכז הכלים — ניווט, צי, אזורי-חלוקה, צ׳אט, יעדי-SLA ואישורי-מסירה במקום אחד.',
  ),
  (
    'דוחות',
    'הביצועים שלך — משלוחים שהושלמו, זמני-מסירה ושליחת דוח-יומי לחנות.',
  ),
  (
    'אזור אישי',
    'הפרופיל שלך — פרטי-נהג, נוכחות, טפסים, תעודות-נהג ותלושי-שכר.',
  ),
];

/// 🛵 שליח — the courier role app. Same shell/style as the contractor app, a
/// faithful port of the prototype `screen-courier` (proto 06 §3 / preact 03
/// §2): a single pane with a vehicle picker, the delivery-summary home, and the
/// job list with the real ready→pickup→transit→delivered advance.
///
/// Orders are the shared [sysOrdersProvider]; a delivery the courier marks
/// "נמסר" syncs straight back to the store + manager views. R8 — every
/// string/number is verbatim from [supplier_data].
///
/// #72 — the courier BOARD: gated by [boardAuthProvider] (חוק הלוחות, כלל 4 —
/// מבחוץ לא רואים כלום), then a vehicle-pick first step, then 4 bottom tabs:
/// משלוחים (default) · פורטל ([CourierPortalTab]) · דוחות ([CourierReportsTab])
/// · אזור אישי ([CourierProfileBody]). The delivery card opens the real detail
/// sheet (#76 — courier_delivery_detail_sheet.dart). Deferred (heavier infra):
/// split-shipment job grouping; live navigation is SERVER-READY in the portal.
class CourierDashboardScreen extends ConsumerStatefulWidget {
  const CourierDashboardScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const CourierDashboardScreen());

  @override
  ConsumerState<CourierDashboardScreen> createState() =>
      _CourierDashboardScreenState();
}

class _CourierDashboardScreenState
    extends ConsumerState<CourierDashboardScreen> {
  /// הרכב שנבחר למשמרת הנוכחית — null עד שהשליח בוחר (#72: בחירת הרכב היא
  /// הצעד הראשון אחרי הכניסה; נשמר ל-session המסך הזה בלבד, כמו בפרוטוטייפ).
  String? _vehicle;

  /// F-30 — שומר ה-seed החד-פעמי (אידיום ticket #24): נדלק ברגע שהשליח מקיש
  /// על צ'יפ רכב, כך ש-load מאוחר של פרופיל-השליח לעולם לא דורס בחירה ידנית
  /// טרייה. ה-seed מ"סוג רכב מועדף" רץ רק כשהדגל כבוי ו-[_vehicle] עוד null.
  bool _vehicleTouched = false;

  /// 0 משלוחים (ברירת המחדל) · 1 פורטל · 2 דוחות · 3 אזור אישי (#72).
  int _tab = 0;

  /// COURIER v2 ג — per-username order ids whose 'משלוח חדש' bell notification
  /// was already emitted (persisted under [kCourierHandoffSeenKey] so an F5
  /// never re-notifies). Mutated only by [_sweepHandoffNotifs].
  final Map<String, Set<String>> _handoffSeen = {};

  /// Load-guard (board_auth idiom): the sweep is gated until the persisted
  /// seen-set resolved, so a fast first build can't double-notify a hand-off
  /// that was already notified before the reload.
  bool _handoffSeenLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadHandoffSeen();
  }

  Future<void> _loadHandoffSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kCourierHandoffSeenKey);
      if (raw != null && raw.isNotEmpty) {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        for (final e in m.entries) {
          if (e.value is List) {
            _handoffSeen[e.key] = {
              for (final id in e.value as List)
                if (id is String) id,
            };
          }
        }
      }
    } on Object catch (_) {
      // Corrupt/old payload — start empty (worst case: one repeat 🔔).
    }
    if (!mounted) return;
    _handoffSeenLoaded = true;
    // Catch hand-offs that happened while this board was not mounted (the
    // store handed off, then the courier logged in).
    _sweepHandoffNotifs(ref.read(sysOrdersProvider));
  }

  Future<void> _persistHandoffSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        kCourierHandoffSeenKey,
        jsonEncode({
          for (final e in _handoffSeen.entries) e.key: [...e.value],
        }),
      );
    } on Object catch (_) {}
  }

  /// COURIER v2 ג — 🔔 'משלוח חדש': every order REALLY in the courier's hands
  /// (engine stage `pickup`/`transit`, i.e. the store's "מסור לשליח" hand-off
  /// happened) that was not notified yet appends a bell notification to the
  /// logged courier's per-username [workerNotifsProvider] feed. Runs on every
  /// live engine change (ref.listen in [build]) AND once on mount (post-load),
  /// so hand-offs made while the board was closed are caught. Dedup'd by the
  /// persisted [_handoffSeen] set — a stage never moves backwards, so each
  /// hand-off notifies exactly once.
  void _sweepHandoffNotifs(List<SysOrder> orders) {
    if (!_handoffSeenLoaded || !mounted) return;
    final s = ref.read(boardAuthProvider);
    if (s == null || s.role != BoardRole.courier) return;
    final seen = _handoffSeen.putIfAbsent(s.username, () => <String>{});
    var dirty = false;
    for (final o in orders) {
      final inHand =
          o.stage == OrderStage.pickup || o.stage == OrderStage.transit;
      if (!inHand || seen.contains(o.id)) continue;
      seen.add(o.id);
      dirty = true;
      ref
          .read(workerNotifsProvider.notifier)
          .addNotification(
            username: s.username,
            emoji: '📦',
            title: 'משלוח חדש — נמסר לידיך מהחנות',
            body: '${o.id} · ${o.who} · 📍 ${o.site}',
          );
    }
    if (dirty) _persistHandoffSeen();
  }

  @override
  Widget build(BuildContext context) {
    // חוק הלוחות (כלל 4 — "מבחוץ לא רואים כלום"): בלי session של שליח נבנה אך
    // ורק שער הרישום (WelcomeScreen במצב-תפקיד) — אף widget מתוכן הלוח לא נבנה.
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.courier) {
      return const WelcomeScreen(boardRole: BoardRole.courier);
    }

    // 🔒 #101 — שער-מוכנות מסמכים (HARD gate): between the auth gate and the
    // vehicle gate, block the board until the logged courier's driver
    // certificates are complete + in-date (each kCourierCertPresets present, no
    // expired cert; see [courierDocsReadiness]). LIVE — adding a valid cert via
    // the gate's deep-link re-evaluates and opens the board.
    // [docsGateOverrideProvider] is the TEST SEAM (non-null forces the
    // decision; board tests set true to bypass).
    final ov = ref.watch(docsGateOverrideProvider);
    final r = ref.watch(courierDocsReadyProvider(session.username));
    final docsReady = ov ?? r.ready;
    if (!docsReady) {
      return DocsReadinessGate(role: BoardRole.courier, readiness: r);
    }

    // COURIER v2 ג — live hand-off watcher: a REAL ready→pickup advance by the
    // store while this board is mounted lands as a 🔔 immediately (the
    // mount-time sweep in [_loadHandoffSeen] covers off-screen hand-offs).
    ref.listen<List<SysOrder>>(
      sysOrdersProvider,
      (_, next) => _sweepHandoffNotifs(next),
    );

    // F-30 — חיווט "סוג רכב מועדף" (#86.1) ↔ שער-הרכב: seed חד-פעמי מהפרופיל,
    // רק כשהשליח טרם נגע בבורר וטרם נבחר רכב (אידיום ticket #24 — מגיב לעדכון
    // ה-provider כשה-load נוחת, ובחירה ידנית טרייה לעולם לא נדרסת). id
    // persisted לא-מוכר נדחה בכנות ב-[_preferredHaul] — בלי haulInfo fallback
    // שממציא העדפה. הבחירה למשמרת נשארת אפמרלית by-design; אין כתיבה חזרה
    // לפרופיל בלי פעולת-משתמש מפורשת.
    final preferred = _preferredHaul(session);
    if (!_vehicleTouched && _vehicle == null && preferred.isNotEmpty) {
      _vehicle = preferred;
    }

    // #72 — הזרם אחרי כניסה: קודם בחירת "הרכב שלי היום" (אם טרם נבחר במשמרת
    // הזו) → ואז הבית עם 4 הטאבים.
    final vehicle = _vehicle;
    if (vehicle == null) return _vehicleGate(preferred);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: _appBar(),
        body: _tabBody(session, vehicle),
        // #31 — each tab wrapped in HelpTarget so help mode highlights it +
        // pops a bubble out of the tab (consistent with the app-bar). Outside
        // help mode the BottomNavCell's InkWell switches tab as before.
        bottomNavigationBar: Material(
          color: const Color(0xFFFFFFFF),
          elevation: 8,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 58,
              child: Row(
                children: [
                  Expanded(
                    child: HelpTarget(
                      title: _kCourierTabHelp[0].$1,
                      body: _kCourierTabHelp[0].$2,
                      child: BottomNavCell(
                        icon: Icon(
                          _tab == 0
                              ? Icons.local_shipping
                              : Icons.local_shipping_outlined,
                        ),
                        label: 'משלוחים',
                        selected: _tab == 0,
                        onTap: () => setState(() => _tab = 0),
                      ),
                    ),
                  ),
                  Expanded(
                    child: HelpTarget(
                      title: _kCourierTabHelp[1].$1,
                      body: _kCourierTabHelp[1].$2,
                      child: BottomNavCell(
                        icon: const Icon(Icons.apps),
                        label: 'פורטל',
                        selected: _tab == 1,
                        onTap: () => setState(() => _tab = 1),
                      ),
                    ),
                  ),
                  Expanded(
                    child: HelpTarget(
                      title: _kCourierTabHelp[2].$1,
                      body: _kCourierTabHelp[2].$2,
                      child: BottomNavCell(
                        icon: Icon(
                          _tab == 2
                              ? Icons.insert_chart
                              : Icons.insert_chart_outlined,
                        ),
                        label: 'דוחות',
                        selected: _tab == 2,
                        onTap: () => setState(() => _tab = 2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: HelpTarget(
                      title: _kCourierTabHelp[3].$1,
                      body: _kCourierTabHelp[3].$2,
                      child: BottomNavCell(
                        icon: Icon(
                          _tab == 3 ? Icons.person : Icons.person_outline,
                        ),
                        label: 'אזור אישי',
                        selected: _tab == 3,
                        onTap: () => setState(() => _tab = 3),
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

  /// F-30 — "סוג רכב מועדף" מפרופיל-השליח (#86.1) של ה-username המחובר,
  /// מאומת מול [kVehicleRank] ('' כשלא-נבחר/לא-מוכר — ערך persisted זר אסור
  /// שייפול ל-[haulInfo], שממציא את kHaulTypes.first).
  String _preferredHaul(BoardSession session) {
    final p = ref.watch(
      courierProfileProvider.select(
        (m) => m[session.username]?.preferredHaul ?? '',
      ),
    );
    return kVehicleRank.containsKey(p) ? p : '';
  }

  Widget _tabBody(BoardSession session, String vehicle) {
    switch (_tab) {
      case 1:
        return const CourierPortalTab();
      case 2:
        return const CourierReportsTab();
      case 3:
        // F-30 — רכב-המשמרת מועבר לפרופיל כדי שסטטיסטיקת "בדרך" תשחזר את
        // סמנטיקת רכב-זכאי של טאב המשלוחים (חוזה 6 — null רק במסך העצמאי).
        return CourierProfileBody(vehicle: vehicle);
      default:
        return _deliveriesTab(session, vehicle);
    }
  }

  /// ה-AppBar המשותף ללוח ולשער-הרכב. Each persona reaches profile + settings
  /// from its OWN dashboard — לשליח יש כעת מסכים ייעודיים (#73). RTL: actions
  /// lay out leading→trailing, so this reads bell · profile · settings · exit
  /// from the right. COURIER v2 ג — the 🔔 bell (unread badge) mirrors the
  /// worker board's `WorkerNotifsBell`, reading the courier's own per-username
  /// feed off the SAME [workerNotifsProvider] store.
  AppBar _appBar() {
    return AppBar(
      backgroundColor: BsTokens.cardLight,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: BsTokens.space4,
      title: const Text(
        '🛵 שליח',
        style: TextStyle(
          color: BsTokens.inkLight,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      actions: [
        // #31 — 💡 enters "מצב היכרות"; the wrapped controls then explain
        // themselves in a bubble instead of acting (the 💡 + ✕ stay tappable
        // so the courier can always toggle/exit).
        const HelpToggleButton(),
        const HelpTarget(
          title: 'התראות',
          body:
              'פעמון ההתראות — נפתח לרשימת המשלוחים שנמסרו לידיך מהחנות '
              'והמסירות שהשלמת. התג האדום מציין כמה לא נקראו.',
          child: _CourierNotifsBell(),
        ),
        HelpTarget(
          title: 'פרופיל',
          body: 'האזור האישי שלך — פרטי הנהג, תעודות, טפסים ותלושים.',
          child: IconButton(
            tooltip: 'פרופיל',
            icon: const Icon(Icons.person_outline, color: BsTokens.mutedLight),
            onPressed:
                () => Navigator.of(context).push(CourierProfileScreen.route()),
          ),
        ),
        HelpTarget(
          title: 'הגדרות',
          body: 'הגדרות לוח-השליח — התראות, תצוגה והעדפות אישיות.',
          child: IconButton(
            tooltip: 'הגדרות',
            icon: const Icon(
              Icons.settings_outlined,
              color: BsTokens.mutedLight,
            ),
            onPressed:
                () => Navigator.of(context).push(CourierSettingsScreen.route()),
          ),
        ),
        HelpTarget(
          title: 'יציאה',
          body:
              'יציאה מהלוח חזרה למסך הקודם — אינה מנתקת אותך מהחשבון; '
              'התנתקות מלאה נמצאת באזור האישי.',
          child: TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text(
              '‹ יציאה',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  /// שער "הרכב שלי היום" (#72) — אותו סלקטור קיים, מקודם למסך-צעד ראשון:
  /// עד שנבחר רכב למשמרת לא נבנה בית הלוח. F-30 — הרכב המועדף מהפרופיל
  /// (כשנקבע) מסומן כברירת-המחדל המוצעת בתג "מועדף"; הבחירה נשארת של השליח.
  Widget _vehicleGate(String preferred) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: _appBar(),
        body: Padding(
          padding: const EdgeInsets.all(BsTokens.space4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '🛵',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 44),
              ),
              const SizedBox(height: BsTokens.space3),
              const Text(
                'הרכב שלי היום',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'בחר רכב כדי להתחיל את המשמרת — רשימת המשלוחים תסונן לפי הקיבולת',
                textAlign: TextAlign.center,
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              ),
              const SizedBox(height: BsTokens.space4),
              // #31 — explains the vehicle picker as a concept (help mode shows
              // the bubble; outside it the buttons select normally).
              HelpTarget(
                title: 'בחירת רכב למשמרת',
                body:
                    'בוחרים את הרכב להיום — רשימת המשלוחים תסונן לפי הקיבולת '
                    'שלו, ומשלוחים גדולים מדי יוצגו בנפרד תחת "דורש רכב אחר".',
                child: Row(
                  children: [
                    for (var i = 0; i < kHaulTypes.length; i++) ...[
                      if (i > 0) const SizedBox(width: BsTokens.space2),
                      Expanded(
                        child: _VehicleButton(
                          haul: kHaulTypes[i],
                          on: false,
                          preferred: kHaulTypes[i].id == preferred,
                          onTap:
                              () => setState(() {
                                _vehicleTouched =
                                    true; // #24 — בחירה ידנית גוברת
                                _vehicle = kHaulTypes[i].id;
                              }),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A6 — apply the pool∪own scope to a SysOrder list when
  /// [visibleOrderIdsProvider] is active (flag ON + courier uid). Returns the
  /// list unchanged otherwise (null id-set ⇒ today's full list, zero regression).
  List<SysOrder> _scopeOrders(List<SysOrder> orders) {
    final ids = ref.watch(visibleOrderIdsProvider);
    if (ids == null) return orders;
    return orders.where((o) => ids.contains(o.id)).toList();
  }

  // ── טאב 1 · משלוחים (ברירת המחדל — מונים + כרטיסי משלוח) ──────────────────
  Widget _deliveriesTab(BoardSession session, String vehicle) {
    final orders = _scopeOrders(ref.watch(sysOrdersProvider));
    final haulName = haulInfo(vehicle).name;
    // F-57 — מנוי יחיד על ה-side-car לכל הטאב (ערכי המפה מחזיקים POD
    // data-URLs ענקיים; watch כפול בתוך לולאת הכרטיסים בנה מחדש את כל הטאב
    // על כל מוטציית fulfillment).
    final fulfillment = ref.watch(fulfillmentProvider);
    final preferred = _preferredHaul(session);
    // F-29 — הברכה מכבדת את ה-override מפרופיל-השליח (#86.1): שם מהפרופיל
    // כשאינו ריק, אחרת displayName של ה-session (בלי המצאות).
    final profileName = ref.watch(
      courierProfileProvider.select(
        (m) => m[session.username]?.displayName ?? '',
      ),
    );
    final greetName =
        profileName.isNotEmpty ? profileName : session.displayName;

    final jobs = orders.courierJobs(vehicle);
    final toPickup = jobs.where((o) => o.stage == OrderStage.ready).length;
    final onRoad =
        jobs
            .where(
              (o) =>
                  o.stage == OrderStage.pickup || o.stage == OrderStage.transit,
            )
            .length;
    final delivered = orders.countAt(OrderStage.delivered);
    final active = jobs.length;
    // #76 — הסינון לפי רכב הוא אמיתי: משלוחים פעילים שהרכב הנבחר לא יכול
    // לשאת לא נעלמים בשקט — הם מוצגים במקטע "דורש רכב אחר" בתחתית.
    const activeStages = [
      OrderStage.ready,
      OrderStage.pickup,
      OrderStage.transit,
    ];
    final otherVehicle =
        orders
            .where(
              (o) =>
                  activeStages.contains(o.stage) &&
                  !vehicleCanCarry(vehicle, o.haul),
            )
            .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        Text(
          'שלום $greetName 🛵',
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'המשלוחים שלך להיום',
          style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
        const SizedBox(height: BsTokens.space4),

        // Vehicle picker (החלפה באמצע משמרת — אותו סלקטור מהצעד הראשון).
        const Text(
          'הרכב שלי היום',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: BsTokens.space2),
        Row(
          children: [
            for (var i = 0; i < kHaulTypes.length; i++) ...[
              if (i > 0) const SizedBox(width: BsTokens.space2),
              Expanded(
                child: _VehicleButton(
                  haul: kHaulTypes[i],
                  on: kHaulTypes[i].id == vehicle,
                  preferred: kHaulTypes[i].id == preferred,
                  onTap:
                      () => setState(() {
                        _vehicleTouched = true; // #24 — בחירה ידנית גוברת
                        _vehicle = kHaulTypes[i].id;
                      }),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: BsTokens.space4),

        // Primary status card.
        _FlatCard(
          child: Text(
            toPickup > 0
                ? '$toPickup משלוחים ממתינים לאיסוף · אסוף מהחנות כדי להתחיל'
                : active > 0
                ? '🚚 $onRoad משלוחים בדרך — אין איסופים ממתינים'
                : '✓ אין משלוחים שמתאימים ל$haulName כרגע',
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: BsTokens.space3),

        // Stats (3).
        Row(
          children: [
            _Stat(value: '$toPickup', label: 'לאיסוף 📦'),
            _Stat(value: '$onRoad', label: 'בדרך 🚚'),
            _Stat(value: '$delivered', label: 'נמסרו ✅'),
          ],
        ),
        const SizedBox(height: BsTokens.space4),

        // Delivery jobs.
        if (jobs.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: BsTokens.space4),
            child: Center(
              child: Text(
                'אין משלוחים שמתאימים ל${haulInfo(vehicle).ic} $haulName. נסה לבחור רכב גדול יותר.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          for (final o in jobs)
            _CourierJobCard(
              order: o,
              podCaptured: fulfillment[o.id]?.podCaptured ?? false,
              splitInto: fulfillment[o.id]?.splitInto ?? 1,
              onAdvance: _advance,
              onPod: () => showPodSheet(context, o.id),
              onTap: () => showCourierDeliveryDetailSheet(context, o.id),
            ),

        // #76 — "דורש רכב אחר": מקטע כן (מכווץ ועמום) במקום הסתרה שקטה.
        if (otherVehicle.isNotEmpty)
          _otherVehicleSection(otherVehicle, vehicle),
      ],
    );
  }

  /// #76 — משלוחים פעילים שהרכב הנוכחי לא נושא: מוצגים בכנות, בלי כפתורי
  /// פעולה (הפעולה היחידה: להחליף רכב בסלקטור למעלה).
  Widget _otherVehicleSection(List<SysOrder> others, String vehicle) {
    return Padding(
      padding: const EdgeInsets.only(top: BsTokens.space2),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Card(
          margin: EdgeInsets.zero,
          color: BsTokens.cardLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: BsTokens.space4,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(
              BsTokens.space4,
              0,
              BsTokens.space4,
              BsTokens.space3,
            ),
            iconColor: BsTokens.mutedLight,
            collapsedIconColor: BsTokens.mutedLight,
            title: Text(
              '🚫 דורש רכב אחר (${others.length})',
              style: const TextStyle(
                color: BsTokens.mutedLight,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              'משלוחים פעילים שמעבר לקיבולת של ${haulInfo(vehicle).name}',
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
            children: [
              for (final o in others)
                Opacity(
                  opacity: 0.55,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: BsTokens.space2),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(BsTokens.space3),
                      decoration: BoxDecoration(
                        color: BsTokens.bgLight,
                        borderRadius: BorderRadius.circular(
                          BsTokens.radiusCard,
                        ),
                      ),
                      child: Text(
                        '📦 ${o.id} · ${o.who} · 📍 ${o.site}\n'
                        'דורש ${haulInfo(o.haul).ic} ${haulInfo(o.haul).name} · ${kOrderStageLabel[o.stage]}',
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 12.5,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _advance(SysOrder o) async {
    // F-12 (א) — staleness guard: double-tap מהיר נוחת על כפתור שנבנה-מחדש
    // באותן קואורדינטות עם שלב ישן — no-op אלא אם המנוע החי עדיין מסכים עם
    // השלב שהכרטיס נבנה עליו.
    SysOrder? current;
    for (final x in ref.read(sysOrdersProvider)) {
      if (x.id == o.id) {
        current = x;
        break;
      }
    }
    if (current == null || current.stage != o.stage) return;

    // COURIER v2 ב — the transition INTO `delivered` is the order tapped while
    // at `transit` (courierAdvance owns pickup→transit→delivered only).
    final wasPickup = o.stage == OrderStage.pickup;
    final wasTransit = o.stage == OrderStage.transit;

    // F-12 (ב) — delivered הוא טרמינלי ובלתי-הפיך: אותו confirmDestructive
    // שכבר קיים בשני המסכים האחים (courier_delivery_detail_sheet /
    // persona_pod_sheet) — אחידות + חסימת double-tap. צבע האישור:
    // successDark (F-34 — לא ‎#1F8A4C בקוד חדש).
    if (wasTransit) {
      final ok = await confirmDestructive(
        context,
        title: 'אישור מסירה?',
        message: 'ההזמנה ${o.id} תסומן כנמסרה ללקוח — פעולה סופית.',
        confirmLabel: 'נמסר',
        confirmColor: BsTokens.successDark,
      );
      if (!ok || !mounted) return;
      // חלון staleness שני נפתח בזמן הדיאלוג — אימות מחדש מול המנוע.
      final still = ref
          .read(sysOrdersProvider)
          .any((x) => x.id == o.id && x.stage == OrderStage.transit);
      if (!still) return;
    }

    ref.read(sysOrdersProvider.notifier).courierAdvance(o.id);

    // Award/stamp only when the engine REALLY moved it (re-read, not assumed)
    // — delivered is terminal + courierAdvance no-ops on it, so the 🪙+🔔 pair
    // can never double-fire for the same order.
    final after = ref.read(sysOrdersProvider);
    final movedToTransit =
        wasPickup &&
        after.any((x) => x.id == o.id && x.stage == OrderStage.transit);
    final delivered =
        wasTransit &&
        after.any((x) => x.id == o.id && x.stage == OrderStage.delivered);

    // F-10 — ה-writer של bs.courier-clock.v1: חותמת-שעון ברגעי ה-advance
    // האמיתיים דרך ה-helper המשותף (פורמט תואם-בייט לקורא בדוחות-השליח).
    // attempts לא נחתם — אין זרימת ניסיון-חוזר אמיתית.
    if (movedToTransit) await stampCourierClock(o.id, pickedUp: true);
    if (delivered) await stampCourierClock(o.id, delivered: true);
    if (!mounted) return;

    if (!delivered) {
      showToast(context, 'המשלוח ${o.id} עודכן — מסונכרן עם החנות והמנהל ✓');
      return;
    }
    // 🪙 fixed DEMO tariff (kCourierDeliveryCoins) onto the shared rewards
    // balance — same seam as the worker's task-approval award (#85ו).
    ref.read(rewardsProvider.notifier).awardCoins(kCourierDeliveryCoins);
    final s = ref.read(boardAuthProvider);
    if (s != null && s.role == BoardRole.courier) {
      // F-1 (#86.6) — רגע המסירה חותם את זהות השליח על רשומת ה-fulfillment
      // (side-car בלבד — מנוע ההזמנות המשותף לא נגוע); זו נקודת-האמת לייחוס
      // per-courier בפרופיל ובדוחות.
      ref.read(fulfillmentProvider.notifier).stampCourier(o.id, s.username);
      // 🔔 'delivered' event onto the courier's own per-username feed.
      ref
          .read(workerNotifsProvider.notifier)
          .addNotification(
            username: s.username,
            emoji: '✅',
            title: 'המשלוח נמסר — +$kCourierDeliveryCoins מטבעות',
            body: '${o.id} · ${o.who}',
          );
    }
    showToast(
      context,
      'המשלוח ${o.id} נמסר ✓ +$kCourierDeliveryCoins מטבעות 🪙',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleButton extends StatelessWidget {
  const _VehicleButton({
    required this.haul,
    required this.on,
    required this.onTap,
    this.preferred = false,
  });
  final HaulType haul;
  final bool on;

  /// F-30 — true כשזה "סוג הרכב המועדף" מפרופיל-השליח (#86.1): תג "מועדף"
  /// כן — ברירת-מחדל מוצעת בלבד, הבחירה למשמרת נשארת של השליח.
  final bool preferred;
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
          padding: const EdgeInsets.symmetric(vertical: BsTokens.space3),
          child: Column(
            children: [
              Text(haul.ic, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 2),
              Text(
                haul.name,
                style: TextStyle(
                  // F-28 — bsOnAccent על מילוי-מותג (לא לבן קשיח): מכבד את
                  // מתג הניגודיות-הגבוהה.
                  color: on ? bsOnAccent(context) : BsTokens.inkLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
              if (preferred) ...[
                const SizedBox(height: 2),
                Text(
                  '★ מועדף',
                  style: TextStyle(
                    color: on ? bsOnAccent(context) : BsTokens.brandDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Courier stage pill (`ready`→לאיסוף yellow, `pickup`→לקיחה blue,
/// `transit`→בדרך green) — proto §3.4.
({String label, Color bg, Color fg}) _courierPill(OrderStage s) => switch (s) {
  OrderStage.ready => (
    label: 'לאיסוף',
    bg: const Color(0xFFFFF4D6),
    fg: const Color(0xFF8A6D00),
  ),
  OrderStage.pickup => (
    label: 'לקיחה',
    bg: const Color(0xFFDCEBFF),
    fg: const Color(0xFF2B6CB0),
  ),
  _ => (
    label: 'בדרך',
    bg: const Color(0xFFD7F5DF),
    fg: const Color(0xFF1F8A4C),
  ),
};

/// Which of the 3 tracker steps (איסוף / בדרך / נמסר) is current.
int _courierPhase(OrderStage s) => switch (s) {
  OrderStage.ready => 0,
  OrderStage.pickup => 1,
  OrderStage.transit => 1,
  OrderStage.delivered => 2,
  _ => 0,
};

class _CourierJobCard extends StatelessWidget {
  const _CourierJobCard({
    required this.order,
    required this.podCaptured,
    required this.splitInto,
    required this.onAdvance,
    required this.onPod,
    required this.onTap,
  });
  final SysOrder order;
  final bool podCaptured;

  /// Number of shipments the store split the order into (proto `o.splitInto`,
  /// 1 = none) — read from the deferred [fulfillmentProvider] side-car, same as
  /// the store card surfaces it (`_StoreOrderCard`).
  final int splitInto;
  final void Function(SysOrder) onAdvance;
  final VoidCallback onPod;

  /// #76 — הקשה על הכרטיס פותחת את גיליון פירוט המשלוח ("הקש לפרטים" אמיתי).
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pill = _courierPill(order.stage);
    // POD is available once the order is in the courier's hands (pickup/transit)
    // — proto §3.5 `courierPOD` lists transit/pickup orders.
    final canPod =
        order.stage == OrderStage.pickup || order.stage == OrderStage.transit;
    final haul = haulInfo(order.haul);
    final phase = _courierPhase(order.stage);
    // Two-step hand-off: the store owns ready→pickup ("מסור לשליח"); the courier
    // acts only once the order is handed to it — receive at `pickup`
    // ("אספתי מהחנות" → transit), then deliver (→delivered). `ready` is view-only.
    final actionLabel = switch (order.stage) {
      OrderStage.ready => '⏳ ממתין למסירה מהחנות',
      OrderStage.pickup => '📦 אספתי מהחנות',
      _ => '✅ נמסר ללקוח',
    };
    final canAct = order.stage != OrderStage.ready;

    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space3),
      child: Material(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        elevation: 1,
        shadowColor: Colors.black26,
        // #76 — "הקש לפרטים" אמיתי: InkWell על כל הכרטיס פותח את גיליון הפירוט.
        child: HelpTarget(
          title: 'פרטי המשלוח',
          body:
              'הקשה על הכרטיס פותחת את גיליון פירוט המשלוח: רשימת הפריטים, לקוח, כתובת, סכום ומסלול ההזמנה, עם קיצורי קידום ו-POD.',
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
                            if (splitInto > 1) ...[
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
                                  '🚚×$splitInto',
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
                          borderRadius: BorderRadius.circular(
                            BsTokens.radiusPill,
                          ),
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
                    '👤 ${order.who}',
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 13.5,
                    ),
                  ),
                  Text(
                    '📍 ${order.site}',
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 12.5,
                    ),
                  ),
                  // 📞/💬 — call / WhatsApp the contractor who placed the order
                  // (hidden when the order carries no phone — seed/legacy).
                  ContactActions(phone: order.customerPhone, compact: true),
                  Text(
                    '🕒 נדרש: בתיאום · ${haul.ic} ${haul.name}',
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: BsTokens.space3),
                  _Tracker(phase: phase),
                  const SizedBox(height: BsTokens.space3),
                  Text(
                    '${order.items} פריטים · ${fMoney(order.sum)} · הקש לפרטים',
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: BsTokens.space3),
                  HelpTarget(
                    title: 'קידום המשלוח',
                    body:
                        "מקדם את המשלוח בשלב אחד. בשלב 'לקיחה' מאשר 'אספתי מהחנות' (→ בדרך); בשלב 'בדרך' מאשר 'נמסר ללקוח' — פעולה סופית עם דיאלוג אישור. בשלב 'לאיסוף' הכפתור מושבת עד שהחנות מוסרת לידיך.",
                    child: FilledButton(
                      onPressed: canAct ? () => onAdvance(order) : null,
                      style: FilledButton.styleFrom(
                        // F-34 — הרקע הירוק הוא successDark (AA מתחת ללבן) במקום
                        // ‎#1F8A4C שנכשל-בקצה; F-28 — התווית ב-bsOnAccent (לא לבן
                        // קשיח) גם על מילוי המותג.
                        backgroundColor:
                            order.stage == OrderStage.transit
                                ? BsTokens.brand
                                : BsTokens.successDark,
                        foregroundColor: bsOnAccent(context),
                        // #63 pattern — guarantees the ≥48dp touch target.
                        minimumSize: const Size(64, 48),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            BsTokens.radiusPill,
                          ),
                        ),
                      ),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  if (canPod) ...[
                    const SizedBox(height: BsTokens.space2),
                    HelpTarget(
                      title: 'אישור מסירה (POD)',
                      body:
                          'פותח את גיליון צילום אישור-המסירה — צילום הלקוח/המשלוח שנשמר כהוכחת מסירה. מופיע רק משלב האיסוף ואילך (כשהמשלוח כבר בידיך).',
                      child: OutlinedButton(
                        onPressed: onPod,
                        style: OutlinedButton.styleFrom(
                          // #63 pattern — guarantees the ≥48dp touch target.
                          minimumSize: const Size(64, 48),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              BsTokens.radiusPill,
                            ),
                          ),
                        ),
                        child: Text(
                          podCaptured
                              ? '📸 אישור מסירה · נשמר ✓'
                              : '📸 אישור מסירה',
                          style: TextStyle(
                            // F-34 — טקסט ירוק על רקע בהיר חייב AA 4.5:1 —
                            // successDark (‎#15803D, ~5.0:1) במקום ‎#1F8A4C.
                            color:
                                podCaptured
                                    ? BsTokens.successDark
                                    : BsTokens.inkLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 3-step delivery tracker: איסוף ── בדרך ── נמסר.
class _Tracker extends StatelessWidget {
  const _Tracker({required this.phase});
  final int phase;

  @override
  Widget build(BuildContext context) {
    const labels = ['איסוף', 'בדרך', 'נמסר'];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                color: i <= phase ? BsTokens.brand : const Color(0xFFE0E0E0),
              ),
            ),
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: i <= phase ? BsTokens.brand : const Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                labels[i],
                style: TextStyle(
                  color: i == phase ? BsTokens.brandDark : BsTokens.mutedLight,
                  fontWeight: i == phase ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ],
      ],
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

// ─────────────────────────────────────────────────────────────────────────────
// COURIER v2 ג · 🔔 courier notifications — bell + sheet (per-username feed)
// ─────────────────────────────────────────────────────────────────────────────

/// The logged courier's own feed off the per-username [workerNotifsProvider]
/// MAP (the spec's reuse — one notification store, per-username isolation).
/// `null` username when no courier session (the board gate keeps these widgets
/// unbuilt anyway). [currentWorkerNotifsProvider] gates on `role == worker`,
/// so the courier reads the map directly by its own session username.
({String? username, List<WorkerNotif> notifs}) _courierFeed(WidgetRef ref) {
  final s = ref.watch(boardAuthProvider);
  if (s == null || s.role != BoardRole.courier) {
    return (username: null, notifs: const []);
  }
  // notif_settings gate (wave-2 batch-3): the 'התראות בתוך האפליקציה' master
  // switch + the '🛵 שליח' per-role toggle silence this live bell when off.
  // Username is kept (mark-read / clear still target the stored feed) — only
  // the SURFACED list is emptied, matching currentWorkerNotifsProvider.
  if (!boardFeedEnabled(ref.watch(notifSettingsProvider), BoardRole.courier)) {
    return (username: s.username, notifs: const []);
  }
  return (
    username: s.username,
    notifs: ref.watch(workerNotifsProvider)[s.username] ?? const [],
  );
}

/// The logged courier's unread bell count — mirrors [_courierFeed]'s gate
/// (in-app master + '🛵 שליח' per-role toggle via [boardFeedEnabled]). Its own
/// provider so the bell can `ref.listen` it for the 🔊 'צליל ורטט' arrival
/// feedback (wave-2 batch-3).
final _courierUnreadCountProvider = Provider<int>((ref) {
  final s = ref.watch(boardAuthProvider);
  if (s == null || s.role != BoardRole.courier) return 0;
  if (!boardFeedEnabled(ref.watch(notifSettingsProvider), BoardRole.courier)) {
    return 0;
  }
  final feed = ref.watch(workerNotifsProvider)[s.username] ?? const [];
  return feed.where((n) => !n.read).length;
});

/// The AppBar bell: red unread badge, tap opens [showCourierNotifsSheet] —
/// a 1:1 mirror of the worker board's `WorkerNotifsBell` (#85ו). IconButton
/// keeps the ≥48dp target.
class _CourierNotifsBell extends ConsumerWidget {
  const _CourierNotifsBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔊 'צליל ורטט': fire sound/vibration when the courier's unread count rises
    // (a real new bell event) — same seam as the worker board's bell.
    ref.listen<int>(_courierUnreadCountProvider, (prev, next) {
      if (next > (prev ?? 0)) {
        playInAppNotifFeedback(ref.read(notifSettingsProvider));
      }
    });
    final unread = ref.watch(_courierUnreadCountProvider);
    return IconButton(
      key: const ValueKey('courier-notifs-bell'),
      tooltip: 'התראות',
      onPressed: () => showCourierNotifsSheet(context),
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

/// Opens the courier notifications sheet (list + mark-read + clear-all).
Future<void> showCourierNotifsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CourierNotifsSheet(),
  );
}

/// The notifications sheet — style mirrors `_WorkerNotifsSheet` (#85ו: white
/// card sheet, RTL, X close, ≥48dp rows); reads/mutates the courier's own
/// per-username feed only.
class _CourierNotifsSheet extends ConsumerWidget {
  const _CourierNotifsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = _courierFeed(ref);
    final username = feed.username;
    final notifs = feed.notifs;
    final unread = notifs.where((n) => !n.read).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder:
            (_, scroll) => Container(
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
                  // ── header: title + X close ──
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
                        icon: const Icon(
                          Icons.close,
                          color: BsTokens.mutedLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: BsTokens.space2),

                  if (notifs.isEmpty)
                    // Honest empty state — the feed fills only from real engine
                    // events (משלוח שנמסר לידיך מהחנות · משלוח שמסרת ללקוח).
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: BsTokens.space5),
                      child: Text(
                        'אין התראות עדיין.\nמשלוחים חדשים שנמסרים לידיך ומסירות שהשלמת יופיעו כאן.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: BsTokens.mutedLight,
                          fontSize: 13.5,
                        ),
                      ),
                    )
                  else ...[
                    // ── actions row: mark-all-read · clear-all (confirmed) ──
                    Row(
                      children: [
                        if (unread > 0)
                          TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(64, 48),
                            ),
                            onPressed:
                                username == null
                                    ? null
                                    : () => ref
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
                          style: TextButton.styleFrom(
                            minimumSize: const Size(64, 48),
                          ),
                          onPressed:
                              username == null
                                  ? null
                                  : () async {
                                    final ok = await confirmDestructive(
                                      context,
                                      title: 'לנקות את כל ההתראות?',
                                      message:
                                          'כל ההתראות יימחקו — פעולה בלתי הפיכה.',
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
                      _CourierNotifRow(
                        notif: n,
                        onTap:
                            username == null || n.read
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

/// One notification row — unread shows an ink title + a brand dot; tapping an
/// unread row marks it read. Min height keeps the ≥48dp target.
class _CourierNotifRow extends StatelessWidget {
  const _CourierNotifRow({required this.notif, this.onTap});

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
