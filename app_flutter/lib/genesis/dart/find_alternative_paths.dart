// ⚛️ אטום-Dart (דרגת-חוזה) · findAlternativePaths
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:450-494
//        (חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק dart:core).
//
// אלגוריתם בסגנון-Yen (install_engine.dart:463-465): מתחיל מהמסלול-הזול, ואז
// לכל קשת בו — מחפש את המסלול-הזול שנמנע מאותה קשת, ושומר את ה-k הזולים.
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • findShortestPath(from,to,maxDepth,tempC) (install_engine.dart:459) ⇒ שקע
//     `shortestPath` (האטום find_shortest_path.dart הנפרד — שכן, לא import).
//   • _findShortestPathExcluding(...,blocked) (install_engine.dart:475-476) ⇒ שקע
//     `shortestPathExcluding` (האטום find_shortest_path_excluding.dart הנפרד).
//   • _pathCost(p) (install_engine.dart:484) ⇒ שקע `pathCost` (האטום path_cost.dart).
//
// קלט:  from, to — AltNode (sku).
//       k        — מספר-החלופות המבוקש (ברירת-מחדל 3, install_engine.dart:453).
//       maxDepth — ברירת-מחדל 6 (install_engine.dart:454).
//       tempC    — ברירת-מחדל 20 (install_engine.dart:455).
//       shortestPath, shortestPathExcluding, pathCost — שקעים.
// פלט:  List<List<AltNode>> — עד k מסלולים שונים, ממוינים לפי-מחיר (install_engine.dart:450);
//        k≤0 ⇒ [] (install_engine.dart:457); אין מסלול-ראשון ⇒ [] (install_engine.dart:460).

/// מחזיק-קלט טהור: הצומת מזוהה ב-sku בלבד (משמש לזוגות-קשת ולדדופ,
/// install_engine.dart:472,482).
class AltNode {
  final String sku;
  const AltNode({required this.sku});
}

/// עד [k] מסלולים חלופיים — התנהגות verbatim של install_engine.dart:450-494.
List<List<AltNode>> findAlternativePaths(
  AltNode from,
  AltNode to, {
  int k = 3,
  int maxDepth = 6,
  int tempC = 20,
  required List<AltNode>? Function(
          AltNode from, AltNode to, int maxDepth, int tempC)
      shortestPath,
  required List<AltNode>? Function(AltNode from, AltNode to, int maxDepth,
          int tempC, Set<(String, String)> blocked)
      shortestPathExcluding,
  required int Function(List<AltNode> path) pathCost,
}) {
  if (k <= 0) return const [];
  final results = <List<AltNode>>[];
  final first = shortestPath(from, to, maxDepth, tempC);
  if (first == null) return const [];
  results.add(first);

  final blocked = <(String, String)>{};
  while (results.length < k) {
    var bestCandidate = <AltNode>[];
    int bestCost = 1 << 30;
    final lastPath = results.last;
    for (var i = 0; i < lastPath.length - 1; i++) {
      final edge = (lastPath[i].sku, lastPath[i + 1].sku);
      if (blocked.contains(edge)) continue;
      blocked.add(edge);
      final p = shortestPathExcluding(from, to, maxDepth, tempC, blocked);
      blocked.remove(edge);
      if (p == null) continue;
      // skip duplicates
      if (results.any((r) =>
          r.length == p.length &&
          List.generate(r.length, (i) => r[i].sku == p[i].sku)
              .every((b) => b))) continue;
      final c = pathCost(p);
      if (c < bestCost) {
        bestCost = c;
        bestCandidate = p;
      }
    }
    if (bestCandidate.isEmpty) break;
    results.add(bestCandidate);
  }
  return results;
}
