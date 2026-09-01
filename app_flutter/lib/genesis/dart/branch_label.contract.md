# חוזה · `branchLabel` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/install_engine.dart:935-936`
(‏`_branchLabel`). ה-const-האחות `_branchLetters` (‏`install_engine.dart:934`,
נקראת אך-ורק ב-:936) הופכה לשקע `letters` (חוק-3). הקורא היחיד: `:1561` (‏`_branchLabel(routed++)`).

## חתימה
```dart
String branchLabel(int i, {required List<String> letters})
```

## קלט
- `i` — אינדקס-ענף, ‏int 0-מבוסס. במקור תמיד ‏≥0 (‏`routed++`, install_engine.dart:1561).
- `letters` — **שקע** (חוק-3): אותיות-האזור בסדר. ערכי-המקור (‏install_engine.dart:934):
  `['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט', 'י']` (10 איברים).

## פלט / התנהגות (עוגני-שורה)
- `install_engine.dart:936` — `'ענף ${i < letters.length ? letters[i] : (i + 1).toString()}'`:
  - אם `i < letters.length` ⇒ המחרוזת `'ענף '` + `letters[i]`.
  - אחרת ⇒ `'ענף '` + `(i + 1).toString()` (מספר 1-מבוסס).
- דין-קצה מהמקור (נאמנות, לא-שיפור): המקור **אינו** מגן על `i` שלילי; `i < length`
  אמת עבור שלילי ⇒ `letters[i]` זורק `RangeError`. האטום שומר על אותה התנהגות.

## דוגמאות מספריות (‏letters = ערכי-המקור, 10 אותיות)
| # | i | ⇒ |
|---|---|---|
| 1 | 0 | `'ענף א'` |
| 2 | 1 | `'ענף ב'` |
| 3 | 2 | `'ענף ג'` |
| 4 | 9 | `'ענף י'` (איבר אחרון) |
| 5 | 10 | `'ענף 11'` (10 < 10 שקר ⇒ (10+1)) |
| 6 | 11 | `'ענף 12'` |
| 7 | 99 | `'ענף 100'` |

## עדשה-עוינת (קלטי-קצה)
| # | i | letters | ⇒ |
|---|---|---------|---|
| 8 | 0 | `[]` (ריק) | `'ענף 1'` (0 < 0 שקר ⇒ (0+1)) |
| 9 | 0 | `['ז']` | `'ענף ז'` (i<1 אמת ⇒ letters[0]) |
| 10 | 1 | `['ז']` | `'ענף 2'` (1 < 1 שקר ⇒ (1+1)) |
| 11 | -1 | ערכי-המקור | זורק `RangeError` (נאמנות-מקור: אין מגן-שלילי) |

## שקעים
- `letters` — הזרקת-רשימה (חוק-3). הבדיקה מספקת את ערכי-המקור verbatim.
- `List.length`, `int.toString`, אינדוקס-רשימה — שפה/סטנדרט (לא-שקע).

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/branch_label_test.dart  ⇒ exit 0 + "OK branchLabel: N asserts passed"
```
