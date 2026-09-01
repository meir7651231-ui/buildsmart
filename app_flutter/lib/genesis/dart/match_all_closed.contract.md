# חוזה · `matchAllClosed` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/registry_view.dart:261-271`
(‏`_matchAllClosed`, private-במקור). קודם לפונקציה top-level ציבורית `matchAllClosed`.

## חתימה
```dart
Set<String> matchAllClosed(Set<String> closed, String reply)
```

## קלט
- `closed` — קבוצה-סגורה של מפתחות-אמת.
- `reply` — תשובת-המודל הגולמית.

## פלט / התנהגות (עוגני-שורה)
- `:262` — `final r = reply.trim()`.
- `:263` — `r.isEmpty ⇒ return const <String>{}` (קבוצה-ריקה).
- `:264-269` — set-comprehension: כל `k` ש-`k.isNotEmpty && r.contains(k)`.
- שלא כמו `matchClosed` — מחזיר את **כל** ההתאמות, לא רק הטוב-ביותר. לעולם לא זורק.
- אין דירוג-אורך: prefix ותת-מחרוזת יכולים לחזור **שניהם** (‏faucet ⊂ kitchenFaucet ⇒ שניהם).

## דוגמאות מספריות
| # | closed | reply | ⇒ |
|---|--------|-------|---|
| 1 | `{'a','b','c'}` | `'a c'` | `{'a','c'}` |
| 2 | `{'faucet','faucetKit'}` | `'faucetKit'` | `{'faucet','faucetKit'}` (שניהם מוכלים!) |
| 3 | `{'a','b'}` | `'   '` | `{}` (ריק אחרי trim) |
| 4 | `{'a','b'}` | `'zzz'` | `{}` (אין-התאמה) |
| 5 | `{'','x'}` | `'x'` | `{'x'}` (מפתח-ריק מסונן) |
| 6 | `{}` | `'anything'` | `{}` (מקור-ריק) |

## שקעים
- אין. `closed` = פרמטר-נתון. `String.trim/contains`, set-comprehension — שפה/סטנדרט.

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/match_all_closed_test.dart  ⇒ exit 0 + "OK matchAllClosed: N asserts passed"
```
