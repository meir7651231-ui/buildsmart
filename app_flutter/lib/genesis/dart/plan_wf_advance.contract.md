# חוזה · `planWfAdvance` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/workflow_engine.dart:192-233`
(commit `a59365dc` — הקובץ אינו על main של buildsmart; חולץ מההיסטוריה, זהה-בייטים לטיוטה).

## חתימה
```dart
WfAdvancePlan? planWfAdvance<C>(
  C cfg,
  String name,
  WfCase a, {
  required bool Function(WfCase) actionVisible,
  required String Function(C) featureLabel,
  required String Function(C) itemLabel,
  required String Function(C) unitLabel,
  required String Function(C, WfStage) stageLabel,
  required int Function(WfCase) unitsTotal,
})
```

## אחים / שקעים (דיבר-1/3, חוק-3 — חוט לא מייבא חוט)
- `enum WfStage` (:22) · `class WfName` (:76-82) · `class WfLog` (:84-89) ·
  `class WfCase` **כולל `copyWith`** (:92-133, המתכנן קורא לו :200/:206/:213/:220/:226) —
  inline verbatim.
- `class WfAdvancePlan` (:182-187) — טיפוס-הפלט של האטום; מוטבע verbatim (record
  `({String title, bool done})?` לאירוע-הלוח).
- **שקעים** — כל קריאת-שכן הפכה לפרמטר-שקע named-required:
  `actionVisible` = wf_action_visible (:193) · `featureLabel` = wfFeatureLabel (:194) ·
  `itemLabel` = wfItemLabel (:195) · `unitLabel` = wfUnitLabel (:196) ·
  `stageLabel` = wf_stage_label (:201 ועוד) · `unitsTotal` = wf_units_total (:211).
- `OrgConfig` הופשט ל-`C` גנרי (חוק-5) — `cfg` מועבר-שקוף לשקעי-התוויות בלבד.
- הזנב בטיוטה (`wfRevertPatch`/`wfNormName`/`planAddName`/`wfDailyRows`) — אחים
  נפרדים, הושמטו (wf_daily_rows כבר מקודם; השאר בטיוטות-אחיות).

## פלט / התנהגות (עוגני-שורה — workflow_engine.dart)
- `:193` — `!actionVisible(a)` ⇒ `null` (ה-guard ראשון, לפני הכול).
- switch על `a.stage` (exhaustive):
  - `intake` (:198-203) ⇒ patch: stage→prep · event: `'$feat: ${stageLabel(prep)} — $name (${a.names.length} $item)'`, done=false · toast: `'נרשמו ${a.names.length} — נכנס ללוח: ${stageLabel(prep)}'`.
  - `prep` (:204-209) ⇒ patch: stage→ready · event: `'$feat: ${stageLabel(prep)} ✓ — $name'`, done=**true** · toast: `'אושר — עכשיו: ${stageLabel(ready)}'`.
  - `ready` (:210-216) ⇒ patch: stage→dispatch · event: `'$feat: ${stageLabel(dispatch)} — $name ($units $unit)'` כש-`units = unitsTotal(a)`, done=false · toast: `'נרשם — נכנס ללוח: ${stageLabel(dispatch)}'`.
  - `dispatch` (:217-229) — **2-לחיצות**:
    - `!a.dispatchPushed` (:218-224) ⇒ patch: `dispatchPushed→true` (**stage נשאר dispatch**) · event: `'$feat: ${stageLabel(dispatch)} — $name'`, done=false · toast: `'נמסר — נרשם בלוח היומי'`.
    - כבר-נדחף (:225-229) ⇒ patch: stage→done · event: `'$feat: ${stageLabel(done)} — $name'`, done=**true** · toast: `'הטיפול הושלם ✓'`.
  - `done` (:230-231) ⇒ `null`.
- ה-patch נבנה ב-`copyWith` ⇒ כל שאר שדות-המקרה (note/nextTouch/names/log…) נשמרים כמו-שהם.

## דוגמאות מספריות (שקעי-בדיקה = ה-fallbacks הניטרליים של המקור: feat='מעקב טיפול' (:64) · item='פריט' (:65) · unit='כמות' (:66) · שלבים חדש/בהכנה/מוכן/מסירה/הושלם (:52-58); actionVisible = ה-guard המקורי :149-161; unitsTotal = fold על units :136-137; name='דוד')
| # | stage | מקרה | ⇒ patch | ⇒ event(title, done) | ⇒ toast |
|---|---|---|---|---|---|
| 1 | `intake` | names ריק | — | — | `null` (‏guard: intake דורש names) |
| 2 | `intake` | 2 שמות | stage=prep | `'מעקב טיפול: בהכנה — דוד (2 פריט)'`, false | `'נרשמו 2 — נכנס ללוח: בהכנה'` |
| 3 | `prep` | — | stage=ready | `'מעקב טיפול: בהכנה ✓ — דוד'`, true | `'אושר — עכשיו: מוכן'` |
| 4 | `ready` | units 3+4 | stage=dispatch | `'מעקב טיפול: מסירה — דוד (7 כמות)'`, false | `'נרשם — נכנס ללוח: מסירה'` |
| 5 | `ready` | אף שם בלי units | — | — | `null` (‏guard: ready דורש units כלשהו) |
| 6 | `dispatch` | pushed=false | dispatchPushed=true, stage=dispatch | `'מעקב טיפול: מסירה — דוד'`, false | `'נמסר — נרשם בלוח היומי'` |
| 7 | `dispatch` | pushed=true | stage=done | `'מעקב טיפול: הושלם — דוד'`, true | `'הטיפול הושלם ✓'` |
| 8 | `done` | — | — | — | `null` (:230-231) |
| 9 | קצה: patch משמר שדות | prep, note='הערה', nextTouch='2026-08-28' | note/nextTouch ללא-שינוי | — | — |
| 10 | קצה: השקע מכריע | prep, אך actionVisible⇒false | — | — | `null` (‏:193 קודם ל-switch) |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/plan_wf_advance_test.dart  ⇒ exit 0 + "OK planWfAdvance: N asserts passed"
```
