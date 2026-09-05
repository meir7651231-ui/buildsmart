// ⚛️ אטום-Dart (דרגת-חוזה) · normName
// מוצא: buildsmart/app_flutter/lib/logic/text_normalize.dart:36-37 (חצב-בינה · חוק-3/4).
// שקע: normSearch ← השכן `normSearch(t)` — נרמול-חיפוש עברי (lowercase · ניקוד · trim).
// normName = normSearch + הסרת כל רווח (מפתח-dedup הדוק). 'בן דוד' ≡ 'בןדוד'.

String normName(String s, {required String Function(String) normSearch}) =>
    normSearch(s).replaceAll(RegExp(r'\s'), '');
