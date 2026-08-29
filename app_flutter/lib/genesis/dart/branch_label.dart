// ⚛️ אטום-Dart (דרגת-חוזה) · branchLabel
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:935-936 (‏_branchLabel; חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). ה-const-האחות
//        `_branchLetters` (install_engine.dart:934 — נקראת אך-ורק ע"י _branchLabel, :936)
//        הופכה לשקע-פרמטר `letters` (חוק-3/דיבר-3: קריאה-לשכן ⇒ פרמטר-שקע).
//
// קלט:  i        — אינדקס-ענף (int, 0-מבוסס; במקור מוזרק כ-`routed++`, install_engine.dart:1561).
//       letters  — שקע: אותיות-האזור בסדר. ערכי-המקור (:934):
//                  ['א','ב','ג','ד','ה','ו','ז','ח','ט','י'].
// פלט:  תווית-אזור עברית: 'ענף '+ (letters[i] אם i<אורך; אחרת (i+1) כמחרוזת).

/// Hebrew branch-zone label. `i < letters.length` ? `letters[i]` : one-based number.
/// Verbatim behaviour of install_engine.dart:935-936 with the sibling const injected.
String branchLabel(int i, {required String Function(String) term, required List<String> letters}) =>
    '${term('anf')}${i < letters.length ? letters[i] : (i + 1).toString()}';
