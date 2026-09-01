// ⚛️ אטום-Dart (דרגת-חוזה) · hebAnnualEq — שוויון יום+חודש עברי לחזרה שנתית.
// מוצא: maor/src/lib/hebrew.ts:95-121 · המקור: new/atoms/heb-annual-eq.mjs.
//        isAdar (helper פרטי) הוטמע פנימה; scanHebYear (סריקת-השכן) הוזרק כשקע (חוק-1).
//        חוק-4 — התנהגות זהה-ביט למקור-ה-JS, לא-משופרת.
//
// תפקיד: א-סימטרי לפי תפקיד — anchor=עוגן (התאריך המקורי), query=היום-הנבדק בשנה
//        הנוכחית. שני דיני-בעלים: כלל-ל׳ (עוגן-30 מול חודש-הבא כשאין 30 בחודש-העוגן)
//        וכלל-אדר (אדר-רגיל⇒אדר-ב׳ במעוברת; אדר-א׳/אדר-ב׳ בלי כפילות ובלי היעלמות).
// שקע (חוק-1): scanHebYear(year) ⇒ (seq, has30) — רצף שמות-החודשים + קבוצת החודשים
//        שיש בהם יום 30. נקרא רק בענף כלל-ל׳ (עוגן-30 מול שאילתה-1 עם year).
// קלט: anchor (day, month) · query (day, month, year?) · השקע scanHebYear. פלט: bool.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  · truthiness (כלל 7): `query.year` truthy ב-JS = לא-null ולא-אפס ⇒ `year != null && year != 0`.
//    `prev` truthy = מחרוזת לא-ריקה ⇒ `prev != null && prev.isNotEmpty` (מקביל ל-`if (prev)`).
//  · `seq.indexOf(m)` מחזיר -1 בשני העולמות; `qi > 0` מטפל ב-{-1,0} ⇒ prev=null (זהה).
//  · אין locale/פורמט/getMonth/מוטביליות/מודולו-שלילי מעורבים; `==` על String = ערך (=== של JS).

/// Hebrew day+month equality for annual recurrence (memorial / birthday /
/// anniversary), asymmetric by role: [anchor] is the original date, [query] is
/// the day-under-test in the current year. [scanHebYear] is the injected socket
/// returning the year's month sequence and the set of months that have a 30th.
/// Verbatim behaviour of the JS source `hebAnnualEq`.
bool hebAnnualEq(
  ({int day, String month}) anchor,
  ({int day, String month, int? year}) query,
  ({List<String> seq, Set<String> has30}) Function(int year) scanHebYear,
) {
  bool isAdar(String m) => m == 'Adar' || m == 'Adar I' || m == 'Adar II';

  // כלל ל׳: עוגן-30 מול א' בחודש-הבא, כשלחודש-העוגן אין 30 בשנת היום-הנבדק.
  if (anchor.day == 30 && query.day == 1 && (query.year != null && query.year != 0)) {
    final scan = scanHebYear(query.year!);
    final seq = scan.seq;
    final has30 = scan.has30;
    final qi = seq.indexOf(query.month);
    final String? prev = qi > 0 ? seq[qi - 1] : null;
    final prevMatches =
        prev == anchor.month || (anchor.month == 'Adar I' && prev == 'Adar');
    if ((prev != null && prev.isNotEmpty) && prevMatches && !has30.contains(prev)) {
      return true;
    }
  }
  if (anchor.day != query.day) return false;
  if (isAdar(anchor.month) || isAdar(query.month)) {
    if (!isAdar(anchor.month) || !isAdar(query.month)) return false; // אחד אדר, השני לא
    if (query.month == 'Adar') return true; // שנה פשוטה — אדר יחיד בולע כל עוגן-אדר
    if (query.month == 'Adar II') {
      return anchor.month == 'Adar' || anchor.month == 'Adar II';
    }
    if (query.month == 'Adar I') return anchor.month == 'Adar I';
    return false;
  }
  return anchor.month == query.month;
}
