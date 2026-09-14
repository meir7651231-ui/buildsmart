// ⚛️ אטום-Dart (דרגת-חוזה) · matesBoost
// מוצא: buildsmart/app_flutter/lib/features/global_search/prediction_ranking.dart:44 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, ייבוא-מדף בלבד (אומת ע"י פותר-המזהים).
// ייבוא-מדף (G69/G70 — אטום משותף מיובא, לא עותק מוטבע ולא שקע): LipskeyCatalogProduct ← ../dart-data/k_lipskey_catalog-table.dart.

import '../dart-data/k_lipskey_catalog-table.dart';

/// PURE. The prediction boost for a candidate that physically CONNECTS to what
/// the user is ALREADY building — the signal ORTHOGONAL to the typed letters that
/// breaks the "re-ranking is zero-sum" wall (swarm finding #1). Once a ½" nipple
/// is in the cart, typing "ברז" should surface the faucets that actually FIT, not
/// a random 4 of ~100. [compatibleSkus] is [contextCompatibleSkus] of the
/// cart/line; membership is the strongest tie-break there is (verified geometry,
/// not a guess). Zero when the context is empty ⇒ byte-safe.
int matesBoost(LipskeyCatalogProduct candidate, Set<String> compatibleSkus) =>
    compatibleSkus.contains(candidate.sku) ? 400 : 0;
