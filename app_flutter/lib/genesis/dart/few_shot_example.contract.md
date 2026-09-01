# חוזה · `fewShotExample` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart`
(‏`_fewShotExample`, גוף 10-שורות — הפונקציה הראשונה בטיוטה, מעל `studioEditPrompt`).
הקריאה `registry.propKeysFor(id)` הפכה לשקע `propKeysFor` (חוק-3).

## חתימה
```dart
String? fewShotExample(List<String> slice, {
  required Iterable<String> Function(String id) propKeysFor,
})
```

## קלט
- `slice` — רשימת מזהי-אלמנט בטווח.
- `propKeysFor` — **שקע** (חוק-3): במקור `registry.propKeysFor(id)`.

## פלט / התנהגות (עוגני-שורה)
- `slice.isEmpty` ⇒ `null` (אין דוגמה).
- לולאה על `slice` בסדר: ה-id הראשון ש-`propKeysFor(id).contains('text')` ⇒
  `'[{"op":"setText","id":"<id>","text":"טקסט לדוגמה"}]'`.
- אם אף id לא חושף 'text' ⇒ `'[{"op":"setHidden","id":"<slice.first>","hidden":false}]'`.
- הבחירה נעצרת ב-id הראשון-בסדר-slice שחושף 'text' (לא ממויין — סדר הרשימה כפי-שהוא).

## דוגמאות מספריות
| # | slice | propKeysFor | ⇒ |
|---|-------|-------------|---|
| 1 | `[]` | — | `null` |
| 2 | `['a']` | a⇒`['text']` | `'[{"op":"setText","id":"a","text":"טקסט לדוגמה"}]'` |
| 3 | `['a','b']` | a⇒`['bg']`, b⇒`['text']` | `'…setText…"id":"b"…'` (b הראשון עם text) |
| 4 | `['a','b']` | שניהם ללא text | `'[{"op":"setHidden","id":"a","hidden":false}]'` (slice.first) |
| 5 | `['x','y']` | x⇒`['text']`, y⇒`['text']` | `'…setText…"id":"x"…'` (x מוקדם בסדר) |

## שקעים
- `propKeysFor` — הזרקת-ריאדר (חוק-3). הבדיקה מספקת מפה סינתטית.

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/few_shot_example_test.dart  ⇒ exit 0 + "OK fewShotExample: N asserts passed"
```
