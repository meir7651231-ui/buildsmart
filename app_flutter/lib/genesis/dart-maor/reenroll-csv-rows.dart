// ⚛️ אטום-Dart (דרגת-חוזה) · reenrollCsvRows — שורות-CSV לרשימת-הרישום-מחדש.
// מוצא: maor/src/components/courses/reenroll-lib.ts:319-337 · המקור: new/atoms/reenroll-csv-rows.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: בונה מטריצת-CSV (שורת-כותרת + שורה פר-רישום) לייצוא רשימת רישום-לשנה-הבאה.
//        טהור-מלא — בלי שקעים.
// קלט: rows — List של Map {memberName, familyName, courseName,
//        summary{presents,absences,balance,statusLabel}, decision, renewed, e{renewNote}}.
// פלט: List<List<String>> — [כותרת, ...שורות].
//
// הערות-המרה (מקור→Dart):
//  · אובייקטי-JS ⇒ Map<String,Object?>; גישת-שדה .x ⇒ ['x']; מקונן summary/e דרך cast.
//  · `String(r.summary.presents)` — presents/absences/balance הם num; num.toString()
//    מחזיר '12'/'-80' זהה ל-JS `String(...)`. (אין locale — אפס RTL-mark; כלל-6.)
//  · `r.renewed ? 'כן' : ''` — truthiness של JS ⇒ _truthy מפורש (לא רק bool).
//  · `r.e.renewNote ?? ''` — שדה-חסר ב-JS = undefined ⇒ ''; גישת-Map ב-Dart מחזירה null
//    למפתח-חסר ⇒ ?? '' זהה. (null==undefined כאן, כי הקלט לעולם לא null-מפורש בחוזה.)
//  · decWord: השוואת-מחרוזת ישירה; decision-חסר ⇒ null ≠ 'yes'/'no'/'hold' ⇒ '' (כמו JS).

bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !v.isNaN;
  return true;
}

String _decWord(Object? d, Map<String, String> T) => d == T['k1']
    ? T['k2']!
    : d == 'no'
        ? T['k3']!
        : d == T['k4']
            ? T['k5']!
            : '';

/// Builds the CSV matrix (header row + one row per enrollment) for the
/// "re-enroll for next year" export. Verbatim behaviour of the JS source
/// `reenrollCsvRows`. שקעים: head (שורת-הכותרת) + T (מילון-ההחלטות) — הכרעה 16.
List<List<String>> reenrollCsvRows(List<Map<String, Object?>> rows, List<String> head, Map<String, String> T) {
  final out = <List<String>>[head];
  for (final r in rows) {
    final summary = (r['summary'] as Map<String, Object?>?) ?? const {};
    final e = (r['e'] as Map<String, Object?>?) ?? const {};
    out.add(<String>[
      (r['memberName'] ?? '') as String,
      (r['familyName'] ?? '') as String,
      (r['courseName'] ?? '') as String,
      '${summary['presents']}',
      '${summary['absences']}',
      '${summary['balance']}',
      (summary['statusLabel'] ?? '') as String,
      _decWord(r['decision'], T),
      _truthy(r['renewed']) ? T['k6']! : '',
      (e['renewNote'] ?? '') as String,
    ]);
  }
  return out;
}
