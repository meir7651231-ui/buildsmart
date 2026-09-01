# חוזה · `scopeElementIds` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart:168-188`.
קובץ-המקור אינו קיים עוד ב-checkout ⇒ הטיוטה = מקור-האמת.

## חתימה
```dart
Set<String> scopeElementIds(String scope, {
  required Set<String> ids,
  required String Function(String id) namespaceOf,
  String all = 'all', String screenPrefix = 'screen:', String singlePrefix = 'element:',
})
```

## שקעים (חוק-3)
- `ids` — מחליף `registry.elementIds()` (מתודה על `RegistryView`-שכן).
- `namespaceOf` — מחליף את העוזר-הפרטי `_namespaceOf(id)`.
- `all`/`screenPrefix`/`singlePrefix` — const-שכנים לא-ניתנים-לשחזור (ברירות-מחדל מייצגות).

## פלט / התנהגות (עוגני-שורה)
- `edit_prompt.dart:170` — `scope == all` ⇒ מחזיר את **כל** `ids` (אותו Set).
- `:171-177` — `startsWith(screenPrefix)`: `ns = substring`; מחזיר את המזהים ש-`namespaceOf(id)==ns`.
- `:178-181` — `startsWith(singlePrefix)`: `id = substring`; `{id}` אם `ids.contains(id)`, אחרת `{}`.
- `:183` — אחרת ⇒ `{}` (**fail-closed** — טווח לא-מוכר לא בוחר דבר).

## דוגמאות (ids={'cart/btn','cart/txt','home/hdr'}, namespaceOf = חלק-לפני-'/')
| # | scope | ⇒ |
|---|-------|---|
| 1 | `'all'` | כל שלושת המזהים |
| 2 | `'screen:cart'` | `{'cart/btn','cart/txt'}` |
| 3 | `'screen:home'` | `{'home/hdr'}` |
| 4 | `'screen:zzz'` (מרחב ריק) | `{}` |
| 5 | `'element:cart/btn'` (קיים) | `{'cart/btn'}` |
| 6 | `'element:nope'` (לא-קיים) | `{}` |
| 7 | `'garbage'` | `{}` (fail-closed) |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/scope_element_ids.dart                    ⇒ No issues found!
dart run --enable-asserts new/dart/scope_element_ids_test.dart  ⇒ exit 0 + "OK scopeElementIds: N asserts passed"
```
