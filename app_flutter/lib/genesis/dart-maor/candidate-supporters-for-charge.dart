// ⚛️ אטום-Dart (דרגת-חוזה) · candidateSupportersForCharge — מועמדים לשיוך עסקה לכרטיס-תורם.
// מוצא: maor/src/lib/nedarimSync.ts:279-302 · המקור: new/atoms/candidate-supporters-for-charge.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core + dart:math.max). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מדרג תומכים כמועמדים לחיוב-סנכרון לפי מפתחות-התאמה משותפים —
//        ext:(5) > id:(4) > ph:(3) > em:(2); ואם אין מפתח-משותף אך השם דו-מילתי
//        ותואם (חסין-סדר) — ניקוד-שם (1). מוחזרים ה-limit הגבוהים, ממוינים יורד.
//
// 🔧 תיקון-הסגר (גל #20): Dart `List.sort` אינו-יציב ל-≥32 איברים (quicksort);
//    JS `Array.sort` יציב-לפי-תקן. שוויון-ציון ב-≥32 מועמדים ⇒ סדר שונה ⇒ קבוצת-מועמדים
//    שונה אחרי slice(limit). התיקון (כלל-מערכתי decorate-sort-undecorate): נשמר אינדקס-מקורי
//    בכל רשומה כשובר-שוויון — שוויון-ציון נפתר לפי סדר-ההוספה, בדיוק כמו מיון-יציב.
//
// שקעים (חוק-1, הוזרקו כפרמטרים — במקור קריאות-שכן keysOf + nameSortKey):
//   · keysOf({extId?, idNum?, zeout?, phone?, email?}) → List<String> (מפתחות בקידומת-חוזק).
//   · nameSortKey(name?) → String (טוקנים ממוינים; ריק אם אין שם).

import 'dart:math' show max;

List<Map<String, Object?>> candidateSupportersForCharge(
  Map<String, Object?> charge,
  List<Map<String, Object?>> supporters,
  List<String> Function(Map<String, Object?>) keysOf,
  String Function(Object?) nameSortKey, {
  int limit = 8,
}) {
  final ck = <String>{
    ...keysOf({
      'extId': charge['toremId'],
      'zeout': charge['zeout'],
      'phone': charge['phone'],
      'email': charge['email'],
    }),
  };
  final cName = nameSortKey(charge['name'] ?? '');
  final scored = <Map<String, Object?>>[];
  var idx = 0;
  for (final sp in supporters) {
    final sk = keysOf({
      'extId': sp['extId'],
      'idNum': sp['idNum'],
      'phone': sp['phone'],
      'email': sp['email'],
    });
    var score = 0;
    for (final k in sk) {
      if (!ck.contains(k)) continue;
      if (k.startsWith('ext:')) {
        score = max(score, 5);
      } else if (k.startsWith('id:')) {
        score = max(score, 4);
      } else if (k.startsWith('ph:')) {
        score = max(score, 3);
      } else if (k.startsWith('em:')) {
        score = max(score, 2);
      }
    }
    if (score == 0 &&
        cName.isNotEmpty &&
        cName.contains(' ') &&
        nameSortKey(sp['name']) == cName) {
      score = 1;
    }
    // decorate: אינדקס-מקורי כשובר-שוויון ⇒ מיון-יציב זהה-JS.
    if (score != 0) scored.add({'sp': sp, 'score': score, 'idx': idx});
    idx++;
  }
  scored.sort((a, b) {
    final ds = (b['score'] as int) - (a['score'] as int);
    if (ds != 0) return ds;
    return (a['idx'] as int) - (b['idx'] as int);
  });
  final end = scored.length < limit ? scored.length : limit;
  return scored
      .sublist(0, end)
      .map((x) => x['sp'] as Map<String, Object?>)
      .toList();
}
