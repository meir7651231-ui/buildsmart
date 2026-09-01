# חוזה · `wfActive` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/workflow_engine.dart:140-148`.
(קובץ-המקור אינו נגיש בעץ buildsmart — הטיוטה במחצב היא מקור-האמת, דיבר-2.)

## חתימה
```dart
bool wfActive(WfCase? a)
```

## אחים-שהוטבעו inline verbatim (דיבר-1)
- `enum WfStage`, `class WfName`, `class WfLog`, `class WfCase` — verbatim (workflow_engine.dart:70-135).
- נחוץ: `a.stage`, `a.names`, `a.lastTouch`, `a.log`.

## קלט
- `a` — `WfCase?` (nullable).

## פלט / התנהגות (עוגני-שורה)
- `workflow_engine.dart:141` — `a == null ⇒ false`.
- `workflow_engine.dart:142-146` — אחרת, `true` אם **לפחות אחד** מהתנאים מתקיים (OR קצר-דרך):
  - `a.stage != WfStage.intake` — לא בשלב-הכניסה, או
  - `a.names.isNotEmpty` — יש שמות, או
  - `a.lastTouch.isNotEmpty` — טופל אי-פעם (מחרוזת לא-ריקה), או
  - `a.log.isNotEmpty` — יש רשומות-לוג.
- ⇒ מקרה בברירת-מחדל (`WfCase()`: intake · שמות-ריק · lastTouch-ריק · log-ריק) הוא **לא-פעיל** (`false`).

## דוגמאות מספריות
| # | a | ⇒ | סיבה |
|---|---|---|---|
| 1 | `null` | `false` | null-guard |
| 2 | `WfCase()` (ברירת-מחדל) | `false` | intake+ריק בכל |
| 3 | `WfCase(stage: WfStage.prep)` | `true` | לא-intake |
| 4 | `WfCase(names: [WfName(...)])` | `true` | יש שם |
| 5 | `WfCase(lastTouch: '2026-08-01')` | `true` | טופל |
| 6 | `WfCase(log: [WfLog(...)])` | `true` | יש לוג |
| 7 | `WfCase(stage: WfStage.done)` | `true` | לא-intake |

## שקעים
- אין. אטום סגור (dart:core בלבד).

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/wf_active_test.dart  ⇒ exit 0 + "OK wfActive: N asserts passed"
```
