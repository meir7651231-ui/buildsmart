# חוזה · `studioScopeTokens` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart:131-146`.
קובץ-המקור נעדר ⇒ הטיוטה היא מקור-האמת; ערכי `kScopeAll`/`kScopeScreenPrefix` אינם בטיוטה.

## חתימה
```dart
Set<String> studioScopeTokens({
  required Iterable<String> Function() elementIds,
  required String Function(String) namespaceOf,
  required String scopeAll,
  required String screenPrefix,
})
```

## שקעים (חוק-3/8)
- `elementIds` — במקום `registry.elementIds()` (‏:133).
- `namespaceOf` — במקום הפונקציה-השכנה `_namespaceOf(id)` (‏:134).
- `scopeAll` / `screenPrefix` — במקום הקבועים `kScopeAll`/`kScopeScreenPrefix` (ערכיהם נעדרים ⇒ שקע, לא המצאה).

## פלט / התנהגות (עוגני-שורה)
- `:132` — קבוצה מאותחלת `{scopeAll}`.
- `:133-136` — לכל id ב-`elementIds()`: `ns = namespaceOf(id)`; אם `ns.isNotEmpty` ⇒
  הוסף `'$screenPrefix$ns'`.
- `Set` ⇒ מרחבי-שם כפולים מתמזגים לטוקן-מסך יחיד; `ns` ריק ⇒ מדולג.
- `scopeAll` תמיד נוכח (גם ברשימה ריקה).

## דוגמאות מספריות
שקעים: `scopeAll='scope:all'`, `screenPrefix='scope:screen:'`,
`namespaceOf` = החלק שלפני `'.'` הראשון (אין `'.'` ⇒ '').

| # | elementIds() | ⇒ |
|---|--------------|---|
| 1 | `[]` | `{'scope:all'}` |
| 2 | `['home.title']` | `{'scope:all', 'scope:screen:home'}` |
| 3 | `['home.title','home.btn']` | `{'scope:all', 'scope:screen:home'}` (מיזוג-כפילות) |
| 4 | `['home.a','cart.b']` | `{'scope:all', 'scope:screen:home', 'scope:screen:cart'}` |
| 5 | `['','flat']` (‏ns ריק ⇒ מדולג) | `{'scope:all'}` |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/studio_scope_tokens_test.dart  ⇒ exit 0 + "OK studioScopeTokens: N asserts passed"
```
