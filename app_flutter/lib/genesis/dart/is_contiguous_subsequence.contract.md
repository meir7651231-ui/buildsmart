# חוזה · `isContiguousSubsequence` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/equipment_stock_join.dart:52-68`
(‏`_isContiguousSubsequence`). אפס שקעים — עצמאי-מלא.

## חתימה
```dart
bool isContiguousSubsequence(List<String> needle, List<String> haystack)
```

## פלט / התנהגות (עוגני-שורה)
- `:53` — `needle.length < 2 || needle.length > haystack.length ⇒ false` (מגן-כפול: מינימום-2 · לא-ארוך-מ-haystack).
- `:54` — `last = haystack.length - needle.length`.
- `:55-63` — חלון-הזזה `i∈[0..last]`: התאמת כל `needle[j]` מול `haystack[i+j]`; אי-התאמה ⇒ `continue outer`.
- התאמה-מלאה ⇒ `true`; מיצוי ⇒ `false`.

## דוגמאות מספריות
| # | needle | haystack | ⇒ | סיבה |
|---|--------|----------|---|------|
| 1 | `['a','b']` | `['x','a','b','y']` | `true` | חלון ב-i=1 |
| 2 | `['a','b']` | `['a','x','b']` | `false` | לא-רציף |
| 3 | `['a']` | `['a','b']` | `false` | needle<2 |
| 4 | `['a','b','c']` | `['a','b']` | `false` | needle ארוך מ-haystack |
| 5 | `['a','b']` | `['a','b']` | `true` | זהה, last=0 |
| 6 | `[]` | `['a','b']` | `false` | needle<2 |
| 7 | `['b','c']` | `['a','b','c']` | `true` | חלון בקצה |
| 8 | `['a','b']` | `['a','a','b']` | `true` | חלון ב-i=1 |

## שקעים
- אין. `List.length`, אינדוקס, `continue <label>` — שפה/סטנדרט.

## DoD
```
dart run --enable-asserts new/dart/is_contiguous_subsequence_test.dart  ⇒ exit 0 + "OK isContiguousSubsequence: N asserts passed"
```
