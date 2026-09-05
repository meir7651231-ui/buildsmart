// ⚛️ אטום-Dart · wfStageIndex
// מוצא: buildsmart/app_flutter/lib/logic/workflow_engine.dart:68-69 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: הפרמטר `WfStage` (enum מ-workflow_engine.dart:22) הוטבע verbatim;
//        הקבוע `kWfStages` (workflow_engine.dart:24-30) הוטבע verbatim.
//        הפונקציה נוגעת רק ב-`indexOf` על הרשימה.

/// שלב-הזרימה — verbatim (workflow_engine.dart:22).
enum WfStage { intake, prep, ready, dispatch, done }

/// סדר-השלבים הקנוני — verbatim (workflow_engine.dart:24-30).
const List<WfStage> kWfStages = [
  WfStage.intake,
  WfStage.prep,
  WfStage.ready,
  WfStage.dispatch,
  WfStage.done,
];

/// האינדקס של שלב בסדר-הקנוני. PURE.
int wfStageIndex(WfStage s) => kWfStages.indexOf(s);
