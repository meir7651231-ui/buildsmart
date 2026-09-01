// ⚛️ אטום-Dart (דרגת-חוזה) · validEmail
// מוצא: buildsmart/app_flutter/lib/logic/input_validators.dart:16-20 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: String.trim · RegExp.hasMatch).
//        השקע-המועמד מהטיוטה (hasMatch) הוא מתודת-סטנדרט על RegExp — לא קריאת-שכן,
//        ולכן אינו הופך לפרמטר-שקע (חוק-1/3: מותר שפה/סטנדרט בלבד).
//
// קלט:  input — מחרוזת חופשית (כתובת-מייל כפי שהוקלדה).
// פלט:  bool — true רק אם אחרי trim הצורה היא x@y.z: בדיוק @ אחד, בלי רווחים,
//        ונקודה בתוך הדומיין (חלק-מקומי · דומיין · סיומת — כל אחד ≥1 תו לא-רווח/לא-@).

/// Basic email shape — `x@y.z`: one `@`, no whitespace, a dot in the domain.
bool validEmail(String input) {
  final s = input.trim();
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
}
