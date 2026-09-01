# חוזה · `formatNis` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/money_format.dart:31-33`
(‏`formatNis`). הקריאה `groupThousands(n)` הפכה לשקע (חוק-3).

## חתימה
```dart
String formatNis(int n, {String prefix = '', required String Function(int) groupThousands})
```

## קלט
- `n` — סכום שלם (יכול להיות שלילי).
- `prefix` — קידומת (ברירת-מחדל `''`).
- `groupThousands` — **שקע**: פונקציית-קיבוץ-אלפים של השכן.

## פלט / התנהגות (עוגני-שורה)
- `money_format.dart:32` — `'$prefix${n < 0 ? '-' : ''}₪${groupThousands(n)}'`:
  1. `prefix` verbatim.
  2. `'-'` אם `n < 0`, אחרת `''` (כולל n==0 ⇒ ללא מינוס).
  3. הסמל `₪` (U+20AA).
  4. תוצאת `groupThousands(n)` — **‏n המקורי מועבר** (כולל שלילי; שימור-מקור).

## דוגמאות מספריות (‏groupThousands stub = `(x) => x.abs().toString()` להדגמת-הרכב)
| # | n | prefix | ⇒ |
|---|---|--------|---|
| 1 | 0 | `''` | `'₪0'` (n==0 ⇒ אין מינוס) |
| 2 | 500 | `''` | `'₪500'` |
| 3 | -500 | `''` | `'-₪500'` (מינוס לפני ₪) |
| 4 | 1200 | `'סה"כ '` | `'סה"כ ₪1200'` (prefix בהתחלה) |
| 5 | -1 | `'X'` | `'X-₪1'` |

**⚠️ קוריוז-מקור מתועד:** ה-stub `x.abs()` נבחר כדי לבודד את הרכבת-האטום.
`groupThousands` האמיתי מקבל את **‏n החתום**; אם הוא בעצמו מוסיף מינוס לשלילי,
הפלט יישא מינוס-כפול (`'-₪-500'`) — התנהגות-המקור verbatim, לא באג-של-האטום.

## שקעים
- `groupThousands` — הזרקת-פונקציה (חוק-3). הבדיקה מזריקה stub דטרמיניסטי (`x.abs()`).

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/format_nis_test.dart  ⇒ exit 0 + "OK formatNis: N asserts passed"
```
