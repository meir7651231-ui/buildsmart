# חוזה · `retentionPct` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/intel/segments.dart:176-177`
(‏`RetentionCohort.retentionPct`). מתודה על מחלקה-שכנה; שאר-הטיוטה אינו היעד. הקובץ אינו
קיים עוד ⇒ הטיוטה = מקור-האמת.

## חתימה
```dart
double retentionPct(int dayOffset, {
  required int size,
  required int Function(int dayOffset) returning,
  double percentScale = 100,
})
```

## שקעים (חוק-3 — מצב-המחלקה הוסב)
- `size` = `RetentionCohort.size`.
- `returning` = המתודה-האחות `returning(dayOffset)` (מספר החוזרים ביום-ההיסט).
- `percentScale` = `_kPercentScale` (const-שכן לא-ניתן-לשחזור). ברירת-המחדל `100` מוסקת
  מהסמנטיקה ("percent") ומתועדת.

## פלט / התנהגות (עוגני-שורה)
- `segments.dart:176-177` — `size == 0 ? 0 : returning(dayOffset) / size * percentScale`:
  - `size == 0` ⇒ `0.0` (קוהורט ריק — הגנת-חלוקה-באפס).
  - אחרת ⇒ `returning(dayOffset) / size * percentScale` (חלוקת-`double`, אחוז).
- נאמנות: אין הגנה על `returning > size` (יכול להחזיר אחוז > 100) — לא-שיפור.

## דוגמאות (size=10, returning: 0→10, 1→5, 2→0, percentScale=100)
| # | dayOffset | ⇒ |
|---|-----------|---|
| 1 | 0 | `100.0` (10/10×100 — יום-0 תמיד מלא) |
| 2 | 1 | `50.0` (5/10×100) |
| 3 | 2 | `0.0` (0/10×100) |
| 4 | 99 (returning 0) | `0.0` |
| 5 | size=0 | `0.0` (הגנת-אפס, בכל dayOffset) |
| 6 | returning 20, size 10 | `200.0` (נאמנות — אין תקרת-100) |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/retention_pct.dart                    ⇒ No issues found!
dart run --enable-asserts new/dart/retention_pct_test.dart  ⇒ exit 0 + "OK retentionPct: N asserts passed"
```
