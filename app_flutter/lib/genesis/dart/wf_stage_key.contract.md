# חוזה · `wfStageKey` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/workflow_engine.dart:34-41`.
(קובץ-המקור אינו נגיש בעץ buildsmart — הטיוטה במחצב היא מקור-האמת, דיבר-2.)

## חתימה
```dart
enum WfStage { intake, prep, ready, dispatch, done }
String wfStageKey(WfStage s)
```

## אח-שהוטבע
- `enum WfStage` — הוטבע inline verbatim (דיבר-1). סדר-האיברים `intake·prep·ready·dispatch·done`
  הוסק מסדר-ה-case בטיוטה (עוגן: workflow_engine.dart:34-41; עקבי בכל טיוטות ה-wf).
  ל-wfStageKey הסדר אינו טעון-משמעות (מיפוי 1:1).

## קלט
- `s` — `WfStage`, אחד מחמשת השלבים.

## פלט / התנהגות (עוגני-שורה)
- `workflow_engine.dart:35-39` — מיפוי כולל 1:1:
  - `WfStage.intake` ⇒ `'intake'`
  - `WfStage.prep` ⇒ `'prep'`
  - `WfStage.ready` ⇒ `'ready'`
  - `WfStage.dispatch` ⇒ `'dispatch'`
  - `WfStage.done` ⇒ `'done'`
- switch-expression exhaustive ⇒ אין ענף-ברירת-מחדל; כל שלב מכוסה.

## דוגמאות מספריות
| # | s | ⇒ |
|---|---|---|
| 1 | `WfStage.intake` | `'intake'` |
| 2 | `WfStage.prep` | `'prep'` |
| 3 | `WfStage.ready` | `'ready'` |
| 4 | `WfStage.dispatch` | `'dispatch'` |
| 5 | `WfStage.done` | `'done'` |

## שקעים
- אין. אטום סגור (dart:core בלבד).

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/wf_stage_key_test.dart  ⇒ exit 0 + "OK wfStageKey: N asserts passed"
```
