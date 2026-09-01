// ⚛️ אטום-Dart (דרגת-חוזה) · plumbingFixtures
// מוצא: buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:204-246 (חוק-4 — התנהגות זהה, לא-משופרת).
// הכרעה: השכן `_smartKeyToId()` והדאטה `kSmartProducts` ⇒ שקעי-פרמטר (חוק-1: חוט לא מייבא חוט);
// מזהי-ההצבה kPlumbingTradeId/kUncategorizedCategoryId ⇒ שקעים (מוסכמת category_id).
// טיפוסי-מינימום מוטבעים verbatim-שדות: קלט SmartProduct/SmartBrand/SmartAcc/SmartStage
// (smart_tree.dart:5-136) · פלט SmartFixture/SmartBrandRef/InstallStage (trade_schema.dart:458-599)
// — רק השדות שהפונקציה נוגעת בהם + ברירות-המחדל של המקור.
// טוהר: אפס import · אפס דאטה-צרובה · דטרמיניסטי (מיון-id יציב).

// ── טיפוסי-קלט מינימליים (verbatim smart_tree.dart) ──────────────────────────

/// צורת-מינימום של SmartStage — שלב-התקנה במקור (smart_tree.dart:5-19).
class SmartStage {
  const SmartStage({
    required this.emoji,
    required this.label,
    required this.sub,
    this.isFinal = false,
    this.match = const [],
  });
  final String emoji;
  final String label;
  final String sub;
  final bool isFinal;
  final List<String> match;
}

/// צורת-מינימום של SmartBrand (smart_tree.dart:82-96).
class SmartBrand {
  const SmartBrand({
    required this.name,
    required this.tag,
    this.price,
    this.rec = false,
    this.sku,
    this.imageAsset,
  });
  final String name;
  final String tag;
  final int? price;
  final bool rec;
  final String? sku;
  final String? imageAsset;
}

/// צורת-מינימום של SmartAcc — הפונקציה קוראת רק את אורך-הרשימה (smart_tree.dart:98-114).
class SmartAcc {
  const SmartAcc();
}

/// צורת-מינימום של SmartProduct — רק השדות ש-plumbingFixtures קורא (smart_tree.dart:116-136).
class SmartProduct {
  const SmartProduct({
    required this.key,
    required this.name,
    required this.emoji,
    required this.brands,
    required this.acc,
    this.diagramTitle = '',
    this.stages = const [],
  });
  final String key;
  final String name;
  final String emoji;
  final List<SmartBrand> brands;
  final List<SmartAcc> acc;
  final String diagramTitle;
  final List<SmartStage> stages;
}

// ── טיפוסי-פלט מינימליים (verbatim trade_schema.dart) ────────────────────────

/// צורת-מינימום של SmartBrandRef (trade_schema.dart:458-482).
class SmartBrandRef {
  const SmartBrandRef({
    required this.name,
    required this.tag,
    this.rec = false,
    this.sku,
    this.imageAsset,
    this.price,
  });
  final String name;
  final String tag;
  final bool rec;
  final String? sku;
  final String? imageAsset;
  final int? price;
}

/// צורת-מינימום של InstallStage (trade_schema.dart:508-529).
class InstallStage {
  const InstallStage({
    required this.emoji,
    required this.labelHe,
    this.subHe = '',
    this.isFinal = false,
    this.matchTokens = const [],
  });
  final String emoji;
  final String labelHe;
  final String subHe;
  final bool isFinal;
  final List<String> matchTokens;
}

/// צורת-מינימום של SmartFixture (trade_schema.dart:554-599).
class SmartFixture {
  const SmartFixture({
    required this.id,
    required this.tradeId,
    required this.categoryId,
    required this.nameHe,
    required this.emoji,
    this.diagramTitleHe = '',
    this.brandRefs = const [],
    this.accessoryRuleIds = const [],
    this.stages = const [],
  });
  final String id;
  final String tradeId;
  final String categoryId;
  final String nameHe;
  final String emoji;
  final String diagramTitleHe;
  final List<SmartBrandRef> brandRefs;
  final List<String> accessoryRuleIds;
  final List<InstallStage> stages;
}

// ── האטום ─────────────────────────────────────────────────────────────────────

/// המוצרים-הקיוריטוריים כ-[SmartFixture]ים (brandRefs + stages + קישורי-אביזרים),
/// ממוינים לפי id. `categoryId` נפתר מהמפה-המוזרקת (`SmartProduct.key` → id);
/// לא-נמצא ⇒ נופל ל-[kUncategorizedCategoryId].
/// verbatim plumbing_trade_seed.dart:204-246 (kSmartProducts ⇒ שקע products ·
/// ‏_smartKeyToId() ⇒ שקע smartKeyToId).
List<SmartFixture> plumbingFixtures({
  required List<SmartProduct> products,
  required Map<String, String> smartKeyToId,
  required String kPlumbingTradeId,
  required String kUncategorizedCategoryId,
}) {
  final smartKeyMap = smartKeyToId;
  return products
      .map(
        (sp) => SmartFixture(
          id: '$kPlumbingTradeId.fixture.${sp.key}',
          tradeId: kPlumbingTradeId,
          categoryId: smartKeyMap[sp.key] ?? kUncategorizedCategoryId,
          nameHe: sp.name,
          emoji: sp.emoji,
          diagramTitleHe: sp.diagramTitle,
          brandRefs: sp.brands
              .map(
                (b) => SmartBrandRef(
                  name: b.name,
                  tag: b.tag,
                  rec: b.rec,
                  sku: b.sku,
                  imageAsset: b.imageAsset,
                  price: b.price,
                ),
              )
              .toList(),
          accessoryRuleIds: [
            for (var i = 0; i < sp.acc.length; i++)
              '$kPlumbingTradeId.acc.${sp.key}.$i',
          ],
          stages: sp.stages
              .map(
                (s) => InstallStage(
                  emoji: s.emoji,
                  labelHe: s.label,
                  subHe: s.sub,
                  isFinal: s.isFinal,
                  matchTokens: s.match,
                ),
              )
              .toList(),
        ),
      )
      .toList()
    ..sort((a, b) => a.id.compareTo(b.id));
}
