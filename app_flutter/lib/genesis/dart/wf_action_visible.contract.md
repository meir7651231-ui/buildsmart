# חוזה · `wfActionVisible` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/workflow_engine.dart:149-163`.
(קובץ-המקור אינו נגיש בעץ buildsmart — הטיוטה במחצב היא מקור-האמת, דיבר-2.)

## חתימה
```dart
bool wfActionVisible(WfCase a)
```

## אחים-שהוטבעו inline verbatim (דיבר-1)
- `enum WfStage`, `class WfName`, `class WfLog`, `class WfCase` — verbatim (workflow_engine.dart:70-135).
- נחוץ: `a.stage`, `a.names`, `WfName.units`.

## קלט
- `a` — `WfCase`.

## פלט / התנהגות (עוגני-שורה)
- `workflow_engine.dart:150-162` — switch על `a.stage` (exhaustive):
  - `done` (:151-152) ⇒ `false` (אין קידום מהסוף).
  - `intake` (:153-154) ⇒ `a.names.isNotEmpty` (גלוי רק אם יש שמות).
  - `ready` (:155-156) ⇒ `a.names.any((n) => n.units != null)` (גלוי רק אם לפחות שם אחד עם כמות).
  - `prep` + `dispatch` (:157-159) ⇒ `true` (תמיד גלוי).

## דוגמאות מספריות
| # | stage | names | ⇒ |
|---|---|---|---|
| 1 | `done` | כלשהו | `false` |
| 2 | `intake` | `[]` | `false` |
| 3 | `intake` | `[WfName(...)]` | `true` |
| 4 | `ready` | `[]` | `false` |
| 5 | `ready` | `[units:null]` | `false` (אין any עם units) |
| 6 | `ready` | `[units:null, units:3]` | `true` |
| 7 | `prep` | `[]` | `true` |
| 8 | `dispatch` | `[]` | `true` |

## שקעים
- אין. אטום סגור (dart:core בלבד).

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/wf_action_visible_test.dart  ⇒ exit 0 + "OK wfActionVisible: N asserts passed"
```
