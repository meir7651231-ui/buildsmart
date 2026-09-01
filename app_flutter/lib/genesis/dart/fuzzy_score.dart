// ⚛️ אטום-Dart (דרגת-חוזה) · fuzzyScore
// תפקיד: ניקוד-קרבה fuzzy בין שאילתה למועמד — 0=הכלה מדויקת, מרחק>0=דמיון בטווח-סובלנות, ‏-1=לא-דומה.
// מוצא: buildsmart/app_flutter/lib/logic/fuzzy_match.dart:78-88 (‏fuzzyScore; חוק-4 — התנהגות verbatim, לא-משופרת).
// טוהר: פונקציית top-level, אפס import (dart:core בלבד). שלוש קריאות-שכן (חוק-3/דיבר-3) הופכו לשקעי-פרמטר:
//        normSearch (נרמול-חיפוש), damerauLevenshtein (מרחק-עריכה), fuzzyTolerance (סף-סובלנות לפי-אורך).
//        `String.contains` = שפה/סטנדרט (לא-שקע). האח `_min3` (fuzzy_match.dart) משרת את damerauLevenshtein
//        בלבד — לא נקרא ע"י fuzzyScore ⇒ לא-הוטבע (סוקק החוצה עם ה-damerauLevenshtein).
//
// קלט:  query, candidate — מחרוזות-קלט.
//        normSearch      — שקע: נרמול-מחרוזת לפני-השוואה (String→String).
//        damerauLevenshtein — שקע: מרחק-עריכה (String,String→int).
//        fuzzyTolerance  — שקע: סף-סובלנות מרבי לפי אורך-השאילתה (int→int).
// פלט:  int — ‏-1 אם אחד ריק-לאחר-נרמול · 0 אם המנורמל-מועמד מכיל את המנורמל-שאילתה ·
//        המרחק אם ≤ הסובלנות · אחרת ‏-1.

/// Fuzzy proximity score. Verbatim behaviour of fuzzy_match.dart:78-88 with the
/// three neighbour calls injected as sockets (law-3).
int fuzzyScore(
  String query,
  String candidate, {
  required String Function(String) normSearch,
  required int Function(String, String) damerauLevenshtein,
  required int Function(int) fuzzyTolerance,
}) {
  final q = normSearch(query);
  final c = normSearch(candidate);
  if (q.isEmpty || c.isEmpty) return -1;
  if (c.contains(q)) return 0;
  final d = damerauLevenshtein(q, c);
  return d <= fuzzyTolerance(q.length) ? d : -1;
}
