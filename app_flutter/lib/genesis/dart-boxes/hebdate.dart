import '../dart-data-maor/month-he-of-sockets.dart' as skb_month_he_of;
import '../dart-data-maor/month-en-of.dart';
// 📦 קופסת-חיבורים · hebdate (Dart) — שכבת קלט/תצוגה תאריך-עברי, מחווטת אטומי-Dart בלבד.
// מקבילה זהת-ביט ל-new/boxes/hebdate.mjs. חוזה משותף: hebdate.contract.md · מקור-האמת (L4):
// maor/src/lib/hebdate.ts. ההכרעות שחיות כאן (חיווט, לא אטום) זהות לקופסת-ה-JS:
//  · isoOf — הרכבת ISO מ-DateTime מקומי דרך pad2 (hebdate.ts:60-62)
//  · hebToIsoEn — סריקת-העוגן: 1-באוגוסט של (hebYear−3761), עד 440 ימים, צהריים-מקומי
//    חסין-שעון-קיץ (hebdate.ts:65-75); גבולות 1..30 / 4000..7000
//  · KNOWN_MONTHS_EN — מילון-התוויות המוכר ל-CLDR-guard (hebdate.ts:124)
//  · ברירת-מחדל hebYear=hebYearNow() לוולידציה (hebdate.ts:125)
// שקעי-IO מוזרקים (לא מימוש): now=שעון (ברירת-מחדל DateTime.now(), נאמן-למקור) ·
// warn=קונסולה (print). שער-ה-CLDR נחשף כפונקציה cldrGuard — הקופסה נקייה מתופעות-לוואי.
// הערת-פורט: JS month index 0-based (7=אוגוסט) ⇒ ב-Dart month 8; day-שבור (Date(NaN))
// מיוצג כ-null (hebParts atom מגן עליו). day לא-שלם (2.5 של ה-JS) בלתי-אפשרי בטיפוס int של Dart.
import '../dart-maor/heb-parts.dart' as hp;
import '../dart-maor/pad2.dart' as p2;
import '../dart-maor/month-he-of.dart' as mho;
import '../dart-maor/month-en-of.dart' as meo;
import '../dart-maor/heb-year-now.dart' as hyn;
import '../dart-maor/is-heb-leap-year.dart' as hly;
import '../dart-maor/heb-months-of.dart' as hmo;
import '../dart-maor/heb-to-iso.dart' as hti;
import '../dart-maor/iso-to-heb-parts.dart' as ithp;
import '../dart-maor/validate-heb-month-names.dart' as vhmn;

// מתאם-שקע: hebParts מוקלד-רחב (DateTime?)⇒Map<String,Object> — נאמן לחתימת-האטום.
Map<String, Object> _hebParts(DateTime? d) => hp.hebParts(d);

// ── חיווט: DateTime⇒ISO מקומי (hebdate.ts:60-62). getFullYear/getMonth+1/getDate ⇒ year/month/day. ──
String isoOf(DateTime d) => '${d.year}-${p2.pad2(d.month)}-${p2.pad2(d.day)}';

// ── חיווט: עברי→לועזי כששם-החודש בשם-Intl — סריקת ~440 ימים מהעוגן (hebdate.ts:65-75). ──
String? hebToIsoEn(int day, String monthEn, int hebYear) {
  // Number.isInteger מובטח ע"י טיפוס int; נותרו גבולות-הטווח בלבד.
  if (day < 1 || day > 30) return null;
  if (hebYear < 4000 || hebYear > 7000) return null;
  final gy = hebYear - 3761; // 1 באוגוסט של השנה הזו קודם תמיד לא׳ תשרי של hebYear
  for (var i = 0; i < 440; i++) {
    final d = DateTime(gy, 8, 1 + i, 12); // צהריים — חסין להיסטי שעון קיץ; חודש 8 = אוגוסט
    final p = hp.hebParts(d);
    if (p['year'] == hebYear && p['month'] == monthEn && p['day'] == day) return isoOf(d);
  }
  return null; // התאריך לא קיים בשנה זו (למשל ל׳ חשוון בשנה חסרה/כסדרה)
}

