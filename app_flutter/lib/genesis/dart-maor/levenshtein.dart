// חוט · levenshtein — מרחק-עריכה בין שתי מחרוזות. חוזה: levenshtein.contract.md
// המרה מ-JS (new/atoms/levenshtein.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// אפס-import (dart-core בלבד). String.length ו-[] ב-Dart = יחידות-UTF16 כמו ב-JS ⇒ תואם.
int levenshtein(String a, String b) {
  final la = a.length;
  final lb = b.length;
  if (la == 0) return lb;
  if (lb == 0) return la;
  final dp = List<int>.filled(lb + 1, 0);
  for (var j = 0; j <= lb; j++) dp[j] = j;
  for (var i = 1; i <= la; i++) {
    var prev = dp[0];
    dp[0] = i;
    for (var j = 1; j <= lb; j++) {
      final tmp = dp[j];
      final sub = prev + (a[i - 1] == b[j - 1] ? 0 : 1);
      var m = dp[j] + 1;
      if (dp[j - 1] + 1 < m) m = dp[j - 1] + 1;
      if (sub < m) m = sub;
      dp[j] = m;
      prev = tmp;
    }
  }
  return dp[lb];
}
