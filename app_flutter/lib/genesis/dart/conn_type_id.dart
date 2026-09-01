// ⚛️ אטום-Dart · connTypeId
// מוצא: buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:40-45 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: הפרמטר `EndType` (enum מ-lib/data/lipskey_verified_connections.dart:24)
//        הוטבע verbatim בצורת-מינימום — הפונקציה נוגעת רק ב-`.name`.
//        הקבוע `kPlumbingTradeId` (plumbing_trade_seed.dart:32) הוטבע verbatim.
//   פרטי-במקור: `_connTypeId` → הוצא-לחוזה כ-top-level ציבורי `connTypeId`.

/// סוג-הקצה של מחבר — verbatim (lipskey_verified_connections.dart:24).
enum EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale, drainOpening }

/// המזהה השמור של סחר-האינסטלציה המובנה — verbatim (plumbing_trade_seed.dart:32).
const String kPlumbingTradeId = 'plumbing';

/// מזהה-סוג-חיבור יציב (id-scheme דטרמיניסטי). PURE.
String connTypeId(EndType e) => '$kPlumbingTradeId.conn.${e.name}';
