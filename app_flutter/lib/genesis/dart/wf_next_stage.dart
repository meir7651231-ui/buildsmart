// ⚛️ אטום-Dart (דרגת-חוזה) · wfNextStage
// מוצא: buildsmart/app_flutter/lib/logic/workflow_engine.dart:70-135 (חוק-4 — התנהגות זהה, לא-משופרת).
//   (בטיוטה מופיע לצד מחלקות WfName/WfLog/WfCase; אלו שייכות לאטומי-wf אחרים ואינן נחוצות כאן — הושמטו.)
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
// אחים-שהוטבעו/סוקקו (דיבר-1/3):
//   • enum `WfStage` — inline verbatim.
//   • const `kWfStages` — הוטבע inline כ-`_kWfStages`. **סדר הוסק** (הכרעה מתועדת מטה).
//   • השקע-המועמד `wfStageIndex(s)` = `kWfStages.indexOf(s)` — הוטבע inline (indexOf של dart:core), לא-שקע.
//
// ⚠️ הכרעת-סדר (const-חסר, דיבר-11): `kWfStages` אינו בטיוטה. הסדר הוסק מזרימת-ה-workflow
//   המתועדת בטיוטות-האחות: intake→prep→ready→dispatch→done (wfAdvanceLabel: intake⇒prep,
//   ready⇒dispatch, dispatch⇒done). זהו גם סדר-ה-case העקבי בכל טיוטות ה-wf.
//
// קלט:  s — שלב-workflow (WfStage).
// פלט:  השלב הבא ברצף, או null אם s הוא השלב האחרון (done).

/// חמשת שלבי ה-workflow. סדר הוסק מסדר-ה-case בטיוטה (verbatim).
enum WfStage { intake, prep, ready, dispatch, done }

/// רצף-השלבים הקנוני. סדר הוסק מזרימת-ה-workflow (ראה כותרת).
const List<WfStage> _kWfStages = [
  WfStage.intake,
  WfStage.prep,
  WfStage.ready,
  WfStage.dispatch,
  WfStage.done,
];

/// השלב הבא ברצף, או null בשלב האחרון. verbatim workflow_engine.dart:70-135.
WfStage? wfNextStage(WfStage s) {
  final i = _kWfStages.indexOf(s);
  return i < _kWfStages.length - 1 ? _kWfStages[i + 1] : null;
}
