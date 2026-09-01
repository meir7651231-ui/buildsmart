// ⚛️ אטום-Dart (דרגת-חוזה) · dynMap
// תפקיד: המרה בטוחה של ערך-JSON-כלשהו ל-Map<String,dynamic> — Map ⇒ cast, אחרת מפה-ריקה.
//        משמש כמגן-קלט ב-fromJson של סכמת-המקצוע (trade_schema).
// מוצא: buildsmart/app_flutter/lib/domain/trade_schema.dart:41-42 (‏_dynMap; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). פרטי-במקור ⇒ public.
// אחים-שהוטבעו: — · אחים-שסוקטו: — (שאר הקובץ = מחלקות Trade/Brand וכו', לא-כלול).
//
// קלט:  v — ערך כלשהו (Object?), בד"כ ערך מתוך JSON מפוענח.
// פלט:  Map<String,dynamic> — v אם הוא Map (מומר ב-cast), אחרת `const {}`.

/// Safe JSON→map coercion: a `Map` is `cast<String,dynamic>()`, anything else
/// (null, list, scalar) yields `const {}`. Verbatim behaviour of trade_schema.dart:41-42.
Map<String, dynamic> dynMap(Object? v) =>
    v is Map ? v.cast<String, dynamic>() : const {};
