// ⚛️ אטום-Dart (דרגת-חוזה) · boxesOverview — מבט "כל הקופות" עם חיפוש/סינון/מיון.
// מוצא: maor/src/components/tzedaka/lib.ts:203-232 · המקור: new/atoms/boxes-overview.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). שלושת השכנים הוזרקו כשקעים (חוק-1/חוק-3):
//        lastCollectionIso · boxTotal · smartFilter.
//
// תפקיד: מרנדר שורת-תצוגה פר-קופה (עם שם-רכז ושם-משפחה מפוענחים, איסוף-אחרון וסכום),
//        מסנן לפי סטטוס, מחפש-חכם על מונחים נגזרים, וממיין לפי הבורר sort.
// קלט:  db (מפה: tzBoxes · tzCoordinators · families) · q (מחרוזת-חיפוש) · status
//        (מחרוזת-סטטוס; ריק ⇒ בלי סינון) · sort ('num'|'lastCollection'|'total') ·
//        שלושת השקעים. פלט: List<Map> שורות-תצוגה ({box, coordName, famName, last, total}).
//
// הערות-המרה (מקור→Dart · תיקוני-מנוע):
//  • המנוע פלט `.firstWhere(...).name ?? ''` — שגוי: (א) firstWhere בלי orElse זורק
//    כשאין התאמה, בעוד המקור `find(...)?.name ?? ''` נופל ל-''; (ב) גישת-`.name` על Map.
//    תוקן ל-lookup ידני שמחזיר null-בהיעדר ⇒ `?['name'] ?? ''` (זהה ל-optional-chaining).
//  • truthiness: `if (status)` (מחרוזת-JS ריקה=falsy) → `if (status.isNotEmpty)`.
//  • `filter` → `where(...).toList()`; `smartFilter(...)` שקע-פונקציה (לא import, חוק-3).
//  • `'#' + r.box.num` — קונקטנציית-מחרוזת; num הוא מחרוזת במקור ⇒ `.toString()` בטוח.
//    `...coordName.split(/\s+/)` → `...coordName.split(RegExp(r'\s+'))` (פיצול זהה).
//  • המנוע פלט `cmp[sort]` כאינדוקס-מפה + `.localeCompare` + `?? 0 ?? 0` כפול. תוקן:
//    comparator-פר-בורר; localeCompare→compareTo (מחרוזות-ISO/ריק: סדר-code-unit זהה,
//    ריק-ראשון ⇒ "מעולם-לא ראשון"); total יורד דרך compareTo(b,a); parseInt||0 →
//    `int.tryParse(...) ?? 0` (יחיד).
//  • יציבות: `Array.prototype.sort` יציב (ES2019+); List.sort בדארט אינו-יציב ⇒ מיון
//    מקושט עם שובר-שוויון על אינדקס-מקורי כדי לשמר סדר-כניסה בתיקו (זהה-התנהגות למקור).
//  • מוטביליות: `rows` הוא var (מוקצה-מחדש ×3 כמו let במקור); השאר final.

/// "All boxes" view with search / status-filter / sort — verbatim port of
/// new/atoms/boxes-overview.mjs (`boxesOverview`). The three neighbours are
/// injected as sockets (Law 1/3): lastCollectionIso · boxTotal · smartFilter.
List<Map<String, dynamic>> boxesOverview(
  Map<String, dynamic> db,
  String q,
  String status,
  String sort,
  String Function(Map<String, dynamic> box) lastCollectionIso,
  num Function(Map<String, dynamic> box) boxTotal,
  List<Map<String, dynamic>> Function(
    String q,
    List<Map<String, dynamic>> items,
    List<dynamic> Function(Map<String, dynamic>) getTerms,
  ) smartFilter,
) {
  // find(c => c.id === box.coordinatorId)?.name ?? ''  — lookup נופל-ל-null.
  String nameById(List<dynamic> list, dynamic id) {
    for (final e in list) {
      if ((e as Map)['id'] == id) return (e['name'] ?? '') as String;
    }
    return '';
  }

  var rows = (db['tzBoxes'] as List)
      .map<Map<String, dynamic>>((box) {
        final b = box as Map<String, dynamic>;
        return <String, dynamic>{
          'box': b,
          'coordName': nameById(db['tzCoordinators'] as List, b['coordinatorId']),
          'famName': nameById(db['families'] as List, b['famId']),
          'last': lastCollectionIso(b),
          'total': boxTotal(b),
        };
      })
      .toList();

  if (status.isNotEmpty) {
    rows = rows.where((r) => (r['box'] as Map)['status'] == status).toList();
  }

  rows = smartFilter(q, rows, (r) {
    final box = r['box'] as Map<String, dynamic>;
    final coordName = r['coordName'] as String;
    return <dynamic>[
      '#' + box['num'].toString(),
      box['num'],
      coordName,
      ...coordName.split(RegExp(r'\s+')),
      r['famName'],
    ];
  });

  final cmp = <String, int Function(Map<String, dynamic>, Map<String, dynamic>)>{
    'num': (a, b) =>
        (int.tryParse((a['box'] as Map)['num'].toString()) ?? 0) -
        (int.tryParse((b['box'] as Map)['num'].toString()) ?? 0),
    // ישן/מעולם-לא ראשון — לרדיפה (מחרוזת ריקה ממוינת קודם).
    'lastCollection': (a, b) => (a['last'] as String).compareTo(b['last'] as String),
    'total': (a, b) => (b['total'] as num).compareTo(a['total'] as num),
  };

  final comparator = cmp[sort]!;
  // מיון-יציב: שובר-שוויון על אינדקס-כניסה, כמו sort יציב ב-JS.
  final indexed = <MapEntry<int, Map<String, dynamic>>>[];
  for (var i = 0; i < rows.length; i++) {
    indexed.add(MapEntry(i, rows[i]));
  }
  indexed.sort((x, y) {
    final c = comparator(x.value, y.value);
    return c != 0 ? c : x.key.compareTo(y.key);
  });
  return indexed.map((e) => e.value).toList();
}
