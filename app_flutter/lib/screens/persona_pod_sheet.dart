// T5.4 POD — proof-of-delivery (courier side).
//
// Proto 06 §3.5 `courierPOD()` [L20842] / `capturePOD()` [L20863] /
// `openSignature`. The courier opens this from the 🛵 delivery-job card
// ("אישור מסירה") for an order it is carrying (pickup/transit). It offers a
// simulated photo capture and a simulated signature; capturing the photo shows
// the SIMULATED demo result inline (a rendered POD preview + the verbatim toast
// `צילום המסירה נשמר 📸 (דורש הרשאת מצלמה במכשיר)`) — NOT a real camera and NOT a
// bare toast-only stub (camera/POD → SIMULATED demo result per the build rules).
//
// POD state (podCaptured / podSigned) is held in state/persona_fulfillment.dart
// keyed by order id, so the "נחתם ✓ / ממתין" pill survives a restart. The order
// stage advance to `delivered` stays on the shared two-step hand-off
// (sysOrdersProvider.courierAdvance) — POD does not bypass it.

import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the courier POD sheet for the order with [orderId].
void showPodSheet(BuildContext context, String orderId) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BsTokens.cardLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: PersonaPodSheet(orderId: orderId),
    ),
  );
}

class PersonaPodSheet extends ConsumerWidget {
  const PersonaPodSheet({required this.orderId, super.key});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(sysOrdersProvider);
    final idx = orders.indexWhere((o) => o.id == orderId);
    final order = idx >= 0 ? orders[idx] : null;
    final f = ref.watch(fulfillmentProvider)[orderId] ?? const Fulfillment();
    final fn = ref.read(fulfillmentProvider.notifier);

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
            const Text(
              '📸 אישור מסירה',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'POD + צילום',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            ),
            const SizedBox(height: BsTokens.space3),
            if (order != null)
              Text(
                '📦 ${order.id} · ${order.who} · ${order.site}',
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontSize: 13.5,
                ),
              ),
            const SizedBox(height: BsTokens.space3),

            // Signature status pill (proto `נחתם ✓`/`ממתין`).
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: f.podSigned
                      ? const Color(0xFFD7F5DF)
                      : const Color(0xFFFFF4D6),
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
                child: Text(
                  f.podSigned ? 'נחתם ✓' : 'ממתין',
                  style: TextStyle(
                    color: f.podSigned
                        ? const Color(0xFF1F8A4C)
                        : const Color(0xFF8A6D00),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: BsTokens.space3),

            // SIMULATED photo preview — the demo result of the capture, shown
            // inline once the photo is "taken".
            Container(
              height: 150,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: f.podCaptured
                    ? const Color(0xFFEAF6EE)
                    : BsTokens.bgLight,
                borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                border: Border.all(
                  color: f.podCaptured
                      ? const Color(0xFF1F8A4C)
                      : const Color(0xFFE0E0E0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    f.podCaptured ? '🖼️' : '📷',
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    f.podCaptured
                        ? '✓ צילום מסירה נשמר (הדגמה)'
                        : 'אין צילום עדיין',
                    style: TextStyle(
                      color: f.podCaptured
                          ? const Color(0xFF1F8A4C)
                          : BsTokens.mutedLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: BsTokens.space3),

            // 📷 צלם מסירה — simulated capture (camera → SIMULATED demo result).
            FilledButton(
              onPressed: () {
                fn.capturePod(orderId);
                showToast(
                  context,
                  'צילום המסירה נשמר 📸 (דורש הרשאת מצלמה במכשיר)',
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: BsTokens.brand,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
              ),
              child: const Text(
                '📷 צלם מסירה',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
            const SizedBox(height: BsTokens.space2),

            // ✍️ חתימה — simulated signature.
            OutlinedButton(
              onPressed: () {
                fn.captureSignature(orderId);
                showToast(context, 'החתימה נשמרה ✍️ (הדגמה)');
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
              ),
              child: const Text(
                '✍️ חתימה',
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),

            // Confirm-delivery shortcut — only when the order is actually on the
            // road (transit) and a POD has been captured. Advances → delivered
            // through the SAME shared courier hand-off (no bypass).
            if (order != null &&
                order.stage == OrderStage.transit &&
                f.podCaptured) ...[
              const SizedBox(height: BsTokens.space3),
              FilledButton(
                onPressed: () {
                  ref
                      .read(sysOrdersProvider.notifier)
                      .courierAdvance(order.id);
                  Navigator.of(context).maybePop();
                  showToast(
                    context,
                    'המשלוח ${order.id} עודכן — מסונכרן עם החנות והמנהל ✓',
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1F8A4C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  ),
                ),
                child: const Text(
                  '✅ נמסר ללקוח',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
