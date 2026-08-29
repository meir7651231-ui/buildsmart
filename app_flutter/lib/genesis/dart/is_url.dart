// ⚛️ אטום-Dart (דרגת-חוזה) · isUrl
// מוצא: buildsmart/app_flutter/lib/data/lipskey_catalog.dart:64-65
//        (static _isUrl של LipskeyCatalogProduct; חוק-4 — התנהגות זהה).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
// פרטי-במקור: מתודה סטטית פרטית `_isUrl` → הוצאה-לחוזה כ-top-level ציבורי `isUrl`.
//
// קלט:  s — מחרוזת. פלט: true אם מתחילה ב-http:// או https://.

/// A company's images come as links (owner 2026-07-26) — URLs pass as-is.
bool isUrl(String s) => s.startsWith('http://') || s.startsWith('https://');
