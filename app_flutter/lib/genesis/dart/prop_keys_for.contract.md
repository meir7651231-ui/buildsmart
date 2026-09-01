# חוזה-אטום · `propKeysFor`

## תפקיד
מחזיר את **קבוצת-שמות-המאפיינים-העריכים** (`Set<String>`) של הרכיב המזוהה ע"י `id`,
מתוך רשומת-המתאר (descriptor) שלו — שמות ה-axes של `editableProps`. אם אין מתאר
ל-`id` — מוחזרת **קבוצה-ריקה** (fail-closed R1-2, הערת-המקור). שמות כפולים
ברשימת-המקור מתמזגים (סמנטיקת `Set`).

מוצא: `buildsmart/app_flutter/lib/logic/studio/registry_view.dart:185-189`
(מתודת `ElementRegistryView.propKeysFor`; חוק-4 — Dart-טהור, לא-מתורגם).
עיגון-מקור: הקובץ אינו בעץ-העבודה של הענף הנוכחי אך **קיים בהיסטוריה** —
commit ‏`d224432d` (ענף `claude/align-main`); גוף-המתודה שם זהה-ביט לטיוטה
(אומת ב-`git show d224432d:app_flutter/lib/logic/studio/registry_view.dart`).

## חתימה
```dart
Set<String> propKeysFor<D>(
  String id, {
  required D descriptors,
  required ({Iterable<({String name})> editableProps})? Function(D, String) findDescriptor,
})
```

## שקעים (חוק-3)
| שקע | טיפוס | מקור-אח | תפקיד |
|-----|-------|---------|-------|
| `findDescriptor` | `({Iterable<({String name})> editableProps})? Function(D, String)` | קריאה-לשכן `findDescriptor(_descriptors, id)` (‏element_registry.dart) | מאתר את המתאר לפי id; `null` ⇒ לא-נמצא. הטיפוס-המוחזר צומצם לשדה היחיד שהאטום נוגע בו (`editableProps`), וכל איבר צומצם לשדה `name` (‏`a.name` בשורה 188). |
| `descriptors` | `D` (גנרי, אטום) | שדה-המצב `_descriptors` | אוסף-המתארים; מועבר as-is ל-`findDescriptor` בלבד. |

הוטבע inline: `_empty` ⇒ `const <String>{}` (ענף ה-null; verbatim קבוצת-מחרוזות ריקה, registry_view.dart:179).

## סמנטיקה (מקריאת-המקור, שורה-שורה — d224432d:185-189)
1. `final d = findDescriptor(descriptors, id);` — איתור-מתאר (שורה 186).
2. `if (d == null) return const <String>{};` — fail-closed ‏(R1-2): לא-נמצא ⇒ קבוצה-ריקה (שורה 187).
3. `return {for (final a in d.editableProps) a.name};` — set-comprehension של שמות-ה-axes;
   כפילויות מתמזגות, `editableProps` ריק ⇒ קבוצה-ריקה (שורה 188).

## דוגמאות-מחייבות
נניח `find` = `(m, id) => m[id]` מעל
`descriptors = { 'door': (editableProps: [(name:'color'),(name:'size'),(name:'color')]), 'label': (editableProps: <({String name})>[]) }`.

| # | קלט | פלט | נימוק |
|---|-----|-----|-------|
| 1 | `propKeysFor('door', descriptors: m, findDescriptor: find)` | `{'color','size'}` | נמצא; הכפילות `'color'` מתמזגת (Set). |
| 2 | `propKeysFor('label', descriptors: m, findDescriptor: find)` | `{}` | נמצא אך `editableProps` ריק ⇒ comprehension ריק. |
| 3 | `propKeysFor('window', descriptors: m, findDescriptor: find)` | `{}` | `find` מחזיר `null` ⇒ ענף-ה-null (fail-closed R1-2). |
| 4 | `propKeysFor('door', descriptors: m, findDescriptor: (_,__) => null)` | `{}` | שקע שמחזיר null תמיד ⇒ ריק (מוכיח את הענף המפורש). |
| 5 | `propKeysFor('', descriptors: m, findDescriptor: find)` | `{}` | id ריק ⇒ לא-נמצא ⇒ ריק (אין guard מיוחד — אותו נתיב). |

## אימות (DoD — נכתב לפני הקוד)
- `dart run --enable-asserts new/dart/prop_keys_for_test.dart` ⇒ exit 0, ‏`OK propKeysFor`.
