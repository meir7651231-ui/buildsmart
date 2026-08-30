// ⚛️ אטום-Dart (דרגת-חוזה) · cockpitCsvRows — שורות-CSV של תור-המשימות (כותרת + שורה למשימה).
// מוצא: maor/src/components/supporters/cockpit.ts:281 + KIND_LABEL:277 (הוטבע inline).
//        המקור-הקדוש: new/atoms/cockpit-csv-rows.mjs. חוק-4 — זהה-ביט למקור-JS.
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
//
// קלט: queue (Map{tasks:List<Map{kind,name,phone,reason}>}). פלט: List<List> (כותרת + שורות).
// הערות-המרה: KIND_LABEL הוטבע inline (Map-literal קבוע); JS spread (...map) ⇒ collection-for.

/// CSV rows for the task queue (header + one row per task).
/// Verbatim port of new/atoms/cockpit-csv-rows.mjs (KIND_LABEL inlined).
List<List> cockpitCsvRows(Map queue, Map<String, String> T) {
  final kindLabel = {'call': T['k1']!, 'thanks': T['k2']!, 'hok': T['k3']!};
  return [
    [T['k4']!, T['k5']!, T['k6']!, T['k7']!],
    for (final tt in (queue['tasks'] as List))
      [
        kindLabel[(tt as Map)['kind']],
        tt['name'],
        tt['phone'],
        tt['reason'],
      ],
  ];
}
