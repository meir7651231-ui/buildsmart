# חוזה · findShortestPath

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/logic/install_engine.dart:553-608`
**אטום:** `new/dart/find_shortest_path.dart` — `List<GraphNode>? findShortestPath(GraphNode from, GraphNode to, {maxDepth, tempC, systemsOf, canConnect, neighbors, usableConnector, edgeCost})`

## קלט
- `from`, `to` — `GraphNode`: `sku` (String).
- `maxDepth` — `int` (ברירת-מחדל 6, :556); `tempC` — `int` (ברירת-מחדל 20, :557).
- `systemsOf` — שקע `Set<String> Function(GraphNode)` — היה `productSystems(x)` (:564-565,598). `WaterSystem` מיוצג כמחרוזות ('supply'/'drainage'), איזומורפי.
- `canConnect` — שקע `bool Function(GraphNode a, GraphNode b)` (:571).
- `neighbors` — שקע `List<GraphNode> Function(GraphNode tail, int tempC)` — היה `compatibleWith(tail,tempC)` (:593).
- `usableConnector` — שקע `bool Function(GraphNode)` — היה `_usableConnector(next)` (:597).
- `edgeCost` — שקע `int Function(GraphNode a, GraphNode b)` — היה `_edgeCost(tail,next)` (:601).

## פלט
`List<GraphNode>?` — המסלול הזול-ביותר (Dijkstra: 10·חלקים + מעברי-חומר), או `null` כשאין מסלול תוך `maxDepth` (:607).

## התנהגות (עוגני-שורה למקור)
1. `from.sku==to.sku` ⇒ `[from]` (:559).
2. `systemsOf(from) ∩ systemsOf(to)` ריק ⇒ `null` (דחייה-מהירה, :570).
3. `canConnect(from,to)` ⇒ `[from,to]` (:571).
4. חיפוש-Dijkstra עם `SplayTreeMap` (:578); דלי-מחיר פוקח LIFO (`removeLast`, :585); דילוג-כניסה-מיושנת (:590); חסם-עומק (:591); דחיית-שוויון `newCost >= bestCost` (:602); חוצה-מערכת ⇒ דחייה (:599-600).

## דוגמאות מספריות (מוכחות ב-find_shortest_path_test.dart)
גרף: `A→[B,C] · B→[D] · C→[D] · D→[]`, כל-הצמתים {supply}, edgeCost=10.
| # | קלט | פלט | עוגן |
|---|-----|-----|------|
| 1 | from=to=A | `[A]` | :559 |
| 2 | systemsOf(A)={supply}, אחרים={drainage} | `null` | :570 |
| 3 | canConnect(A,B)=true | `[A,B]` | :571 |
| 4 | canConnect=false, BFS | `[A,C,D]` | :585,602 |
| 5 | maxDepth=1 | `null` | :591,607 |

## עדשה-עוינת
- #4 מחזיר `A→C→D` ולא `A→B→D`: `removeLast` פוקח את C (נוסף-אחרון) קודם, ונתיב-B נדחה בשוויון-מחיר (`>=`, :602) — התנהגות verbatim תלוית-סדר.
- `usableConnector` נבדק רק על צמתים שאינם-היעד (`!isTarget`, :597) — היעד עצמו פטור.
- `SplayTreeMap` (dart:collection) = ספריית-תקן, לא import-אטום (LAW: שפה/סטנדרט מותר).
