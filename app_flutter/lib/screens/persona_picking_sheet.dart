// T5.1 גיליון-ליקוט · T5.2 פריט-חסר (held-for-missing loop) · T5.3 פיצול-משלוחים
//
// The store picking sheet — proto 06 §2.5 `renderStorePick()` [L17455] +
// §2.6 missing-item decision loop. Opened from the 🏪 store work-queue card
// ("הקש לתעודת ליקוט"). It renders each order line with the six prototype line
// states, the per-line ✓/חסר buttons, the held-for-missing hold gate, the split
// banner + per-shipment grouping, and the footer stage action (which delegates
// to the SAME `storeAdvance` two-step hand-off so store→courier→manager stay one
// source of truth). All deferred per-order fields live in
// state/persona_fulfillment.dart; the canonical stage still flows through
// `sysOrdersProvider`.
//
// camera/POD note: this sheet has no camera. The missing-item loop and split are
// pure state. Every Hebrew string is VERBATIM from proto 06 §2.5/§2.6.

import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the picking sheet for the order with [orderId].
void showPickingSheet(BuildContext context, String orderId) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BsTokens.cardLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: PersonaPickingSheet(orderId: orderId),
      ),
    ),
  );
}

class PersonaPickingSheet extends ConsumerWidget {
  const PersonaPickingSheet({required this.orderId, super.key});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(sysOrdersProvider);
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx < 0) {
      // Order vanished (e.g. delivered/removed) — nothing to pick.
      return const Padding(
        padding: EdgeInsets.all(BsTokens.space5),
        child: Text(
          'אין הזמנות בקטגוריה זו ✓',
          style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
        ),
      );
    }
    final order = orders[idx];
    final f = ref.watch(fulfillmentProvider)[orderId] ?? const Fulfillment();
    final fn = ref.read(fulfillmentProvider.notifier);
    final lines = order.lines;

    final handled = List.generate(lines.length, (i) => i)
        .where((i) {
          final s = f.lineStatus[i] ?? LineStatus.pending;
          return s != LineStatus.pending;
        })
        .length;
    final allHandled = lines.isNotEmpty && handled == lines.length;

    return Column(
      children: [
        // Grab handle.
        const Padding(
          padding: EdgeInsets.only(top: BsTokens.space3),
          child: _Grip(),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              BsTokens.space4,
              BsTokens.space3,
              BsTokens.space4,
              BsTokens.space5,
            ),
            children: [
              // Header.
              Text(
                '📦 ${order.id}',
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${order.who} · ${order.site}',
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'סטטוס: ${kOrderStageLabel[order.stage]}',
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: BsTokens.space3),

              // Progress.
              Text(
                '$handled/${lines.length} פריטים טופלו',
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: BsTokens.space2),
              ClipRRect(
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                child: LinearProgressIndicator(
                  value: lines.isEmpty ? 0 : handled / lines.length,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: const AlwaysStoppedAnimation(BsTokens.brand),
                ),
              ),
              const SizedBox(height: BsTokens.space3),

              // Held / missing alert.
              if (f.heldForMissing)
                _Banner(
                  text: '⏳ פריט חסר — ממתין לבחירת הקבלן (החלפה / ביטול)',
                  bg: const Color(0xFFFFF4D6),
                  fg: const Color(0xFF8A6D00),
                )
              else if (f.missingCount > 0)
                _Banner(
                  text: '⚠️ ${f.missingCount} פריטים חסרים — הקבלן עודכן',
                  bg: const Color(0xFFFFE3E3),
                  fg: BsTokens.brandDark,
                ),

              // Split banner + split control.
              if (f.splitInto > 1)
                _Banner(
                  text:
                      '🚚 ההזמנה מפוצלת ל-${f.splitInto} משלוחים — הכן כל קבוצה כחבילה נפרדת.',
                  bg: const Color(0xFFE7F0FF),
                  fg: const Color(0xFF2B6CB0),
                ),
              const SizedBox(height: BsTokens.space2),

              // Lines — grouped by shipment when split.
              if (f.splitInto > 1 && f.splitPlan.length == lines.length)
                ..._splitGroups(context, ref, order, f, fn)
              else
                for (var i = 0; i < lines.length; i++)
                  _PickLine(
                    line: lines[i],
                    status: f.lineStatus[i] ?? LineStatus.pending,
                    onPick: () => _onPick(context, ref, order, i),
                    onMiss: () => _onMiss(context, ref, order, i),
                  ),

              const SizedBox(height: BsTokens.space3),

              // Split tool (only while still preparing/new).
              if (order.stage == OrderStage.newOrder ||
                  order.stage == OrderStage.preparing)
                _SplitControl(
                  splitInto: f.splitInto,
                  onSelect: (g) {
                    fn.split(order.id, lines.length, g);
                    showToast(
                      context,
                      g > 1
                          ? '🚚 ההזמנה הוכנה ב-$g חבילות'
                          : 'הפיצול בוטל — חבילה אחת',
                    );
                  },
                ),
              const SizedBox(height: BsTokens.space3),

              // Footer stage action.
              ..._footer(context, ref, order, f, allHandled),

              const SizedBox(height: BsTokens.space3),

              // Always: delivery note.
              OutlinedButton(
                onPressed: () => _showDeliveryNote(context, order, f),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  ),
                ),
                child: const Text(
                  '📄 הצג תעודת משלוח',
                  style: TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Line actions ────────────────────────────────────────────────────────────

  void _onPick(BuildContext context, WidgetRef ref, SysOrder o, int i) {
    ref.read(fulfillmentProvider.notifier).pickLine(o.id, i);
  }

  void _onMiss(BuildContext context, WidgetRef ref, SysOrder o, int i) {
    final newlyHeld = ref.read(fulfillmentProvider.notifier).missLine(o.id, i);
    if (newlyHeld) {
      // proto `storeMissLine` → pushNotification + openMissingDecision sheet.
      _openMissingDecision(context, ref, o, i);
    }
  }

  // ── Missing-item decision (T5.2) ─────────────────────────────────────────────

  void _openMissingDecision(
    BuildContext context,
    WidgetRef ref,
    SysOrder o,
    int line,
  ) {
    final name = line < o.lines.length ? o.lines[line].name : '';
    final qty = line < o.lines.length ? o.lines[line].qty : 0;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BsTokens.cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Directionality(
        textDirection: TextDirection.rtl,
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
              const _Grip(),
              const SizedBox(height: BsTokens.space3),
              const Text(
                'פריט חסר — נדרשת החלטה',
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: BsTokens.space3),
              _decisionRow('הזמנה: ${o.id}'),
              _decisionRow('פריט חסר: $name'),
              _decisionRow('כמות: $qty'),
              _decisionRow(
                'התהליך נעצר. יש לבחור: להתקדם בלי הפריט, או להחליף אותו.',
              ),
              const SizedBox(height: BsTokens.space3),
              FilledButton(
                onPressed: () {
                  ref
                      .read(fulfillmentProvider.notifier)
                      .replaceLine(o.id, line);
                  Navigator.of(sheetCtx).pop();
                  showToast(context, 'עדכון מהקבלן — הפריט יוחלף');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: BsTokens.brand,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  ),
                ),
                child: const Text(
                  '🔁 החלף מוצר',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
              const SizedBox(height: BsTokens.space2),
              OutlinedButton(
                onPressed: () {
                  ref
                      .read(fulfillmentProvider.notifier)
                      .proceedWithout(o.id, line);
                  Navigator.of(sheetCtx).pop();
                  showToast(
                    context,
                    'הקבלן ביטל את הפריט "$name" — המשך בליקוט',
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  ),
                ),
                child: const Text(
                  'דלג — הסר מההזמנה',
                  style: TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _decisionRow(String text) => Padding(
    padding: const EdgeInsets.only(bottom: BsTokens.space2),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space4,
        vertical: BsTokens.space3,
      ),
      decoration: BoxDecoration(
        color: BsTokens.bgLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: Text(
        text,
        style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
      ),
    ),
  );

  // ── Split groups (T5.3) ──────────────────────────────────────────────────────

  List<Widget> _splitGroups(
    BuildContext context,
    WidgetRef ref,
    SysOrder order,
    Fulfillment f,
    FulfillmentNotifier fn,
  ) {
    final haul = haulInfo(order.haul);
    final out = <Widget>[];
    for (var g = 1; g <= f.splitInto; g++) {
      final idxs = [
        for (var i = 0; i < order.lines.length; i++)
          if (f.splitPlan[i] == g) i,
      ];
      if (idxs.isEmpty) continue;
      out.add(
        Padding(
          padding: const EdgeInsets.only(
            top: BsTokens.space2,
            bottom: BsTokens.space2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📦 משלוח $g — ${idxs.length} פריטים',
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '🕒 בתיאום · 📍 ${order.site} · ${haul.ic} ${haul.name}',
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
      for (final i in idxs) {
        out.add(
          _PickLine(
            line: order.lines[i],
            status: f.lineStatus[i] ?? LineStatus.pending,
            onPick: () => _onPick(context, ref, order, i),
            onMiss: () => _onMiss(context, ref, order, i),
          ),
        );
      }
    }
    return out;
  }

  // ── Footer (stage action) ────────────────────────────────────────────────────

  List<Widget> _footer(
    BuildContext context,
    WidgetRef ref,
    SysOrder order,
    Fulfillment f,
    bool allHandled,
  ) {
    // proto §2.5 footer logic.
    if (order.stage == OrderStage.ready ||
        order.stage == OrderStage.pickup ||
        order.stage == OrderStage.transit ||
        order.stage == OrderStage.delivered) {
      return [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F3F5),
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          ),
          child: const Text(
            '🛵 ההזמנה מוכנה — ממתינה לאיסוף השליח',
            style: TextStyle(
              color: BsTokens.mutedLight,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
        ),
      ];
    }

    final label = order.stage == OrderStage.newOrder
        ? '✓ אשר וקבל להכנה'
        : allHandled
        ? '📦 כל הפריטים טופלו — סמן כמוכן'
        : 'סמן כמוכן בכל זאת';

    final out = <Widget>[];
    if (order.stage == OrderStage.preparing && !allHandled) {
      out.add(
        const Padding(
          padding: EdgeInsets.only(bottom: BsTokens.space2),
          child: Text(
            'סמן כל פריט כ"לוקט" או "חסר" כדי לסיים את ההכנה',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
          ),
        ),
      );
    }
    out.add(
      FilledButton(
        onPressed: () => _advanceFromSheet(context, ref, order, f),
        style: FilledButton.styleFrom(
          backgroundColor: order.stage == OrderStage.newOrder
              ? const Color(0xFF1F8A4C)
              : BsTokens.brand,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ),
    );
    return out;
  }

  /// `storeAdvanceFromSheet()` [L17817] — refuses on `ready`; aborts (toast) when
  /// held-for-missing; else delegates to the shared two-step `storeAdvance`.
  void _advanceFromSheet(
    BuildContext context,
    WidgetRef ref,
    SysOrder order,
    Fulfillment f,
  ) {
    if (order.stage == OrderStage.ready) return;
    if (f.heldForMissing) {
      showToast(
        context,
        '⚠️ ההזמנה ממתינה להחלטת הקבלן על פריט חסר — לא ניתן להמשיך',
      );
      return;
    }
    ref.read(sysOrdersProvider.notifier).storeAdvance(order.id);
    showToast(
      context,
      'ההזמנה ${order.id} עודכנה — מסונכרן עם השליח והמנהל ✓',
    );
  }

  // ── Delivery note (printed document stand-in) ────────────────────────────────

  void _showDeliveryNote(BuildContext context, SysOrder o, Fulfillment f) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
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
                const _Grip(),
                const SizedBox(height: BsTokens.space3),
                const Text(
                  'תעודת משלוח',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${o.id} · ${o.who}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: BsTokens.space2),
                Text(
                  '📍 ${o.site}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 13,
                  ),
                ),
                const Divider(height: BsTokens.space4),
                for (var i = 0; i < o.lines.length; i++)
                  _dnLine(o.lines[i], f.lineStatus[i] ?? LineStatus.pending),
                const Divider(height: BsTokens.space4),
                Text(
                  '${o.items} פריטים · ${fMoney(o.sum)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                if (f.splitInto > 1) ...[
                  const SizedBox(height: 4),
                  Text(
                    '🚚 הוכן ב-${f.splitInto} חבילות',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF2B6CB0),
                      fontSize: 12.5,
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

  Widget _dnLine(OrderLine l, LineStatus s) {
    final mark = switch (s) {
      LineStatus.picked => '✓',
      LineStatus.missing => '✕',
      LineStatus.cancelled => '✕',
      LineStatus.replaced => '🔁',
      _ => '·',
    };
    final strike = s == LineStatus.cancelled;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 22, child: Text(mark)),
          Expanded(
            child: Text(
              l.name,
              style: TextStyle(
                color: BsTokens.inkLight,
                fontSize: 13.5,
                decoration: strike ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            '×${l.qty}',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PickLine extends StatelessWidget {
  const _PickLine({
    required this.line,
    required this.status,
    required this.onPick,
    required this.onMiss,
  });
  final OrderLine line;
  final LineStatus status;
  final VoidCallback onPick;
  final VoidCallback onMiss;

  @override
  Widget build(BuildContext context) {
    // proto `renderSpLine` status text.
    final (statusText, statusColor) = switch (status) {
      LineStatus.picked => ('✓ לוקט', const Color(0xFF1F8A4C)),
      LineStatus.missing => ('✕ חסר', BsTokens.brandDark),
      LineStatus.pendingDecision => (
        '⏳ ממתין לבחירת הקבלן',
        const Color(0xFF8A6D00),
      ),
      LineStatus.cancelled => ('✕ בוטל ע״י הקבלן', BsTokens.brandDark),
      LineStatus.replaced => ('🔁 הוחלף ע״י הקבלן', const Color(0xFF2B6CB0)),
      LineStatus.pending => ('', BsTokens.mutedLight),
    };
    final picked = status == LineStatus.picked;
    final missing = status == LineStatus.missing ||
        status == LineStatus.pendingDecision ||
        status == LineStatus.cancelled;

    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Container(
        padding: const EdgeInsets.all(BsTokens.space3),
        decoration: BoxDecoration(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          border: Border.all(color: const Color(0xFFEDEDED)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              line.name,
                              style: const TextStyle(
                                color: BsTokens.inkLight,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (status == LineStatus.replaced) ...[
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
                              child: const Text(
                                'מוצר חלופי',
                                style: TextStyle(
                                  color: Color(0xFF2B6CB0),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'כמות לליקוט: ${line.qty}',
                        style: const TextStyle(
                          color: BsTokens.mutedLight,
                          fontSize: 12,
                        ),
                      ),
                      if (statusText.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: BsTokens.space2),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPick,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: picked
                          ? const Color(0xFFD7F5DF)
                          : Colors.transparent,
                      side: BorderSide(
                        color: picked
                            ? const Color(0xFF1F8A4C)
                            : const Color(0xFFE0E0E0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                      ),
                    ),
                    child: Text(
                      '✓',
                      style: TextStyle(
                        color: picked
                            ? const Color(0xFF1F8A4C)
                            : BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onMiss,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: missing
                          ? const Color(0xFFFFE3E3)
                          : Colors.transparent,
                      side: BorderSide(
                        color: missing
                            ? BsTokens.brandDark
                            : const Color(0xFFE0E0E0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                      ),
                    ),
                    child: Text(
                      'חסר',
                      style: TextStyle(
                        color: missing ? BsTokens.brandDark : BsTokens.inkLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitControl extends StatelessWidget {
  const _SplitControl({required this.splitInto, required this.onSelect});
  final int splitInto;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.bgLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🚚 פיצול משלוחים',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          Row(
            children: [
              for (final g in const [1, 2, 3]) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onSelect(g),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: splitInto == g
                          ? BsTokens.brand
                          : Colors.transparent,
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                      ),
                    ),
                    child: Text(
                      g == 1 ? 'חבילה אחת' : '$g חבילות',
                      style: TextStyle(
                        color: splitInto == g
                            ? bsOnAccent(context)
                            : BsTokens.inkLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
                if (g != 3) const SizedBox(width: BsTokens.space2),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space3,
          vertical: BsTokens.space3,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _Grip extends StatelessWidget {
  const _Grip();
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 38,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}
