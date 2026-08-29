// ⚛️ אטום-Dart (דרגת-חוזה) · hebMonthsOf — חודשי שנה עברית לפי הסדר, בתוויות עבריות.
// מוצא: maor/src/lib/hebdate.ts:91-94 · המקור: new/atoms/heb-months-of.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). השכנים isHebLeapYear/monthHeOf
//        הוזרקו כשקעים (חוק-1/חוק-3); סדרי-החודשים = קבוע-נתונים באטום.
//
// תפקיד: שנה פשוטה (isHebLeapYear==false) ⇒ 12 חודשים עם 'אדר'; שנה מעוברת ⇒ 13,
//        עם 'אדר א׳' ו'אדר ב׳' במקום 'אדר'. סדר-החודשים תשרי→אלול (שמות Intl) מוטמע.
// קלט:  hebYear (int) · isHebLeapYear(hebYear)⇒bool · monthHeOf(en)⇒String.
// פלט:  List<String> (12 או 13).
//
// הערות-המרה (מקור→Dart) — הכללים ב-machtzev/emit/DART-PORTING-RULES.md:
//  • אין שקע-locale/פורמט, אין truthiness/undefined, אין מוטביליות — המרה ישירה.
//  • `order.map(monthHeOf)` (JS מחזיר Array) ⇒ `order.map(monthHeOf).toList()`
//    (List גשמי, כמו המערך שה-JS מחזיר; ולא Iterable עצל).
//  • השכנים isHebLeapYear/monthHeOf — פרמטרי-פונקציה, לא import (חוק-3).

/// סדר החודשים בשנה פשוטה (12) ובשנה מעוברת (13) — שמות Intl.
const List<String> _orderCommon = [
  'Tishri', 'Heshvan', 'Kislev', 'Tevet', 'Shevat', 'Adar',
  'Nisan', 'Iyar', 'Sivan', 'Tamuz', 'Av', 'Elul',
];
const List<String> _orderLeap = [
  'Tishri', 'Heshvan', 'Kislev', 'Tevet', 'Shevat', 'Adar I', 'Adar II',
  'Nisan', 'Iyar', 'Sivan', 'Tamuz', 'Av', 'Elul',
];

/// Hebrew month labels for a given Hebrew year, in order. Verbatim port of
/// new/atoms/heb-months-of.mjs (`hebMonthsOf`). `isHebLeapYear` and `monthHeOf`
/// are injected sockets (Law 1/3).
List<String> hebMonthsOf(
  int hebYear,
  bool Function(int hebYear) isHebLeapYear,
  String Function(String en) monthHeOf,
) {
  final order = isHebLeapYear(hebYear) ? _orderLeap : _orderCommon;
  return order.map(monthHeOf).toList();
}
