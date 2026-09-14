// ⚛️ אטום-Dart (דרגת-חוזה) · chainArrowText
// מוצא: buildsmart/app_flutter/lib/data/related_info.dart:1464 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, ייבוא-מדף בלבד (אומת ע"י פותר-המזהים).
// ייבוא-מדף (G69/G70 — אטום משותף מיובא, לא עותק מוטבע ולא שקע): LipskeyCatalogProduct ← ../dart-data/k_lipskey_catalog-table.dart.

import '../dart-data/k_lipskey_catalog-table.dart';

/// Format a materialized line (the engine's `plan.items`, which already include
/// the inserted pipes/couplings/safety) as a glanceable RTL arrow sequence,
/// e.g. "מחסום ← צינור ← מצמד". Pure formatting; empty list → ''.
String chainArrowText(List<LipskeyCatalogProduct> items) =>
    items.map((p) => p.nameHe).join(' ← ');
