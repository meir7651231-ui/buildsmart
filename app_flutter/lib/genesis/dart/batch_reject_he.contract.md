# חוזה · `batchRejectHe` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:456-457` (‏`_batchRejectHe`).

## תפקיד
הודעת-דחייה עברית ל-scope רחב-מדי (מעל תקרת-האצווה).

## חתימה
```dart
String batchRejectHe(int count, {required int maxBatch})
```

## התנהגות (עוגן edit_intent.dart:456-457)
`'השינוי נרחב מדי — $count יעדים (מעל התקרה $maxBatch). צמצם את הטווח.'`

## שקעים
- `maxBatch` — **שקע** (חוק-3): במקור const-מודול `kStudioMaxBatch` (אינו בטיוטה; ערך-המקור לא-נגיש). מוזרק כ-slot, כדפוס branch_label/letters.

## דוגמאות-מחייבות
| # | count | maxBatch | ⇒ |
|---|-------|----------|---|
| 1 | 42 | 20 | 'השינוי נרחב מדי — 42 יעדים (מעל התקרה 20). צמצם את הטווח.' |
| 2 | 0 | 5 | '...0 יעדים (מעל התקרה 5)...' |
| 3 | 1000 | 999 | '...1000 יעדים (מעל התקרה 999)...' |

## DoD
```
dart run --enable-asserts new/dart/batch_reject_he_test.dart  ⇒ exit 0 + "OK batchRejectHe: 3 asserts passed"
```
