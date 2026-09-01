# חוזה · `contractorCredit` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/manager_dashboard.dart:263-278`.
כל ה-const-ים (`lo`/`hi`/`span`) הם עוזרי-מקום פרטיים בגוף-המקור ⇒ מוטבעים inline verbatim.
אין קריאה-לשכן ⇒ אין שקע.

## חתימה
```dart
int contractorCredit(String name)
```

## קלט
- `name` — שם-הקבלן (String, כל תוכן). האטום קורא `name.hashCode.abs()`.

## פלט / התנהגות (עוגני-שורה)
- `manager_dashboard.dart:271` — `h = name.hashCode.abs()` (‏hash לא-שלילי).
- `:272` — `raw = 30000 + (h % 90001)` ⇒ `raw ∈ [30000, 120000]`.
- `:273` — `return (raw ~/ 100) * 100` ⇒ עיגול-מטה למכפלת-100.
- **טווח**: הפלט תמיד ‏`30000 ≤ x ≤ 120000` ותמיד `x % 100 == 0`.
- **דטרמיניסטיות**: אותה מחרוזת ⇒ אותו פלט (idempotent) בתוך אותו SDK.
- דין-קצה: מחרוזת ריקה `''` ⇒ `hashCode == 1` (קבוע ב-Dart VM) ⇒ `raw = 30001` ⇒ `30000`.

## דוגמאות מספריות (נצפו על Dart SDK 3.5.4 — hashCode דטרמיניסטי)
| # | name | hashCode | ⇒ |
|---|------|----------|---|
| 1 | `''` (ריק) | 1 | `30000` (‏30001→עיגול-מטה) |
| 2 | `'a'` | 170824770 | `32800` |
| 3 | `'אבי'` | 1012240888 | `119600` |
| 4 | `'דוד לוי'` | 1056795669 | `33900` |

## שקעים
- אין. hashCode/abs/‏% /~/ — שפה/סטנדרט (dart:core).

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/contractor_credit_test.dart  ⇒ exit 0 + "OK contractorCredit: N asserts passed"
```
