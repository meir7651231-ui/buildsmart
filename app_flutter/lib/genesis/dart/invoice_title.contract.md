# חוזה · `invoiceTitle` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/invoice.dart:45-47`.
⚠️ קובץ-המקור **נמחק מהעץ-החי** (find ריק 2026-08-26) — הטיוטה במחצב היא מקור-האמת.
הקריאה-לשכן `order.id` קופלה לשקע `orderId` (חוק-3; Order טיפוס-שכן גדול, לא-inline).

## חתימה
```dart
String invoiceTitle(String orderId, {required bool receipt})
```

## פלט / התנהגות (עוגני-שורה)
- מקור: `'${receipt ? 'קבלה' : 'חשבונית'} — ${order.id}'`.
- המפריד הוא הרצף `' — '` (רווח · מקף-אם U+2014 · רווח) verbatim מהמקור.

## דוגמאות מספריות
| # | orderId | receipt | ⇒ |
|---|---------|---------|---|
| 1 | `'ORD-1'` | `true` | `'קבלה — ORD-1'` |
| 2 | `'ORD-1'` | `false` | `'חשבונית — ORD-1'` |
| 3 | `'42'` | `true` | `'קבלה — 42'` |
| 4 | `''` | `false` | `'חשבונית — '` (id ריק — נאמנות-מקור) |

## שקעים
- `orderId` — הזרקת-מזהה (חוק-3, קיפול `order.id`).
- אינטרפולציה, ternary — שפה/סטנדרט.

## DoD
```
dart run --enable-asserts new/dart/invoice_title_test.dart  ⇒ exit 0 + "OK invoiceTitle: N asserts passed"
```
