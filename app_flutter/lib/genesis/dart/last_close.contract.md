# חוזה · `lastClose` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:323-333`
(‏`_lastClose`). אפס שקעים — עצמאי-מלא.

## חתימה
```dart
int lastClose(String s)
```

## פלט / התנהגות (עוגני-שורה)
- `:324` — `brace = s.lastIndexOf('}')`.
- `:325` — `bracket = s.lastIndexOf(']')`.
- `:326` — `brace > bracket ? brace : bracket` (המקסימום; שניהם נעדרים ⇒ ‏-1 > -1 שקר ⇒ bracket=-1).

## דוגמאות מספריות
| # | s | brace | bracket | ⇒ |
|---|---|-------|---------|---|
| 1 | `'{a}'` | 2 | -1 | `2` |
| 2 | `'[a]'` | -1 | 2 | `2` |
| 3 | `'{}[]'` | 1 | 3 | `3` |
| 4 | `'[]{}'` | 3 | 1 | `3` |
| 5 | `'abc'` | -1 | -1 | `-1` |
| 6 | `''` | -1 | -1 | `-1` |
| 7 | `'}]'` | 0 | 1 | `1` |
| 8 | `'{[}]'` | 2 | 3 | `3` |

## שקעים
- אין. `String.lastIndexOf`, ternary — שפה/סטנדרט.

## DoD
```
dart run --enable-asserts new/dart/last_close_test.dart  ⇒ exit 0 + "OK lastClose: N asserts passed"
```
