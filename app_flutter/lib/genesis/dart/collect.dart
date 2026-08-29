// ⚛️ אטום-Dart (דרגת-חוזה) · collect
// תפקיד: מעבר-עומק רקורסיבי שאוסף את קטגוריות-העלים (lipskeyCategory) של תת-עץ CatalogNode.
// מוצא: buildsmart/app_flutter/lib/logic/category_division.dart:112-121 (ה-closure `collect`; חוק-4).
// אחים: במקור זה closure שסוגר על הקבוצה `cats`; כאן הופך לפונקציית-top-level עצמאית
//       שמקבלת את הקבוצה-הצוברת כפרמטר `out` (חוק-3: הצבירה החיצונית ⇒ פרמטר).
//       טיפוס-השכן CatalogNode הוטבע inline verbatim. הזנב `catalogRepo()...` בטיוטה שייך
//       לפונקציה-העוטפת catNodeProductCount ואינו חלק מ-closure זה — הושמט.
// טוהר: dart:core בלבד.

/// עלה ⇒ מוסיף את lipskeyCategory (אם לא-null) ל-[out]; פנימי ⇒ רקורסיה על הילדים.
/// verbatim category_division.dart:112-121.
void collect(CatalogNode n, Set<String> out) {
  if (n.isLeaf) {
    final l = n.lipskeyCategory;
    if (l != null) out.add(l);
  } else {
    for (final c in n.children) {
      collect(c, out);
    }
  }
}

// — טיפוס-השכן מוטבע (השדות הנקראים ע"י האטום בלבד) —
class CatalogNode {
  const CatalogNode({
    required this.isLeaf,
    this.lipskeyCategory,
    this.children = const [],
  });

  final bool isLeaf;
  final String? lipskeyCategory;
  final List<CatalogNode> children;
}
