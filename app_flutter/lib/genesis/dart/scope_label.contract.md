# חוזה · `scopeLabel` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart:189-201`
(‏`scopeLabel`). קובץ-המקור אינו קיים עוד ב-checkout ⇒ הטיוטה = מקור-האמת.

## חתימה
```dart
String scopeLabel(String scope, {
  String all = 'all', String screenPrefix = 'screen:', String singlePrefix = 'element:',
})
```

## שקעים (חוק-3)
`kScopeAll`/`kScopeScreenPrefix`/`kScopeSinglePrefix` — const-שכנים לא-ניתנים-לשחזור,
הורמו לשקעים; ברירות-המחדל מייצגות בלבד. הבדיקה מעבירה ערכים מפורשים.

## פלט / התנהגות (עוגני-שורה)
- `edit_prompt.dart:190` — `scope == all` ⇒ `'מתוך: כל האלמנטים'`.
- `:192` — `startsWith(screenPrefix)` ⇒ `'מתוך: מרחב «' + substring + '»'`.
- `:195` — `startsWith(singlePrefix)` ⇒ `'מתוך: האלמנט «' + substring + '»'`.
- `:198` — אחרת ⇒ `'מתוך: (טווח לא מזוהה)'`.
- ⚠️ שים לב: `scope_he` משתמש ב-`'מסך «…»'`, אך כאן הטקסט הוא `'מתוך: מרחב «…»'` (מונח שונה!).

## דוגמאות (all='all', screen:'screen:', single:'element:')
| # | scope | ⇒ |
|---|-------|---|
| 1 | `'all'` | `'מתוך: כל האלמנטים'` |
| 2 | `'screen:cart'` | `'מתוך: מרחב «cart»'` |
| 3 | `'element:btn-pay'` | `'מתוך: האלמנט «btn-pay»'` |
| 4 | `'zzz'` | `'מתוך: (טווח לא מזוהה)'` |
| 5 | `'screen:'` | `'מתוך: מרחב «»'` |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/scope_label.dart                     ⇒ No issues found!
dart run --enable-asserts new/dart/scope_label_test.dart   ⇒ exit 0 + "OK scopeLabel: N asserts passed"
```
