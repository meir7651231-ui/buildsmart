// ⚛️ אטום-Dart (דרגת-חוזה) · progress — מדד-התקדמות של קמפיין-חיוג (החייגן-המונחה).
// מוצא: maor/src/lib/dialer.ts:80-96 · המקור: new/atoms/progress.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core + dart:math ל-max).
//        חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// שקע (חוק-1): requeueOutcomes — השכן REQUEUE_OUTCOMES שהוזרק כפרמטר
//        (=['noanswer','skip']; קיים כאטום requeue-outcomes, החיבור בקופסה).
// קלט: c (Map עם total · queue: List<String> · log: List<Map{id,outcome,at}>)
//        + השקע requeueOutcomes (List).
// פלט: Map{'total','remaining','finalized','counts'} — counts תמיד 6 מפתחות
//        (donated/noanswer/refused/callback/done/skip), גם כשהם 0.
//
// הערות-המרה (מקור→Dart):
//   • `new Set(c.queue)` ⇒ `{...}` (Set-ליטרל) — כפילות בתור נספרת ייחודית.
//   • `pending.size` ⇒ `.length`.
//   • `seen[e.outcome] ??= new Set()` ⇒ `putIfAbsent` (Set פר-תוצאת-חזרה).
//   • `s.has(id)` ⇒ `.contains(id)`; `counts[k]++` ⇒ עדכון-מפורש (Dart אין ++-על-Map).
//   • `Math.max(0, …)` ⇒ `max` מ-dart:math — קיטום finalized ל-0. אין locale/פורמט.
import 'dart:math';

/// Campaign-dialer progress metrics. Verbatim behaviour of the JS source
/// `progress`: counts pending queue ids (unique via a Set), finalized =
/// max(0, total − remaining), and a per-outcome tally where requeue outcomes
/// (injected via [requeueOutcomes]) are counted once per unique id and all
/// other outcomes are counted per log record.
Map<String, dynamic> progress(Map c, List requeueOutcomes) {
  final pending = <dynamic>{...(c['queue'] as List)};
  final int remaining = pending.length;
  final Map<String, int> counts = {
    'donated': 0,
    'noanswer': 0,
    'refused': 0,
    'callback': 0,
    'done': 0,
    'skip': 0,
  };
  final Map<dynamic, Set> seen = {};
  for (final e in (c['log'] as List)) {
    final m = e as Map;
    final outcome = m['outcome'];
    if (requeueOutcomes.contains(outcome)) {
      final s = seen.putIfAbsent(outcome, () => <dynamic>{});
      if (s.contains(m['id'])) continue;
      s.add(m['id']);
    }
    counts[outcome] = (counts[outcome] ?? 0) + 1;
  }
  final num total = c['total'] as num;
  return {
    'total': total,
    'remaining': remaining,
    'finalized': max(0, total - remaining),
    'counts': counts,
  };
}
