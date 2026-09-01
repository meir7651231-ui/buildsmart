# חוזה · `fuzzyNameMatch` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/fuzzy_match.dart:68-77`
(‏`fuzzyNameMatch`). הקריאה `fuzzyMatch` — שהוא **אטום-אחר** — הפכה לשקע (חוק-3
+ חוק-1: חוט לא מייבא חוט; האטום לא מייבא את `fuzzy_match.dart`).

## חתימה
```dart
bool fuzzyNameMatch(String query, String candidate, {
  required bool Function(String query, String candidate) fuzzyMatch,
})
```

## קלט
- `query`, `candidate` — מחרוזות.
- `fuzzyMatch` — **שקע** (חוק-3): אטום-fuzzyMatch השכן.

## פלט / התנהגות (עוגני-שורה)
- `fuzzy_match.dart:69` — `if (fuzzyMatch(query, candidate)) return true;` (התאמה-שלמה).
- `fuzzy_match.dart:70` — פיצול `candidate.split(RegExp(r'\s+'))` (רווחים לבנים).
- `fuzzy_match.dart:71` — לכל `word` לא-ריק: `fuzzyMatch(query, word)` ⇒ `true`.
- `fuzzy_match.dart:74` — אחרת `false`.
- שים-לב: `split(RegExp(r'\s+'))` על מחרוזת שמתחילה ברווח מייצר איבר-ריק ראשון —
  לכן המגן `word.isNotEmpty`.

## דוגמאות מספריות (‏fuzzyMatch stub = התאמה-מדויקת, `(q,c) => q == c`)
| # | query | candidate | ⇒ | נימוק |
|---|-------|-----------|---|-------|
| 1 | `'יוסי כהן'` | `'יוסי כהן'` | true | התאמה-שלמה (שורה 69) |
| 2 | `'כהן'` | `'יוסי כהן'` | true | מילה 'כהן' תואמת |
| 3 | `'יוסי'` | `'יוסי כהן'` | true | מילה 'יוסי' תואמת |
| 4 | `'לוי'` | `'יוסי כהן'` | false | לא שלם ולא מילה |
| 5 | `'כהן'` | `'  יוסי   כהן  '` | true | רווחים-כפולים, איבר-ריק מדולג |
| 6 | `'x'` | `''` | false | פיצול ריק ⇒ אין מילים |

## שקעים
- `fuzzyMatch` — הזרקת-אטום-שכן (חוק-3/חוק-1). הבדיקה מזריקה stub התאמה-מדויקת
  כדי לבודד את **לוגיקת-פיצול-המילים** של האטום עצמו.

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/fuzzy_name_match_test.dart  ⇒ exit 0 + "OK fuzzyNameMatch: N asserts passed"
```
