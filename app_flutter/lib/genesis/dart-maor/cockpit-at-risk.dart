// ⚛️ אטום-Dart (דרגת-חוזה) · cockpitAtRisk — תורמים בסיכון-נטישה (ממוין מהשקט-ביותר).
// מוצא: maor/src/components/supporters/cockpit.ts:67 + hasGiven:51 (inline) + COCKPIT_SILENT_DAYS=60.
//        המקור-הקדוש: new/atoms/cockpit-at-risk.mjs. חוק-4 — זהה-ביט למקור-JS.
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). השכנים supCount/supLast/daysSince
//        מוזרקים כשקעי-פונקציה (חוק-1/חוק-3). hasGiven הוטבע inline (כמו במקור).
//
// תפקיד: נתן-בעבר (supCount>0 && supLast) · בלי nextDate · שקט ≥ silentDays. ממוין יורד לפי-השקט.
// קלט: supporters (List<Map>) · todayIso · silentDays (int) · שקעים. פלט: List<Map> (התורמים).
// הערות-המרה:
//  • `!!supLast(sp)` truthiness ⇒ supLast(sp).isNotEmpty.
//  • `if (sp.nextDate) return false` — nextDate ריק/חסר ⇒ נמשיך (null/'' = falsy).
//  • המיון `daysSince(b)-daysSince(a)` (יורד). לערכים סופיים ⇒ compareTo יורד. שמירת-יציבות
//    (JS Array.sort יציב) דרך עוגן-אינדקס משני (Dart List.sort אינו יציב).

/// Supporters at churn risk (gave before, no nextDate, silent ≥ threshold), most-silent first.
/// Verbatim port of new/atoms/cockpit-at-risk.mjs (neighbours injected as sockets).
List cockpitAtRisk(
  List supporters,
  String todayIso,
  int silentDays,
  int Function(Map) supCount,
  String Function(Map) supLast,
  num Function(String, String) daysSince,
) {
  bool hasGiven(Map sp) => supCount(sp) > 0 && supLast(sp).isNotEmpty;
  final filtered = <Map>[];
  for (final s in supporters) {
    final sp = s as Map;
    if (!hasGiven(sp)) continue;
    final nd = sp['nextDate'];
    if (nd != null && nd != '') continue;
    if (daysSince(supLast(sp), todayIso) >= silentDays) filtered.add(sp);
  }
  // מיון יורד לפי-השקט, יציב (עוגן-אינדקס משני) — נאמן ל-Array.sort היציב של JS.
  final order = List<int>.generate(filtered.length, (i) => i);
  order.sort((x, y) {
    final dy = daysSince(supLast(filtered[y]), todayIso);
    final dx = daysSince(supLast(filtered[x]), todayIso);
    final c = dy.compareTo(dx);
    return c != 0 ? c : x.compareTo(y);
  });
  return [for (final i in order) filtered[i]];
}
