# חוזה · findAlternativePaths

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/logic/install_engine.dart:450-494`
**אטום:** `new/dart/find_alternative_paths.dart` — `List<List<AltNode>> findAlternativePaths(AltNode from, AltNode to, {k, maxDepth, tempC, shortestPath, shortestPathExcluding, pathCost})`

## קלט
- `from`, `to` — `AltNode` (`sku`).
- `k` — `int` מספר-החלופות (ברירת-מחדל 3, :453); `maxDepth` (6, :454); `tempC` (20, :455).
- `shortestPath` — שקע `List<AltNode>? Function(AltNode from, AltNode to, int maxDepth, int tempC)` — היה `findShortestPath(...)` (:459).
- `shortestPathExcluding` — שקע `List<AltNode>? Function(AltNode from, AltNode to, int maxDepth, int tempC, Set<(String,String)> blocked)` — היה `_findShortestPathExcluding(...)` (:475-476).
- `pathCost` — שקע `int Function(List<AltNode> path)` — היה `_pathCost(p)` (:484).

## פלט
`List<List<AltNode>>` — עד `k` מסלולים שונים, ממוינים לפי-מחיר (:450).

## התנהגות (עוגני-שורה למקור)
1. `k<=0` ⇒ `[]` (:457).
2. `first = shortestPath(...)`; אם `null` ⇒ `[]` (:459-460); אחרת `results=[first]` (:461).
3. לולאת-Yen עד `results.length==k` (:467): לכל-קשת במסלול-האחרון שאינה-חסומה — חוסם-אותה, קורא `shortestPathExcluding` (:475), מסיר-חסימה; מדלג-כפילויות (:480-483); שומר את המועמד הזול-ביותר לפי `pathCost` (:484-488).
4. מועמד-ריק ⇒ `break` (:490); אחרת מוסיף (:491).

## דוגמאות מספריות (מוכחות ב-find_alternative_paths_test.dart)
שקעים מבוקרים: `shortestPath ⇒ [A,C,D]`; `shortestPathExcluding ⇒ [A,B,D]` כשחסום (A,C) או (C,D), אחרת null; `pathCost = (אורך-1)·10`.
| # | k · שקעים | פלט | עוגן |
|---|-----|-----|------|
| 1 | k=2 | `[[A,C,D],[A,B,D]]` | :471-491 |
| 2 | k=1 | `[[A,C,D]]` | :467 |
| 3 | k=0 | `[]` | :457 |
| 4 | shortestPath⇒null | `[]` | :460 |
| 5 | k=3, Excluding⇒null-תמיד | `[[A,C,D]]` | :490 |

## עדשה-עוינת
- #5: אף-חלופה לא-נמצאה (Excluding=null) ⇒ `bestCandidate` נשאר ריק ⇒ `break`, מחזיר רק-את-הזול, גם כש-k=3 — לא נכנס ללולאה-אינסופית.
- #2: k=1 ⇒ הלולאה כלל-לא-רצה (`results.length(1) < 1` = false).
- דדופ (:480-483): מסלול זהה-אורך + זהה-skus אינו-מתווסף פעמיים.
- דטרמיניזם: אין `Date.now`/אקראיות — פלט תלוי-שקעים בלבד.
