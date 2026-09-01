# חוזה · `pressureDropToString` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/pressure_drop.dart:183-187`
(‏`PressureDropResult.toString`). מתודת-מופע ⇒ פורקה לפורמטר-טהור top-level.

## חתימה
```dart
String pressureDropToString({
  required double dropBar,
  required double totalK,
  required double frictionMetres,
  required double minBoreMm,
  required String? bottleneckSku,
})
```

## שקעים (חוק-3)
- השדות-שנקראו במתודה הוזרקו כפרמטרים: `dropBar`/`totalK`/`frictionMetres`/`minBoreMm`
  (‏`double`), ו-`bottleneck?.sku` ⇒ `bottleneckSku` (‏`String?`).

## פלט / התנהגות (עוגני-שורה)
- `pressure_drop.dart:184-187` — מחרוזת:
  `'ΔP = ${dropBar.toStringAsFixed(2)} bar  (K=${totalK.toStringAsFixed(2)}, L=${frictionMetres.toStringAsFixed(1)}m, minBore=${minBoreMm.toStringAsFixed(1)}mm, bottleneck=${bottleneckSku ?? "—"})'`.
  - `dropBar`, `totalK` — 2 ספרות-עשרוניות; `frictionMetres`, `minBoreMm` — ספרה אחת.
  - **רווח-כפול** אחרי `bar` (verbatim מהמקור).
  - `bottleneckSku == null` ⇒ המקף `"—"` (U+2014).

## דוגמאות מספריות (‏toStringAsFixed אומת מול ה-SDK)
| # | dropBar | totalK | frictionMetres | minBoreMm | bottleneckSku | ⇒ |
|---|---------|--------|----------------|-----------|---------------|---|
| 1 | 0.5 | 3.2 | 5.0 | 13.0 | `'PIPE-A'` | `ΔP = 0.50 bar  (K=3.20, L=5.0m, minBore=13.0mm, bottleneck=PIPE-A)` |
| 2 | 0.5 | 3.2 | 5.0 | 13.0 | `null` | `ΔP = 0.50 bar  (K=3.20, L=5.0m, minBore=13.0mm, bottleneck=—)` |
| 3 | 1.239 | 0.0 | 12.34 | 12.34 | `'X'` | `ΔP = 1.24 bar  (K=0.00, L=12.3m, minBore=12.3mm, bottleneck=X)` |
| 4 | 100.0 | 100.0 | 100.0 | 100.0 | `''` | `ΔP = 100.00 bar  (K=100.00, L=100.0m, minBore=100.0mm, bottleneck=)` |

(בדוגמה 4: `bottleneckSku=''` אינו null ⇒ מוצג ריק, לא מקף.)

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/to_string_test.dart  ⇒ exit 0 + "OK pressureDropToString: N asserts passed"
```
