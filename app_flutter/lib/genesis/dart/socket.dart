// ⚛️ אטום-Dart (דרגת-חוזה) · socket
// מוצא: buildsmart/app_flutter/lib/features/fittings/plan/deep_ends.dart:25 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, ייבוא-מדף בלבד (אומת ע"י פותר-המזהים).
// טבלאות-מדף (G69 — אטום-דאטה משותף מיובא, לא עותק מוטבע): ConnectorEnd · EndType ← ../dart-data/k_verified_specs-table.dart.
// חלול: ConnectorEnd = const ConnectorEnd(EndType.hdpeCompression, 'a')

import '../dart-data/k_verified_specs-table.dart';

/// שקע-ריתוך יחיד ב-DN נתון (ה-overload המתועד של `hdpeCompression`).
ConnectorEnd socket(int dn) =>
    ConnectorEnd(EndType.hdpeCompression, dn.toString());
