# אטום · `wfDailyRows`

מוצא: `buildsmart/app_flutter/lib/logic/workflow_engine.dart:266-304`

## חתימה
```dart
List<List<Object>> wfDailyRows(
  OrgConfig cfg,
  List<({String name, String phone, WfCase? wf})> entities,
  String todayIso, {
  required String Function(OrgConfig) unitLabel,
  required String Function(OrgConfig) itemLabel,
  required String Function(OrgConfig, WfStage) stageLabel,
  required int Function(WfCase) unitsTotal,
})
```

## חוזה
דוח "טופל-היום" כמטריצת-שורות (שורה-ראשונה = כותרת).

- **מדלג** ישות בלי `wf`, וישות שלא-נגעו-בה-היום (`lastTouch != today` וגם אין `log` מהיום).
- `unitsToday`: אם יש log-היום → סכום היחידות שלו; אחרת `unitsTotal(a)` (0 ⇒ `''`).
- `namesLine`: כל שם עם `·units` (אם קיים) ו-`✓` (אם `done`), מחוברים ב-` · `.
- כל שורה: `[name, phone, unitsToday, stageLabel, namesLine, nextTouch, note]`.

## שקעים (תלויי-קונפיג)
`unitLabel`/`itemLabel` (תוויות-כותרת) · `stageLabel(cfg, stage)` · `unitsTotal(case)`.

## מוטבע-מינימום
`WfCase`{stage, lastTouch, nextTouch, note, log, names} · `WfLog`{date, units} ·
`WfName`{name, units?, done} · `OrgConfig` (אטום, עובר-לשקעים) · `WfStage` enum.

## טוהר
דטרמיניסטי (היום מוזרק), בלי state/IO.
