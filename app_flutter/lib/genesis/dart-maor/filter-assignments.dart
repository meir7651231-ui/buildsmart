// ⚛️ אטום-Dart (דרגת-חוזה) · filterAssignments — סינון+מיון שיוכי-החנות.
// מוצא: maor/src/components/shop/lib.ts:504-537 · המקור: new/atoms/filter-assignments.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). חמש קריאות-השכן הוזרקו כשקעים (חוק-1/3):
//        upcomingHolidays · SHOP_HOLIDAY_DUE_DAYS · pendingCount · smartFilter · progressOf.
//
// תפקיד: [...db.shopAssignments] ⇒ סינון status (ריק=הכול) ⇒ סינון productId (ריק=הכול) ⇒
//        pendingOnly (רק שיוך עם רכיב-ממתין) ⇒ חיפוש q דרך smartFilter (מונחים: שם-המשפחה ·
//        כל מילה משם-המשפחה בנפרד · שם-החבילה) ⇒ מיון sort:
//        'pending' — יש-רכיב-ממתין קודם ובתוכם since עולה (ריק⇒'9999'); ממומש-כולו אחרון.
//        'name'    — שם-המשפחה, localeCompare עברית עולה.
//        'progress'— התקדמות-המימוש עולה.
//        todayIso? ⇒ holidays=upcomingHolidays(todayIso, SHOP_HOLIDAY_DUE_DAYS) מושחל כלשונו
//        לכל קריאת pendingCount; חסר ⇒ null (ההתנהגות ההיסטורית undefined).
//
// הערות-המרה (מקור→Dart — DART-PORTING-RULES):
//  • מיון-יציב (כלל-1): JS `list.sort` יציב; Dart לא-יציב ל-≥32. ⇒ decorate-sort-undecorate
//    עם האינדקס-המקורי כשובר-שוויון — מחקה בדיוק את יציבות-ה-JS (חשוב לקבוצות-since שוות).
//  • null מול undefined (כלל-2): JS `todayIso ?` נופל ל-undefined; Dart אין undefined ⇒ null.
//    holidays מושחל null/HOLS by-reference — הבדיקה מאמתת identical/null.
//  • truthiness (כלל-7): `if (status)`/`if (productId)`/`todayIso ?` הם בדיקת-אמת-מחרוזת של JS
//    (מחרוזת-ריקה=false) ⇒ `.isNotEmpty`. `a.since || '9999'` (ריק/null⇒default) ⇒ `_or`.
//  • locale (כלל-6): `localeCompare` על מחרוזות-ISO ועל שם עברי ⇒ `compareTo` (סדר-code-unit;
//    לאותיות-עברית-בסיס זהה לסדר-א"ב, ולתאריכי-ISO/ריק זהה — תקדים boxes-overview).
//  • comparator מחזיר int: `progressOf(a) - progressOf(b)` של JS (double, נקרא לפי סימן) ⇒
//    `.compareTo` (‏-1/0/1, אותו סימן). `pa - pb` נשאר חיסור-int.
//  • מוטביליות: `list` עותק-מקומי דרך List.from; שאר-המקומיים final.

/// `a.since || '9999'` של JS: null או מחרוזת-ריקה ⇒ ברירת-המחדל; אחרת הערך.
String _or(dynamic v, String d) =>
    (v == null || (v is String && v.isEmpty)) ? d : v.toString();

/// find על מערך-Maps לפי מפתח/ערך (מחקה `xs.find(x => x[key] === val)` ⇒ null אם אין).
Map<String, dynamic>? _find(List<dynamic> xs, String key, dynamic val) {
  for (final x in xs) {
    final m = x as Map<String, dynamic>;
    if (m[key] == val) return m;
  }
  return null;
}

/// Filter + sort shop assignments — verbatim port of new/atoms/filter-assignments.mjs
/// (`filterAssignments`). The five neighbour calls are injected as sockets (Law 1/3).
List<dynamic> filterAssignments(
  Map<String, dynamic> db,
  String q,
  String status,
  bool pendingOnly,
  String productId,
  String sort,
  String? todayIso,
  List<dynamic> Function(String, int) upcomingHolidays,
  int shopHolidayDueDays,
  num Function(dynamic, dynamic, dynamic) pendingCount,
  List<dynamic> Function(String, List<dynamic>, List<dynamic> Function(dynamic))
      smartFilter,
  num Function(dynamic, dynamic, dynamic) progressOf,
) {
  final dynamic holidays = (todayIso != null && todayIso.isNotEmpty)
      ? upcomingHolidays(todayIso, shopHolidayDueDays)
      : null;

  final families = db['families'] as List<dynamic>;
  final shopProducts = db['shopProducts'] as List<dynamic>;

  var list = List<dynamic>.from(db['shopAssignments'] as List<dynamic>);

  if (status.isNotEmpty) {
    list = list.where((a) => (a as Map)['status'] == status).toList();
  }
  if (productId.isNotEmpty) {
    list = list.where((a) => (a as Map)['productId'] == productId).toList();
  }
  if (pendingOnly) {
    list = list.where((a) => pendingCount(db, a, holidays) > 0).toList();
  }

  list = List<dynamic>.from(smartFilter(q, list, (a) {
    final fam = _find(families, 'id', (a as Map)['famId']);
    final product = _find(shopProducts, 'id', a['productId']);
    final terms = <dynamic>[];
    terms.add(fam == null ? '' : (fam['name'] ?? ''));
    if (fam != null && fam['name'] != null) {
      terms.addAll((fam['name'] as String).split(RegExp(r'\s+')));
    }
    terms.add(product == null ? '' : (product['name'] ?? ''));
    return terms;
  }));

  String famName(dynamic a) {
    final fam = _find(families, 'id', (a as Map)['famId']);
    return fam == null ? '' : ((fam['name'] as String?) ?? '');
  }

  final cmp = <String, int Function(dynamic, dynamic)>{
    'pending': (a, b) {
      final pa = pendingCount(db, a, holidays) > 0 ? 0 : 1;
      final pb = pendingCount(db, b, holidays) > 0 ? 0 : 1;
      if (pa != pb) return pa - pb; // ממתינים קודם; ממומש-כולו אחרון
      return _or((a as Map)['since'], '9999')
          .compareTo(_or((b as Map)['since'], '9999')); // הכי-ותיק-ממתין ראשון
    },
    'name': (a, b) => famName(a).compareTo(famName(b)),
    'progress': (a, b) =>
        progressOf(db, a, holidays).compareTo(progressOf(db, b, holidays)),
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
