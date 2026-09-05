// ⚛️ אטום-Dart (דרגת-חוזה) · cockpitQueue — שלוש קבוצות + רשימה-מאוחדת + מונה.
// מוצא: maor/src/components/supporters/cockpit.ts:250 · המקור-הקדוש: new/atoms/cockpit-queue.mjs.
//        חוק-4 — זהה-ביט למקור-JS. השכנים cockpitCalls/cockpitThanks/cockpitHokTasks מוזרקים כשקעים.
//
// קלט: supporters (List<Map>) · todayIso · rate · שקעים. פלט: Map בסדר calls→thanks→hok→tasks→total.
// הערות-המרה: `[...calls, ...thanks, ...hok]` ⇒ spread-list. אין מיון (הרשימות כבר ממוינות בשקעים).
//  cockpitCalls נקרא עם rate (3 ארגומנטים); cockpitThanks/cockpitHokTasks — 2 ארגומנטים.

/// Three task groups + a merged list + a count.
/// Verbatim port of new/atoms/cockpit-queue.mjs (neighbours injected as sockets).
Map<String, dynamic> cockpitQueue(
  List supporters,
  String todayIso,
  num rate,
  List Function(List, String, num) cockpitCalls,
  List Function(List, String) cockpitThanks,
  List Function(List, String) cockpitHokTasks,
) {
  final calls = cockpitCalls(supporters, todayIso, rate);
  final thanks = cockpitThanks(supporters, todayIso);
  final hok = cockpitHokTasks(supporters, todayIso);
  final tasks = [...calls, ...thanks, ...hok];
  return {
    'calls': calls,
    'thanks': thanks,
    'hok': hok,
    'tasks': tasks,
    'total': tasks.length,
  };
}
