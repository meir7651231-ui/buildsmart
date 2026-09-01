// ⚛️ אטום-Dart (דרגת-חוזה) · leaderboard — לוח-המובילים של רכזי-הקופות (גיימיפיקציה).
// מוצא: maor/src/components/tzedaka/lib.ts:142-148 · המקור: new/atoms/leaderboard.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). שני השכנים הוזרקו כשקעים (חוק-1/חוק-3):
//        coordinatorTotal · coordinatorBoxes.
//
// תפקיד: רכזים פעילים בלבד (c.active); שורה פר-רכז {coordinator, total(שקע),
//        boxCount(אורך תוצאת-השקע השני)}; מיון: score יורד, ותיקו-score מוכרע ב-total יורד.
// קלט:  coordinators (רשימת-מפות) · boxes (מוזרם לשקעים) · שני השקעים.
//        פלט: List<Map> שורות-לוח ({coordinator, total, boxCount}).
//
// הערות-המרה (מקור→Dart · כללי DART-PORTING):
//  • המנוע (dart-from-maor) לא הפיק טיוטה לחוט הזה — פורט מהמקור לפי הפטרן של boxes-overview.
//  • truthiness (כלל 7): `.filter(c => c.active)` — JS שומר truthy. שקע `_truthy` שמחקה
//    את falsy-של-JS (null/false/0/NaN/''); בחוזה active הוא bool, והשקע מטפל בו ישירות.
//  • המיון `b.score - a.score || b.total - a.total`: `||` של JS ⇒ אם הפרש-ה-score אפס
//    (falsy) נופלים להפרש-ה-total. ה-comparator מחזיר int-סימן בלבד (למיון חשוב הסימן,
//    לא הגודל) — score יורד, ואז total יורד.
//  • יציבות (כלל 1): `Array.prototype.sort` יציב (ES2019+); List.sort בדארט אינו-יציב ⇒
//    מיון מקושט עם שובר-שוויון על אינדקס-כניסה, לשימור סדר-כניסה בתיקו-מלא (זהה-התנהגות).
//  • `.length` על תוצאת-השקע השני ⇒ `.length` של List בדארט.
//  • מוטביליות: rows נבנה בלולאה (var-מקומי), ללא מוטציה של הקלט.

/// Coordinator leaderboard — active coordinators only, each row
/// {coordinator, total (via socket), boxCount (length of second socket's result)},
/// sorted by score descending, ties broken by total descending. Verbatim port of
/// new/atoms/leaderboard.mjs (`leaderboard`). Neighbours coordinatorTotal /
/// coordinatorBoxes are injected as sockets (Law 1/3).
List<Map<String, dynamic>> leaderboard(
  List<dynamic> coordinators,
  List<dynamic> boxes,
  num Function(List<dynamic> boxes, dynamic coordId) coordinatorTotal,
  List<dynamic> Function(List<dynamic> boxes, dynamic coordId) coordinatorBoxes,
) {
  // falsy-של-JS (כלל-המרה 7): null/false/0/NaN/'' ⇒ false; אחרת ⇒ true.
  bool truthy(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0 && !v.isNaN;
    if (v is String) return v.isNotEmpty;
    return true;
  }

  // filter(active) → map(row) — סדר-הקריאה לשקעים זהה למקור.
  final rows = <Map<String, dynamic>>[];
  for (final c in coordinators) {
    final cm = c as Map<String, dynamic>;
    if (!truthy(cm['active'])) continue;
    rows.add(<String, dynamic>{
      'coordinator': cm,
      'total': coordinatorTotal(boxes, cm['id']),
      'boxCount': coordinatorBoxes(boxes, cm['id']).length,
    });
  }

  // מיון-יציב: comparator = score יורד → total יורד → שובר-שוויון על אינדקס-כניסה.
  final indexed = <MapEntry<int, Map<String, dynamic>>>[];
  for (var i = 0; i < rows.length; i++) {
    indexed.add(MapEntry(i, rows[i]));
  }
  indexed.sort((x, y) {
    final a = x.value;
    final b = y.value;
    final num s = ((b['coordinator'] as Map)['score'] as num) -
        ((a['coordinator'] as Map)['score'] as num);
    if (s != 0) return s < 0 ? -1 : 1;
    final num t = (b['total'] as num) - (a['total'] as num);
    if (t != 0) return t < 0 ? -1 : 1;
    return x.key.compareTo(y.key);
  });
  return indexed.map((e) => e.value).toList();
}
