// ⚛️ אטום-Dart (דרגת-חוזה) · findShortestPath
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:553-608
//        (חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import-אטום. dart:collection = ספריית-תקן
//        (SplayTreeMap, install_engine.dart:578) ⇒ מותר (LAW.md: "שפה/סטנדרט בלבד").
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • productSystems(x) (install_engine.dart:564-565,598) ⇒ שקע `systemsOf`:
//     Set<String> Function(GraphNode). מייצג את WaterSystem כמחרוזות
//     ('supply'/'drainage') — איזומורפי, בלי לייבא את ה-enum.
//   • canConnect(from,to) (install_engine.dart:571) ⇒ שקע `canConnect`.
//   • compatibleWith(tail, tempC) (install_engine.dart:593) ⇒ שקע `neighbors`:
//     List<GraphNode> Function(GraphNode tail, int tempC).
//   • _usableConnector(next) (install_engine.dart:597) ⇒ שקע `usableConnector`.
//   • _edgeCost(tail,next) (install_engine.dart:601) ⇒ שקע `edgeCost`.
//
// קלט:  from, to  — GraphNode (sku).
//       maxDepth  — תקרת-קפיצות (ברירת-מחדל 6, install_engine.dart:556).
//       tempC     — טמפרטורת-הקו (ברירת-מחדל 20, install_engine.dart:557).
//       systemsOf, canConnect, neighbors, usableConnector, edgeCost — שקעים.
// פלט:  List<GraphNode>? — המסלול הזול-ביותר (Dijkstra: 10·חלקים + מעברי-חומר),
//        או null כשאין מסלול תוך maxDepth (install_engine.dart:607).

import 'dart:collection';

/// מחזיק-קלט טהור: הצומת מזוהה ב-sku בלבד (install_engine.dart:559,589,594).
class GraphNode {
  final String sku;
  const GraphNode({required this.sku});
}

/// המסלול הקצר-ביותר בגרף-התאימות — התנהגות verbatim של install_engine.dart:553-608.
List<GraphNode>? findShortestPath(
  GraphNode from,
  GraphNode to, {
  int maxDepth = 6,
  int tempC = 20,
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
  if (canConnect(from, to)) return [from, to];

  final buckets = SplayTreeMap<int, List<(List<GraphNode>, Set<String>)>>();
  buckets[0] = [([from], sysFrom)];
  final bestCost = <String, int>{from.sku: 0};

  while (buckets.isNotEmpty) {
    final cost = buckets.firstKey()!;
    final bucket = buckets[cost]!;
    final (path, sysAcc) = bucket.removeLast();
    if (bucket.isEmpty) buckets.remove(cost);

    final tail = path.last;
    if (tail.sku == to.sku) return path; // popped goal at minimum cost
    if (cost > (bestCost[tail.sku] ?? 1 << 30)) continue; // stale entry
    if (path.length > maxDepth) continue;

    for (final next in neighbors(tail, tempC)) {
      final isTarget = next.sku == to.sku;
      if (!isTarget && !usableConnector(next)) continue;
      final sysNext = sysAcc.intersection(systemsOf(next));
      if (sysNext.isEmpty) continue; // would cross systems — reject
      if (isTarget && sysNext.intersection(sysTo).isEmpty) continue;
      final newCost = cost + edgeCost(tail, next);
      if (newCost >= (bestCost[next.sku] ?? 1 << 30)) continue;
      bestCost[next.sku] = newCost;
      buckets.putIfAbsent(newCost, () => []).add(([...path, next], sysNext));
    }
  }
  return null;
}
