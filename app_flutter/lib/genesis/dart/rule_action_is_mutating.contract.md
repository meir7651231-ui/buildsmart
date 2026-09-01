# חוזה · `ruleActionIsMutating` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/rules_model.dart:167-179`.
הקובץ אינו קיים עוד ב-checkout ⇒ הטיוטה = מקור-האמת.

## חתימה
```dart
bool ruleActionIsMutating(String actionId, {
  required List<({String id, bool mutating})> actions,
})
```

## שקעים (חוק-3)
`kRuleActions` — קטלוג-פעולות const-שכן שהגדרתו אינה ניתנת לשחזור. הורם לשקע `actions`
כרשומות `({String id, bool mutating})` — רק שני-השדות שהאטום נוגע בהם (‏`.id`, `.mutating`).

## פלט / התנהגות (עוגני-שורה)
- `rules_model.dart:168-171` — סריקה ליניארית: על **ההתאמה הראשונה** ל-`actionId` מחזיר
  את `a.mutating` שלה (גם אם `false`).
- `:172` — אין התאמה ⇒ `false` (fail-safe — id לא-מוכר אינו-משנה).
- כפילות-id: מנצחת הראשונה בסדר-הרשימה (סמנטיקת first-match).

## דוגמאות (actions = [ (id:'setStatus', mutating:true), (id:'notify', mutating:false), (id:'setStatus', mutating:false) ])
| # | actionId | ⇒ |
|---|----------|---|
| 1 | `'setStatus'` | `true` (ההתאמה הראשונה, למרות כפילות עם false) |
| 2 | `'notify'` | `false` (קיים אך לא-משנה) |
| 3 | `'unknown'` | `false` (fail-safe) |
| 4 | `''` (ריק) | `false` |
| 5 | `actions = []` | `false` תמיד |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/rule_action_is_mutating.dart                    ⇒ No issues found!
dart run --enable-asserts new/dart/rule_action_is_mutating_test.dart  ⇒ exit 0 + "OK ruleActionIsMutating: N asserts passed"
```
