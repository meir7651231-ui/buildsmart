// ⚛️ אטום-Dart (דרגת-חוזה) · headers
// מוצא: buildsmart/app_flutter/lib/data/edge/firestore_rest.dart:107-112 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// מהות: בניית כותרות-בקשה עם אסימון-הרשאה אם קיים.

Map<String, String> headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
