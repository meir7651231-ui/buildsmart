# חוזה · `collect` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/category_division.dart:112-121` (ה-closure `collect`).

## תפקיד
מעבר-עומק רקורסיבי שאוסף את קטגוריות-העלים (lipskeyCategory) של תת-עץ CatalogNode לתוך קבוצה-צוברת.

## חתימה
```dart
void collect(CatalogNode n, Set<String> out)
// CatalogNode{ bool isLeaf; String? lipskeyCategory; List<CatalogNode> children } — מוטבע
```

## התנהגות (עוגן category_division.dart:112-121)
- `n.isLeaf` ⇒ `l=n.lipskeyCategory`; `if (l != null) out.add(l)`.
- אחרת ⇒ `for (c in n.children) collect(c, out)`.
- הזנב `catalogRepo()...` בטיוטה שייך לפונקציה-העוטפת (catNodeProductCount) — אינו חלק מ-closure זה.

## שקעים
- `out` — הקבוצה-הצוברת החיצונית (במקור closure סוגר עליה) ⇒ פרמטר (חוק-3).

## דוגמאות-מחייבות
| # | עץ | out-לפני | ⇒ out-אחרי |
|---|-----|----------|------------|
| 1 | פנימי[עלה'צנרת', פנימי[עלה'ברזים', עלה-null]] | {} | {צנרת, ברזים} |
| 2 | עלה'x' | {} | {x} |
| 3 | עלה בלי-קטגוריה | {} | {} |
| 4 | עלה'צנרת' | {צנרת} | {צנרת} (Set — אין כפילות) |
| 5 | פנימי ריק | {} | {} |

## DoD
```
dart run --enable-asserts new/dart/collect_test.dart  ⇒ exit 0 + "OK collect: 5 asserts passed"
```
