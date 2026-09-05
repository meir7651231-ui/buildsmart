// ⚛️ אטום-Dart · triggerMatches
// מוצא: buildsmart/app_flutter/lib/logic/studio/rules_model.dart:385-400 (חצב-בינה · מפל-מינימום · חוק-4).

// ── consts מוטבעים verbatim (חוק-3: השכן טהור ⇒ אטום-מלא) ──────────────────
const String kTriggerOrderNew = 'order.new';
const String kTriggerOrderStuck = 'order.stuck';
const String kTriggerOrderOpen = 'order.open';
const String kTriggerOrderDelivered = 'order.delivered';

/// הזמנה (מוטבע-מינימום — רק `stage` + ה-getter הטהור `isOpen`).
class Order {
  const Order({required this.stage});
  final String stage;

  /// פתוחה = לא-נמסרה (verbatim מהמנוע).
  bool get isOpen => stage != 'delivered';
}

/// The base predicate for [trigger] over one [order]. An unknown trigger → false
/// (fail-closed). READ-ONLY — reads `stage` / `isOpen`, mutates nothing.
bool triggerMatches(String trigger, Order order) {
  switch (trigger) {
    case kTriggerOrderNew:
      return order.stage == 'new';
    case kTriggerOrderStuck:
      return order.isOpen; // "stuck" = open (the ageDays condition refines it).
    case kTriggerOrderOpen:
      return order.isOpen;
    case kTriggerOrderDelivered:
      return order.stage == 'delivered';
  }
  return false;
}
