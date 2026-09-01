# חוזה · `criticalOpen` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/install_engine.dart:976-978`
(‏`criticalOpen` — מתודה במקור ⇒ top-level).

**שקע:** `compliance(tempC, accessories)` הומר לשקע `compliance` (חוק-3). ה-enum
`CheckSeverity.critical` צומצם לשדה-bool `critical` ברשומת-הפריט (רק הבחנת "קריטי" נצרכת).
במקור `accessories` הוא פרמטר-מיקום אופציונלי `[... = const {}]` ⇒ הומר ל-named עם אותה ברירת-מחדל.

## חתימה
```dart
int criticalOpen(int tempC, {
  Set<String> accessories = const {},
  required List<({bool satisfied, bool critical})> Function(int, Set<String>) compliance,
})
```

## קלט
- `tempC` — טמפרטורת-הקו; מועברת אל השקע.
- `accessories` — קבוצת-אביזרים (ברירת-מחדל ריקה); מועברת אל השקע.
- `compliance` — **שקע**: צ'ק-ליסט-התאימות כרשומות `satisfied`/`critical`.

## פלט / התנהגות (עוגני-שורה)
- `:976-978` — `compliance(tempC, accessories).where((c) => !c.satisfied && c.severity==CheckSeverity.critical).length`
  ⇒ באטום `!c.satisfied && c.critical`. ספירת פריטים שגם לא-מסופקים וגם קריטיים.

## דוגמאות (רשומות = הפלט של השקע)
| # | פריטים (satisfied, critical) | ⇒ |
|---|------------------------------|---|
| 1 | `[(F,T),(T,T),(F,F)]` | `1` (רק (F,T)) |
| 2 | `[]` (ריק) | `0` |
| 3 | `[(T,T),(T,T)]` (כולם מסופקים) | `0` |
| 4 | `[(F,T),(F,T),(F,F)]` | `2` |
| 5 | `[(F,F),(F,F)]` (לא-קריטיים) | `0` |

## שקעים
- `compliance` — מוזרק. הבדיקה מזריקה רשימות-קבועות ומאמתת שהספירה עוברת דרך tempC/accessories.

## DoD
```
dart run --enable-asserts new/dart/critical_open_test.dart  ⇒ exit 0 + "OK criticalOpen: N asserts passed"
```
