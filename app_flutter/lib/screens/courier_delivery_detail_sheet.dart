// #76 — גיליון פירוט משלוח (לוח השליח): "הקש לפרטים" הופך אמיתי.
//
// נפתח מהקשה על כרטיס משלוח בלוח השליח. מציג אך ורק שדות אמיתיים שכבר קיימים
// על ההזמנה ([sysOrdersProvider] → [SysOrder]): רשימת הפריטים מתוך `lines`,
// לקוח (`who`), כתובת (`site`), סכום (`sum`), והמיקום בזרימת השלבים לפי
// [kOrderFlow]. קיצורי דרך: POD (ה-[PersonaPodSheet] הקיים) וקידום המסירה דרך
// אותו hand-off משותף (`sysOrdersProvider.courierAdvance`) — בלי לעקוף את הזרם.
//
// אין המצאות: למנוע ההזמנות אין חותמות-זמן לשלבים בדמו — מוצג סדר השלבים בלבד
// עם שורת-אמת שחותמות הזמן יחוברו עם חיבור השרת.

import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/persona_pod_sheet.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the courier delivery-detail sheet for the order with [orderId].
void showCourierDeliveryDetailSheet(BuildContext context, String orderId) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BsTokens.cardLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: CourierDeliveryDetailSheet(orderId: orderId),
    ),
  );
}

/// Stage pill colors — same palette as the courier job card pills.
({Color bg, Color fg}) _stageColors(OrderStage s) => switch (s) {
  OrderStage.ready => (
    bg: const Color(0xFFFFF4D6),
    fg: const Color(0xFF8A6D00),
  ),
  OrderStage.pickup => (
    bg: const Color(0xFFDCEBFF),
    fg: const Color(0xFF2B6CB0),
  ),
  OrderStage.transit || OrderStage.delivered => (
    bg: const Color(0xFFD7F5DF),
    fg: const Color(0xFF1F8A4C),
  ),
  _ => (bg: const Color(0xFFEFEFEF), fg: BsTokens.mutedLight),
};

