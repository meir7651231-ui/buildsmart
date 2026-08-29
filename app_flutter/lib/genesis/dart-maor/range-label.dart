// ⚛️ אטום-Dart (דרגת-חוזה) · rangeLabel
// מוצא: maor · new/atoms/range-label.mjs (חוק-4 — התנהגות זהה-לחלוטין למקור-ה-JS, לא-משופרת).
//        המקור: maor/src/components/reports/lib.ts:32-38 (תווית טווח-תאריכים במסך הדוחות).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). השכן fmtDate מוזרק כשקע
//        (חוק-1/3 — חוט לא מייבא שכן; קריאה-לשכן ⇒ פרמטר-שקע).
//
// תיקוני-פורט מול טיוטת-המנוע (התנהגות משומרת ביט-אחר-ביט):
//   • גישת-שדות — המנוע פלט `r.from`/`r.to` על `dynamic`; ב-Dart על אובייקט-JS (Map)
//                 זו גישת-מפתח ⇒ `r['from']`/`r['to']`. הטיפוס הופך מפורש (Map).
//   • truthiness — המנוע פלט `_falsy(...)` (לא-מוגדר) ובהמשך `r.from && r.to` / `r.from ?`.
//                 ב-JS from/to הם מחרוזת; falsy = null/חסר או '' (מחרוזת-ריקה).
//                 ⇒ שקע-פנימי `_truthy` מפורש (כלל-פורט 7): לא-null ולא-ריק.
//   • שקע-הפורמט — fmtDate נשאר שקע חובה (String ⇒ String); הבדיקה מזריקה את התנהגות-המקור
//                 (ISO ⇒ dd/mm/yyyy) ומאמתת סדר/מספר הקריאות (עדות-שקע).
//
// קלט:  r ({from?, to?} — מחרוזות ISO או ריק/חסר) · fmtDate — שקע חובה: מחרוזת ⇒ מחרוזת.
// פלט:  תווית עברית: 'כל התאריכים' / '<from> – <to>' / 'מ-<from>' / 'עד <to>'.

bool _truthy(Object? v) => v != null && v != '';

/// תווית עברית לטווח-תאריכים {from,to} במסך הדוחות. fmtDate מעצב כל גבול.
String rangeLabel(Map r, String Function(String) fmtDate) {
  final from = r['from'];
  final to = r['to'];
  if (!_truthy(from) && !_truthy(to)) return 'כל התאריכים';
  if (_truthy(from) && _truthy(to)) return '${fmtDate(from as String)} – ${fmtDate(to as String)}';
  return _truthy(from) ? 'מ-' + fmtDate(from as String) : 'עד ' + fmtDate(to as String);
}
