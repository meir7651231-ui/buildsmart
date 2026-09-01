// ⚛️ אטום-Dart (דרגת-חוזה) · seedPool
// מוצא: buildsmart/app_flutter/lib/features/card_keyboard/pool_seed.dart:28-33 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level ציבורית, אפס import (רק dart:core).
//
// אחים שהוטבעו (טיפוסי-שכן, כלל-1):
//   • `LipskeyCatalogProduct` — מ-lipskey_catalog.dart, רק השדה `sku` (הפרדיקט
//        בבדיקה קורא אותו; הפונקציה עצמה אינה קוראת שדה).
//   • `CardSeed` — מ-card_seed.dart:11, רק השדה `seedPredicate` (הפונקציה קוראת
//        אותו בלבד; שאר השדות/מתודות הושמטו).
//
// קלט:  seed — זרע-קליק; universe — היקום.
// פלט:  היקום מסונן בפרדיקט-הזרע — כל תוצאה מוצר-אמת (אינו ממציא).

/// טיפוס-שכן מוטבע (lipskey_catalog.dart) — רק `sku`.
class LipskeyCatalogProduct {
  const LipskeyCatalogProduct({required this.sku});
  final String sku;
}

/// טיפוס-שכן מוטבע (card_seed.dart:11) — רק `seedPredicate`.
class CardSeed {
  const CardSeed({required this.seedPredicate});
  final bool Function(LipskeyCatalogProduct) seedPredicate;
}

/// [universe] מצומצם בפרדיקט של [seed]. טהור.
List<LipskeyCatalogProduct> seedPool(
  CardSeed seed,
  List<LipskeyCatalogProduct> universe,
) =>
    universe.where(seed.seedPredicate).toList();
