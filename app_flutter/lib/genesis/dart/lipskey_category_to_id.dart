// ⚛️ אטום-Dart (דרגת-חוזה) · lipskeyCategoryToId
// תפקיד: המפה `lipskeyCategory → מזהה-קטגוריה`, נבנית פעם-אחת מהליכת-יער
//        קדם-סדר על עץ-הקטלוג (רק צמתים עם lipskeyCategory לא-null) וממוטמנת במחזיק.
// מוצא: buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:91-94
//       (‏_lipskeyCategoryToId) + החצי-lipskey של הבנאי _buildCategoryResolvers (‏:70-88;
//       השורות הנקראות: 71, 74-75, 78-88; חוק-4 — verbatim).
//       ⚠️ חולץ מ-commit dea7af3f — הקובץ אינו בעץ-העבודה הנוכחי של buildsmart.
// אחים: במקור הבנאי ממלא בהליכה-אחת שתי מפות (lipskey+smart) לשני מטמונים
//       גלובליים. פירוק לפי כלל-העצירה של חוק-5: כל מפה = יחידת-קלט/פלט משלה;
//       "שתי המפות בהליכה-אחת" = אופטימיזציית-חיווט של הקופסה. החצי-הזה נושא
//       אך ורק את שורות-ה-lipskey (‏:74-75 בטבע ההליכה); האח smart_key_to_id
//       (כבר-מקודם) נושא את שורות-ה-smart (‏:76-77).
// שקעים שהוזרקו (קריאה-לשכן/סטייט ⇒ פרמטר-שקע · חוק-1/3, דיבר-3):
//   • `kCatalogTree` (‏:83) — דאטה-גלובלית ⇒ פרמטר `tree` (יער-שורשים).
//   • `_categoryId(n.id)` (‏:75) ⇒ שקע `categoryIdOf` — סכימת-המזהים של הקופסה
//     (האטום-האח categoryId; במקור: '$kPlumbingTradeId.cat.$key').
//   • `_lipskeyCategoryToIdCache` (‏:67) — סטייט-מודול nullable ⇒ מחזיק
//     `LipskeyCategoryToIdCache` מוזרק (תקדים end_pair_memoized: הסטייט חי אצל
//     הקופסה; תקדים walk: מחזיק-מוטבל כי Dart לא מעביר by-ref).
//   • טיפוס-השכן CatalogNode הוטבע inline (השדות הנקראים בלבד: id·lipskeyCategory·children).
// טוהר: dart:core בלבד. אפס-דאטה: העץ, הסכימה והמטמון מוזרקים.

/// ‏plumbing_trade_seed.dart:91-94 verbatim: מטמון ריק ⇒ בנייה (הליכת-יער
/// קדם-סדר, צומת-עם-lipskeyCategory ⇒ `map[lipskeyCategory] = categoryIdOf(n.id)`
/// — כתיבה אחרונה גוברת בכפילות); מטמון מלא ⇒ מוחזר כמות-שהוא, [tree] לא נסרק
/// ו-[categoryIdOf] לא נקרא (שורה 92: `if (_lipskeyCategoryToIdCache == null)`).
Map<String, String> lipskeyCategoryToId(
  List<CatalogNode> tree, {
  required String Function(String key) categoryIdOf,
  required LipskeyCategoryToIdCache cache,
}) {
  if (cache.map == null) {
    final lipskey = <String, String>{};
    void walk(CatalogNode n) {
      final lipskeyCategory = n.lipskeyCategory;
      if (lipskeyCategory != null) lipskey[lipskeyCategory] = categoryIdOf(n.id);
      for (final c in n.children) {
        walk(c);
      }
    }

    for (final n in tree) {
      walk(n);
    }
    cache.map = lipskey;
  }
  return cache.map!;
}

/// מחזיק-המטמון המוטבל — במקור המשתנה הגלובלי `Map<String, String>?
/// _lipskeyCategoryToIdCache` (שורה 67). מוזרק כדי שהסטייט יחיה אצל הקופסה (חוק-5).
class LipskeyCategoryToIdCache {
  LipskeyCategoryToIdCache([this.map]);
  Map<String, String>? map;
}

// — טיפוס-השכן מוטבע (השדות הנקראים ע"י האטום בלבד; catalog_tree.dart:10-31) —
class CatalogNode {
  const CatalogNode({
    required this.id,
    this.lipskeyCategory,
    this.children = const [],
  });

  final String id;
  final String? lipskeyCategory;
  final List<CatalogNode> children;
}
