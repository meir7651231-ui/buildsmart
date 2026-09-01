# חוזה · `generateCsvTemplate` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/trade_import.dart:36-232`.
⚠️ קובץ-המקור **נמחק מהעץ-החי** (find/grep ריקים 2026-08-26) — הטיוטה במחצב היא מקור-האמת.
שני שקעים (חוק-3): `defNames` (קיפול `defs.map((d)=>d.nameHe)`) · `fixedColumns`
(ה-const `kImportFixedColumns` בלתי-בר-שחזור ⇒ סוקק במקום זיוף, דיבר-9).

## חתימה
```dart
String generateCsvTemplate(List<String> defNames, {required List<String> fixedColumns})
```

## פלט / התנהגות (עוגני-שורה)
- מקור: `header = [...kImportFixedColumns, for (final d in defs) d.nameHe]`.
- `blankRow = List.filled(header.length, '').join(',')` — `count-1` פסיקים.
- החזרה: `'${header.join(',')}\n$blankRow'` — שתי שורות, מופרדות `\n`.

## דוגמאות מספריות
| # | fixedColumns | defNames | ⇒ |
|---|--------------|----------|---|
| 1 | `['sku','name','cat']` | `['צבע']` | `"sku,name,cat,צבע\n,,,"` (4 עמודות ⇒ 3 פסיקים) |
| 2 | `['sku','name','cat']` | `[]` | `"sku,name,cat\n,,"` (3 עמודות ⇒ 2 פסיקים) |
| 3 | `['a']` | `['b','c']` | `"a,b,c\n,,"` |
| 4 | `[]` | `[]` | `"\n"` (0 עמודות ⇒ כותרת ריקה + שורה ריקה) |
| 5 | `['x']` | `[]` | `"x\n"` (עמודה יחידה ⇒ 0 פסיקים) |

## שקעים
- `defNames` · `fixedColumns` — הזרקת-רשימות (חוק-3).
- `List.filled`, `Iterable.join`, אינטרפולציה — שפה/סטנדרט.

## DoD
```
dart run --enable-asserts new/dart/generate_csv_template_test.dart  ⇒ exit 0 + "OK generateCsvTemplate: N asserts passed"
```
