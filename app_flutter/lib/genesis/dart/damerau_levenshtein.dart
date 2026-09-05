// ⚛️ אטום-Dart (דרגת-חוזה) · damerauLevenshtein
// תפקיד: מרחק-עריכה Damerau-Levenshtein (הוספה/מחיקה/החלפה + חילוף-שכנים) בין שתי מחרוזות,
//        גרסת שלוש-שורות-מתגלגלות (זיכרון O(m)) על codeUnits.
// מוצא: buildsmart/app_flutter/lib/logic/fuzzy_match.dart:16-57 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
// אחים-שהוטבעו: `_min3` — עוזר-מינימום-של-שלושה שנקרא בטיוטה (:32) אך **גופו לא הופיע בטיוטה**.
//        הוסק verbatim מהשם+השימוש (מינימום שלושת-המועמדים ברקורסיית-DL) והוטבע inline.
//        אחים-שסוקטו: — (‏fuzzyTolerance/fuzzyMatch שבהמשך-הקובץ אינם חלק מהאטום).
//
// קלט:  a, b — שתי מחרוזות (מושוות פר-codeUnit, לא פר-גרפמה).
// פלט:  int ≥ 0 — מרחק-העריכה המינימלי.

/// עוזר-מינימום פרטי (מוסק — גוף `_min3` לא הופיע בטיוטה; הסמנטיקה קבועה ע"י
/// השם והשימוש כמינימום שלושת מועמדי-DL). מחזיר את הקטן משלושת הארגומנטים.
int _min3(int a, int b, int c) {
  final m = a < b ? a : b;
  return m < c ? m : c;
}

/// Damerau-Levenshtein edit distance (insert / delete / substitute + adjacent
/// transposition), three rolling rows. Verbatim behaviour of fuzzy_match.dart:16-57.
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