/// תווית עברית של חודש לפי שם Intl ('Av' → 'אב'), או '' אם לא מוכר. (hebdate.ts:42-44)
String monthHeOf(String en) => mho.monthHeOf(en, skb_month_he_of.monthHeOf_MONTHS);

/// שם Intl של חודש לפי תווית עברית ('אב' → 'Av'), או null אם לא מוכר. (hebdate.ts:47-49)
String? monthEnOf(String he) => meo.monthEnOf(he, months: kMonths);

/// השנה העברית של רגע נתון (ברירת-מחדל: עכשיו — כמו במקור). (hebdate.ts:52-54)
int hebYearNow([DateTime? now]) => hyn.hebYearNow(_hebParts, now ?? DateTime.now());

/// האם שנה עברית מעוברת — האם קיים בה 'Adar I' (עם cache באטום). (hebdate.ts:79-85)
bool isHebLeapYear(int hebYear) => hly.isHebLeapYear(hebYear, hebToIsoEn);

/// חודשי שנה עברית לפי הסדר, בתוויות עבריות — 12 בפשוטה / 13 במעוברת. (hebdate.ts:91-94)
List<String> hebMonthsOf(int hebYear) => hmo.hebMonthsOf(hebYear, isHebLeapYear, monthHeOf);

/// עברי→לועזי: (23,'אב',5786) → '2026-08-06'; null אם הצירוף לא קיים. (hebdate.ts:100-104)
String? hebToIso(int day, String monthHe, int hebYear) =>
    hti.hebToIso(day, monthHe, hebYear, monthEnOf, hebToIsoEn);

/// G49 · נקודת-כניסה ייחודית: קלט-עברי (יום · תווית-חודש · שנה או השנה-הנוכחית) ⇒ ISO | null
String? hebInputToIso(int day, String monthHe, [int? hebYear]) => hebToIso(day, monthHe, hebYear ?? hebYearNow());
/// לועזי→עברי: '2026-08-06' → {day:23, monthHe:'אב', year:5786} | null. (hebdate.ts:107-115)
Map<String, dynamic>? isoToHebParts(String iso) =>
    ithp.isoToHebParts(iso, (DateTime d) => hp.hebParts(d), monthHeOf);

/// מילון-החודשים המוכרים (שמות-Intl, כולל 'Adar' + 'Adar I/II') — הכרעת-קופסה. (hebdate.ts:124)
final Set<String> KNOWN_MONTHS_EN = <String>{
  'Tishri', 'Heshvan', 'Kislev', 'Tevet', 'Shevat', 'Adar', 'Adar I', 'Adar II',
  'Nisan', 'Iyar', 'Sivan', 'Tamuz', 'Av', 'Elul',
};

/// ולידציית-ריצה: סריקת שנה עברית ⇒ שמות-חודשי-Intl לא-מוכרים (ריק = תקין). (hebdate.ts:125-137)
List<Object?> validateHebMonthNames([int? hebYear]) =>
    vhmn.validateHebMonthNames(hebYear ?? hebYearNow(), (DateTime d) => hp.hebParts(d), KNOWN_MONTHS_EN);

// סנטינל: מבחין בין "לא-הועבר now" (⇒DateTime.now()) לבין "הועבר null במפורש" (⇒שעון-שבור).
const Object _noNow = Object();

/// שער-CLDR זול O(1): שם-חודש-היום חייב להיות מוכר; לא-מוכר ⇒ warn (אין throw) ומחזיר false.
/// במקור רץ בטעינת-המודול (hebdate.ts:139-143) — כאן שקע-מחווט ללוח-האם. now=null ⇒ שעון-שבור.
bool cldrGuard([Object? now = _noNow, void Function(String)? warn]) {
  final DateTime? clock = identical(now, _noNow) ? DateTime.now() : now as DateTime?;
  final w = warn ?? print;
  if (!KNOWN_MONTHS_EN.contains(_hebParts(clock)['month'])) {
    w('⚠ שם חודש עברי לא-צפוי מ-Intl — ייתכן שינוי CLDR שישבור המרות תאריך. הריצו validateHebMonthNames().');
    return false;
  }
  return true;
}
