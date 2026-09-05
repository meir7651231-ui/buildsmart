// ⚛️ אטום-Dart (דרגת-חוזה) · filterItems — סינון פריטי-קטלוג לפי שם ומצב-מלאי.
// מוצא: maor/src/components/shop/lib.ts:551-564 · המקור: new/atoms/filter-items.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). שני השכנים הוזרקו כשקעים (חוק-1/3):
//        itemRemaining · smartFilter.
//
// תפקיד: [...db.shopItems] ⇒ אם stockState לא-ריק, סינון לפי יתרת-מלאי:
//        'untracked' — יתרה null (ללא-מעקב) · 'out' — יתרה 0 (אזל) ·
//        אחרת (low) — יש-מעקב ו-0 < יתרה ≤ 2. ⇒ חיפוש q דרך smartFilter,
//        עם getTerms(i) = [i.name, ...פיצול-מילים(i.name)].
//        stockState ריק ⇒ אף קריאה ל-itemRemaining (short-circuit, כמו המקור).
//
// הערות-המרה (מקור→Dart — DART-PORTING-RULES):
//  • truthiness (כלל-7): `if (stockState)` של JS הוא בדיקת-אמת-מחרוזת (ריק=false) ⇒
//    `.isNotEmpty`. שאר-הבדיקות `=== 'untracked'`/`=== 'out'` ⇒ `== '...'` (השוואת-ערך).
//  • null מול undefined (כלל-2): `itemRemaining` מחזיר number|null; ב-Dart `num?`.
//    `rem === null` ⇒ `rem == null` (מספר לעולם לא == null, אז שקול). `rem === 0` ⇒
//    `rem == 0` (null == 0 ⇒ false, כמו JS). ה-low מגן `rem != null` לפני `> 0 && <= 2`.
//  • getTerms: `i.name.split(/\s+/)` ⇒ `name.split(RegExp(r'\s+'))` (סמנטיקה זהה,
//    כולל איבר-ריק על רווח-מוביל). אין locale/getMonth/24:00/substring-שלילי כאן.
//  • מוטביליות: `list` עותק-מקומי משתנה (List.from + reassign ב-where); לא נוגע ב-db.

/// Filters the shop's standalone catalog items by name and stock state.
/// Verbatim behaviour of the JS source new/atoms/filter-items.mjs.
/// Sockets (חוק-1): [itemRemaining] (num?/null=untracked) · [smartFilter] (shared search).
List<dynamic> filterItems(
  Map<String, dynamic> db,
  String q,
  String stockState,
  num? Function(dynamic, dynamic) itemRemaining,
  List<dynamic> Function(String, List<dynamic>, List<dynamic> Function(dynamic))
      smartFilter,
) {
  var list = List<dynamic>.from(db['shopItems'] as List);
  if (stockState.isNotEmpty) {
    list = list.where((i) {
      final rem = itemRemaining(db, (i as Map)['id']);
      if (stockState == 'untracked') return rem == null;
      if (stockState == 'out') return rem == 0;
      return rem != null && rem > 0 && rem <= 2; // low
    }).toList();
  }
  return smartFilter(q, list, (i) {
    final name = (i as Map)['name'] as String;
    return <dynamic>[name, ...name.split(RegExp(r'\s+'))];
  });
}