class CourierDeliveryDetailSheet extends ConsumerWidget {
  const CourierDeliveryDetailSheet({required this.orderId, super.key});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(sysOrdersProvider);
    final idx = orders.indexWhere((o) => o.id == orderId);
    final order = idx >= 0 ? orders[idx] : null;
    if (order == null) {
      // אותו מצב-ריק כן כמו ב-PersonaPodSheet — ההזמנה כבר לא קיימת.
      return const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: BsTokens.space4,
          vertical: BsTokens.space5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📦', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              'ההזמנה לא נמצאה',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'ייתכן שההזמנה הוסרה או שהמשלוח כבר נסגר — חזרו לרשימת המשלוחים',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
          ],
        ),
      );
    }

    final haul = haulInfo(order.haul);
    final pill = _stageColors(order.stage);
    final curIdx = kOrderFlow.indexOf(order.stage);
    // POD זמין רק כשההזמנה בידי השליח (pickup/transit) — כמו בכרטיס.
    final canPod =
        order.stage == OrderStage.pickup || order.stage == OrderStage.transit;
    // אותה לוגיקת hand-off דו-שלבית של הכרטיס: ready שייך לחנות (צפייה בלבד).
    final actionLabel = switch (order.stage) {
      OrderStage.ready => '⏳ ממתין למסירה מהחנות',
      OrderStage.pickup => '📦 אספתי מהחנות',
      OrderStage.transit => '✅ נמסר ללקוח',
      _ => null, // new/preparing — עוד אצל החנות; delivered — נסגר.
    };
    final canAct =
        order.stage == OrderStage.pickup || order.stage == OrderStage.transit;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space3,
        BsTokens.space4,
        BsTokens.space5,
      ),
      child: SingleChildScrollView(
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

            // Header — order id + live stage pill.
            Row(
              children: [
                Expanded(
                  child: Text(
                    '📦 ${order.id}',
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                    ),
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
                    kOrderStageLabel[order.stage] ?? '',
                    style: TextStyle(
                      color: pill.fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: BsTokens.space3),

            // Real order fields only (R8): customer · address · haul · sum.
            _infoRow('👤 ${order.who}'),
            _infoRow('📍 ${order.site}'),
            _infoRow('${haul.ic} דורש ${haul.name}'),
            _infoRow('${order.items} פריטים · סה״כ ${fMoney(order.sum)}'),
            const SizedBox(height: BsTokens.space3),

            // Items — the order's real lines.
            const Text(
              'פריטי המשלוח',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: BsTokens.space2),
            if (order.lines.isEmpty)
              // ביושר: להזמנה הזו אין שורות פריטים שמורות במנוע.
              _infoRow('אין פירוט פריטים שמור להזמנה זו')
            else
              for (final l in order.lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: BsTokens.space1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: BsTokens.space4,
                      vertical: BsTokens.space2,
                    ),
                    decoration: BoxDecoration(
                      color: BsTokens.bgLight,
                      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.name,
                            style: const TextStyle(
                              color: BsTokens.inkLight,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        Text(
                          '×${l.qty}',
                          style: const TextStyle(
                            color: BsTokens.mutedLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: BsTokens.space3),

            // Stage flow — the order's position in kOrderFlow. No timestamps in
            // the demo engine, so none are shown (honest).
            const Text(
              'מסלול ההזמנה',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: BsTokens.space2),
            for (var i = 0; i < kOrderFlow.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: BsTokens.space1),
                child: Row(
                  children: [
                    Text(
                      i < curIdx
                          ? '✓'
                          : i == curIdx
                          ? '●'
                          : '○',
                      style: TextStyle(
                        color: i < curIdx
                            ? const Color(0xFF1F8A4C)
                            : i == curIdx
                            ? BsTokens.brand
                            : const Color(0xFFBBBBBB),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: BsTokens.space2),
                    Text(
                      kOrderStageLabel[kOrderFlow[i]] ?? '',
                      style: TextStyle(
                        color: i == curIdx
                            ? BsTokens.inkLight
                            : BsTokens.mutedLight,
                        fontWeight: i == curIdx
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 2),
            const Text(
              'חותמות זמן לשלבים יחוברו עם חיבור השרת',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 11.5),
            ),
            const SizedBox(height: BsTokens.space4),

            // Shortcut: advance through the SAME shared two-step hand-off.
            if (actionLabel != null)
              FilledButton(
                onPressed: canAct ? () => _advance(context, ref, order) : null,
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
              )
            else if (order.stage == OrderStage.delivered)
              _infoRow('✅ המשלוח נמסר ללקוח — סגור')
            else
              _infoRow('⏳ ההזמנה עדיין בהכנה אצל החנות'),
            const SizedBox(height: BsTokens.space2),

            // Shortcut: POD — opens the existing PersonaPodSheet.
            OutlinedButton(
              onPressed: canPod ? () => showPodSheet(context, order.id) : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 11),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
              ),
              child: Text(
                '📸 אישור מסירה (POD)',
                style: TextStyle(
                  color: canPod ? BsTokens.inkLight : BsTokens.mutedLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            if (!canPod) ...[
              const SizedBox(height: 2),
              const Text(
                'POD זמין משלב האיסוף (כשההזמנה בידי השליח)',
                textAlign: TextAlign.center,
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 11.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// אותו advance משותף של הכרטיס; המעבר הסופי (transit→delivered) עובר דרך
  /// confirmDestructive כמו ב-PersonaPodSheet — פעולה סופית.
  Future<void> _advance(
    BuildContext context,
    WidgetRef ref,
    SysOrder order,
  ) async {
    if (order.stage == OrderStage.transit) {
      final ok = await confirmDestructive(
        context,
        title: 'אישור מסירה?',
        message: 'ההזמנה ${order.id} תסומן כנמסרה ללקוח — פעולה סופית.',
        confirmLabel: 'נמסר',
        confirmColor: const Color(0xFF1F8A4C),
      );
      if (!ok || !context.mounted) return;
    }
    ref.read(sysOrdersProvider.notifier).courierAdvance(order.id);
    showToast(context, 'המשלוח ${order.id} עודכן — מסונכרן עם החנות והמנהל ✓');
  }

  Widget _infoRow(String text) => Padding(
    padding: const EdgeInsets.only(bottom: BsTokens.space1),
    child: Text(
      text,
      style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
    ),
  );
}
