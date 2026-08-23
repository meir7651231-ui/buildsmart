// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · GIANT Phase-2 · שכבת-הספק של דירוג-הלקוחות — מחלצת מהמנועים החיים
// אל ה-DTO הטהור (`RfmInput`) ומזינה את `scoreCustomer`. כאן מותר DateTime.now()
// וקריאת-providers; הלוגיקה נשארת ב-logic/customer_score.dart טהורה ונקית-משעון.
//
// כבוי (ברירת-מחדל): אף מסך לא צורך → זהה-בייטים. דלוק (`manager.scoring`):
// כרטיס-הלקוח וגיליון-הפרטים צורכים `customerScoreProvider(name)`.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/logic/customer_score.dart';
import 'package:buildsmart/logic/manager_dashboard.dart' show ManagerCustomer;
import 'package:buildsmart/state/orders_engine.dart'
    show managerCustomersProvider, ordersEngineProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The RFM score for a customer by display name. Frequency + Monetary come from
/// the derived [ManagerCustomer]; Recency is computed HERE from the raw orders'
/// `createdAt` (the aggregate is date-blind). An order with no `createdAt`
/// contributes no recency, so seed/legacy customers degrade to FM-only —
/// honest, never a crash.
final customerScoreProvider = Provider.family<CustomerScore, String>((ref, name) {
  final customers = ref.watch(managerCustomersProvider);
  ManagerCustomer? mc;
  for (final c in customers) {
    if (c.name == name) {
      mc = c;
      break;
    }
  }
  final orderCount = mc?.orderCount ?? 0;
  final totalSpend = mc?.totalSpend ?? 0;

  // Recency: days since this buyer's most-recent DATED order. Null when none
  // of their orders carry a timestamp (seed data) → FM-only score.
  DateTime? latest;
  for (final o in ref.watch(ordersEngineProvider)) {
    if (o.who != name || o.createdAt == null) continue;
    if (latest == null || o.createdAt!.isAfter(latest)) latest = o.createdAt;
  }
  final recencyDays =
      latest == null ? null : DateTime.now().difference(latest).inDays;

  return scoreCustomer(RfmInput(
    orderCount: orderCount,
    totalSpend: totalSpend,
    recencyDays: recencyDays,
  ));
});
