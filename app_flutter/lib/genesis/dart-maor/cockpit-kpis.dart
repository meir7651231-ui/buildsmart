// ⚛️ אטום-Dart (דרגת-חוזה) · cockpitKpis — ארבעת מדדי-הראש של הקוקפיט.
// מוצא: maor/src/components/supporters/cockpit.ts:227 · המקור-הקדוש: new/atoms/cockpit-kpis.mjs.
//        חוק-4 — זהה-ביט למקור-JS. השכנים cockpitCollectedThisMonth/hokMonthlyTotal/cockpitAtRisk
//        מוזרקים כשקעי-פונקציה (חוק-1/חוק-3).
//
// קלט: supporters (List<Map>) · todayIso · rate · שקעים. פלט: Map בסדר total→collected→expectedHok→atRisk.
// הערות-המרה: `cockpitAtRisk(supporters, todayIso)` — 2 ארגומנטים (silentDays ברירת-מחדל בשקע).
//  `supporters.length` ⇒ .length. אין מיון/פורמט.

/// The four head KPIs of the cockpit: {total, collected, expectedHok, atRisk}.
/// Verbatim port of new/atoms/cockpit-kpis.mjs (neighbours injected as sockets).
Map<String, dynamic> cockpitKpis(
  List supporters,
  String todayIso,
  num rate,
  int Function(List, String, num) cockpitCollectedThisMonth,
  num Function(List, num) hokMonthlyTotal,
  List Function(List, String) cockpitAtRisk,
) {
  return {
    'total': supporters.length,
    'collected': cockpitCollectedThisMonth(supporters, todayIso, rate),
    'expectedHok': hokMonthlyTotal(supporters, rate),
    'atRisk': cockpitAtRisk(supporters, todayIso).length,
  };
}
