# חוזה · `wfAdvanceLabel` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/workflow_engine.dart:164-191`.
(קובץ-המקור אינו נגיש בעץ buildsmart — הטיוטה במחצב היא מקור-האמת, דיבר-2.)

## חתימה
```dart
String wfAdvanceLabel<C>(
  C cfg,
  WfCase a, {
  required String Function(C cfg, WfStage s) wfStageLabel,
})
```

## אחים / שקעים
- `enum WfStage`, `class WfName`, `class WfLog`, `class WfCase` — inline verbatim. נחוץ: `a.stage`, `a.dispatchPushed`.
- **שקע `wfStageLabel`** (חוק-3) — האטום wf_stage_label. חתימת-מקור `(cfg, s)`.
- `OrgConfig` הופשט ל-`C` גנרי (חוק-5): `cfg` מועבר-שקוף ל-`wfStageLabel` בלבד.
- האחים `WfAdvancePlan`/המתכנן שמופיעים בזנב-הטיוטה — הושמטו (אטומים נפרדים).

## פלט / התנהגות (עוגני-שורה)
- `workflow_engine.dart:165-190` — switch על `a.stage` (exhaustive):
  - `intake` (:166-167) ⇒ `'${wfStageLabel(cfg, prep)} ←'`.
  - `prep` (:168-169) ⇒ `'✓ אישור — ${wfStageLabel(cfg, prep)}'`.
  - `ready` (:170-171) ⇒ `'${wfStageLabel(cfg, dispatch)} ←'`.
  - `dispatch` (:172-176) — **2-לחיצות**: `a.dispatchPushed ? '✓ ${wfStageLabel(cfg, done)}' : '📞 דחיפה ללוח'`.
  - `done` (:177-178) ⇒ `''` (אין כפתור).

## דוגמאות מספריות (שקע-בדיקה `wfStageLabel` = ה-fallback הניטרלי: intake=חדש · prep=בהכנה · ready=מוכן · dispatch=מסירה · done=הושלם)
| # | stage | dispatchPushed | ⇒ |
|---|---|---|---|
| 1 | `intake` | — | `'בהכנה ←'` |
| 2 | `prep` | — | `'✓ אישור — בהכנה'` |
| 3 | `ready` | — | `'מסירה ←'` |
| 4 | `dispatch` | `false` | `'📞 דחיפה ללוח'` |
| 5 | `dispatch` | `true` | `'✓ הושלם'` |
| 6 | `done` | — | `''` |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/wf_advance_label_test.dart  ⇒ exit 0 + "OK wfAdvanceLabel: N asserts passed"
```
