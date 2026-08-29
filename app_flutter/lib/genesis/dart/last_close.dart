// ⚛️ אטום-Dart (דרגת-חוזה) · lastClose
// תפקיד: המיקום האחרון של סוגר-סוגריים סגירה — המקסימום מבין lastIndexOf('}') ל-lastIndexOf(']').
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:323-333 (‏_lastClose; חוק-4 — verbatim).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). `String.lastIndexOf` = שפה/סטנדרט.
//        פרטי-במקור (`_`) ⇒ פורסם public. האח שמתחת (בודק-קטיעה מודע-מחרוזות) לא נקרא ⇒ לא-הוטבע.
//
// קלט:  s — מחרוזת (בד"כ מקטע-JSON).
// פלט:  int — המיקום הגדול מבין '}' ל-']' (‏-1 אם שניהם נעדרים).

/// The last position of a closing `}` or `]` (whichever is later; -1 if neither).
/// Verbatim of edit_intent.dart:323-333.
int lastClose(String s) {
  final brace = s.lastIndexOf('}');
  final bracket = s.lastIndexOf(']');
  return brace > bracket ? brace : bracket;
}
