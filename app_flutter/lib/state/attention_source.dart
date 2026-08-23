// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · GIANT Phase-2 · שכבת-הספק של מנוע-ההתראות — מחלצת מהמנועים החיים
// אל ה-DTO הטהור (`AttentionInput`) ומזינה את `attentionItems`. כאן מותר לקרוא
// providers ו-DateTime.now(); הלוגיקה נשארת ב-logic/attention_engine.dart טהורה.
//
// כבוי (ברירת-מחדל): אף מסך לא צורך את הספקים האלה, והמנוע כולו רדום ⇒ זהה-בייטים.
// דלוק (`manager.attention`): הדשבורד צורך `attentionItemsProvider`.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/logic/attention_engine.dart';
import 'package:buildsmart/state/org_config_store.dart' show orgConfigProvider;
import 'package:buildsmart/state/orders_engine.dart' show ordersEngineProvider;
import 'package:buildsmart/state/role_requests.dart'
    show pendingRoleRequestsProvider;
import 'package:buildsmart/state/vacation_requests.dart'
    show kVacationPending, vacationRequestsProvider;
import 'package:buildsmart/state/worker_tasks_engine.dart'
    show pendingApprovalTasksProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The live fan-in: reads each needs-action queue and folds it into the pure
/// [AttentionInput]. Aging is computed here (needs `DateTime.now()`); an order
/// with no `createdAt` contributes age 0 (never flagged) — honest, never a crash.
final attentionInputProvider = Provider<AttentionInput>((ref) {
  final now = DateTime.now();
  final orders = ref.watch(ordersEngineProvider);
  final aging = <AgingOrder>[
    for (final o in orders)
      if (o.isOpen && o.createdAt != null)
        AgingOrder(o.id, now.difference(o.createdAt!).inDays),
  ]..removeWhere((a) => a.ageDays < kAttnOrderWarnDays);

  final approvals = ref.watch(pendingApprovalTasksProvider).length;
  final vacations = ref
      .watch(vacationRequestsProvider)
      .where((v) => v.status == kVacationPending)
      .length;
  // Role/account requests are a Firebase stream; demo/test/off-backend yields
  // an empty list, so this is 0 without a live backend — no crash, no item.
  final accountReqs =
      ref.watch(pendingRoleRequestsProvider).asData?.value.length ?? 0;

  return AttentionInput(
    agingOrders: aging,
    pendingApprovals: approvals,
    pendingVacations: vacations,
    pendingAccountReqs: accountReqs,
  );
});

/// The ranked attention list the dashboard renders (crit-before-warn, terms
/// applied). Pure engine over the live input + the org config in force.
final attentionItemsProvider = Provider<List<AttentionItem>>((ref) {
  return attentionItems(
    ref.watch(attentionInputProvider),
    cfg: ref.watch(orgConfigProvider),
  );
});
