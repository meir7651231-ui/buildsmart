// ⚛️ אטום-Dart (דרגת-חוזה) · wfAdvanceLabel
// מוצא: buildsmart/app_flutter/lib/logic/workflow_engine.dart:164-191 (חוק-4 — התנהגות זהה, לא-משופרת).
//   (בטיוטה מופיעים אחריו class `WfAdvancePlan` והמתכנן `plan/wfAdvance` — אחים נפרדים, הושמטו.)
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
// אחים/שקעים (דיבר-1/3):
//   • enum `WfStage`, מחלקות `WfName`/`WfLog`/`WfCase` — inline verbatim (נחוץ: `stage`, `dispatchPushed`).
//   • שקע `wfStageLabel` — קריאה-לאטום-שכן ⇒ פרמטר-שקע named-required (חוק-3). חתימת-מקור (cfg, s).
//   • `OrgConfig` הופשט ל-`C` גנרי (חוק-5) — cfg מועבר-שקוף ל-wfStageLabel בלבד.
//
// קלט:  cfg — קונפיג-הארגון (גנרי C, שקוף); a — מקרה (WfCase); wfStageLabel — שקע-תווית-שלב.
// פלט:  תווית-כפתור-הקידום פר-שלב. שלב dispatch הוא 2-לחיצות (ראה חוזה). done ⇒ '' (אין כפתור).

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

/// מקרה-workflow יחיד — immutable. verbatim (נחוץ: stage, dispatchPushed).
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

/// תווית-כפתור-הקידום פר-שלב. verbatim workflow_engine.dart:164-191 (השכן כשקע).
String wfAdvanceLabel<C>(
  C cfg,
  WfCase a, {required String Function(String) term, 
  required String Function(C cfg, WfStage s) wfStageLabel,
}) {
  switch (a.stage) {
    case WfStage.intake:
      return '${wfStageLabel(cfg, WfStage.prep)} ←';
    case WfStage.prep:
      return '${term('xi_ayshvr')}${wfStageLabel(cfg, WfStage.prep)}';
    case WfStage.ready:
      return '${wfStageLabel(cfg, WfStage.dispatch)} ←';
    case WfStage.dispatch:
      return a.dispatchPushed
          ? '✓ ${wfStageLabel(cfg, WfStage.done)}'
          : term('dchyph-llvch');
    case WfStage.done:
      return '';
  }
}
