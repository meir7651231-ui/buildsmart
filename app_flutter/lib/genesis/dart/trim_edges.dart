// ⚛️ אטום-Dart · trimEdges
// מוצא: buildsmart/app_flutter/lib/features/global_search/narrowers.dart:36-46 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core). הפרטי `_trimEdges`→ציבורי.
//   מפל: הקבוע `edge` (:34) הוטבע verbatim.

/// Punctuation stripped from a token's ENDS only (internal kept, so "ש״ת" and
/// "ח.פ" survive): period · asterisk · hash · quote · apostrophe · geresh ·
/// gershayim. Kills junk chips like "מס." · "*עם" · a dangling inch-mark.

/// גוזם רק פיסוק-קצה משני-הצדדים של [t]; פיסוק-פנימי נשמר. ללא-שינוי ⇒ אותו-מופע.
String trimEdges(String t, {required String edge}) {
  var start = 0;
  var end = t.length;
  while (start < end && edge.contains(t[start])) start++;
  while (end > start && edge.contains(t[end - 1])) end--;
  return start == 0 && end == t.length ? t : t.substring(start, end);
}
