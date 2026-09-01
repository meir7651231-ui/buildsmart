# חוזה · `fuzzyMatch` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/fuzzy_match.dart:58-67`
(‏`fuzzyMatch`). שלוש קריאות-שכן (`normSearch`, `damerauLevenshtein`, `fuzzyTolerance`)
הפכו לשקעים (חוק-3).

## חתימה
```dart
bool fuzzyMatch(String query, String candidate, {
  required String Function(String) normSearch,
  required int Function(String, String) damerauLevenshtein,
  required int Function(int) fuzzyTolerance,
})
```

## קלט
- `query`, `candidate` — מחרוזות.
- `normSearch` / `damerauLevenshtein` / `fuzzyTolerance` — **שקעים** (חוק-3).

## פלט / התנהגות (עוגני-שורה)
- `fuzzy_match.dart:59-60` — `q = normSearch(query)`, `c = normSearch(candidate)`.
- `fuzzy_match.dart:61` — `q.isEmpty || c.isEmpty` ⇒ `false` (אחרי-נרמול).
- `fuzzy_match.dart:62` — `c.contains(q)` ⇒ `true` (התאמת-מצע).
- `fuzzy_match.dart:63` — אחרת `damerauLevenshtein(q, c) <= fuzzyTolerance(q.length)`.

## דוגמאות מספריות
שקעים לבדיקה: `normSearch = trim+toLowerCase`; `damerauLevenshtein` אמיתי (הזרקת-stub
המחשב מרחק); `fuzzyTolerance = (len) => len >= 4 ? 1 : 0`.

| # | query | candidate | ⇒ | נימוק |
|---|-------|-----------|---|-------|
| 1 | `'abc'` | `'xxabcxx'` | true | מצע: c מכיל q |
| 2 | `''` | `'abc'` | false | q ריק |
| 3 | `'abc'` | `'   '` | false | c ריק אחרי-trim |
| 4 | `'abcd'` | `'abxd'` | true | מרחק 1 ≤ סף(4)=1 |
| 5 | `'abcd'` | `'xyzw'` | false | מרחק 4 > סף 1 |
| 6 | `'ab'` | `'ax'` | false | מרחק 1 > סף(2)=0 |
| 7 | `'ABC'` | `'abcxx'` | true | נרמול toLowerCase ⇒ מצע |

## שקעים
- `normSearch`, `damerauLevenshtein`, `fuzzyTolerance` — הזרקת-פונקציות (חוק-3).
  הבדיקה מזריקה stubs דטרמיניסטיים (`normSearch`=trim+lower, `damerau`=מימוש-קלאסי,
  `tolerance`=len≥4?1:0) כדי לאמת את **קסקדת-ההחלטה** של האטום.

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/fuzzy_match_test.dart  ⇒ exit 0 + "OK fuzzyMatch: N asserts passed"
```
