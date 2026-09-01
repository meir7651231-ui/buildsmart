# חוזה · `scopeHe` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:565-579`
(‏`scopeHe`). קובץ-המקור אינו קיים עוד ב-checkout ⇒ הטיוטה במחצב היא מקור-האמת.

## חתימה
```dart
String scopeHe(String token, {
  String all = 'all', String actionable = 'actionable',
  String everyPrefix = 'every:', String screenPrefix = 'screen:',
  String singlePrefix = 'element:',
})
```

## שקעים (חוק-3 — אוצר-מילים לא-ניתן-לשחזור)
`kScopeAll`/`kScopeActionable`/`kScopeEveryPrefix`/`kScopeScreenPrefix`/`kScopeSinglePrefix`
הם const-שכנים שערכם הליטרלי **אינו ניתן לשחזור** (הקובץ נעלם, grep בכל buildsmart ריק).
הוּרמו לשקעים בשם; ברירות-המחדל (`'all'`/`'actionable'`/`'every:'`/`'screen:'`/`'element:'`)
הן **מייצגות בלבד** — הקורא מזריק את האמיתיות, והבדיקה מעבירה ערכים מפורשים.

## פלט / התנהגות (עוגני-שורה, edit_intent.dart:565-579)
סדר-ההכרעה קשיח:
1. `token == all` ⇒ `'כל האלמנטים'`.
2. `token == actionable` ⇒ `'כל הכפתורים'`.
3. `startsWith(everyPrefix)` ⇒ `'כל «' + token.substring(len(everyPrefix)) + '»'`.
4. `startsWith(screenPrefix)` ⇒ `'מסך «' + …substring… + '»'`.
5. `startsWith(singlePrefix)` ⇒ `'האלמנט «' + …substring… + '»'`.
6. אחרת ⇒ `'(טווח לא מזוהה)'`.

## דוגמאות (עם השקעים המפורשים all='all', … every:'every:' screen:'screen:' single:'element:')
| # | token | ⇒ |
|---|-------|---|
| 1 | `'all'` | `'כל האלמנטים'` |
| 2 | `'actionable'` | `'כל הכפתורים'` |
| 3 | `'every:button'` | `'כל «button»'` |
| 4 | `'screen:cart'` | `'מסך «cart»'` |
| 5 | `'element:btn-pay'` | `'האלמנט «btn-pay»'` |
| 6 | `'wat'` (לא-מוכר) | `'(טווח לא מזוהה)'` |
| 7 | `'screen:'` (קידומת ריקה) | `'מסך «»'` |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/scope_he.dart                      ⇒ No issues found!
dart run --enable-asserts new/dart/scope_he_test.dart    ⇒ exit 0 + "OK scopeHe: N asserts passed"
```
