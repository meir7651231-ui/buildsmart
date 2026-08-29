// ⚛️ אטום-Dart (דרגת-חוזה) · supLast — תאריך התרומה האחרונה של תומך.
// מוצא: maor/src/components/supporters/lib.ts:123-132 · המקור: new/atoms/sup-last.mjs —
//   `export function supLast(sp) {
//      let m = sp.last || '';
//      for (const h of sp.hist ?? []) if (h.d > m) m = h.d;
//      return m; }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: המאוחר מבין מונה-הקבלות (last) לבין הקובץ ההיסטורי (hist[].d,
//   הכרעת-בעלים 9.8 "לכולל"); אין אף תרומה ⇒ ''. ההשוואה לקסיקוגרפית על
//   ISO‏ (yyyy-mm-dd) — לכן זהה להשוואת-תאריכים. טהור, אפס שקעים.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//   • כלל-2 (null≠undefined): ‏`sp.last || ''` ו-`sp.hist ?? []` ב-JS מתייחסים
//     ל-undefined (מפתח-חסר) ול-null באותו אופן (falsy/nullish) ⇒ ‏`sp['last']`/
//     ‏`sp['hist']` של Dart (null לחסר ולמפורש) = מיפוי נאמן; אין צורך ב-containsKey.
//   • כלל-7 (truthiness): ‏`sp.last || ''` ⇒ עוזר ‏_falsy מפורש (null/''/0/false/NaN ⇒ '').
//   • ‏`h.d > m` — אופרטור-יחס של JS: שתי מחרוזות ⇒ השוואת code-unit לקסיקוגרפית
//     ⇒ ‏String.compareTo > 0 (זהה ל-UTF-16 של JS). אופרנד לא-מחרוזת (undefined/null
//     על d חסר) ⇒ false ב-JS (‏undefined⇒NaN; ‏null⇒0 מול ''⇒0) — משוקף ב-_jsGt.
//   • אפס locale/פורמט/getMonth/מודולו/trim/toLowerCase/מוטציה — קריאה בלבד.

/// Latest donation date of a supporter: the max of the receipts counter
/// (`sp['last']`) and the historical file (`sp['hist'][i]['d']`), compared
/// lexicographically on ISO (yyyy-mm-dd); no donation at all ⇒ ''.
/// Verbatim behaviour of the JS source `supLast`.
dynamic supLast(Map sp) {
  final last = sp['last'];
  dynamic m = _falsy(last) ? '' : last;
  final hist = sp['hist'] ?? const [];
  for (final h in hist as List) {
    final d = (h as Map)['d'];
    if (_jsGt(d, m)) m = d;
  }
  return m;
}

// JS `a > b`: שתי מחרוזות ⇒ לקסיקוגרפי (code-unit); אחרת (d חסר ⇒ undefined,
// או null) ⇒ false — כמו ב-JS (NaN/0>0). התחום המחויב בחוזה: מחרוזות-ISO.
bool _jsGt(dynamic a, dynamic b) {
  if (a is String && b is String) return a.compareTo(b) > 0;
  return false;
}

// JS falsy: undefined/null (⇒ null ב-Dart) · '' · 0 · false · NaN.
bool _falsy(dynamic v) =>
    v == null || v == '' || v == 0 || v == false || (v is double && v.isNaN);
