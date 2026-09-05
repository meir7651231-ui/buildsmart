// חוט · in-range — האם תאריך-ISO בתוך טווח {from,to} (השוואה לקסיקוגרפית, גבולות כוללים).
// חוזה: in-range.contract.md · חולץ כלשונו מ-maor/src/components/reports/lib.ts:25-30.
// המרה מ-JS (new/atoms/in-range.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// אפס-import (dart-core בלבד). אין שקעים — עצמאי מלידה.
//
// תיקוני-מנוע (הזנב שהמנוע פספס):
//   • JS `if (!iso)` (truthiness) ⇒ _falsy מפורש: ריק/null ⇒ false (DART-PORTING-RULES §7).
//   • JS `r.from &&` / `r.to &&` (truthiness של קצה-הטווח) ⇒ !_falsy מפורש: קצה ריק=פתוח.
//   • JS `iso < r.from` / `iso > r.to` על מחרוזות = השוואה לקסיקוגרפית ⇒ String.compareTo
//     (ל-String אין אופרטור </<= ב-Dart; ISO ממוין כמו תאריך).
//   • r מיוצג כרשומה `({String? from, String? to})` — צורת-החוזה (r.from/r.to) נשמרת.
bool inRange(String? iso, ({String? from, String? to}) r) {
  if (_falsy(iso)) return false;
  if (!_falsy(r.from) && iso!.compareTo(r.from!) < 0) return false;
  if (!_falsy(r.to) && iso!.compareTo(r.to!) > 0) return false;
  return true;
}

// JS falsy למחרוזת: null/undefined/'' ⇒ falsy.
bool _falsy(String? s) => s == null || s.isEmpty;
