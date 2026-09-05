// ⚛️ אטום-Dart (דרגת-חוזה) · isHebLeapYear — האם שנה עברית מעוברת.
// מוצא: maor · new/atoms/is-heb-leap-year.mjs (חוק-4 — התנהגות זהה-לחלוטין למקור-ה-JS, לא-משופרת).
//        חולץ מ-maor/src/lib/hebdate.ts (isHebLeapYear). קריאת-החוץ hebToIsoEn הפכה
//        לשקע-פרמטר (חוק-1/3 — אפס import פנימי). המבחן: האם 'Adar I' קיים בשנה.
//
// DART-PORTING-RULES כלל-2 (null≠undefined): המקור בודק `hit !== undefined` על ה-cache.
//   הערכים הנשמרים הם bool בלבד (לעולם לא null/undefined) ⇒ הבחנת "קיים במטמון" נאמנה
//   ל-JS היא `containsKey`, לא `!= null`. השקע מחזיר String?  ⇒ `!= null` נאמן ל-`!== null`.
// אפס-import (dart-core בלבד). המטמון = מצב-מודול, כמו leapCache ב-JS.

final Map<int, bool> _leapCache = {};

bool isHebLeapYear(int hebYear, String? Function(int, String, int) hebToIsoEn) {
  if (_leapCache.containsKey(hebYear)) return _leapCache[hebYear]!;
  final leap = hebToIsoEn(1, 'Adar I', hebYear) != null;
  _leapCache[hebYear] = leap;
  return leap;
}
