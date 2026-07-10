// T5.4 POD — proof-of-delivery (courier side), COURIER v2 (a) REAL capture.
//
// Proto 06 §3.5 `courierPOD()` [L20842] / `capturePOD()` [L20863] /
// `openSignature`. The courier opens this from the 🛵 delivery-job card
// ("אישור מסירה") for an order it is carrying (pickup/transit). The 📷 button
// captures a REAL photo through the shared services/task_photo.dart
// [pickTaskPhoto] seam — on desktop web that is the live getUserMedia webcam
// dialog (screens/webcam_capture_sheet.dart; the browser file picker only as
// the honest fallback on a webcam ERROR), on mobile the device camera with a
// one-shot gallery retry. A cancel/failure returns null and NOTHING is stored
// — no fake capture, no demo toast. The ✍️ signature button now opens a REAL
// on-device signature pad (widgets/signature_pad.dart): the recipient signs
// with finger/mouse, the strokes rasterize to a PNG data-URL stored as
// podSignature — NO backend, NO fake. An empty pad cannot save; a cancel
// stores nothing.
//
// POD state (podPhoto + podSignature data-URLs + podCaptured / podSigned) is
// held in state/persona_fulfillment.dart keyed by order id and PERSISTED
// (`bs.fulfillment.v1`), so the photo, the signature and the "נחתם ✓ / ממתין"
// pill survive a restart — and the SAME strings are what the store's delivered card
// and the manager render (both sides see one source of truth). The order
// stage advance to `delivered` stays on the shared two-step hand-off
// (sysOrdersProvider.courierAdvance) — POD does not bypass it.
//
// #86.6: a capture / confirm-delivery by a LOGGED-IN courier session stamps
// `courierUser` on the fulfillment record (F-1) and the delivery clock
// (state/courier_clock.dart `stampCourierClock`, F-10); non-courier flows
// (persona portal) honestly stamp nothing.

import 'dart:async';

