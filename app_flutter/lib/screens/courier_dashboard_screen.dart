import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/courier_delivery_detail_sheet.dart';
import 'package:buildsmart/screens/courier_portal_tab.dart';
import 'package:buildsmart/screens/courier_profile_screen.dart';
import 'package:buildsmart/screens/courier_reports_tab.dart';
import 'package:buildsmart/screens/courier_settings_screen.dart';
import 'package:buildsmart/screens/persona_pod_sheet.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// 0 משלוחים (ברירת המחדל) · 1 פורטל · 2 דוחות · 3 אזור אישי (#72).
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    // חוק הלוחות (כלל 4 — "מבחוץ לא רואים כלום"): בלי session של שליח נבנה אך
    // ורק שער הרישום (WelcomeScreen במצב-תפקיד) — אף widget מתוכן הלוח לא נבנה.
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.courier) {
      return const WelcomeScreen(boardRole: BoardRole.courier);
    }

    // #72 — הזרם אחרי כניסה: קודם בחירת "הרכב שלי היום" (אם טרם נבחר במשמרת
    // הזו) → ואז הבית עם 4 הטאבים.
    final vehicle = _vehicle;
    if (vehicle == null) return _vehicleGate();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: _appBar(),
        body: _tabBody(session, vehicle),
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
              icon: Icon(Icons.local_shipping_outlined),
              activeIcon: Icon(Icons.local_shipping),
              label: 'משלוחים',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'פורטל'),
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart_outlined),
              activeIcon: Icon(Icons.insert_chart),
              label: 'דוחות',
            ),
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

  Widget _tabBody(BoardSession session, String vehicle) {
    switch (_tab) {
      case 1:
        return const CourierPortalTab();
      case 2:
        return const CourierReportsTab();
      case 3:
        return const CourierProfileBody();
      default:
        return _deliveriesTab(session, vehicle);
    }
  }

  /// ה-AppBar המשותף ללוח ולשער-הרכב. Each persona reaches profile + settings
  /// from its OWN dashboard — לשליח יש כעת מסכים ייעודיים (#73). RTL: actions
  /// lay out leading→trailing, so this reads profile · settings · exit from
  /// the right.
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
        IconButton(
          tooltip: 'פרופיל',
          icon: const Icon(Icons.person_outline, color: BsTokens.mutedLight),
          onPressed:
              () => Navigator.of(context).push(CourierProfileScreen.route()),
        ),
        IconButton(
          tooltip: 'הגדרות',
          icon: const Icon(Icons.settings_outlined, color: BsTokens.mutedLight),
          onPressed:
              () => Navigator.of(context).push(CourierSettingsScreen.route()),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text(
            '‹ יציאה',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
          ),
        ),
      ],
    );
  }

  /// שער "הרכב שלי היום" (#72) — אותו סלקטור קיים, מקודם למסך-צעד ראשון:
  /// עד שנבחר רכב למשמרת לא נבנה בית הלוח.
  Widget _vehicleGate() {
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
              Row(
                children: [
                  for (var i = 0; i < kHaulTypes.length; i++) ...[
                    if (i > 0) const SizedBox(width: BsTokens.space2),
                    Expanded(
                      child: _VehicleButton(
                        haul: kHaulTypes[i],
                        on: false,
                        onTap:
                            () => setState(() => _vehicle = kHaulTypes[i].id),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── טאב 1 · משלוחים (ברירת המחדל — מונים + כרטיסי משלוח) ──────────────────
  Widget _deliveriesTab(BoardSession session, String vehicle) {
    final orders = ref.watch(sysOrdersProvider);
    final haulName = haulInfo(vehicle).name;

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
          'שלום ${session.displayName} 🛵',
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
                  onTap: () => setState(() => _vehicle = kHaulTypes[i].id),
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
              podCaptured:
                  (ref.watch(fulfillmentProvider)[o.id]?.podCaptured) ?? false,
              splitInto: (ref.watch(fulfillmentProvider)[o.id]?.splitInto) ?? 1,
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

  void _advance(SysOrder o) {
    ref.read(sysOrdersProvider.notifier).courierAdvance(o.id);
    showToast(context, 'המשלוח ${o.id} עודכן — מסונכרן עם החנות והמנהל ✓');
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
  });
  final HaulType haul;
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
          padding: const EdgeInsets.symmetric(vertical: BsTokens.space3),
          child: Column(
            children: [
              Text(haul.ic, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 2),
              Text(
                haul.name,
                style: TextStyle(
                  color: on ? Colors.white : BsTokens.inkLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
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
                FilledButton(
                  onPressed: canAct ? () => onAdvance(order) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        order.stage == OrderStage.transit
                            ? BsTokens.brand
                            : const Color(0xFF1F8A4C),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
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
                if (canPod) ...[
                  const SizedBox(height: BsTokens.space2),
                  OutlinedButton(
                    onPressed: onPod,
                    style: OutlinedButton.styleFrom(
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
                        color:
                            podCaptured
                                ? const Color(0xFF1F8A4C)
                                : BsTokens.inkLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
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
