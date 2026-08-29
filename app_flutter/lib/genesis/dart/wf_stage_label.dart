// ⚛️ אטום-Dart (דרגת-חוזה) · wfStageLabel
// מוצא: buildsmart/app_flutter/lib/logic/workflow_engine.dart:60-69 (חוק-4 — התנהגות זהה, לא-משופרת).
//   (בטיוטה מופיעות לצדו wfFeatureLabel/wfItemLabel/wfUnitLabel/wfStageIndex — אחים נפרדים, הושמטו.)
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
// אחים/שקעים (דיבר-1/3):
//   • enum `WfStage` — inline verbatim.
//   • const `_kStageFallback` (workflow_engine.dart:49-55 בטיוטת wf_stage_from_key) — הוטבע inline verbatim.
//   • שקע `termOf` — קריאה-לשכן ⇒ פרמטר-שקע named-required (חוק-3). חתימת-המקור: (cfg, key, fallback).
//   • שקע `wfStageKey` — קריאה-לאטום-שכן ⇒ פרמטר-שקע named-required (חוק-3).
//   • טיפוס-הקונפיג `OrgConfig` הופשט לפרמטר-טיפוס-גנרי `C` (אטום אינו נושא ידע-הקשר; חוק-5)
//     — cfg מועבר-שקוף ל-termOf בלבד, אין תלות במבנהו.
//
// קלט:  cfg — קונפיג-הארגון (גנרי C, שקוף); s — שלב (WfStage).
//       termOf — שקע פענוח-מונח; wfStageKey — שקע מפתח-שלב.
// פלט:  התווית המפוענחת של השלב (מונח-ארגון אם קיים, אחרת ה-fallback הניטרלי).

/// חמשת שלבי ה-workflow. סדר הוסק מסדר-ה-case בטיוטה (verbatim).
enum WfStage { intake, prep, ready, dispatch, done }

/// תוויות-נופלות ניטרליות פר-שלב. verbatim workflow_engine.dart (‏_kStageFallback).
const Map<WfStage, String> _kStageFallback = {
  WfStage.intake: 'חדש',
  WfStage.prep: 'בהכנה',
  WfStage.ready: 'מוכן',
  WfStage.dispatch: 'מסירה',
  WfStage.done: 'הושלם',
};

/// תווית-שלב ניתנת-לשם. verbatim workflow_engine.dart:60-69 (השכנים כשקעים).
String wfStageLabel<C>(
  C cfg,
  WfStage s, {
  required String Function(C cfg, String key, String fallback) termOf,
  required String Function(WfStage s) wfStageKey,
}) =>
    termOf(cfg, 'workflow.stage.${wfStageKey(s)}', _kStageFallback[s]!);
