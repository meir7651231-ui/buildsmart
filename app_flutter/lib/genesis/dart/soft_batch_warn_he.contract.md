# חוזה · `softBatchWarnHe` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:373-376`
(‏`softBatchWarnHe`). שאר-הטיוטה (‏`_reasonToBlock`) אינו היעד. הקובץ אינו קיים עוד ⇒
הטיוטה = מקור-האמת.

## חתימה
```dart
String? softBatchWarnHe(int opCount, {int softWarn = 5, int maxBatch = 20})
```

## שקעים (חוק-3)
`kStudioSoftBatchWarn`/`kStudioMaxBatch` — const-שכנים לא-ניתנים-לשחזור. הורמו לשקעים;
ברירות-המחדל (5 / 20) מוסקות מהסמנטיקה של השמות ("אזהרה-רכה" נמוך, "מקסימום-אצווה" גבוה)
ומתועדות ככאלה. הבדיקה מעבירה ספים מפורשים.

## פלט / התנהגות (עוגני-שורה)
- `edit_safety.dart:374-376` — טווח **סגור-דו-צדדי**:
  - `softWarn <= opCount <= maxBatch` ⇒ `'שים לב — $opCount פעולות בבת אחת. אפשר להמשיך, או לצמצם.'`.
  - אחרת (`opCount < softWarn` **או** `opCount > maxBatch`) ⇒ `null`.
- הודעה מתחת-לסף = null (עדיין לא-מזהיר); מעל-המקסימום = null (חסימה קשה נעשית במקום אחר).

## דוגמאות (softWarn=5, maxBatch=20)
| # | opCount | ⇒ |
|---|---------|---|
| 1 | 4 | `null` (מתחת לסף) |
| 2 | 5 | `'שים לב — 5 פעולות בבת אחת. אפשר להמשיך, או לצמצם.'` (קצה-תחתון כולל) |
| 3 | 12 | `'שים לב — 12 פעולות בבת אחת. אפשר להמשיך, או לצמצם.'` |
| 4 | 20 | `'שים לב — 20 פעולות בבת אחת. אפשר להמשיך, או לצמצם.'` (קצה-עליון כולל) |
| 5 | 21 | `null` (מעל המקסימום) |
| 6 | 0 | `null` |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/soft_batch_warn_he.dart                    ⇒ No issues found!
dart run --enable-asserts new/dart/soft_batch_warn_he_test.dart  ⇒ exit 0 + "OK softBatchWarnHe: N asserts passed"
```
