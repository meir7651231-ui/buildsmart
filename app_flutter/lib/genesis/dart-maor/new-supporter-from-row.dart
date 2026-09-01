// ⚛️ אטום-Dart (דרגת-חוזה) · newSupporterFromRow — שורת-ייבוא ⇒ רשומת-תומך חדשה ומאופסת.
// מוצא: maor/src/components/supporters/lib.ts:652-678 · המקור: new/atoms/new-supporter-from-row.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). השכנים fixPhone + mergeHist הוזרקו כשקעים (חוק-1/חוק-3).
//
// תפקיד: בונה Supporter חדש משורת-ייבוא — שדות-הטקסט נחתכים-רווחים (trim), הטלפון
//        נחתך-ואז-עובר-שקע (fixPhone(row.phone.trim())), והמונים/הצבירות נולדים מאופסים.
//        row.hist נכנס רק כשקיים ולא-ריק — דרך mergeHist([], row.hist); אחרת מפתח hist
//        לא קיים כלל ברשומה (spread-מותנה).
// קלט:  id · row {name,phone,email,idNum,address,cat,forWho,hist?} · שני השקעים. פלט: Map חדש.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • spread-מותנה `...(row.hist?.length ? {hist:…} : {})`: ב-JS `row.hist?.length` הוא
//    truthy כאשר hist קיים **ולא-ריק** (length>0). ב-Dart: `(row['hist'] as List?)` לא-null
//    ולא-ריק ⇒ רק אז מוסיפים את המפתח 'hist'. hist נעדר/null/[] ⇒ אין מפתח כלל (דוגמאות 1,3).
//    ה-`?.length` של JS על undefined/null מחזיר undefined (falsy), על [] מחזיר 0 (falsy) —
//    שתי המקרים ⇒ אין hist; מומש כ-`histList != null && histList.isNotEmpty`.
//  • `.trim()` של JS ⇒ `.trim()` של Dart — שניהם חותכים whitespace דו-צדדי (זהה לתחום).
//  • השקעים: fixPhone(String)⇒String מקבל את הטלפון **אחרי** trim; mergeHist(List,List)⇒List
//    נקרא תמיד עם [] כבסיס (const [] טרי — אינו מוטבל, mergeHist בונה חדש).
//  • מוטביליות: ה-Map נבנה כליטרל אחד; המפתח hist מתווסף רק בענף. אין locale/פורמט/getMonth/
//    מודולו/substring — כל השקעים חיים בפונקציות המוזרקות.

/// Builds a fresh Supporter record from an import row: text fields are trimmed,
/// phone is trimmed-then-socketed via fixPhone, and all counters/aggregates are
/// born zeroed (notes:'' · count/ils/usd:0 · first/last/nextDate:'' · donations:[]).
/// row.hist is merged in (via mergeHist over an empty base) only when present and
/// non-empty; otherwise the 'hist' key is absent entirely (conditional spread).
/// Verbatim port of new/atoms/new-supporter-from-row.mjs (`newSupporterFromRow`);
/// the neighbour calls fixPhone + mergeHist are injected as sockets (Law 1/3).
Map<String, dynamic> newSupporterFromRow(
  dynamic id,
  Map<String, dynamic> row,
  String Function(String) fixPhone,
  List Function(List existing, List incoming) mergeHist,
) {
  final out = <String, dynamic>{
    'id': id,
    'name': (row['name'] as String).trim(),
    'phone': fixPhone((row['phone'] as String).trim()),
    'email': (row['email'] as String).trim(),
    'idNum': (row['idNum'] as String).trim(),
    'address': (row['address'] as String).trim(),
    'cat': (row['cat'] as String).trim(),
    'forWho': (row['forWho'] as String).trim(),
    'notes': '',
    'count': 0,
    'ils': 0,
    'usd': 0,
    'first': '',
    'last': '',
    'nextDate': '',
    'donations': <dynamic>[],
  };
  final histList = row['hist'] as List?;
  if (histList != null && histList.isNotEmpty) {
    out['hist'] = mergeHist(<dynamic>[], histList);
  }
  return out;
}
