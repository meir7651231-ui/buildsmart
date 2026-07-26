// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · GIANT Phase-2 · פרימיטיב חיפוש-סובל-שגיאות — PURE Dart, אפס Flutter.
//
// port של Maor `search.ts` (searchFuzzy) — מרחק-עריכה Damerau (הוספה/מחיקה/
// החלפה/**חילוף-שכנים**) + סף-סובלנות `floor(len/3)+1`, מעל נרמול-החיפוש-העברי
// המשותף (text_normalize.normSearch). זה מה שהיה **חסר** באפליקציה: היום החיפוש
// הוא contains-בלבד (data/fuzzy_search.dart — לא-נגוע, נעול ב-6 סוויטות).
//
// פרימיטיב טהור: הצרכן החי (חיפוש-לקוחות מגודר `search.fuzzy`) בפרוסה נפרדת.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/logic/text_normalize.dart' show normSearch;

/// מרחק-עריכה Damerau-Levenshtein בין שתי מחרוזות (הוספה·מחיקה·החלפה·חילוף-
/// שכנים סמוכים, כל אחד עלות 1). O(n·m) זמן, O(m) מקום. סימטרי.
int damerauLevenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  final n = a.length;
  final m = b.length;
  var prev2 = List<int>.filled(m + 1, 0); // שורה i-2 (לחילוף)
  var prev = List<int>.generate(m + 1, (j) => j); // שורה i-1
  var cur = List<int>.filled(m + 1, 0);
  for (var i = 1; i <= n; i++) {
    cur[0] = i;
    for (var j = 1; j <= m; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      var v = _min3(
        cur[j - 1] + 1, // הוספה
        prev[j] + 1, // מחיקה
        prev[j - 1] + cost, // החלפה
      );
      // חילוף שני תווים שכנים (transposition).
      if (i > 1 &&
          j > 1 &&
          a.codeUnitAt(i - 1) == b.codeUnitAt(j - 2) &&
          a.codeUnitAt(i - 2) == b.codeUnitAt(j - 1)) {
        final t = prev2[j - 2] + 1;
        if (t < v) v = t;
      }
      cur[j] = v;
    }
    final tmp = prev2;
    prev2 = prev;
    prev = cur;
    cur = tmp;
  }
  return prev[m];
}

/// סף-הסובלנות של Maor: `floor(len/3) + 1` — מרחק-העריכה המרבי שעדיין נחשב
/// התאמה, פר-אורך-המחרוזת-המנורמלת של השאילתה.
int fuzzyTolerance(int len) => (len ~/ 3) + 1;

/// האם [candidate] תואם-בקירוב את [query]? נרמול-עברי משותף על שניהם, ואז:
/// התאמת-מצע (contains) = תמיד תואם (מרחק 0); אחרת מרחק-עריכה ≤ סף. ריק=לא-תואם.
bool fuzzyMatch(String query, String candidate) {
  final q = normSearch(query);
  final c = normSearch(candidate);
  if (q.isEmpty || c.isEmpty) return false;
  if (c.contains(q)) return true;
  return damerauLevenshtein(q, c) <= fuzzyTolerance(q.length);
}

/// ציון-קרבה (נמוך=טוב): 0 להתאמת-מצע, אחרת מרחק-העריכה. -1 = לא-תואם (מעל הסף)
/// — לסינון ומיון בשכבת-החיפוש.
int fuzzyScore(String query, String candidate) {
  final q = normSearch(query);
  final c = normSearch(candidate);
  if (q.isEmpty || c.isEmpty) return -1;
  if (c.contains(q)) return 0;
  final d = damerauLevenshtein(q, c);
  return d <= fuzzyTolerance(q.length) ? d : -1;
}

int _min3(int a, int b, int c) => a < b ? (a < c ? a : c) : (b < c ? b : c);
