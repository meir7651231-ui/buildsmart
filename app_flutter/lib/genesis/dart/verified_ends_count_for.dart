// ⚛️ אטום-Dart (דרגת-חוזה) · verifiedEndsCountFor
// מוצא: buildsmart/app_flutter/lib/data/related_info.dart:278 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, ייבוא-מדף בלבד (אומת ע"י פותר-המזהים).
// ייבוא-מדף (G69/G70 — אטום משותף מיובא, לא עותק מוטבע ולא שקע): kVerifiedSpecs · LipskeyCatalogProduct ← ../dart-data/k_verified_specs-table.dart ../dart-data/k_lipskey_catalog-table.dart.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-הקורא features__internal_card__full_internal_card — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): חזור · מק״ט · מוטבע · על · התמונה · נגיעה · גלריה · מה · מתחבר · לצד · מ״מ · חובה

import '../dart-data/k_verified_specs-table.dart';
import '../dart-data/k_lipskey_catalog-table.dart';

/// D4 · how many physical connector ends [p] has (0 when no verified spec).
int verifiedEndsCountFor(LipskeyCatalogProduct p) =>
    kVerifiedSpecs[p.sku]?.ends.length ?? 0;
