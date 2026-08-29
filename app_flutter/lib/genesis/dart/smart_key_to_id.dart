// ⚛️ אטום-Dart (דרגת-חוזה) · smartKeyToId
// תפקיד: המפה `SmartProduct.key → מזהה-קטגוריה`, נבנית פעם-אחת מהליכת-יער
//        קדם-סדר על עץ-הקטלוג (רק צמתים עם smartKey לא-null) וממוטמנת במחזיק.
// מוצא: buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:97-100
//       (‏_smartKeyToId) + החצי-החכם של הבנאי _buildCategoryResolvers (‏:70-88;
//       השורות הנקראות: 72, 76-77, 78-88; חוק-4 — verbatim).
//       ⚠️ חולץ מ-commit dea7af3f — הקובץ אינו בעץ-העבודה הנוכחי של buildsmart.
// אחים: במקור הבנאי ממלא בהליכה-אחת שתי מפות (lipskey+smart) לשני מטמונים
//       גלובליים. פירוק לפי כלל-העצירה של חוק-5: כל מפה = יחידת-קלט/פלט משלה;
//       "שתי המפות בהליכה-אחת" = אופטימיזציית-חיווט של הקופסה. החצי-הזה נושא
//       אך ורק את שורות-ה-smart (‏:76-77 בטבע ההליכה); האח lipskey_category_to_id
//       נושא את שורות-ה-lipskey (‏:74-75).
// שקעים שהוזרקו (קריאה-לשכן/סטייט ⇒ פרמטר-שקע · חוק-1/3, דיבר-3):
//   • `kCatalogTree` (‏:83) — דאטה-גלובלית ⇒ פרמטר `tree` (יער-שורשים).
//   • `_categoryId(n.id)` (‏:77) ⇒ שקע `categoryIdOf` — סכימת-המזהים של הקופסה
//     (האטום-האח categoryId; במקור: '$kPlumbingTradeId.cat.$key').
//   • `_smartKeyToIdCache` (‏:68) — סטייט-מודול nullable ⇒ מחזיק `SmartKeyToIdCache`
//     מוזרק (תקדים end_pair_memoized: הסטייט חי אצל הקופסה; תקדים walk: מחזיק-
//     מוטבל כי Dart לא מעביר by-ref).
//   • טיפוס-השכן CatalogNode הוטבע inline (השדות הנקראים בלבד: id·smartKey·children).
// טוהר: dart:core בלבד. אפס-דאטה: העץ, הסכימה והמטמון מוזרקים.

/// ‏plumbing_trade_seed.dart:97-100 verbatim: מטמון ריק ⇒ בנייה (הליכת-יער
/// קדם-סדר, צומת-עם-smartKey ⇒ `map[smartKey] = categoryIdOf(n.id)` — כתיבה
/// אחרונה גוברת בכפילות); מטמון מלא ⇒ מוחזר כמות-שהוא, [tree] לא נסרק
/// ו-[categoryIdOf] לא נקרא (שורה 98: `if (_smartKeyToIdCache == null)`).
Map<String, String> smartKeyToId(
  List<CatalogNode> tree, {
  required String Function(String key) categoryIdOf,
  required SmartKeyToIdCache cache,
}) {
  if (cache.map == null) {
    final smart = <String, String>{};
    void walk(CatalogNode n) {
      final smartKey = n.smartKey;
      if (smartKey != null) smart[smartKey] = categoryIdOf(n.id);
      for (final c in n.children) {
        walk(c);
      }
    }

    for (final n in tree) {
      walk(n);
    }
    cache.map = smart;
  }
  return cache.map!;
}

/// מחזיק-המטמון המוטבל — במקור המשתנה הגלובלי `Map<String, String>?
/// _smartKeyToIdCache` (שורה 68). מוזרק כדי שהסטייט יחיה אצל הקופסה (חוק-5).
class SmartKeyToIdCache {
  SmartKeyToIdCache([this.map]);
  Map<String, String>? map;
}

// — טיפוס-השכן מוטבע (השדות הנקראים ע"י האטום בלבד; catalog_tree.dart:10-31) —
class CatalogNode {
  const CatalogNode({
    required this.id,
    this.smartKey,
    this.children = const [],
  });

  final String id;
  final String? smartKey;
  final List<CatalogNode> children;
}
