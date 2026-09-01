# חוזה · `parseRule` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/rules_model.dart:308-343`
(‏`parseRule` — "הפרסר הטוטאלי", מראה של `parseConfigEdit`). קובץ-המקור נעדר מה-checkout
הנוכחי; אומת **ביט-ביט מול הענף** `claude/align-main` בריפו buildsmart (‏git show) —
הטיוטה זהה למקור.

**אחים-שסוקטו:** `evalRuleAdvisory`/`_triggerMatches`/`_conditionMatches` — אטומים
נפרדים (‏condition_matches / trigger_matches), לא הועתקו.

## חתימה
```dart
R? parseRule<T, A, C, R>(String raw, {
  required T? Function(String) matchTriggerId,
  required A? Function(String) matchRuleActionId,
  required C? Function(Object?) validateCondition,
  required R Function(T trigger, C condition, A action) makeRule,
})
```

## שקעים (חוק-3 — הכרעה 1 של הגל: שכן ⇒ שקע-פרמטר)
- `matchTriggerId` — שקע במקום הפונקציה-השכנה (‏:322; קיימת כאטום `match_trigger_id`).
- `matchRuleActionId` — שקע במקום השכנה (‏:327; קיימת כאטום `match_action_id`).
- `validateCondition` — שקע במקום `_validateCondition` (‏:331; קיימת כאטום `validate_condition`).
- `makeRule` — שקע-מפעל במקום `Rule(trigger:, condition:, action:)` (‏:333).
- הטיפוסים `Trigger`/`Action`/`Condition`/`Rule` ⇒ גנריים `T`/`A`/`C`/`R`
  (אותה מוסכמה כמו האח `validate_condition`).
- `jsonDecode` — **לא** שקע: ‏`dart:convert` = ספריית-סטנדרט (מותר באטום, LAW חוק-1;
  תקדים: `decode.dart`).

## פלט / התנהגות — 7 שערי-כשל, טוטאלי, לעולם-לא-זורק (עוגני-שורה)
1. `:309` — ‏trim על הקלט.
2. `:311-312` — `indexOf('{') < 0` ⇒ `null` (פרוזה בלי JSON).
3. `:313-314` — `lastIndexOf('}') <= start` ⇒ `null` (נפתח ולא-נסגר / `}` לפני `{`).
4. `:315` — brace-extract: ‏`substring(start, end + 1)`.
5. `:317-318` — `jsonDecode` בתוך try; ‏`decoded is! Map` ⇒ `null`.
6. `:319` — מפתחות ⇒ `toString` (מפה מחרוזתית).
7. `:322-323` — ‏TOKEN 1: ‏`matchTriggerId((m['trigger'] ?? '').toString())` ‏== null ⇒ `null`.
8. `:327-328` — ‏TOKEN 2: ‏`matchRuleActionId((m['action'] ?? '').toString())` ‏== null ⇒ `null`
   (פעולה-ממוטטת חוקית כאן — נדחית בביצוע, לא בפרסינג).
9. `:331-332` — ‏TOKEN 3/4/5: ‏`validateCondition(m['condition'])` ‏== null ⇒ `null` (הכול-או-כלום).
10. `:334` — הצלחה ⇒ `makeRule(trigger, condition, action)`.
11. `:335-338` — ‏`catch (_)` טרמינלי ⇒ `null` (‏JSON שבור — לעולם לא throw).

## דוגמאות מספריות
שקעי-הבדיקה: ‏`matchTriggerId` = חברוּת-מדויקת ב-{'order.new','order.stuck'} אחרת null ·
‏`matchRuleActionId` = חברוּת ב-{'notify.manager'} אחרת null ·
‏`validateCondition` = ‏Map עם `value` מספרי ⇒ הרשומה `(v: value)`, אחרת null ·
‏`makeRule` = ‏`(t,c,a) => (trigger:t, condition:c, action:a)`.

| # | raw | ⇒ |
|---|-----|---|
| 1 | `'סתם פרוזה'` (אין `{`) | `null` |
| 2 | `'טקסט { שנפתח ולא נסגר'` | `null` (‏end=-1 ≤ start) |
| 3 | `'} הפוך {'` | `null` (‏end < start) |
| 4 | `'{לא json}'` | `null` (‏jsonDecode זורק ⇒ catch) |
| 5 | `'{"a":1} רעש {"b":2}'` | `null` (חילוץ-סוגריים תופס את שניהם ⇒ JSON שבור ⇒ catch) |
| 6 | `'{"trigger":"order.fake","action":"notify.manager","condition":{"value":2}}'` | `null` (טריגר מומצא) |
| 7 | `'{"action":"notify.manager","condition":{"value":2}}'` (בלי trigger) | `null` (‏'' פסול) |
| 8 | `'{"trigger":"order.new","action":"delete.everything","condition":{"value":2}}'` | `null` (פעולה מומצאת) |
| 9 | `'{"trigger":"order.new","action":"notify.manager","condition":{"value":"abc"}}'` | `null` (תנאי פסול) |
| 10 | `'{"trigger":"order.new","action":"notify.manager"}'` (בלי condition) | `null` (‏validateCondition(null)) |
| 11 | `'בטח! {"trigger":"order.stuck","condition":{"value":2},"action":"notify.manager"} בוצע'` | `(trigger:'order.stuck', condition:(v:2), action:'notify.manager')` — פרוזה סביב ה-JSON נחתכת |
| 12 | `'{"trigger":5,"condition":{"value":2},"action":"notify.manager"}'` | `null` (‏toString ⇒ '5' פסול) |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/parse_rule_test.dart  ⇒ exit 0 + "OK parseRule: N asserts passed"
```
