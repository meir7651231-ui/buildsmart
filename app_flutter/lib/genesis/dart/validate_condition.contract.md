# חוזה · `validateCondition` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/rules_model.dart:344-384`
(‏`_validateCondition`, פרטי-במקור — גולגל). קובץ-המקור נעדר ⇒ הטיוטה היא מקור-האמת.

**אחים-שסוקטו:** `evalRuleAdvisory` / `_triggerMatches` בטיוטה — אטומים נפרדים, לא הועתקו.

## חתימה
```dart
C? validateCondition<F, O, C>(Object? raw, {
  required F? Function(String) matchConditionField,
  required O? Function(String) matchRuleOp,
  required C Function(F field, O op, num value) makeCondition,
})
```

## שקעים (חוק-3)
- `matchConditionField` / `matchRuleOp` — שקעים במקום הפונקציות-השכנות (‏:347/:349).
- `makeCondition` — שקע-מפעל במקום `RuleCondition(field, op, value)` (‏:355).
- `ConditionField`/`RuleOp`/`RuleCondition` ⇒ גנריים `F`/`O`/`C` (מקור נעדר).

## פלט / התנהגות — 4 שערי-כשל (עוגני-שורה)
1. `:345` — `raw is! Map` ⇒ `null`.
2. `:346` — מפתחות ⇒ toString (`Map<String,dynamic>` פנימי).
3. `:347-348` — `matchConditionField((c['field'] ?? '').toString()) == null` ⇒ `null`.
4. `:349-350` — `matchRuleOp((c['op'] ?? '').toString()) == null` ⇒ `null`.
5. `:351-354` — `value`: אם `c['value']` הוא `num` ⇒ כמות-שהוא; אחרת `num.tryParse((value ?? '').toString())`. אם התוצאה `null` (לא-מספרי) ⇒ `null`.
6. `:355` — אחרת ⇒ `makeCondition(field, op, value)`.

## דוגמאות מספריות
שקעי-הבדיקה: `matchConditionField`= החזר-אם-ב-{age,total} אחרת null · `matchRuleOp`= החזר-אם-ב-{gt,lt} אחרת null · `makeCondition`= `(f,o,v) => (field:f, op:o, value:v)`.

| # | raw | ⇒ |
|---|-----|---|
| 1 | `'x'` (לא-Map) | `null` |
| 2 | `null` | `null` |
| 3 | `{'op':'gt','value':5}` (בלי field) | `null` (field '' פסול) |
| 4 | `{'field':'zzz','op':'gt','value':5}` | `null` (שדה לא-מוכר) |
| 5 | `{'field':'age','value':5}` (בלי op) | `null` (op '' פסול) |
| 6 | `{'field':'age','op':'gt','value':5}` | `(field:'age', op:'gt', value:5)` |
| 7 | `{'field':'age','op':'gt','value':'7'}` | `(..., value:7)` (‏tryParse מחרוזת) |
| 8 | `{'field':'age','op':'gt','value':'abc'}` | `null` (לא-מספרי) |
| 9 | `{'field':'age','op':'gt'}` (בלי value) | `null` (‏null⇒''⇒tryParse null) |
| 10 | `{'field':'total','op':'lt','value':3.5}` | `(..., value:3.5)` (double) |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/validate_condition_test.dart  ⇒ exit 0 + "OK validateCondition: N asserts passed"
```
