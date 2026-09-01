# חוזה · `elementLine` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart:236-248`
(‏`_elementLine`). שתי קריאות-השכן על `RegistryView` הופכו לשקעים (חוק-3).

## חתימה
```dart
String elementLine(String id, {
  required Iterable<String> Function(String id) propKeysFor,
  required Iterable<String> Function(String id) actionIdsFor,
})
```

## קלט
- `id` — מזהה-אלמנט.
- `propKeysFor` — **שקע** (חוק-3): במקור `registry.propKeysFor(id)`.
- `actionIdsFor` — **שקע** (חוק-3): במקור `registry.actionIdsFor(id)`.

## פלט / התנהגות (עוגני-שורה)
- `edit_prompt.dart:237` — `props = propKeysFor(id).toList()..sort()` (ממויין עולה).
- `edit_prompt.dart:238` — `actions = actionIdsFor(id).toList()..sort()`.
- `edit_prompt.dart:240-241` — props לא-ריק ⇒ מוסיף `'props ' + props.join('/')`.
- `edit_prompt.dart:242-243` — actions לא-ריק ⇒ מוסיף `'actions ' + actions.join('/')`.
- `edit_prompt.dart:244` — `rhs` ריק ⇒ מחזיר `id`; אחרת `'$id = ' + rhs.join(' · ')`.
- מפריד בין props ל-actions: ` · ` (רווח-נקודה-רווח, U+00B7).

## דוגמאות מספריות
| # | id | propKeysFor | actionIdsFor | ⇒ |
|---|----|-------------|--------------|---|
| 1 | `'title'` | `['text','color']` | `[]` | `'title = props color/text'` (ממויין!) |
| 2 | `'btn'` | `[]` | `['tap','long']` | `'btn = actions long/tap'` |
| 3 | `'card'` | `['bg','text']` | `['open']` | `'card = props bg/text · actions open'` |
| 4 | `'x'` | `[]` | `[]` | `'x'` (שניהם ריקים ⇒ id בלבד) |
| 5 | `'z'` | `['a']` | `[]` | `'z = props a'` |

## שקעים
- `propKeysFor`, `actionIdsFor` — הזרקת-ריאדרים (חוק-3). הבדיקה מספקת מפות סינתטיות.
- `List.sort`, `Iterable.join`, `Iterable.toList` — שפה/סטנדרט.

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/element_line_test.dart  ⇒ exit 0 + "OK elementLine: N asserts passed"
```
