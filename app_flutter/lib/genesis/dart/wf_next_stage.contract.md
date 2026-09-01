# חוזה · `wfNextStage` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/workflow_engine.dart:70-135`.
(קובץ-המקור אינו נגיש בעץ buildsmart — הטיוטה במחצב היא מקור-האמת, דיבר-2.)

## חתימה
```dart
enum WfStage { intake, prep, ready, dispatch, done }
WfStage? wfNextStage(WfStage s)
```

## אחים / הכרעות (דיבר-11 — const חסר)
- `enum WfStage` — inline verbatim.
- `kWfStages` — **חסר בטיוטה**. הוטבע כ-`_kWfStages` בסדר `intake·prep·ready·dispatch·done`.
  ההכרעה נשענת על:
  1. זרימת-ה-workflow ב-`wfAdvanceLabel` (טיוטת-האחות): intake⇒prep · ready⇒dispatch · dispatch⇒done.
  2. סדר-ה-case העקבי בכל טיוטות ה-wf (wfStageKey/wfStageFromKey/wfActionVisible).
- השקע-המועמד `wfStageIndex(s) = kWfStages.indexOf(s)` — הוטבע inline (`_kWfStages.indexOf(s)`, indexOf של dart:core).

## קלט
- `s` — `WfStage`.

## פלט / התנהגות (עוגני-שורה)
- `workflow_engine.dart` — `final i = wfStageIndex(s); return i < kWfStages.length - 1 ? kWfStages[i + 1] : null;`
  - כל שלב שאינו האחרון ⇒ השלב הבא ברצף.
  - השלב האחרון (`done`, אינדקס 4 = length-1) ⇒ `null`.
- הערה: `indexOf` מחזיר -1 עבור ערך-חוץ; מאחר שכל `WfStage.values` ⊆ `_kWfStages`, לא ייתכן -1 כאן.

## דוגמאות מספריות (`_kWfStages` באורך 5)
| # | s | i | ⇒ |
|---|---|---|---|
| 1 | `WfStage.intake` | 0 | `WfStage.prep` |
| 2 | `WfStage.prep` | 1 | `WfStage.ready` |
| 3 | `WfStage.ready` | 2 | `WfStage.dispatch` |
| 4 | `WfStage.dispatch` | 3 | `WfStage.done` |
| 5 | `WfStage.done` | 4 | `null` (4 < 4 שקר) |

## שקעים
- אין. אטום סגור (dart:core בלבד).

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/wf_next_stage_test.dart  ⇒ exit 0 + "OK wfNextStage: N asserts passed"
```
