# חוזה · `kindEmoji` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/diff_preview.dart:140-150`
(‏`_kindEmoji`). ה-enum `ConfigOpKind` הוטבע inline verbatim (טיפוס-שכן-קטן, 6 ערכים
נגזרים מסדר-ה-case). switch ממצה על ה-enum.

## חתימה
```dart
enum ConfigOpKind { setText, setEmoji, setHidden, setOrder, setStyle, setAction }
String kindEmoji(ConfigOpKind kind)
```

## פלט / התנהגות (עוגני-שורה) — מיפוי 1:1
- `:141` setText ⇒ `'✏️'`
- `:142` setEmoji ⇒ `'🙂'`
- `:143` setHidden ⇒ `'🙈'`
- `:144` setOrder ⇒ `'↕️'`
- `:145` setStyle ⇒ `'🎨'`
- `:146` setAction ⇒ `'⚙️'`

## דוגמאות מספריות
| # | kind | ⇒ |
|---|------|---|
| 1 | `setText` | `'✏️'` |
| 2 | `setEmoji` | `'🙂'` |
| 3 | `setHidden` | `'🙈'` |
| 4 | `setOrder` | `'↕️'` |
| 5 | `setStyle` | `'🎨'` |
| 6 | `setAction` | `'⚙️'` |

## שקעים
- אין. ה-enum מוטבע verbatim; switch = שפה/סטנדרט.

## DoD
```
dart run --enable-asserts new/dart/kind_emoji_test.dart  ⇒ exit 0 + "OK kindEmoji: N asserts passed"
```
