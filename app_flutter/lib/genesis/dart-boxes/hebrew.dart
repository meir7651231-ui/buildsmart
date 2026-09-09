import '../dart-data-maor/gematria-sockets.dart' as td_gematria;
import '../dart-data-maor/holiday-of-terms.dart';
// 📦 קופסת-חיבורים · hebrew (Dart) — הלוח העברי המלא, מחווטת אטומי-Dart בלבד.
// מקבילה זהת-ביט ל-new/boxes/hebrew.mjs. חוזה משותף: hebrew.contract.md · מקור-האמת (L4):
// maor/src/lib/hebrew.ts. זהו ההוכחה ש-מאור(JS) ובנייה-חכמה(Dart) מתחברות לאותה קופסה:
// אותם קלטים ⇒ אותו פלט. ה-ID/הכרעת-החיווט היחידה שחיה כאן (לא אטום) = scanHebYear
// (קומפוזיציית heb-parts, לא-IO), זהה ביט-אחר-ביט להכרעת-קופסת-ה-JS:
//  · חלון 440 ימים · עוגן 1-באוגוסט של (hebYear−3761) בצהריים · מטמון-Map פר-שנה.
// שקעי-IO: אין — הכול Intl/סטנדרט (heb-parts ממיר את הלוח ידנית ב-Dart; אין DOM/רשת/אחסון).
//
// הערות-פורט (JS→Dart):
//  · JS `new Date(gy, 7, 1+i, 12)` — month index 0-based, 7=אוגוסט ⇒ Dart `DateTime(gy, 8, …)`.
//  · anchor/query של JS = object-literal ⇒ Dart record (חתימת-האטום heb-annual-eq).
//  · scanHebYear של heb-annual-eq דורש record ‏(seq,has30); של holiday-of דורש Map עם ['has30'].
//    שני צרכנים, אותו מנוע: _scanHebYear (רשומה) + מתאם-Map דק ל-holidayOf.
//  · hebParts מחזיר Map<String,Object> — מתואם לחתימות-האטום השונות דרך מתאמי-טיפוס דקים.
import '../dart-maor/gematria.dart' as g;
import '../dart-maor/gem-year.dart' as gy;
import '../dart-maor/adar-norm.dart' as an;
import '../dart-maor/heb-annual-eq.dart' as hae;
import '../dart-maor/heb-parts.dart' as hp;
import '../dart-maor/heb-parts-of-iso.dart' as hpi;
import '../dart-data-maor/heb-date-full-sockets.dart' as sk_hdf;
import '../dart-maor/heb-date-full.dart' as hdf;
import '../dart-maor/holidays.dart' as hol;
import '../dart-maor/holiday-of.dart' as ho;
import '../dart-maor/upcoming-holidays.dart' as uh;   // G49

// ── חיווט: סריקת-שנה-עברית (מקור hebrew.ts:60-76 / hebrew.mjs) — הכרעות-הקופסה:
//    חלון 440 ימים, עוגן 1-באוגוסט של (hebYear-3761) בצהריים, מטמון-Map פר-שנה.
//    קומפוזיציה של אטום heb-parts (לא-IO) — לכן חיה כאן ולא כפרמטר. משרתת את כלל-ל'
//    (heb-annual-eq) ואת דין-חנוכה-ח' (holiday-of).
final Map<int, ({List<String> seq, Set<String> has30})> _hebYearScan = {};
({List<String> seq, Set<String> has30}) _scanHebYear(int hebYear) {
  final hit = _hebYearScan[hebYear];
  if (hit != null) return hit;
  final seq = <String>[];
  final has30 = <String>{};
  final gyear = hebYear - 3761; // 1 באוגוסט של השנה הזו קודם תמיד לא' תשרי של hebYear
  for (var i = 0; i < 440; i++) {
    final p = hp.hebParts(DateTime(gyear, 8, 1 + i, 12)); // חודש 8 = אוגוסט (JS index 7)
    if (p['year'] != hebYear) continue;
    final month = p['month'] as String;
    if (!seq.contains(month)) seq.add(month);
    if (p['day'] == 30) has30.add(month);
  }
  final res = (seq: seq, has30: has30);
  _hebYearScan[hebYear] = res;
  return res;
}

