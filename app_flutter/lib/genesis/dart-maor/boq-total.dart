// חוט · boq-total — סה"כ כתב-הכמויות של תיק. חוזה: boq-total.contract.md
// המרה מ-JS (new/atoms/boq-total.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// המקור: a.names.reduce((t, n) => t + boqLineAmount(n), 0).
// השכן boqLineAmount מוזרק כשקע (חוק-1 — אפס import פנימי).
// אפס-import (dart-core בלבד). המנוע פספס: dynamic→טיפוסים, reduce+0→fold(0),
// שקע-הפונקציה→פרמטר num Function(Map).
num boqTotal(Map<String, dynamic> a, num Function(Map<String, dynamic>) boqLineAmount) {
  final List names = (a['names'] as List?) ?? const [];
  return names.fold<num>(0, (t, n) => t + boqLineAmount((n as Map).cast<String, dynamic>()));
}
