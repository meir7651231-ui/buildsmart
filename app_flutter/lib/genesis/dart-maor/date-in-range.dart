// חוט · date-in-range — תאריך-ISO בטווח כוללני, קצה ריק=פתוח. חוזה: date-in-range.contract.md
// המרה מ-JS (new/atoms/date-in-range.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// אפס-import (dart-core בלבד). אין שקעים — עצמאי מלידה.
//
// תיקוני-מנוע (הזנב שהמנוע פספס):
//   • JS `!fromIso` (truthiness) ⇒ _falsy מפורש: ריק/null=פתוח (DART-PORTING-RULES §7).
//   • JS `iso >= fromIso` על מחרוזות = השוואה לקסיקוגרפית ⇒ String.compareTo
//     (ל-dynamic/String אין אופרטור >= ב-Dart; ISO ממוין כמו תאריך).
bool dateInRange(String iso, String? fromIso, String? toIso) {
  return (_falsy(fromIso) || iso.compareTo(fromIso!) >= 0) &&
      (_falsy(toIso) || iso.compareTo(toIso!) <= 0);
}

// JS falsy למחרוזת: null/undefined/'' ⇒ קצה-פתוח.
bool _falsy(String? s) => s == null || s.isEmpty;
