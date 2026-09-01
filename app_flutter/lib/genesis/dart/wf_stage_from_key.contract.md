# חוזה · `wfStageFromKey` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/workflow_engine.dart:42-59`.
(קובץ-המקור אינו נגיש בעץ buildsmart — הטיוטה במחצב היא מקור-האמת, דיבר-2.)

## חתימה
```dart
enum WfStage { intake, prep, ready, dispatch, done }
WfStage? wfStageFromKey(String k)
```

## אחים
- `enum WfStage` — הוטבע inline verbatim (דיבר-1). סדר לא-טעון-משמעות כאן (מיפוי מפתח→ערך).
- ה-const `_kStageFallback` שמופיע בזנב-הטיוטה שייך ל-`wfStageLabel` (עוגן: הערת-הזנב "תוויות-נופלות") — **הושמט** מאטום זה.

## קלט
- `k` — `String`, מפתח-שלב אפשרי.

## פלט / התנהגות (עוגני-שורה)
- `workflow_engine.dart:43-47` — התאמה מדויקת של המפתח:
  - `'intake'` ⇒ `WfStage.intake`
  - `'prep'` ⇒ `WfStage.prep`
  - `'ready'` ⇒ `WfStage.ready`
  - `'dispatch'` ⇒ `WfStage.dispatch`
  - `'done'` ⇒ `WfStage.done`
- `workflow_engine.dart:48` — `_ => null`: כל מחרוזת אחרת (ריק, אותיות-גדולות, רווח, מפתח-לא-מוכר) ⇒ `null`.
- הופכי מדויק ל-`wfStageKey`: `wfStageFromKey(wfStageKey(s)) == s` לכל `s`.

## דוגמאות מספריות
| # | k | ⇒ |
|---|---|---|
| 1 | `'intake'` | `WfStage.intake` |
| 2 | `'prep'` | `WfStage.prep` |
| 3 | `'ready'` | `WfStage.ready` |
| 4 | `'dispatch'` | `WfStage.dispatch` |
| 5 | `'done'` | `WfStage.done` |

## עדשה-עוינת
| # | k | ⇒ |
|---|---|---|
| 6 | `''` (ריק) | `null` |
| 7 | `'INTAKE'` (אותיות-גדולות) | `null` (התאמה רגישת-רישיות) |
| 8 | `' intake'` (רווח מוביל) | `null` |
| 9 | `'foo'` | `null` |

## שקעים
- אין. אטום סגור (dart:core בלבד).

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/wf_stage_from_key_test.dart  ⇒ exit 0 + "OK wfStageFromKey: N asserts passed"
```
