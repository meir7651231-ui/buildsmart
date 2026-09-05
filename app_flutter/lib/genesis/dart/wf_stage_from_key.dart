// ⚛️ אטום-Dart (דרגת-חוזה) · wfStageFromKey
// מוצא: buildsmart/app_flutter/lib/logic/workflow_engine.dart:42-59 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
// אח-שהוטבע: enum `WfStage` — הוטבע inline verbatim (דיבר-1).
//   סדר-האיברים הוסק מסדר-ה-case בטיוטה (intake·prep·ready·dispatch·done); אינו טעון-משמעות כאן.
// אח-שסוקק/הושמט: ה-const `_kStageFallback` שמופיע בזנב-הטיוטה שייך ל-wfStageLabel (לא לאטום זה) — הושמט.
//
// קלט:  k — מחרוזת-מפתח (String).
// פלט:  WfStage תואם, או null אם המפתח אינו אחד מחמשת המפתחות (הופכי ל-wfStageKey).

/// חמשת שלבי ה-workflow. סדר הוסק מסדר-ה-case בטיוטה (verbatim).
enum WfStage { intake, prep, ready, dispatch, done }

/// המרת-מפתח→שלב. null עבור מפתח לא-מוכר. verbatim workflow_engine.dart:42-59.
WfStage? wfStageFromKey(String k) => switch (k) {
      'intake' => WfStage.intake,
      'prep' => WfStage.prep,
      'ready' => WfStage.ready,
      'dispatch' => WfStage.dispatch,
      'done' => WfStage.done,
      _ => null,
    };
