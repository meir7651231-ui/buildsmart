# חוזה · `wfUnitsTotal` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/workflow_engine.dart:136-139`.
(קובץ-המקור אינו נגיש בעץ buildsmart — הטיוטה במחצב היא מקור-האמת, דיבר-2.)

## חתימה
```dart
int wfUnitsTotal(WfCase a)
```

## אחים-שהוטבעו inline verbatim (דיבר-1)
- `enum WfStage`, `class WfName`, `class WfLog`, `class WfCase` — הועתקו verbatim (workflow_engine.dart:70-135).
- נחוץ לאטום: `WfCase.names` (`List<WfName>`), `WfName.units` (`int?`).
- `fold` = `Iterable.fold` של dart:core (לא-שקע).

## קלט
- `a` — `WfCase`. רלוונטי: `a.names` (רשימת `WfName`, כ״א עם `units` אופציונלי).

## פלט / התנהגות (עוגני-שורה)
- `workflow_engine.dart:137-138` — `a.names.fold(0, (t, x) => t + (x.units ?? 0))`:
  - סכום `units` על-פני כל השמות.
  - `units == null` (לא-נספר) תורם 0.
  - רשימת-שמות ריקה ⇒ 0 (זרע-ה-fold).

## דוגמאות מספריות
| # | names (units) | ⇒ |
|---|---|---|
| 1 | `[]` (ריק) | `0` |
| 2 | `[3]` | `3` |
| 3 | `[3, 5]` | `8` |
| 4 | `[3, null, 5]` | `8` (null=0) |
| 5 | `[null, null]` | `0` |
| 6 | `[0, 0, 7]` | `7` |

## שקעים
- אין. אטום סגור (dart:core בלבד).

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/wf_units_total_test.dart  ⇒ exit 0 + "OK wfUnitsTotal: N asserts passed"
```
