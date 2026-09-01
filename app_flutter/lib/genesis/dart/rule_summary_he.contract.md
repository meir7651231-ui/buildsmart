# חוזה · `ruleSummaryHe` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/rules_model.dart:460-469`
(‏`ruleSummaryHe`). `advisoryHe` שבטיוטה אינו היעד. הקובץ אינו קיים עוד ⇒ הטיוטה = מקור-האמת.

## חתימה
```dart
String ruleSummaryHe({
  required String triggerLabel, required String fieldLabel,
  required String opRaw, required Object value,
  required String actionLabel, required Map<String, String> opLabels,
})
```

## שקעים (חוק-3)
- `triggerLabel` / `fieldLabel` / `actionLabel` — פלטי העוזרים-השכנים
  `triggerLabelHe(r.trigger)` / `fieldLabelHe(r.condition.field)` / `actionLabelHe(r.action)`.
- `opRaw` = `r.condition.op` · `value` = `r.condition.value` (‏`Rule`-שכן גדול, פורק לשדות).
- `opLabels` = `kRuleOpLabelsHe` (מפת אופרטור→תווית עברית).

## פלט / התנהגות (עוגני-שורה)
- `rules_model.dart:461` — `op = opLabels[opRaw] ?? opRaw` (אם אין תרגום — האופרטור הגולמי).
- `:462-464` — הפורמט: `'<trigger> · <field> <op> <value> · <action>'`
  (מפריד ` · ` בין שלושת-החלקים; בתוך החלק-האמצעי רווחים בודדים סביב `<op>` ו-`<value>`).
- `value` הוא `Object` ⇒ מוטבע דרך `toString()`.

## דוגמאות (opLabels = {'gte':'≥','eq':'='})
| # | קלט | ⇒ |
|---|-----|---|
| 1 | trigger='הזמנה חדשה', field='סכום', opRaw='gte', value=500, action='שלח מייל' | `'הזמנה חדשה · סכום ≥ 500 · שלח מייל'` |
| 2 | opRaw='eq', value='VIP' (שאר כמו #1 עם field='דרגה') | `'הזמנה חדשה · דרגה = VIP · שלח מייל'` |
| 3 | opRaw='lt' (**לא** במפה), value=10 | `<op>` נשאר `'lt'` ⇒ `'… lt 10 · …'` (נפילת-אופרטור) |
| 4 | value=`true` (bool) | מוטבע כ-`'true'` |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/rule_summary_he.dart                    ⇒ No issues found!
dart run --enable-asserts new/dart/rule_summary_he_test.dart  ⇒ exit 0 + "OK ruleSummaryHe: N asserts passed"
```
