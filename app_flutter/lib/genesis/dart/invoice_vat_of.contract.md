# חוזה · `invoiceVatOf` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/invoice.dart:19-44`.
⚠️ קובץ-המקור **נמחק מהעץ-החי** (find/grep ריקים 2026-08-26) — הטיוטה במחצב היא מקור-האמת.
ה-const `kVatRate` **בלתי-בר-שחזור** ⇒ סוקק כ-`vatRate` במקום זיוף-ערך (דיבר-9).

## חתימה
```dart
int invoiceVatOf(int grossTotal, {required double vatRate})
```

## פלט / התנהגות (עוגני-שורה)
- מקור: `grossTotal - (grossTotal / (1 + kVatRate)).round()`.
- החלוקה ב-double, `.round()` = חצי-מתרחק-מאפס (סמנטיקת `double.round` של Dart).

## דוגמאות מספריות
| # | grossTotal | vatRate | ביניים `round(g/(1+r))` | ⇒ |
|---|-----------|---------|--------------------------|---|
| 1 | `118` | `0.18` | round(100.0)=100 | `18` |
| 2 | `1180` | `0.18` | round(1000.0)=1000 | `180` |
| 3 | `59` | `0.18` | round(50.0)=50 | `9` |
| 4 | `100` | `0.18` | round(84.745)=85 | `15` |
| 5 | `117` | `0.17` | round(100.0)=100 | `17` |
| 6 | `0` | `0.18` | round(0)=0 | `0` |
| 7 | `1` | `0.18` | round(0.847)=1 | `0` |

## שקעים
- `vatRate` — הזרקת-שיעור (חוק-3/דיבר-9; const בלתי-בר-שחזור).
- `int`/`double` אריתמטיקה, `double.round` — שפה/סטנדרט.

## DoD
```
dart run --enable-asserts new/dart/invoice_vat_of_test.dart  ⇒ exit 0 + "OK invoiceVatOf: N asserts passed"
```
