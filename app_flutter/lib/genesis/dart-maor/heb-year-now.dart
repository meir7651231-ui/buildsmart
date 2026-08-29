// ⚛️ אטום-Dart (דרגת-חוזה) · hebYearNow — השנה העברית של רגע נתון (למשל 5786).
//    גבול-השנה = א׳ תשרי, לא 1 בינואר.
// מוצא: maor/src/lib/hebdate.ts:52-54 (hebYearNow) · המקור: new/atoms/heb-year-now.mjs.
//        חוק-4 — התנהגות זהה-ביט למקור-ה-JS, לא-משופרת.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core בלבד).
//
// שקעים (חוק-1 — השכן והשעון-הסמוי הוזרקו כפרמטרים):
//  · hebParts — (Date)⇒{day,month,year}; במקור-ה-JS `hebParts(now).year`.
//    ב-Dart השקע מחזיר Map<String,Object> וה־year נקרא במפתח 'year' (int).
//  · now — השעון מוזרק. תאריך-שבור של המקור (Invalid Date) מיוצג כ-null,
//    בדיוק כמו באחות heb-parts.dart (DateTime.tryParse מחזיר null על קלט-רע);
//    השקע hebParts מגן עליו ומחזיר {'year':0} ⇒ הפלט 0 (זהה למקור).
//
// הערות-המרה (DART-PORTING-RULES): אין locale/פורמט/getMonth/מוטביליות/מודולו-שלילי
//  מעורבים באטום עצמו — זהו חוט-הצבעה טהור: קורא-שכן ומחזיר את שדה-השנה.

/// השנה העברית של הרגע [now], דרך השקע [hebParts] (חוק-1). זהה-ביט למקור
/// ה-JS `hebParts(now).year`; תאריך-שבור (now==null) ⇒ hebParts מחזיר year:0 ⇒ 0.
int hebYearNow(
  Map<String, Object> Function(DateTime? now) hebParts,
  DateTime? now,
) {
  return hebParts(now)['year'] as int;
}
