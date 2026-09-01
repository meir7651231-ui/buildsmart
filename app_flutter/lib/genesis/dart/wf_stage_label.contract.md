# חוזה · `wfStageLabel` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/workflow_engine.dart:60-69`.
(קובץ-המקור אינו נגיש בעץ buildsmart — הטיוטה במחצב היא מקור-האמת, דיבר-2.)

## חתימה
```dart
String wfStageLabel<C>(
  C cfg,
  WfStage s, {
  required String Function(C cfg, String key, String fallback) termOf,
  required String Function(WfStage s) wfStageKey,
})
```

## אחים / שקעים
- `enum WfStage` — inline verbatim.
- `_kStageFallback` — const מיפוי-נפילה inline verbatim: `{intake:'חדש', prep:'בהכנה', ready:'מוכן', dispatch:'מסירה', done:'הושלם'}`.
- **שקע `termOf`** (חוק-3) — פענוח-מונח, חתימת-מקור `(cfg, key, fallback)`.
- **שקע `wfStageKey`** (חוק-3) — מפתח-שלב (האטום wf_stage_key).
- `OrgConfig` הופשט ל-`C` גנרי (חוק-5): `cfg` מועבר-שקוף ל-`termOf` בלבד.

## פלט / התנהגות (עוגני-שורה)
- `workflow_engine.dart:61-62` — `termOf(cfg, 'workflow.stage.${wfStageKey(s)}', _kStageFallback[s]!)`:
  - המפתח שנבנה: `'workflow.stage.'` + `wfStageKey(s)` (למשל `'workflow.stage.intake'`).
  - ה-fallback: הערך הניטרלי מ-`_kStageFallback` פר-שלב.
  - התוצאה = מה ש-`termOf` מחזיר (מונח-ארגון אם הוגדר, אחרת ה-fallback).

## דוגמאות מספריות (שקע-בדיקה `termOf` שמחזיר `'K:<key>|F:<fallback>'`; `wfStageKey` אמיתי)
| # | s | key שנבנה | fallback | ⇒ |
|---|---|---|---|---|
| 1 | `intake` | `workflow.stage.intake` | `חדש` | `'K:workflow.stage.intake|F:חדש'` |
| 2 | `prep` | `workflow.stage.prep` | `בהכנה` | `'K:workflow.stage.prep|F:בהכנה'` |
| 3 | `dispatch` | `workflow.stage.dispatch` | `מסירה` | `'K:workflow.stage.dispatch|F:מסירה'` |

## דוגמאות-שקע נוספות
| # | התנהגות termOf | s | ⇒ |
|---|---|---|---|
| 4 | תמיד fallback | `ready` | `'מוכן'` |
| 5 | תמיד fallback | `done` | `'הושלם'` |
| 6 | מונח-ארגון קבוע `'X'` | `intake` | `'X'` |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/wf_stage_label_test.dart  ⇒ exit 0 + "OK wfStageLabel: N asserts passed"
```
