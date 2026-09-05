// ⚛️ אטום-Dart (דרגת-חוזה) · findShortestPathExcluding
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:507-548
//        (במקור `_findShortestPathExcluding`; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import-אטום. dart:collection = ספריית-תקן
//        (SplayTreeMap, install_engine.dart:522) ⇒ מותר (LAW.md: "שפה/סטנדרט בלבד").
//
// זהה ל-findShortestPath, עם תוספת אחת: קבוצת-קשתות-חסומות `blocked` (sku→sku,
// install_engine.dart:512) שמדלגת עליהן החיפוש. משמש את findAlternativePaths
// לייצור חלופות בסגנון-Yen (install_engine.dart:504-506).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • productSystems(x) (install_engine.dart:515-516,538) ⇒ שקע `systemsOf`:
//     Set<String> Function(GraphNode) — WaterSystem כמחרוזות, איזומורפי.
//   • canConnect(from,to) (install_engine.dart:518) ⇒ שקע `canConnect`.
//   • compatibleWith(tail, tempC) (install_engine.dart:534) ⇒ שקע `neighbors`.
//   • _usableConnector(next) (install_engine.dart:537) ⇒ שקע `usableConnector`.
//   • _edgeCost(tail,next) (install_engine.dart:541) ⇒ שקע `edgeCost`.
//
// קלט:  from, to  — GraphNode (sku).
//       maxDepth, tempC — required (install_engine.dart:510-511).
//       blocked   — Set<(String,String)> קשתות-חסומות מכוונות (install_engine.dart:512).
//       systemsOf, canConnect, neighbors, usableConnector, edgeCost — שקעים.
// פלט:  List<GraphNode>? — המסלול הזול-ביותר שאינו משתמש בקשת-חסומה, או null.

import 'dart:collection';

/// מחזיק-קלט טהור: הצומת מזוהה ב-sku בלבד (install_engine.dart:514,530,535).
class GraphNode {
  final String sku;
  const GraphNode({required this.sku});
}

/// כמו findShortestPath אך עם קשתות-חסומות — verbatim של install_engine.dart:507-548.
List<GraphNode>? findShortestPathExcluding(
  GraphNode from,
  GraphNode to, {
  required int maxDepth,
  required int tempC,
  required Set<(String, String)> blocked,
  required Set<String> Function(GraphNode p) systemsOf,
  required bool Function(GraphNode a, GraphNode b) canConnect,
  required List<GraphNode> Function(GraphNode tail, int tempC) neighbors,
  required bool Function(GraphNode p) usableConnector,
  required int Function(GraphNode a, GraphNode b) edgeCost,
}) {
  if (from.sku == to.sku) return [from];
  final sysFrom = systemsOf(from);
  final sysTo = systemsOf(to);
  if (sysFrom.intersection(sysTo).isEmpty) return null;
  if (canConnect(from, to) && !blocked.contains((from.sku, to.sku))) {
    return [from, to];
  }
  final buckets = SplayTreeMap<int, List<(List<GraphNode>, Set<String>)>>();
  buckets[0] = [([from], sysFrom)];
  final bestCost = <String, int>{from.sku: 0};
  while (buckets.isNotEmpty) {
    final cost = buckets.firstKey()!;
    final bucket = buckets[cost]!;
    final (path, sysAcc) = bucket.removeLast();
    if (bucket.isEmpty) buckets.remove(cost);
    final tail = path.last;
    if (tail.sku == to.sku) return path;
    if (cost > (bestCost[tail.sku] ?? 1 << 30)) continue;
    if (path.length > maxDepth) continue;
    for (final next in neighbors(tail, tempC)) {
      if (blocked.contains((tail.sku, next.sku))) continue;
      final isTarget = next.sku == to.sku;
      if (!isTarget && !usableConnector(next)) continue;
      final sysNext = sysAcc.intersection(systemsOf(next));
      if (sysNext.isEmpty) continue;
      if (isTarget && sysNext.intersection(sysTo).isEmpty) continue;
      final newCost = cost + edgeCost(tail, next);
      if (newCost >= (bestCost[next.sku] ?? 1 << 30)) continue;
      bestCost[next.sku] = newCost;
      buckets.putIfAbsent(newCost, () => []).add(([...path, next], sysNext));
    }
  }
  return null;
}
