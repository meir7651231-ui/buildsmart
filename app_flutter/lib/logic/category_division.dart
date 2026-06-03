import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';

/// Benzi #1 (reframed) — "fixtures vs pipes" department layout.
///
/// Each plumbing department is shown as **small headings, each followed by its
/// category rows** (no drill-in "שפכים"/"לבנים" super-category). The rows are
/// catalog-tree nodes by title: a clean top-node (e.g. צנרת PPR — all water)
/// shows as ONE row that drills into its sub-tree; a genuinely-mixed top-node
/// (ברזים וכיורים = faucets + line-valves) is split into its leaf categories so
/// each lands under the right heading.
///
/// Authority: the per-category classification reviewed with the user. Tools
/// (כלי עבודה / כלי ריתוך / חותך צינורות) are intentionally absent — they live
/// in the tool departments.
typedef DeptHeading = ({String emoji, String label, List<String> titles});

const Map<String, List<DeptHeading>> kDeptCatHeadings = {
  'ברזים וסניטריים': [
    (emoji: '🚽', label: 'כלים לבנים', titles: ['אסלות']),
    (
      emoji: '🛁',
      label: 'כלים גמר',
      titles: [
        'מקלחות ואמבטיות',
        'אביזרים נלווים',
        'ברזי כיור',
        'ברזי מטבח',
        'ברזי קיר',
        'ברזי אמבטיה',
        'ברזי מקלחת',
        'ברזי דלי',
        'אביזרי ברזים',
      ],
    ),
  ],
  'אינסטלציה': [
    (
      emoji: '💧',
      label: 'צינורות מים',
      titles: [
        'צנרת PPR (פולירול)',
        'אביזרי קצה וחיבורים',
        'גינון והשקיה',
        'ברזי מעבר',
        'ברזי ניל',
        'מחלקים',
        'ארונות מחלק',
        'נקודות מים',
        'צינורות רב שכבתי',
        // דו-מערכתי — מופיע גם תחת שפכים (מתאים לשני סוגי הצנרת).
        'אטמים ופקקים',
        'חבקי תליה',
        'חבקי צינור',
        'עוגנים ובנדים',
        'סטי הידוק וחיבורים',
      ],
    ),
    (
      emoji: '🟤',
      label: 'צינורות שפכים',
      titles: [
        'ניקוז וצנרת',
        'דלוחין SmartLock (חוליות)',
        'מסעפים וחיבורי אסלה',
        // דו-מערכתי — מופיע גם תחת מים (מתאים לשני סוגי הצנרת).
        'אטמים ופקקים',
        'חבקי תליה',
        'חבקי צינור',
        'עוגנים ובנדים',
        'סטי הידוק וחיבורים',
      ],
    ),
  ],
};

/// True if [deptName] uses the heading/category layout (vs a water-system or
/// tool department).
bool isCatalogDept(String deptName) => kDeptCatHeadings.containsKey(deptName);

/// Resolve a heading title to its catalog-tree node: a real branch/leaf when the
/// title is a node title, else a synthetic leaf when it's a bare `categoryHe`
/// (so a split-out leaf like `ברזי כיור` still drills to its products).
CatalogNode? resolveCatTitle(String title) {
  CatalogNode? hit;
  void walk(CatalogNode n) {
    if (hit != null) return;
    if (n.title == title || n.lipskeyCategory == title) {
      hit = n;
      return;
    }
    for (final c in n.children) {
      walk(c);
    }
  }

  for (final t in kCatalogTree) {
    walk(t);
  }
  if (hit != null) return hit;
  // Bare categoryHe with no node of its own → synthetic leaf.
  if (kCatalogProducts.any((p) => p.categoryHe == title)) {
    return CatalogNode(
        id: 'catdept.$title', title: title, emoji: '📦', lipskeyCategory: title);
  }
  return null;
}

/// Total products reachable under [node] (sums its leaf categories).
int catNodeProductCount(CatalogNode node) {
  final cats = <String>{};
  void collect(CatalogNode n) {
    if (n.isLeaf) {
      final l = n.lipskeyCategory;
      if (l != null) cats.add(l);
    } else {
      for (final c in n.children) {
        collect(c);
      }
    }
  }

  collect(node);
  return kCatalogProducts.where((p) => cats.contains(p.categoryHe)).length;
}
