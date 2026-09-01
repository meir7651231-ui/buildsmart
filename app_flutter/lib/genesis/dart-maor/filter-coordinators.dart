// ⚛️ אטום-Dart (דרגת-חוזה) · filterCoordinators — סינון+מיון רכזי-הקופות.
// מוצא: maor/src/components/tzedaka/lib.ts:174-202 · המקור: new/atoms/filter-coordinators.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). שלוש קריאות-השכן הוזרקו כשקעים (חוק-1/3):
//        smartFilter · coordinatorTotal · coordinatorLastCollection.
//
// תפקיד: onlyActive ⇒ רק active (אחרת עותק [...coords]) ⇒ חיפוש q דרך smartFilter
//        (מונחים: השם המלא + כל מילה בנפרד ⇒ שגיאת-כתיב במילה נתפסת) ⇒ מיון sort:
//        'name'  — localeCompare עברית עולה.
//        'score' — ציון יורד (b.score - a.score).
//        'total' — סך-הריקונים יורד (שקע-coordinatorTotal).
//        'stale' — ריקון-אחרון עולה (localeCompare; '' = מעולם-לא ⇒ ראשון).
//        המיון על עותק — הקלט לא משתנה.
//
// הערות-המרה (מקור→Dart — DART-PORTING-RULES):
//  • מיון-יציב (כלל-1): JS `list.sort` יציב; Dart לא-יציב ל-≥32. ⇒ decorate-sort-undecorate
//    עם האינדקס-המקורי כשובר-שוויון — מחקה בדיוק את יציבות-ה-JS (ציונים/תאריכים שווים).
//  • locale (כלל-6): `localeCompare(_,'he')` על שם עברי-בסיס ועל תאריכי-ISO/'' ⇒ `compareTo`
//    (סדר-code-unit: לאותיות-עברית-בסיס זהה לסדר-א"ב, ולתאריכי-ISO/ריק זהה — תקדים filter-assignments).
//  • comparator מחזיר int (כלל: sort של JS נקרא לפי-סימן): `b.score - a.score` ⇒
//    `(bScore).compareTo(aScore)` (יורד, אותו סימן, ותקין ל-num); `total` באותו אופן על השקע.
//  • מוטביליות: `base`/`list` עותקים מקומיים; הקלט coords לא משתנה.

/// Filter + sort collection coordinators — verbatim port of
/// new/atoms/filter-coordinators.mjs (`filterCoordinators`).
/// The three neighbour calls are injected as sockets (Law 1/3).
List<dynamic> filterCoordinators(
  List<dynamic> coords,
  dynamic boxes,
  String q,
  bool onlyActive,
  String sort,
  List<dynamic> Function(String, List<dynamic>, List<dynamic> Function(dynamic))
      smartFilter,
  num Function(dynamic, dynamic) coordinatorTotal,
  String Function(dynamic, dynamic) coordinatorLastCollection,
) {
  final base = onlyActive
      ? coords.where((c) => (c as Map)['active'] == true).toList()
      : List<dynamic>.from(coords);

  // גם מילות השם בנפרד — כדי ששגיאת-כתיב במילה אחת תיתפס (levenshtein פר-מילה)
  final list = smartFilter(q, base, (c) {
    final name = (c as Map)['name'] as String;
    final terms = <dynamic>[name];
    terms.addAll(name.split(RegExp(r'\s+')));
    return terms;
  });

  String nameOf(dynamic c) => (c as Map)['name'] as String;
  num scoreOf(dynamic c) => (c as Map)['score'] as num;
  String idOf(dynamic c) => (c as Map)['id'] as String;

  final cmp = <String, int Function(dynamic, dynamic)>{
    'name': (a, b) => nameOf(a).compareTo(nameOf(b)),
    'score': (a, b) => scoreOf(b).compareTo(scoreOf(a)),
    'total': (a, b) => coordinatorTotal(boxes, idOf(b))
        .compareTo(coordinatorTotal(boxes, idOf(a))),
    'stale': (a, b) => coordinatorLastCollection(boxes, idOf(a))
        .compareTo(coordinatorLastCollection(boxes, idOf(b))),
  };

  final selected = cmp[sort]!;
  // decorate-sort-undecorate: אינדקס-מקורי כשובר-שוויון ⇒ יציבות זהה ל-JS (כלל-1).
  final indexed = <List<dynamic>>[];
  for (var i = 0; i < list.length; i++) {
    indexed.add([i, list[i]]);
  }
  indexed.sort((x, y) {
    final c = selected(x[1], y[1]);
    return c != 0 ? c : (x[0] as int).compareTo(y[0] as int);
  });
  return indexed.map((e) => e[1]).toList();
}
