// ⚛️ אטום-Dart (דרגת-חוזה) · jobBoost
// מוצא: buildsmart/app_flutter/lib/features/global_search/prediction_ranking.dart:55 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, ייבוא-מדף בלבד (אומת ע"י פותר-המזהים).
// ייבוא-מדף (G69/G70 — אטום משותף מיובא, לא עותק מוטבע ולא שקע): LipskeyCatalogProduct ← ../dart-data/k_lipskey_catalog-table.dart.

import '../dart-data/k_lipskey_catalog-table.dart';

/// PURE. The keystroke-ZERO boost for a candidate that IS a product the OPEN JOB
/// needs (its own kit) — the signal that steers even the FIRST pick, on an empty
/// cart, before [matesBoost] has anything to mate against (swarm finding #2). From
/// the letters alone the keyboard can't tell which of ~100 "couplers" you mean; the
/// job you're on can ("hot-water line" ⇒ its PEX couplers lead the moment you type
/// "מקשר"). [jobSkus] is [keyboardJobSkusProvider]'s set; empty ⇒ no effect
/// (byte-safe). A notch below [matesBoost]: a verified physical mate to what's
/// in-hand is a stronger intent than mere job-kit membership.
int jobBoost(LipskeyCatalogProduct candidate, Set<String> jobSkus) =>
    jobSkus.contains(candidate.sku) ? 300 : 0;
