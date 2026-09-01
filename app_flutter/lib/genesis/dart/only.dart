// ⚛️ אטום-Dart (דרגת-חוזה) · only
// מוצא: buildsmart/app_flutter/lib/features/card_keyboard/hop_graph.dart:55-84
//        (הפונקציה המקוננת `only` בתוך crossesSystem; חוק-4 — התנהגות זהה).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//
// אח שהוטבע (טיפוס-שכן קטן, כלל-1): ה-enum `WaterSystem` — טיפוס-האיבר של
//        הקבוצה. הוטבע verbatim מ-lib/data/lipskey_verified_connections.dart:41
//        כדי לקיים חוק-1 (אטום עצמאי, אפס import של אטום-אחר).
// פרטי-במקור: `only` הייתה סגור (closure) מקומי בתוך crossesSystem — הוצאה
//        לחוזה כ-top-level ציבורי.
//
// קלט:  s — קבוצת-מערכות; w — מערכת בודקת.
// פלט:  true אם הקבוצה מכילה בדיוק איבר-אחד והוא w.

/// enum verbatim מהמקור (lipskey_verified_connections.dart:41).
enum WaterSystem { supply, drainage }

/// True אם [s] היא בת-איבר-יחיד המכילה בדיוק את [w].
bool only(Set<WaterSystem> s, WaterSystem w) =>
    s.length == 1 && s.contains(w);
