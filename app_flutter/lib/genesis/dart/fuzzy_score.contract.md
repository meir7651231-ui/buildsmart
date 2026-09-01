# חוזה · `fuzzyScore` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/fuzzy_match.dart:78-88`.
שלוש קריאות-שכן הופכו לשקעים (חוק-3): `normSearch`, `damerauLevenshtein`, `fuzzyTolerance`.
`String.contains` = שפה/סטנדרט (לא-שקע). האח `_min3` משרת רק את damerauLevenshtein — לא-הוטבע.

## חתימה
```dart
int fuzzyScore(String query, String candidate, {
  required String Function(String) normSearch,
  required int Function(String, String) damerauLevenshtein,
  required int Function(int) fuzzyTolerance,
})
```

## פלט / התנהגות (עוגני-שורה)
- `fuzzy_match.dart:79-80` — `q = normSearch(query)`, `c = normSearch(candidate)`.
- `:81` — `q.isEmpty || c.isEmpty ⇒ return -1`.
- `:82` — `c.contains(q) ⇒ return 0` (הכלה מדויקת = הניקוד הטוב ביותר).
- `:83` — `d = damerauLevenshtein(q, c)`.
- `:84` — `d <= fuzzyTolerance(q.length) ? d : -1`.

## דוגמאות מספריות
שקעי-הבדיקה (דטרמיניסטיים): `normSearch = trim().toLowerCase()` ·
`damerauLevenshtein` = מרחק-לוונשטיין קלאסי · `fuzzyTolerance(n) = n <= 3 ? 1 : 2`.

| # | query | candidate | ⇒ | סיבה |
|---|-------|-----------|---|------|
| 1 | `'abc'` | `'abcdef'` | `0` | c מכיל q (‏:82) |
| 2 | `''` | `'x'` | `-1` | q ריק (‏:81) |
| 3 | `'x'` | `''` | `-1` | c ריק (‏:81) |
| 4 | `'  AB '` | `'ab'` | `0` | לאחר-נרמול q='ab', c='ab', מכיל (‏:82) |
| 5 | `'abc'` | `'abx'` | `1` | מרחק=1 ≤ סובלנות(3)=1 (‏:84) |
| 6 | `'abc'` | `'xyz'` | `-1` | מרחק=3 > סובלנות(3)=1 (‏:84) |
| 7 | `'abcd'` | `'abxy'` | `2` | מרחק=2 ≤ סובלנות(4)=2 (‏:84) |
| 8 | `'abcd'` | `'wxyz'` | `-1` | מרחק=4 > סובלנות(4)=2 (‏:84) |

## שקעים
- `normSearch` · `damerauLevenshtein` · `fuzzyTolerance` — הזרקת-פונקציות (חוק-3).
- `String.contains`, `String.isEmpty`, `String.length` — שפה/סטנדרט.

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/fuzzy_score_test.dart  ⇒ exit 0 + "OK fuzzyScore: N asserts passed"
```
