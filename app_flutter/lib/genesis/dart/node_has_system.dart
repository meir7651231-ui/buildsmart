// ⚛️ אטום-Dart (דרגת-חוזה) · nodeHasSystem
// תפקיד: האם צומת-קטלוג שייך למערכת-מים נתונה — קבועות (fixtures) גם-וגם; אחרת
//        המערכת-הדומיננטית (סכימת sup/dr על כל העלים שמתחתיו) מכריעה.
// מוצא: buildsmart/app_flutter/lib/logic/system_division.dart:70-95 (‏nodeHasSystem;
//       שוחזר מלא מ-main של buildsmart — קו-האמת, L16; חוק-4 — התנהגות זהה, לא-משופרת).
// אחים/שקעים (חוק-3 + הכרעה-13, קריאה-לשכן/דאטה ⇒ פרמטר-שקע):
//   • `_fixtureTitles` (דאטה-const, system_division.dart:40 — {'אסלות','מקלחות ואמבטיות',
//     'גופי תברואה'}) ⇒ שקע `fixtureTitles`. הדאטה חיה בקופסה, לא במנוע.
//   • `_catSystemTallyIndex` (אינדקס-נגזר מ-catalogRepo().allProducts(), שורות 47-60)
//     ⇒ שקע `catSystemTally` — Map קטגוריה ⇒ (sup, dr). הקופסה בונה/מזריקה.
//   • `_nodeHasSystemCache` (מצב-מודול memo, שורה 65) ⇒ שקע `cache` — הקופסה מחזיקה
//     Map מתמיד לקבלת ה-memoization של המקור; Map ריק-פר-קריאה = אותן תוצאות בדיוק.
//   • ה-closure הפנימי `walk` (שורות 76-89) הוטבע verbatim — עוזר-מקומי של הפונקציה.
//   • טיפוסי-השכן CatalogNode (catalog_tree.dart:10-33, השדות הנקראים בלבד; isLeaf =
//     getter על children.isEmpty — verbatim) ו-WaterSystem הוטבעו inline (הכרעת-טיפוס-מותאם).
// טוהר: dart:core בלבד, אפס import, אפס דאטה-צרובה.
//
// קלט:  node · system · fixtureTitles · catSystemTally · cache.
// פלט:  bool — האם הצומת שייך למערכת.

/// מערכת-מים (הוטבע inline, זהה לאטום-האח productDivisionSystems). אספקה / ניקוז.
enum WaterSystem { supply, drainage }

/// צומת עץ-הקטלוג — טיפוס-שכן מוטבע, השדות שהאטום קורא בלבד
/// (catalog_tree.dart: id · title · children · lipskeyCategory · isLeaf-getter, verbatim).
class CatalogNode {
  const CatalogNode({
    required this.id,
    required this.title,
    this.children = const [],
    this.lipskeyCategory,
  });

  final String id;
  final String title;
  final List<CatalogNode> children;
  final String? lipskeyCategory;

  bool get isLeaf => children.isEmpty;
}

/// True if [node] belongs to [system]: fixtures → both sides; otherwise the
/// node's dominant system (over all products under it). Drives the department
/// division at the sub-category level. Verbatim system_division.dart:70-95 —
/// הגלובלים הורמו לשקעים [fixtureTitles] · [catSystemTally] · [cache].
bool nodeHasSystem(
  CatalogNode node,
  WaterSystem system, {
  required Set<String> fixtureTitles,
  required Map<String, ({int sup, int dr})> catSystemTally,
  required Map<String, bool> cache,
}) {
  if (fixtureTitles.contains(node.title)) return true;
  final cacheKey = '${node.id}|${system.name}';
  final cached = cache[cacheKey];
  if (cached != null) return cached;
  var sup = 0, dr = 0;
  void walk(CatalogNode n) {
    if (n.isLeaf) {
      final c = n.lipskeyCategory;
      if (c == null) return;
      final t = catSystemTally[c];
      if (t == null) return;
      sup += t.sup;
      dr += t.dr;
    } else {
      for (final ch in n.children) {
        walk(ch);
      }
    }
  }

  walk(node);
  final result = (sup != 0 || dr != 0) &&
      (sup >= dr ? WaterSystem.supply : WaterSystem.drainage) == system;
  return cache[cacheKey] = result;
}
