# חוזה · findShortestPathExcluding

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/logic/install_engine.dart:507-548`
**אטום:** `new/dart/find_shortest_path_excluding.dart` — `List<GraphNode>? findShortestPathExcluding(GraphNode from, GraphNode to, {maxDepth, tempC, blocked, systemsOf, canConnect, neighbors, usableConnector, edgeCost})`

## קלט
- `from`, `to` — `GraphNode` (`sku`).
- `maxDepth`, `tempC` — `int` required (:510-511).
- `blocked` — `Set<(String,String)>` — קשתות-מכוונות חסומות (sku→sku, :512).
- `systemsOf` — שקע `Set<String> Function(GraphNode)` (:515-516,538).
- `canConnect` — שקע `bool Function(GraphNode a, GraphNode b)` (:518).
- `neighbors` — שקע `List<GraphNode> Function(GraphNode tail, int tempC)` — היה `compatibleWith(tail,tempC)` (:534).
- `usableConnector` — שקע `bool Function(GraphNode)` (:537).
- `edgeCost` — שקע `int Function(GraphNode a, GraphNode b)` (:541).

## פלט
`List<GraphNode>?` — כמו findShortestPath, אך אף-קשת ב-`blocked` אינה בשימוש; `null` כשאין מסלול-כזה.

## התנהגות (עוגני-שורה למקור)
זהה ל-findShortestPath, בתוספת:
1. קיצור-הדרך הישיר `[from,to]` נחסם אם `blocked.contains((from.sku,to.sku))` — התנאי `canConnect(from,to) && !blocked.contains(...)` (:518).
2. הרחבת-שכן: `blocked.contains((tail.sku,next.sku))` ⇒ דילוג-הקשת (:535).
שאר-השלבים: מערכות-זרות⇒null (:517); Dijkstra LIFO (:528); דחיית-מיושן (:532); חסם-עומק (:533); דחיית-שוויון (:542).

## דוגמאות מספריות (מוכחות ב-find_shortest_path_excluding_test.dart)
גרף: `A→[B,C] · B→[D] · C→[D]`, כולם {supply}, edgeCost=10, canConnect=false (אלא-אם צוין).
| # | blocked · canConnect | פלט | עוגן |
|---|-----|-----|------|
| 1 | `{}` | `[A,C,D]` | :528,542 |
| 2 | `{(A,C)}` | `[A,B,D]` | :535 |
| 3 | `{(A,B),(A,C)}` | `null` | :535,547 |
| 4 | from=to=A | `[A]` | :514 |
| 5 | `{(A,D)}` · canConnect(A,D)=true | `[A,C,D]` | :518 |

## עדשה-עוינת
- #5: קיצור-הדרך הישיר (A,D) חסום ⇒ `canConnect && !blocked` = false, נופל ל-BFS; ה-BFS מחזיר `A→C→D` (LIFO) ולא `A→B→D`.
- #2 חוסם קשת-יציאה-ראשונה (A,C) ⇒ נאלץ B; #3 חוסם את שתי-קשתות-היציאה ⇒ אין-מסלול.
- `blocked` מכוון: `(A,C)` חוסם רק A→C, לא C→A.
