// ⚛️ אטום-Dart (דרגת-חוזה) · hasCoords
// מוצא: buildsmart/app_flutter/lib/services/nav_launch.dart:31-33 (_hasCoords; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core). בדיקת-null בלבד —
//        לא נוגעת ב-launcher/URL (אלה שכניה הלא-טהורים בקובץ-המקור).
// פרטי-במקור: `_hasCoords` → הוצא-לחוזה כ-top-level ציבורי `hasCoords`.
//
// קלט:  lat, lng. פלט: true כששניהם קיימים (נקודה-אמיתית לניווט).

/// True when both coordinates are present (a real point to navigate to).
bool hasCoords(double? lat, double? lng) => lat != null && lng != null;
