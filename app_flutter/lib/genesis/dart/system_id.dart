// ⚛️ אטום-Dart · systemId
// מוצא: buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:38-39 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: הפרמטר `WaterSystem` (enum מ-lib/data/lipskey_verified_connections.dart:41)
//        הוטבע verbatim בצורת-מינימום — הפונקציה נוגעת רק ב-`.name`.
//        הקבוע `kPlumbingTradeId` (plumbing_trade_seed.dart:32) הוטבע verbatim.
//   פרטי-במקור: `_systemId` → הוצא-לחוזה כ-top-level ציבורי `systemId`.

/// המערכת ההידראולית — verbatim (lipskey_verified_connections.dart:41).
enum WaterSystem { supply, drainage }

/// המזהה השמור של סחר-האינסטלציה המובנה — verbatim (plumbing_trade_seed.dart:32).
const String kPlumbingTradeId = 'plumbing';

/// מזהה-מערכת יציב (id-scheme דטרמיניסטי). PURE.
String systemId(WaterSystem s) => '$kPlumbingTradeId.sys.${s.name}';
