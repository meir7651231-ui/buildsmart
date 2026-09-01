# חוזה · `scopeTokenHe` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart:202-212`
(‏`_scopeTokenHe`, פרטי-במקור). קובץ-המקור אינו קיים עוד ⇒ הטיוטה = מקור-האמת.

## חתימה
```dart
String scopeTokenHe(String token, {String all = 'all', String screenPrefix = 'screen:'})
```

## שקעים (חוק-3)
`kScopeAll`/`kScopeScreenPrefix` — const-שכנים לא-ניתנים-לשחזור, הורמו לשקעים; ברירות-מחדל
מייצגות. הבדיקה מעבירה ערכים מפורשים.

## פלט / התנהגות (עוגני-שורה)
- `edit_prompt.dart:203` — `token == all` ⇒ `'כל האלמנטים'`.
- `:205` — `startsWith(screenPrefix)` ⇒ `'מרחב «' + substring + '»'`.
- `:208` — **fall-through ל-`token` עצמו** (לא '(לא מזוהה)' — זה ההבדל מ-`scopeHe`/`scopeLabel`).

## דוגמאות (all='all', screen:'screen:')
| # | token | ⇒ |
|---|-------|---|
| 1 | `'all'` | `'כל האלמנטים'` |
| 2 | `'screen:cart'` | `'מרחב «cart»'` |
| 3 | `'element:btn'` | `'element:btn'` (verbatim — fall-through) |
| 4 | `'random'` | `'random'` (verbatim) |
| 5 | `'screen:'` | `'מרחב «»'` |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/scope_token_he.dart                    ⇒ No issues found!
dart run --enable-asserts new/dart/scope_token_he_test.dart  ⇒ exit 0 + "OK scopeTokenHe: N asserts passed"
```
