// ⚛️ אטום-Dart (דרגת-חוזה) · fuzzyNameMatch
// מוצא: buildsmart/app_flutter/lib/logic/fuzzy_match.dart:68-77 (‏fuzzyNameMatch; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import. הקריאה-לשכן `fuzzyMatch` (שהוא אטום-אחר!)
//        הופכה לשקע-פרמטר (חוק-3 + חוק-1: חוט לא מייבא חוט — גם לא את fuzzy_match.dart).
//        `RegExp(r'\s+')`, `String.split` — שפה/סטנדרט.
//
// קלט:  query, candidate — מחרוזות.
//       fuzzyMatch       — שקע: (q,c) ⇒ bool (במקור אטום-fuzzyMatch השכן).
// פלט:  bool — התאמת המחרוזת-השלמה, או של כל **מילה** בתוכה (פיצול על רווחים).

/// Word-aware fuzzy name match: whole-string match OR any whitespace-split word
/// matches. Verbatim behaviour of fuzzy_match.dart:68-77 with `fuzzyMatch` injected.
bool fuzzyNameMatch(
  String query,
  String candidate, {
  required bool Function(String query, String candidate) fuzzyMatch,
}) {
  if (fuzzyMatch(query, candidate)) return true;
  for (final word in candidate.split(RegExp(r'\s+'))) {
    if (word.isNotEmpty && fuzzyMatch(query, word)) return true;
  }
  return false;
}
