// ⚛️ אטום-Dart · plumbingProducts — מנוע-זריעה נקי (מיפוי-קטלוג→מוצרי-מקצוע + מיון, אפס-דאטה).
// מוצא: buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:156-168 (ענף claude/align-main · חוק-4).
// טוהר-מוחלט: פונקציית top-level גנרית, אפס import, **אפס דאטה צרובה**. כל השכנים שקעים (הכרעה 1):
//   • `catalogProducts`        — במקור kCatalogProducts (data/polyroll_catalog). דאטה מוזרקת.
//   • `lipskeyCategoryToId`    — במקור _lipskeyCategoryToId() (:91-94); כאן המפה המוכנה מוזרקת
//                                (האטום-האח lipskey_category_to_id בונה אותה — הבוקס מחווט).
//   • `tradeProductFromLegacy` — במקור המתאם מ-domain/trade_product_adapter; שקע-פונקציה
//                                באותה חתימה בדיוק: (p, {tradeId, categoryId}).
//   • `categoryHe`             — שקע-ריאדר: P ⇒ שם-הקטגוריה (במקור p.categoryHe).
//   • `tradeId`                — במקור kPlumbingTradeId ('plumbing', :30). דאטה מוזרקת.
//   • `uncategorizedCategoryId`— במקור kUncategorizedCategoryId (:61). דאטה מוזרקת.
//   • `idOf`                   — שקע-ריאדר למיון (במקור a.id.compareTo(b.id), :167).
// התנהגות זהה-ביט למקור כשמזריקים את שכני-המקור.
//
// קלט:  catalogProducts · lipskeyCategoryToId · categoryHe · tradeProductFromLegacy ·
//        tradeId · uncategorizedCategoryId · idOf.
// פלט:  List<R> — כל מוצר דרך המתאם (קטגוריה לא-במפה ⇒ uncategorizedCategoryId), ממוין עולה לפי idOf.

/// כל מוצרי-הקטלוג דרך המתאם, ממוינים לפי מזהה. **מנוע-בלבד**: הקטלוג, המפה,
/// המתאם והקבועים מוזרקים. קטגוריה שאינה במפה נופלת ל-[uncategorizedCategoryId]
/// (שלמות-FK — כל מוצר מצביע על קטגוריה אמיתית).
List<R> plumbingProducts<P, R>(
  List<P> catalogProducts, {
  required Map<String, String> lipskeyCategoryToId,
  required String Function(P) categoryHe,
  required R Function(P, {required String tradeId, required String categoryId})
      tradeProductFromLegacy,
  required String tradeId,
  required String uncategorizedCategoryId,
  required String Function(R) idOf,
}) {
  return catalogProducts
      .map(
        (p) => tradeProductFromLegacy(
          p,
          tradeId: tradeId,
          categoryId:
              lipskeyCategoryToId[categoryHe(p)] ?? uncategorizedCategoryId,
        ),
      )
      .toList()
    ..sort((a, b) => idOf(a).compareTo(idOf(b)));
}
