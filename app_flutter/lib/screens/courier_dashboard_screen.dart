import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/screens/persona_pod_sheet.dart';
import 'package:buildsmart/screens/persona_portal.dart';
import 'package:buildsmart/screens/profile_screen.dart';
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
/// Deferred (heavier infra): split-shipment job grouping, the detail sheet,
/// POD capture, real navigation, and localStorage persistence.
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
  String _vehicle = 'truck'; // default (proto courierVehicle='truck')

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(sysOrdersProvider);
    final haulName = haulInfo(_vehicle).name;

    final jobs = orders.courierJobs(_vehicle);
    final toPickup = jobs.where((o) => o.stage == OrderStage.ready).length;
    final onRoad = jobs.where((o) => o.stage == OrderStage.pickup || o.stage == OrderStage.transit).length;
    final delivered = orders.countAt(OrderStage.delivered);
    final active = jobs.length;

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
            '🛵 שליח',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          actions: [
            // Each persona reaches profile + settings from its OWN dashboard
            // (product-owner: separately per role). Two muted AppBar actions
            // sit before the '‹ יציאה' exit; tooltips double as Semantics
            // labels for a11y. RTL: actions lay out leading→trailing, so this
            // reads profile · settings · exit from the right.
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
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space5,
          ),
          children: [
            const Text(
              'שלום 🛵',
              style: TextStyle(
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

            // Vehicle picker.
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
                      on: kHaulTypes[i].id == _vehicle,
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
            const SizedBox(height: BsTokens.space3),

            // Portal button.
            Semantics(
              button: true,
              label: 'פורטל השליח',
              child: Material(
                color: const Color(0xFFFFF0E3),
                borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                child: InkWell(
                  borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                  onTap: () => showPersonaPortalGrid(
                    context,
                    '🧰 פורטל השליח',
                    kCourierPortalTiles,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(BsTokens.space4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'פורטל השליח',
                          style: TextStyle(
                            color: BsTokens.brandDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'ניווט, צי רכב, צ׳אט ומעקב SLA',
                          style: TextStyle(
                            color: BsTokens.brandDark,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: BsTokens.space4),

            // Delivery jobs.
            if (jobs.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: BsTokens.space4),
                child: Center(
                  child: Text(
                    'אין משלוחים שמתאימים ל${haulInfo(_vehicle).ic} $haulName. נסה לבחור רכב גדול יותר.',
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
                      (ref.watch(fulfillmentProvider)[o.id]?.podCaptured) ??
                          false,
                  splitInto:
                      (ref.watch(fulfillmentProvider)[o.id]?.splitInto) ?? 1,
                  onAdvance: _advance,
                  onPod: () => showPodSheet(context, o.id),
                ),
          ],
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
  });
  final SysOrder order;
  final bool podCaptured;

  /// Number of shipments the store split the order into (proto `o.splitInto`,
  /// 1 = none) — read from the deferred [fulfillmentProvider] side-car, same as
  /// the store card surfaces it (`_StoreOrderCard`).
  final int splitInto;
  final void Function(SysOrder) onAdvance;
  final VoidCallback onPod;

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
                  backgroundColor: order.stage == OrderStage.transit
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
                      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                    ),
                  ),
                  child: Text(
                    podCaptured ? '📸 אישור מסירה · נשמר ✓' : '📸 אישור מסירה',
                    style: TextStyle(
                      color: podCaptured
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
