// ⚛️ אטום-Dart (דרגת-חוזה) · plumbingCategories
// תפקיד: שיטוח עץ-קטלוג (CatalogNode, 3 רמות) לרשימת TradeCategory מקושרת-הורים
//        + דלי-fallback "ללא קטגוריה" (שלמות-FK), ממוין דטרמיניסטית לפי id.
// מוצא: buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:114-150
//       (‏plumbingCategories; חוק-4 — verbatim). המקור בגיט: commit dea7af3f
//       (הקובץ אינו בעץ-העבודה הנוכחי של buildsmart — חולץ מההיסטוריה).
// הכרעת-הקידום (טיוטה-"קשה" — שילוב 1+2):
//   🔌 שכנים ⇒ שקעים (חוק-1/3, "דאטה=שקע" הכרעה-13 — אפס דאטה-צרובה במנוע):
//     • `kCatalogTree`  (data/catalog_tree.dart)  ⇒ פרמטר `catalogTree` — עץ-הדאטה מוזרק.
//     • `_categoryId`   (‏:32, כבר אטום category_id.dart) ⇒ שקע-פונקציה `categoryId`.
//     • `kPlumbingTradeId` (‏:30, 'plumbing')      ⇒ פרמטר `tradeId`.
//     • `kUncategorizedCategoryId` (‏:61)          ⇒ פרמטר `uncategorizedCategoryId`.
//   ⚛️ טיפוסי-שכן הוטבעו מינימלית (השדות שהאטום נוגע בהם בלבד):
//     • `CatalogNode`   (data/catalog_tree.dart:10-33)  — id/title/emoji/children/smartKey.
//     • `TradeCategory` (domain/trade_schema.dart:107-165) — בנאי+שדות verbatim
//       (‏fromJson/toJson/==/hashCode של המקור תלויים ב-flutter/foundation — הושמטו;
//       החיווט-בקופסה מספק את מחלקת-הסכמה המלאה).
//   המחרוזות 'ללא קטגוריה'/'❓' = התנהגות-המקור של דלי-ה-fallback (‏:142-143) — verbatim
//   (תקדים galvanic_group: ליטרלים אינטגרליים-להתנהגות נשארים בגוף).
// טוהר: dart:core בלבד, אפס-import. הגוף verbatim פרט לשמות-השקעים.

/// שיטוח העץ ל-[TradeCategory]-ים מקושרי-הורים. verbatim plumbing_trade_seed.dart:114-150:
/// DFS קדם-סדר; sortIndex = מקום-בין-האחים; דלי-fallback מצורף אחרון עם
/// sortIndex=out.length (לפני-המיון — יציב); מיון סופי לפי id (דטרמיניזם).
List<TradeCategory> plumbingCategories(
  List<CatalogNode> catalogTree, {required String Function(String) term, 
  required String Function(String key) categoryId,
  required String tradeId,
  required String uncategorizedCategoryId,
}) {
  final out = <TradeCategory>[];
  void walk(CatalogNode n, String? parentId, int sortIndex) {
    out.add(
      TradeCategory(
        id: categoryId(n.id),
        tradeId: tradeId,
        titleHe: n.title,
        emoji: n.emoji,
        parentId: parentId,
        sortIndex: sortIndex,
        smartFixtureId: n.smartKey,
      ),
    );
    for (var i = 0; i < n.children.length; i++) {
      walk(n.children[i], categoryId(n.id), i);
    }
  }

  for (var i = 0; i < catalogTree.length; i++) {
    walk(catalogTree[i], null, i);
  }
  // Fallback bucket so any unresolved product/fixture/accessory ref still has a
  // valid target (FK integrity). sortIndex stays stable (appended last, pre-sort).
  out.add(
    TradeCategory(
      id: uncategorizedCategoryId,
      tradeId: tradeId,
      titleHe: term('lla-ktgvryh'),
      emoji: '❓',
      parentId: null,
      sortIndex: out.length,
    ),
  );
  out.sort((a, b) => a.id.compareTo(b.id));
  return out;
}

// — טיפוסי-השכן מוטבעים (השדות שהאטום נוגע בהם בלבד) —

/// צומת עץ-הקטלוג (catalog_tree.dart:10-33; מינימלי — id/title/emoji/children/smartKey).
class CatalogNode {
  const CatalogNode({
    required this.id,
    required this.title,
    required this.emoji,
    this.children = const [],
    this.smartKey,
  });

  final String id;
  final String title;
  final String emoji;
  final List<CatalogNode> children;
  final String? smartKey;
}

/// קטגוריית-מקצוע (trade_schema.dart:107-165; בנאי+שדות verbatim, בלי json/equality).
class TradeCategory {
  const TradeCategory({
    required this.id,
    required this.tradeId,
    required this.titleHe,
    required this.emoji,
    this.parentId,
    this.sortIndex = 0,
    this.attributeSchemaIds = const [],
    this.smartFixtureId,
  });

  final String id;
  final String tradeId;
  final String titleHe;
  final String emoji;
  final String? parentId; // null = top level (tree via parent links)
  final int sortIndex;
  final List<String> attributeSchemaIds;
  final String? smartFixtureId;
}
