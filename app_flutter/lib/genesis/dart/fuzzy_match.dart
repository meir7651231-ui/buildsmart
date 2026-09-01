// ⚛️ אטום-Dart (דרגת-חוזה) · fuzzyMatch
// מוצא: buildsmart/app_flutter/lib/logic/fuzzy_match.dart:58-67 (‏fuzzyMatch; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import. שלוש קריאות-שכן הופכו לשקעים (חוק-3):
//        `normSearch` (נרמול), `damerauLevenshtein` (מרחק-עריכה), `fuzzyTolerance`
//        (סף לפי-אורך). `String.contains` — שפה/סטנדרט.
//
// קלט:  query, candidate    — מחרוזות.
//       normSearch          — שקע: String ⇒ String מנורמל.
//       damerauLevenshtein  — שקע: (a,b) ⇒ מרחק-עריכה int.
//       fuzzyTolerance      — שקע: אורך ⇒ סף-סבילות int.
// פלט:  bool — התאמה: מצע (contains) או מרחק ≤ סף.

/// Fuzzy string match: normalize both, empty→false, substring hit→true,
/// else edit-distance within the length-tolerance. Verbatim: fuzzy_match.dart:58-67.
bool fuzzyMatch(
  String query,
  String candidate, {
  required String Function(String) normSearch,
  required int Function(String, String) damerauLevenshtein,
  required int Function(int) fuzzyTolerance,
}) {
  final q = normSearch(query);
  final c = normSearch(candidate);
  if (q.isEmpty || c.isEmpty) return false;
  if (c.contains(q)) return true;
  return damerauLevenshtein(q, c) <= fuzzyTolerance(q.length);
}
