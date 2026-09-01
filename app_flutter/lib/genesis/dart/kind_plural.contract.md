# חוזה · `kindPlural` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/diff_preview.dart:151-164`
(‏`_kindPlural`). ה-enum `ConfigOpKind` הוטבע inline verbatim (טיפוס-שכן-קטן, 6 ערכים).
switch ממצה על ה-enum.

## חתימה
```dart
enum ConfigOpKind { setText, setEmoji, setHidden, setOrder, setStyle, setAction }
String kindPlural(ConfigOpKind kind, bool styleAllColor)
```

## פלט / התנהגות (עוגני-שורה)
- `:152` setText ⇒ `'טקסטים'`
- `:153` setEmoji ⇒ `'אמוג׳ים'` (גרש U+05F3)
- `:154` setHidden ⇒ `'הסתרות'`
- `:155` setOrder ⇒ `'שינויי סדר'`
- `:156` setStyle ⇒ `styleAllColor ? 'צבעים' : 'עיצובים'` (הפרמטר משפיע רק כאן)
- `:157` setAction ⇒ `'פעולות'`

## דוגמאות מספריות
| # | kind | styleAllColor | ⇒ |
|---|------|---------------|---|
| 1 | `setText` | `false` | `'טקסטים'` |
| 2 | `setEmoji` | `false` | `'אמוג׳ים'` |
| 3 | `setHidden` | `false` | `'הסתרות'` |
| 4 | `setOrder` | `false` | `'שינויי סדר'` |
| 5 | `setStyle` | `true` | `'צבעים'` |
| 6 | `setStyle` | `false` | `'עיצובים'` |
| 7 | `setAction` | `true` | `'פעולות'` (הדגל לא-משפיע) |
| 8 | `setText` | `true` | `'טקסטים'` (הדגל לא-משפיע) |

## שקעים
- אין. ה-enum מוטבע verbatim; switch/ternary = שפה/סטנדרט.

## DoD
```
dart run --enable-asserts new/dart/kind_plural_test.dart  ⇒ exit 0 + "OK kindPlural: N asserts passed"
```
