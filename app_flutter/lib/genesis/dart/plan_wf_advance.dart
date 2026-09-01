// ⚛️ אטום-Dart (דרגת-חוזה) · planWfAdvance
// מוצא: buildsmart/app_flutter/lib/logic/workflow_engine.dart:192-233 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
// אחים-שהוטבעו inline verbatim (דיבר-1): enum `WfStage`, מחלקות `WfName`/`WfLog`/`WfCase`
//   (כולל `copyWith` — המתכנן בונה בו את ה-patch) + `WfAdvancePlan` (טיפוס-הפלט, :182-187).
// שקעים (חוק-3 — כל קריאת-שכן ⇒ פרמטר named-required):
//   • `actionVisible` — ה-guard (wf_action_visible, מקור :193).
//   • `featureLabel`/`itemLabel`/`unitLabel` — תוויות-termOf (מקור :194-196).
//   • `stageLabel` — תווית-שלב (wf_stage_label, מקור :201 ועוד).
//   • `unitsTotal` — סך-יחידות-המקרה (wf_units_total, מקור :211).
// `OrgConfig` הופשט ל-`C` גנרי (חוק-5) — cfg מועבר-שקוף לשקעי-התוויות בלבד.
//
// קלט:  cfg (גנרי C) · name — שם-הישות לכותרות · a — המקרה (WfCase) · 6 שקעים.
// פלט:  WfAdvancePlan(patch, event, toast) — או null כשהפעולה לא-גלויה / done.
//        שלב dispatch הוא 2-לחיצות: לחיצה-1 מדליקה dispatchPushed ונשארת ב-dispatch;
//        לחיצה-2 מקדמת ל-done.

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

/// מקרה-workflow יחיד — immutable; `copyWith` לשינויים. verbatim (:92-133).
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

  WfCase copyWith({
    WfStage? stage,
    String? note,
    bool? dispatchPushed,
    String? nextTouch,
    String? nextTouchTime,
    String? lastTouch,
    List<WfName>? names,
    List<WfLog>? log,
  }) =>
      WfCase(
        stage: stage ?? this.stage,
        note: note ?? this.note,
        dispatchPushed: dispatchPushed ?? this.dispatchPushed,
        nextTouch: nextTouch ?? this.nextTouch,
        nextTouchTime: nextTouchTime ?? this.nextTouchTime,
        lastTouch: lastTouch ?? this.lastTouch,
        names: names ?? this.names,
        log: log ?? this.log,
      );
}

/// תוצאת-תכנון-מעבר: patch + אירוע-לוח אופציונלי + toast. verbatim (:182-187).
class WfAdvancePlan {
  const WfAdvancePlan({required this.patch, required this.event, required this.toast});
  final WfCase patch; // מוחל דרך copyWith על המקרה החי
  final ({String title, bool done})? event;
  final String toast;
}

/// מתכנן-המעבר הטהור. מחזיר null כשהפעולה לא-גלויה. verbatim workflow_engine.dart:192-233
/// (השכנים כשקעים; ההתנהגות זהה כשמזריקים את אטומי-המקור).
WfAdvancePlan? planWfAdvance<C>(
  C cfg,
  String name,
  WfCase a, {required String Function(String) term, 
  required bool Function(WfCase) actionVisible,
  required String Function(C) featureLabel,
  required String Function(C) itemLabel,
  required String Function(C) unitLabel,
  required String Function(C, WfStage) stageLabel,
  required int Function(WfCase) unitsTotal,
}) {
  if (!actionVisible(a)) return null;
  final feat = featureLabel(cfg);
  final item = itemLabel(cfg);
  final unit = unitLabel(cfg);
  switch (a.stage) {
    case WfStage.intake:
      return WfAdvancePlan(
        patch: a.copyWith(stage: WfStage.prep),
        event: (title: '$feat: ${stageLabel(cfg, WfStage.prep)} — $name (${a.names.length} $item)', done: false),
        toast: '${term('xi_nrshmv')}${a.names.length}${term('xi_nkns-llvch')}${stageLabel(cfg, WfStage.prep)}',
      );
    case WfStage.prep:
      return WfAdvancePlan(
        patch: a.copyWith(stage: WfStage.ready),
        event: (title: '$feat: ${stageLabel(cfg, WfStage.prep)} ✓ — $name', done: true),
        toast: '${term('xi_avshr-akshyv')}${stageLabel(cfg, WfStage.ready)}',
      );
    case WfStage.ready:
      final units = unitsTotal(a);
      return WfAdvancePlan(
        patch: a.copyWith(stage: WfStage.dispatch),
        event: (title: '$feat: ${stageLabel(cfg, WfStage.dispatch)} — $name ($units $unit)', done: false),
        toast: '${term('xi_nrshm-nkns-llvch')}${stageLabel(cfg, WfStage.dispatch)}',
      );
    case WfStage.dispatch:
      if (!a.dispatchPushed) {
        return WfAdvancePlan(
          patch: a.copyWith(dispatchPushed: true),
          event: (title: '$feat: ${stageLabel(cfg, WfStage.dispatch)} — $name', done: false),
          toast: term('nmsr-nrshm-blvch-hyvmy'),
        );
      }
      return WfAdvancePlan(
        patch: a.copyWith(stage: WfStage.done),
        event: (title: '$feat: ${stageLabel(cfg, WfStage.done)} — $name', done: true),
        toast: term('htypvl-hvshlm'),
      );
    case WfStage.done:
      return null;
  }
}