import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/worker_task_detail_sheet.dart'
    show taskPhotoWidget;
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/courier_clock.dart';
import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/signature_pad.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
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
    if (order == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space4,
          vertical: BsTokens.space5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📦', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            CfgText(
              'persona_pod_sheet.t01',
              'ההזמנה לא נמצאה',
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            CfgText(
              'persona_pod_sheet.t02',
              'ייתכן שההזמנה הוסרה או שהמשלוח כבר נסגר — חזרו לרשימת המשלוחים',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
          ],
        ),
      );
    }
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
            CfgText(
              'persona_pod_sheet.t03',
              '📸 אישור מסירה',
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 2),
            CfgText(
              'persona_pod_sheet.t04',
              'POD + צילום',
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            ),
            const SizedBox(height: BsTokens.space3),
            Text(
              '📦 ${order.id} · ${order.who} · ${order.site}',
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: BsTokens.space3),

            // Signature status pill (proto `נחתם ✓`/`ממתין`).
            // Directional start (gate #62 idiom) — not a physical centerRight.
            Align(
              alignment: AlignmentDirectional.centerStart,
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
                    // F-34: #1F8A4C on the light-green pill is 3.75:1 (< AA);
                    // successDark passes.
                    color: f.podSigned
                        ? BsTokens.successDark
                        : const Color(0xFF8A6D00),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: BsTokens.space3),

            // REAL POD photo preview — the captured shot rendered via the
            // SHARED [taskPhotoWidget] (worker_task_detail_sheet.dart), the
            // exact same thumbnail seam the store's delivered card and the
            // manager use, so all sides see the identical proof. No photo yet
            // (including legacy pre-v2 simulated records, which carry no
            // image) → an honest empty box, never a fake preview.
            if (f.podPhoto != null)
              taskPhotoWidget(f.podPhoto, height: 150)
            else
              Container(
                height: 150,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: BsTokens.bgLight,
                  borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📷', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 6),
                    CfgText(
                      'persona_pod_sheet.t05',
                      'אין צילום עדיין',
                      style: const TextStyle(
                        color: BsTokens.mutedLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: BsTokens.space3),

            // 📷 צלם מסירה — REAL capture via [pickTaskPhoto] (webcam sheet on
            // desktop web, device camera on mobile, picker only as the honest
            // error fallback). null = cancel/failure → nothing stored and no
            // success toast (the seam already toasts its own honest errors).
            FilledButton(
              onPressed: () async {
                final photo = await pickTaskPhoto(context);
                if (photo == null || !context.mounted) return;
                // #86.6 (F-1): stamp the LOGGED-IN courier on the POD record —
                // the sheet also opens from non-courier flows (persona portal),
                // so anyone else honestly leaves courierUser null.
                final s = ref.read(boardAuthProvider);
                final ok = await fn.capturePod(
                  orderId,
                  photo,
                  courierUser: (s != null && s.role == BoardRole.courier)
                      ? s.username
                      : null,
                );
                if (!context.mounted) return;
                // F-2: success toast ONLY when the persist actually landed —
                // on a storage failure (web quota) the state was rolled back
                // and nothing was kept; never fake a success.
                showToast(
                  context,
                  ok
                      ? 'צילום המסירה נשמר 📸 — מוצג לחנות ולמנהל'
                      : 'התמונה גדולה מדי — לא נשמרה',
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: BsTokens.brand,
                // F-28: legible on the brand fill under high-contrast mode.
                foregroundColor: bsOnAccent(context),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
              ),
              child: Text(
                f.podPhoto == null ? '📷 צלם מסירה' : '📷 צלם שוב',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: BsTokens.space2),

            // ✍️ חתימה — opens a REAL on-device signature pad
            // (widgets/signature_pad.dart). The recipient signs; the strokes
            // rasterize to a PNG data-URL stored as podSignature (podSigned then
            // reads true honestly — only with a real image). null = cancel /
            // empty pad → nothing stored, no success toast.
            OutlinedButton(
              onPressed: () async {
                final sig = await openSignaturePad(context);
                if (sig == null || !context.mounted) return;
                // A3 — await the persist; toast success ONLY when it landed.
                final ok = await fn.captureSignature(orderId, sig);
                if (!context.mounted) return;
                showToast(context,
                    ok ? 'החתימה נשמרה ✍️' : 'החתימה לא נשמרה — נסה שוב');
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
              ),
              child: Text(
                f.podSignature == null ? '✍️ חתימה' : '✍️ חתום מחדש',
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),

            // REAL captured signature preview — the recipient's signed PNG,
            // rendered via the SHARED [taskPhotoWidget] (the same dual-render
            // seam the POD photo uses: a data-URL today, an uploaded https URL
            // when kCloudPhotos is ON). Shown only once a signature exists — no
            // signature → nothing here (never a fake preview).
            if (f.podSignature != null) ...[
              const SizedBox(height: BsTokens.space2),
              taskPhotoWidget(f.podSignature, height: 110),
            ],

            // Confirm-delivery shortcut — only when the order is actually on the
            // road (transit) and a REAL POD photo exists (a legacy simulated
            // flag with no image does not count). Advances → delivered through
            // the SAME shared courier hand-off (no bypass).
            if (order.stage == OrderStage.transit && f.podPhoto != null) ...[
              const SizedBox(height: BsTokens.space3),
              FilledButton(
                onPressed: () async {
                  final ok = await confirmDestructive(
                    context,
                    title: 'אישור מסירה?',
                    message:
                        'ההזמנה ${order.id} תסומן כנמסרה ללקוח — פעולה סופית.',
                    confirmLabel: 'נמסר',
                    confirmColor: BsTokens.successDark,
                  );
                  if (!ok || !context.mounted) return;
                  // #86.6 (F-1): attribute the delivery to the LOGGED-IN
                  // courier at the moment it happens — non-courier sessions
                  // honestly leave courierUser null.
                  final s = ref.read(boardAuthProvider);
                  if (s != null && s.role == BoardRole.courier) {
                    fn.stampCourier(order.id, s.username);
                  }
                  // F-10: stamp the delivery clock BEFORE the advance — the
                  // order mutation is exactly what triggers the reports-tab
                  // re-read, so the stamp is already on disk by then.
                  await stampCourierClock(order.id, delivered: true);
                  if (!context.mounted) return;
                  ref
                      .read(sysOrdersProvider.notifier)
                      .courierAdvance(order.id);
                  unawaited(Navigator.of(context).maybePop());
                  showToast(
                    context,
                    'המשלוח ${order.id} עודכן — מסונכרן עם החנות והמנהל ✓',
                  );
                },
                style: FilledButton.styleFrom(
                  // F-34: white-on-#1F8A4C is 4.38:1 (< AA) — successDark +
                  // the high-contrast-aware foreground pass.
                  backgroundColor: BsTokens.successDark,
                  foregroundColor: bsOnAccent(context),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  ),
                ),
                child: CfgText(
                  'persona_pod_sheet.t06',
                  '✅ נמסר ללקוח',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
