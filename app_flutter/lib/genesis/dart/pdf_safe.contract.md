# חוזה · `pdfSafe` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/finance_report_pdf.dart:38-48`
(‏`_pdfSafe`, פרטי-במקור). מקודם ל-public (כלל-הגלגול). מנקה טקסט לפני הזרקה
ל-PDF: משאיר רק תווים שהגופן/ה-RTL מטפלים בהם נכון.

## חתימה
```dart
String pdfSafe(String s)
```

## קלט
- `s` — טקסט חופשי (למשל שם-סעיף בדוח).

## התנהגות (עוגני-שורה)
- `finance_report_pdf.dart:41-44` — משמר רונה אם: עברית `0x0590..0x05FF`
  **או** ASCII-נדפס `0x0020..0x007E` **או** `0x20AA` (₪). כל השאר מושמט.
- `:46` — התוצאה עוברת `trim` (מסיר רווחים מובילים/נגררים שנותרו).
- טאב/שורה-חדשה (`0x09`/`0x0A`) < `0x20` ⇒ מושמטים.

## דוגמאות מספריות
| # | s | ⇒ |
|---|---|---|
| 1 | `'שלום עולם'` | `'שלום עולם'` (עברית + רווח-ASCII) |
| 2 | `'Budget: 500'` | `'Budget: 500'` |
| 3 | `'₪1,234'` | `'₪1,234'` (₪ נשמר) |
| 4 | `'café ☕'` | `'caf'` (é ו-☕ מושמטים, הרווח-הנגרר נחתך) |
| 5 | `'  hi  '` | `'hi'` (trim) |
| 6 | `'a\tb\nc'` | `'abc'` (טאב/newline מושמטים) |
| 7 | `''` | `''` |

## שקעים
אין. `String.runes`/`StringBuffer.writeCharCode`/`trim` — שפה בלבד.

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/pdf_safe_test.dart  ⇒ exit 0 + "OK pdfSafe: N asserts passed"
```
