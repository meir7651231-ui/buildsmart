// ⚛️ אטום-Dart (דרגת-חוזה) · warehouseOverview — סקירת-מחסן: הקצאה-נגזרת פר-פריט מול הפרויקטים.
// מוצא: maor/src/lib/warehouse.ts:31-67 · המקור: new/atoms/warehouse-overview.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). השכן norm הוזרק כשקע (חוק-1/חוק-3).
//
// תפקיד: לכל פריט-מחסן — כמה הוקצה בפרויקטים (סכום sp.ayin.mat[].qty לפי התאמת-שם
//        מנורמלת) וכמה נותר. צבירה פר-פרויקט-ושם; שם-ריק מדולג; סכום-פרויקט ≤0 מדולג.
//
// הערות-המרה (הנקודות שהמנוע פספס בטיוטה):
//  • `sp.ayin?.mat` — שרשור-אופציונלי: גישת-Map דו-שלבית עם בדיקת-null (הטיוטה קרסה על sp.ayin).
//  • `!mat || !mat.length` — truthiness של JS ⇒ _falsy (חוק-7): null/רשימה-ריקה מדולגים.
//  • `+m.qty || 0` — ToNumber של ES ואז נפילת-falsy (NaN/0/-0 ⇒ 0) ⇒ _plusOr0 (חוקים 10/17/18:
//    דקדוק-ES לפני tryParse; אריתמטיקה תמיד float64 ⇒ double).
//  • `perName.get/set` של JS-Map ⇒ אינדוקס-Map של Dart; סדר-איטרציה = סדר-הכנסה
//    (LinkedHashMap ≡ JS Map) — נשמר גם ב-used וגם ב-perName.
//  • `for (const [k, qty] of perName)` — פירוק-זוגות ⇒ entries (הטיוטה פלטה `undefined`).
//  • `[...rows].sort((a,b)=>b.qty-a.qty)` — sort של JS יציב (ES2019); של Dart לא-מובטח ⇒
//    decorate-sort-undecorate עם אינדקס שובר-שוויון (חוק-1 של התקציר).
//  • `warehouse.map(...)` ⇒ List חדשה; item מוחזר by-reference כמו במקור.

/// חיקוי falsy של JS לתחום-האטום: null/false/0/-0/NaN/'' כוזבים; כל השאר אמת.
bool _falsy(dynamic v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || (v is double && v.isNaN);
  if (v is String) return v.isEmpty;
  return false;
}

/// חיקוי `+v || 0` של JS: ToNumber (מספר/בוליאני/מחרוזת-בדקדוק-ES/Infinity/hex; אחרת NaN),
/// ואז נפילת-falsy — NaN/0/-0 ⇒ 0. תמיד double (חוק-17: אריתמטיקת-JS = float64).
double _plusOr0(dynamic v) {
  double n;
  if (v is num) {
    n = v.toDouble();
  } else if (v is bool) {
    n = v ? 1.0 : 0.0;
  } else if (v is String) {
    final t = v.trim();
    if (t.isEmpty) {
      n = 0.0;
    } else if (RegExp(r'^[+-]?Infinity$').hasMatch(t)) {
      n = t.startsWith('-') ? double.negativeInfinity : double.infinity;
    } else if (RegExp(r'^[+-]?(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?$').hasMatch(t)) {
      // חוק-18: דקדוק-מספר-ES מאומת לפני parse; מיישרים ל-parse של Dart ('3.'⇒'3.0', '.5'⇒'0.5').
      var s = t.replaceFirst(RegExp(r'^\+'), '');
      s = s.replaceFirstMapped(RegExp(r'\.($|[eE])'), (m) => '.0${m[1]}');
      s = s.replaceFirstMapped(RegExp(r'^(-?)\.'), (m) => '${m[1]}0.');
      n = double.parse(s);
    } else if (RegExp(r'^0[xX][0-9a-fA-F]+$').hasMatch(t)) {
      n = int.parse(t.substring(2), radix: 16).toDouble();
    } else {
      n = double.nan;
    }
  } else {
    // null/undefined ⇒ 0/NaN בהתאמה — שניהם נופלים ל-0 ב-`|| 0`; אובייקט/מערך ⇒ NaN (בתחום-האטום).
    n = double.nan;
  }
  return (n.isNaN || n == 0) ? 0.0 : n;
}

/// Warehouse overview: for each warehouse item, derived allocation across projects
/// (sum of sp.ayin.mat[].qty by normalized-name match) and the remainder.
/// Verbatim port of new/atoms/warehouse-overview.mjs (`warehouseOverview`);
/// the same-file helper `norm` is injected as a socket (Law 1/3).
List<Map<String, dynamic>> warehouseOverview(
  List<dynamic> warehouse,
  List<dynamic> supporters,
  String Function(dynamic) norm,
) {
  // איסוף צריכה פר-שם-מנורמל: name → [{id, name, qty}] — סדר-הכנסה כמו JS Map.
  final used = <String, List<Map<String, dynamic>>>{};
  for (final sp in supporters) {
    final ayin = (sp as Map)['ayin'];
    final mat = ayin == null ? null : (ayin as Map)['mat'];
    if (_falsy(mat) || _falsy((mat as List).length)) continue;
    // צבירה פר-פרויקט-ושם (כמה מאותו-חומר בפרויקט אחד).
    final perName = <String, double>{};
    for (final m in mat) {
      final k = norm((m as Map)['name']);
      if (_falsy(k)) continue;
      perName[k] = (perName[k] ?? 0.0) + _plusOr0(m['qty']);
    }
    for (final e in perName.entries) {
      final qty = e.value;
      if (qty <= 0) continue;
      used[e.key] = [
        ...(used[e.key] ?? const []),
        {'id': sp['id'], 'name': sp['name'], 'qty': qty},
      ];
    }
  }
  return warehouse.map((item) {
    final rows = used[norm((item as Map)['name'])] ?? const <Map<String, dynamic>>[];
    final allocated =
        rows.fold<double>(0.0, (a, r) => a + (r['qty'] as num).toDouble());
    final remaining = _plusOr0(item['qty']) - allocated;
    // sort יציב כמו JS: decorate-sort-undecorate (אינדקס שובר-שוויון), יורד לפי qty.
    final decorated = <List<dynamic>>[
      for (var i = 0; i < rows.length; i++) [i, rows[i]],
    ];
    decorated.sort((a, b) {
      final d = ((b[1] as Map)['qty'] as num).toDouble() -
          ((a[1] as Map)['qty'] as num).toDouble();
      if (d > 0) return 1;
      if (d < 0) return -1;
      return (a[0] as int) - (b[0] as int);
    });
    return <String, dynamic>{
      'item': item,
      'allocated': allocated,
      'remaining': remaining,
      'short': remaining < 0,
      'byProject': [for (final e in decorated) e[1]],
    };
  }).toList();
}
