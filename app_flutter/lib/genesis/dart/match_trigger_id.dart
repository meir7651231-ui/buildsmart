// ⚛️ אטום-Dart (דרגת-חוזה) · matchTriggerId
// מוצא: buildsmart/app_flutter/lib/logic/studio/rules_model.dart:198-200 (חצב-בינה · חוק-3/4).
// שקע: matchClosed ← השכן `_matchClosed(closed, reply)` — עיגון מחרוזת לקבוצה-סגורה.
// מוטבע verbatim (ערך-נתונים, כלל-1): מזהי-הטריגר וקבוצתם (rules_model.dart:51-81).
//        kRuleTriggerIds = {for t in kRuleTriggers: t.id} נפתר לארבעת המזהים בסדר-המקור.
// עיגון תשובת-מודל למזהה-טריגר-אמת, או null (הפלת-הכלל).

const String kTriggerOrderNew = 'order.new';
const String kTriggerOrderStuck = 'order.stuck';
const String kTriggerOrderOpen = 'order.open';
const String kTriggerOrderDelivered = 'order.delivered';

final Set<String> kRuleTriggerIds = {
  kTriggerOrderStuck,
  kTriggerOrderNew,
  kTriggerOrderOpen,
  kTriggerOrderDelivered,
};

String? matchTriggerId(String reply,
        {required String? Function(Set<String>, String) matchClosed}) =>
    matchClosed(kRuleTriggerIds, reply);
