// ⚛️ אטום-Dart (דרגת-חוזה) · mergeSupporterInto — מיזוג שני כרטיסי-תומך:
//   כל הכסף עובר ל"שומר" (keep), הצבירה מחושבת-מחדש. חוזה: merge-supporter-into.contract.md
// מוצא: maor/src/lib/dedup.ts:342-387 · המקור: new/atoms/merge-supporter-into.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). שני השכנים הוזרקו כשקעים (חוק-1/חוק-3):
//        mergeHist(existing, incoming)⇒מיזוג-היסטוריה אידמפוטנטי · photoMax⇒תקרת-תמונות
//        (במקור PHOTO_MAX=5 — ידע-הצבה, חוק-5: מוזרק בקופסה).
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נטה לפספס, מ-DART-PORTING-RULES.md):
//  • כלל-1 מיון-יציב: JS `Array.sort` יציב (ES2019); Dart `List.sort` לא-יציב ל-≥32 →
//    decorate-sort-undecorate עם אינדקס-מקורי כשובר-שוויון. `localeCompare` על מחרוזות-ISO
//    (ספרות+'-') ≡ `compareTo` code-unit.
//  • כלל-7 truthiness: כל `a || b` של JS = `_truthy(a) ? a : b` (null/''/false/0 = כבוי);
//    `keep.hist ?? []` הוא nullish (null בלבד) → `?? const []`. `hok: keep.hok ?? drop.hok`
//    הוא nullish (לא `||`) → `keep['hok'] ?? drop['hok']`.
//  • ספרד-אובייקט: מתחילים ב-`Map.of(keep)` (מקביל ל-`...keep`), ואז דורסים/מוסיפים מפתחות.
//    הספרד-המותנה `...(cond ? {k:v} : {})` = הוספה-בלבד כשהתנאי אמת (אף פעם לא הסרה) —
//    לכן מתחילים מהעתק-keep ורק מציבים. `new Set([...])` שומר סדר-הכנסה ⇒ Set-Dart (LinkedHashSet).
//  • `nextEventId: keep.nextEventId || undefined` — המפתח תמיד מוצב; falsy⇒undefined→null.
//  • `.slice(0, photoMax)` (סלחני, פחות-מ-photoMax ⇒ הכול) → `.take(photoMax)` (לא sublist שזורק).
//  • מוטביליות: keep/drop לא משתנים — הכול רשימות/מפות חדשות.

bool _truthy(dynamic v) => v != null && v != false && v != '' && v != 0;

/// JS `a || b` — returns [a] when truthy, else [b] (value as-is).
dynamic _or(dynamic a, dynamic b) => _truthy(a) ? a : b;

/// Unique preserving first-occurrence order (JS `[...new Set(list)]`).
List<dynamic> _uniq(List<dynamic> list) => list.toSet().toList();

/// Stable sort of donation maps by their 'date' string (JS `Array.sort` is stable).
List<dynamic> _sortByDate(List<dynamic> items) {
  final indexed = <List<dynamic>>[];
  for (var i = 0; i < items.length; i++) {
    indexed.add(<dynamic>[items[i], i]);
  }
  indexed.sort((x, y) {
    final c = ((x[0] as Map)['date'].toString())
        .compareTo((y[0] as Map)['date'].toString());
    if (c != 0) return c;
    return (x[1] as int).compareTo(y[1] as int);
  });
  return indexed.map((e) => e[0]).toList();
}

/// Merges supporter [drop] into [keep]: all money moves to [keep], totals are
/// recomputed. Verbatim behaviour of the JS source new/atoms/merge-supporter-into.mjs
/// (`mergeSupporterInto`). Neighbours [mergeHist] (idempotent history merge) and
/// [photoMax] (photo cap) are injected sockets (Law 1/3/5).
Map<String, dynamic> mergeSupporterInto(
  Map<String, dynamic> keep,
  Map<String, dynamic> drop,
  List<dynamic> Function(dynamic existing, dynamic incoming) mergeHist,
  int photoMax,
) {
  final donations = _sortByDate(<dynamic>[
    ...((keep['donations'] ?? const <dynamic>[]) as List),
    ...((drop['donations'] ?? const <dynamic>[]) as List),
  ]);

  final hist = mergeHist(
    keep['hist'] ?? const <dynamic>[],
    drop['hist'] ?? const <dynamic>[],
  );

  final photos = _uniq(<dynamic>[
    ...((keep['photos'] ?? const <dynamic>[]) as List),
    ...((drop['photos'] ?? const <dynamic>[]) as List),
  ]).take(photoMax).toList();

  final nextNote = _or(keep['nextNote'], drop['nextNote']);

  final ils = donations
      .where((d) => (d as Map)['cur'] != '\$')
      .fold<num>(0, (a, d) => a + ((d as Map)['amount'] as num));
  final usd = donations
      .where((d) => (d as Map)['cur'] == '\$')
      .fold<num>(0, (a, d) => a + ((d as Map)['amount'] as num));

  final notes = _uniq(<dynamic>[keep['notes'], drop['notes']]
          .map((n) => (_truthy(n) ? n : '').toString().trim())
          .where((s) => s.isNotEmpty)
          .toList())
      .join(' · ');

  final result = Map<String, dynamic>.of(keep);
  result['phone'] = _or(keep['phone'], drop['phone']);
  result['email'] = _or(keep['email'], drop['email']);
  result['address'] = _or(keep['address'], drop['address']);
  result['city'] = _or(keep['city'], drop['city']);
  result['idNum'] = _or(keep['idNum'], drop['idNum']);
  result['cat'] = _or(keep['cat'], drop['cat']);
  result['forWho'] = _or(keep['forWho'], drop['forWho']);
  result['notes'] = notes;
  result['nextDate'] = _or(keep['nextDate'], drop['nextDate']);
  if (_truthy(nextNote)) result['nextNote'] = nextNote;
  result['nextEventId'] = _truthy(keep['nextEventId']) ? keep['nextEventId'] : null;
  result['donations'] = donations;
  if (hist.isNotEmpty) result['hist'] = hist;
  if (photos.isNotEmpty) result['photos'] = photos;
  result['count'] = donations.length;
  result['ils'] = ils;
  result['usd'] = usd;
  result['first'] =
      donations.isNotEmpty ? (donations[0] as Map)['date'] : (keep['first'] ?? '');
  result['last'] = donations.isNotEmpty
      ? (donations[donations.length - 1] as Map)['date']
      : (keep['last'] ?? '');
  if (_truthy(keep['extId']) || _truthy(drop['extId'])) {
    result['extId'] = _or(keep['extId'], drop['extId']);
  }
  if (_truthy(keep['hok']) || _truthy(drop['hok'])) {
    result['hok'] = keep['hok'] ?? drop['hok'];
  }
  if (_truthy(keep['ayin']) || _truthy(drop['ayin'])) {
    result['ayin'] = keep['ayin'] ?? drop['ayin'];
  }
  return result;
}
