// ⚛️ אטום-Dart (דרגת-חוזה) · wfStageKey
// מוצא: buildsmart/app_flutter/lib/logic/workflow_engine.dart:34-41 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
// אח-שהוטבע: enum `WfStage` (חמשת השלבים) — הוטבע inline verbatim (דיבר-1: טיפוס-שכן ⇒ inline).
//   ⚠️ סדר-האיברים הוסק מסדר-ה-case בטיוטה (intake·prep·ready·dispatch·done) — עקבי בכל
//   טיוטות ה-wf. הסדר אינו טעון-משמעות ל-wfStageKey (מיפוי 1:1), אך שומר-מקור לשאר האטומים.
//
// קלט:  s — שלב-workflow (WfStage).
// פלט:  מפתח-המחרוזת הקבוע פר-שלב (intake/prep/ready/dispatch/done). מיפוי כולל (exhaustive).

/// חמשת שלבי ה-workflow. סדר הוסק מסדר-ה-case בטיוטה (verbatim).
enum WfStage { intake, prep, ready, dispatch, done }

/// מפתח-המחרוזת הקבוע של שלב. verbatim workflow_engine.dart:34-41.
String wfStageKey(WfStage s) => switch (s) {
      WfStage.intake => 'intake',
      WfStage.prep => 'prep',
      WfStage.ready => 'ready',
      WfStage.dispatch => 'dispatch',
      WfStage.done => 'done',
    };
