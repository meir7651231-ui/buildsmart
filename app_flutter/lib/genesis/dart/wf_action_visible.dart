// ⚛️ אטום-Dart (דרגת-חוזה) · wfActionVisible
// מוצא: buildsmart/app_flutter/lib/logic/workflow_engine.dart:149-163 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
// אחים-שהוטבעו inline verbatim (דיבר-1): enum `WfStage`, מחלקות `WfName`/`WfLog`/`WfCase`
//   (workflow_engine.dart:70-135). נחוץ: `stage`, `names`, `WfName.units`.
//
// קלט:  a — מקרה-workflow (WfCase).
// פלט:  bool — האם כפתור-הקידום גלוי בשלב הנוכחי (ה-guard).

/// חמשת שלבי ה-workflow. סדר הוסק מסדר-ה-case בטיוטה (verbatim).
enum WfStage { intake, prep, ready, dispatch, done }

/// פריט-שורה במקרה-workflow. verbatim.
class WfName {
  const WfName({required this.id, required this.name, this.units, this.done = false});
  final String id;
  final String name;
  final int? units;
  final bool done;
}

/// רשומת-לוג במקרה. verbatim.
class WfLog {
  const WfLog({required this.date, required this.units, this.name});
  final String date;
  final int units;
  final String? name;
}

/// מקרה-workflow יחיד — immutable. verbatim.
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

/// האם כפתור-הקידום גלוי בשלב הנוכחי (ה-guard). verbatim workflow_engine.dart:149-163.
bool wfActionVisible(WfCase a) {
  switch (a.stage) {
    case WfStage.done:
      return false;
    case WfStage.intake:
      return a.names.isNotEmpty;
    case WfStage.ready:
      return a.names.any((n) => n.units != null);
    case WfStage.prep:
    case WfStage.dispatch:
      return true;
  }
}
