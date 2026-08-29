// ⚛️ אטום-Dart (דרגת-חוזה) · annualAllLines — דוח-מרוכז שנתי לכל התורמים.
// מוצא: maor/src/lib/annualReport.ts:87-108 · המקור: new/atoms/annual-all-lines.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). שני השכנים הוזרקו כשקעים (חוק-1/חוק-3):
//        donationsOfYear(donations, year) · annualReportLines(input).
//
// תפקיד: מקטע-שורות לכל תורם/ת שיש לו/ה תרומות בשנה, עם מפריד-עמוד ('', '\f', '')
//        **בין** מקטעים (לא לפני הראשון ולא אחרי האחרון). תורם/ת בלי תרומות-השנה
//        מדולג/ת. אף תורם/ת ⇒ שורה יחידה 'אין תורמים עם תרומות בשנת YYYY.'.
// קלט:  orgName · orgTaxId? · year · supporters=[{name, idNum?, donations[]}] · site? +
//        donationsOfYear(donations, year)⇒תרומות-השנה · annualReportLines(input)⇒שורות-המקטע.
//        פלט: List<String>.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • `.length === 0` → `.isEmpty` — השקע מחזיר List, אותה סמנטיקה בדיוק (אפס-איברים).
//  • `count > 0` — מונה שלם; `out.push('', '\f', '')` → `out.addAll(['', '\f', ''])`.
//  • `out.push(...annualReportLines(...))` (spread) → `out.addAll(annualReportLines(...))`.
//  • המפתחות למקטע: supporterName=sp.name · payerId=sp.idNum · donations=sp.donations —
//    כל היעדר-שדה (idNum ריק) עובר כ-null בדיוק כמו `undefined` של JS.
//  • שרשור-מחרוזת: 'אין תורמים... ' + year + '.' — year הוא String (זהה למקור).
//  • מוטביליות: `out` final (מוטבל דרך addAll/add); `count` הוא var (עולה בלולאה) —
//    בדיוק כמו `let count` במקור. אין locale/פורמט/getMonth — הפורמט חי בשקעים.

/// A year-wide donor report — one section per supporter with donations that year, a page
/// break ('', '\f', '') BETWEEN sections (not before the first, not after the last).
/// Supporters with no donations that year are skipped; none at all ⇒ a single Hebrew line.
/// Verbatim port of new/atoms/annual-all-lines.mjs (`annualAllLines`); the neighbours
/// donationsOfYear and annualReportLines are injected as sockets (Law 1/3).
List<String> annualAllLines(
  String orgName,
  String? orgTaxId,
  String year,
  List<Map<String, dynamic>> supporters,
  dynamic site,
  List<dynamic> Function(dynamic donations, String year) donationsOfYear,
  List<String> Function(Map<String, dynamic> input) annualReportLines,
 {required String Function(String) term}) {
  final out = <String>[];
  var count = 0;
  for (final sp in supporters) {
    if (donationsOfYear(sp['donations'], year).isEmpty) continue;
    if (count > 0) out.addAll(['', '\f', '']);
    out.addAll(annualReportLines({
      'orgName': orgName,
      'orgTaxId': orgTaxId,
      'supporterName': sp['name'],
      'payerId': sp['idNum'],
      'year': year,
      'donations': sp['donations'],
      'site': site,
    }));
    count++;
  }
  if (count == 0) out.add(term('ayn-tvrmym-am-trvmvt-bshnt') + year + '.');
  return out;
}
