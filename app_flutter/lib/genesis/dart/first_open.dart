// ⚛️ אטום-Dart (דרגת-חוזה) · firstOpen
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:314-322 (‏_firstOpen; חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). אין שכנים, אין const-אחות.
//        רק שוני-שם: `_firstOpen` (פרטי במקור) ⇒ `firstOpen` (top-level ציבורי, אותו גוף verbatim).
//
// קלט:  s — מחרוזת (מקור: תשובת-מודל שאולי עטופה בטקסט; edit_intent.dart).
// פלט:  int — האינדקס של הפותח הראשון מבין '{' ו-'[' ב-s; -1 אם אף אחד לא קיים.

/// Index of the earliest opening `{` or `[` in [s], or -1 (nothing opens).
/// Verbatim behaviour of edit_intent.dart:314-322.
int firstOpen(String s) {
  final brace = s.indexOf('{');
  final bracket = s.indexOf('[');
  if (brace < 0) return bracket;
  if (bracket < 0) return brace;
  return brace < bracket ? brace : bracket;
}
