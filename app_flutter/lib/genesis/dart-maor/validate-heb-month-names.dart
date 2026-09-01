// ⚛️ אטום-Dart (דרגת-חוזה) · validateHebMonthNames — סריקת שנה עברית לאיתור
//    שמות-חודשי-Intl לא-מוכרים (רשת-הביטחון של לוח-Intl; ריק = תקין).
// מוצא: maor/src/lib/hebdate.ts:125-137 · המקור: new/atoms/validate-heb-month-names.mjs.
//        חוק-4 — התנהגות זהה-ביט למקור-ה-JS, לא-משופרת.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core).
//
// שקעים (חוק-1 — השכנים הוזרקו כפרמטרים):
//  · hebParts — (DateTime)⇒Map עם 'year'/'month'/'day' — פירוק עברי של יום
//    לועזי (במקור: lib/hebrew על Intl; 'month' = שם אנגלי).
//  · knownMonths — Set שמות-החודשים המוכרים (במקור KNOWN_MONTHS_EN — 14 שמות).
//  · ברירת-המחדל hebYear=hebYearNow() של המקור הפכה לחיווט — הקורא מוסר שנה.
//
// הערות-המרה (DART-PORTING-RULES):
//  · חוק-3: העוגן `new Date(gy, 7, 1+i, 12)` — חודש-JS ‏0-based ⇒ ב-Dart חודש 8
//    (אוגוסט); גלישת-היום (1+i עד 440) מגלגלת-חודשים ב-V8 וב-DateTime של Dart
//    באותה נורמליזציה בדיוק (ימים חיוביים, אין Invalid).
//  · חוק-11: אין חישוב-לוח-עברי כאן — הכול דרך השקע המוזרק.
//  · דדופ-seen לפי סדר-הופעה ראשון — List.add משמר סדר-הכנסה כמו push של JS.

/// סורק 440 ימים מ-1 באוגוסט של gy=hebYear−3761 (צהריים, חסין-DST) ומחזיר
/// את שמות-החודשים של [hebYear] שאינם ב-[knownMonths], לפי סדר-הופעה ראשון
/// (דדופ). ימים של שנה עברית אחרת מדולגים. זהה-ביט למקור-ה-JS.
List<Object?> validateHebMonthNames(
  int hebYear,
  Map<String, Object?> Function(DateTime d) hebParts,
  Set<Object?> knownMonths,
) {
  final known = knownMonths;
  final unknown = <Object?>[];
  final seen = <Object?>{};
  final gy = hebYear - 3761;
  for (var i = 0; i < 440; i++) {
    final p = hebParts(DateTime(gy, 8, 1 + i, 12));
    if (p['year'] != hebYear || seen.contains(p['month'])) continue;
    seen.add(p['month']);
    if (!known.contains(p['month'])) unknown.add(p['month']);
  }
  return unknown;
}
