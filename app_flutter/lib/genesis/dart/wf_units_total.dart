// ⚛️ אטום-Dart (דרגת-חוזה) · wfUnitsTotal
// מוצא: buildsmart/app_flutter/lib/logic/workflow_engine.dart:136-139 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
// אחים-שהוטבעו inline verbatim (דיבר-1: טיפוס-שכן-קטן):
//   enum `WfStage`, מחלקות `WfName`/`WfLog`/`WfCase` — הועתקו verbatim מהטיוטה (workflow_engine.dart:70-135).
//   נחוץ לאטום זה: `WfCase.names` (List<WfName>) ו-`WfName.units` (int?).
// השקע-המועמד `fold` — Iterable.fold של dart:core (לא-שקע).
//
// קלט:  a — מקרה-workflow (WfCase).
// פלט:  סכום `units` של כל השמות; `units==null` נספר כ-0.

/// חמשת שלבי ה-workflow. סדר הוסק מסדר-ה-case בטיוטה (verbatim).
enum WfStage { intake, prep, ready, dispatch, done }

/// פריט-שורה במקרה-workflow (dedup לפי שם-מנורמל; כמות אופציונלית). verbatim.
class WfName {
  const WfName({required this.id, required this.name, this.units, this.done = false});
  final String id;
  final String name;
  final int? units; // null = לא-נספר
  final bool done;
}

/// רשומת-לוג במקרה. verbatim.
class WfLog {
  const WfLog({required this.date, required this.units, this.name});
  final String date;
  final int units;
  final String? name;
}

/// מקרה-workflow יחיד — immutable. verbatim (כאן נחוץ רק `names`).
class WfCase {
  const WfCase({
    this.stage = WfStage.intake,
    this.note = '',
    this.dispatchPushed = false,
    this.nextTouch = '',
    this.nextTouchTime = '',
    this.lastTouch = '',
    this.names = const [],
    this.log = const [],
  });

  final WfStage stage;
  final String note;
  final bool dispatchPushed;
  final String nextTouch;
  final String nextTouchTime;
  final String lastTouch;
  final List<WfName> names;
  final List<WfLog> log;
}

/// כמות מצטברת של כל השמות. verbatim workflow_engine.dart:136-139.
int wfUnitsTotal(WfCase a) => a.names.fold(0, (t, x) => t + (x.units ?? 0));