// מתאם-שקע ל-holiday-of: הוא דורש `Map Function(dynamic year)` עם ['has30'] כ-Set.
Map _scanForHoliday(dynamic year) => {'has30': _scanHebYear(year as int).has30};

// מתאם-שקע ל-holiday-of: hebParts מוקלד-רחב (DateTime)⇒Map — נאמן לחתימת-האטום.
Map _hebPartsForHoliday(DateTime d) => hp.hebParts(d);

// ── חשיפה: שמות-המקור verbatim (חוק-7 — החלפה-הפיכה) ──

/// גימטריה — מספר⇒אותיות עבריות (טו/טז, גרש/גרשיים). קלט לא-חוקי ⇒ ''.
String gem(num n) => g.gem(n, td_gematria.gematria_U, td_gematria.gematria_T, td_gematria.gematria_H, td_gematria.gematria_T2);

/// שנה עברית⇒גימטריה מקוצרת (mod 1000). מקבל int או String (ToNumber של JS).
String gemYear(Object? y) => gy.gemYear(y, gem);

/// דין-אדר לנרמול: 'Adar II' ⇒ 'Adar'; כל שם-אחר עובר כמו-שהוא.
String adarNorm(String monthEn) => an.adarNorm(monthEn);

/// רכיבי-תאריך-עברי של לועזי: {day:int, month:String(אנגלי), year:int}.
/// קלט-שבור (null — מקביל ל-Invalid Date) ⇒ {day:0, month:'', year:0}.
Map<String, Object> hebParts(DateTime? d) => hp.hebParts(d);

/// שוויון יום+חודש עברי לחזרה שנתית (א-סימטרי: anchor=עוגן, query=היום-הנבדק).
/// כלל-ל' + דין-אדר. השקע scanHebYear מחווט למנוע-הקופסה.
bool hebAnnualEq(
        ({int day, String month}) anchor, ({int day, String month, int? year}) query) =>
    hae.hebAnnualEq(anchor, query, _scanHebYear);

/// רכיבי-התאריך-העברי של ISO, ממומואיז לפי מחרוזת-ה-ISO (מטמון חסום 3000).
Map<String, dynamic> hebPartsOfIso(String iso) =>
    hpi.hebPartsOfIso(iso, (dynamic date) => hp.hebParts(date as DateTime?));

/// 'ט״ו אלול תשפ״ו' מתוך ISO (צהריים-מקומי — חסין-אזורי-זמן). ריק/שבור ⇒ ''.
String hebDateFull(String? iso) => hdf.hebDateFull(iso, gem, gemYear, (DateTime d) => hp.hebParts(d), sk_hdf.hebDateFull_monthNames);

/// מפת "חודש-עברי יום" ⇒ שם-חג (33 מפתחות סטטיים).
const Map<String, String> HOLIDAYS = hol.HOLIDAYS; // ignore: constant_identifier_names

/// שם החג/הצום בתאריך לועזי נתון, או null (דיני חנוכה-ח'/צום-נדחה/תענית-אסתר-מוקדמת).
String? holidayOf(DateTime d) => ho.holidayOf(d, _hebPartsForHoliday, _scanForHoliday, hol.HOLIDAYS, term: (k)=>kTerms[k]!);
/// G49 · נקודות-כניסה ייחודיות (המפקד מקטלג לפי-שם): חג/צום בתאריך-ISO · החגים ב-N הימים הבאים [{iso,name}]
String? hebHolidayOn(String iso) => iso.length < 10 ? null : holidayOf(DateTime.parse(iso.substring(0, 10) + 'T12:00:00'));
List<Map<String, dynamic>> hebHolidaysAhead(String isoFrom, int days) => uh.upcomingHolidays(isoFrom, holidayOf, (DateTime d) => d.toIso8601String().substring(0, 10), days);
