// ⚛️ אטום-Dart (דרגת-חוזה) · angleDigits
// מוצא: buildsmart/app_flutter/lib/features/catalog_config/product_chips.dart:256-263
//        (הפונקציה הפרטית `_angleDigits` — חוק-4, התנהגות זהה).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core · RegExp).
//
// פרטי-במקור: `_angleDigits` היה פרטי — הוצא לחוזה כ-top-level ציבורי `angleDigits`.
//
// קלט:  s — תווית/טוקן של זווית (למשל `15°`).
// פלט:  מספר-המעלות החשוף (`15`); אם אין ספרות — המחרוזת כמות-שהיא.

/// המספר החשוף של תווית-זווית (`15°` → `15`); בהיעדר ספרה — [s] כמות-שהיא.
String angleDigits(String s) => RegExp(r'\d+').firstMatch(s)?.group(0) ?? s;
