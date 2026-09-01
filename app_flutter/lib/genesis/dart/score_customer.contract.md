# חוזה · `scoreCustomer` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/customer_score.dart:65-110`.
הקובץ אינו קיים עוד ⇒ הטיוטה = מקור-האמת.

## חתימה
```dart
CustomerScore scoreCustomer(RfmInput input, {
  num freqHigh = 5, num freqMid = 2,
  num moneyHigh = 1000, num moneyMid = 300,
  int recentDays = 30, int staleDays = 90,
})
```
`RfmInput{int orderCount, num totalSpend, int? recencyDays}` ·
`CustomerScore{int r,f,m,points,maxPoints; String tier; bool atRisk}` — שניהם הוטבעו inline.

## הטבעות ושקעים
- `_band(v,high,mid)` — גופו **אינו בטיוטה**; הוסק `v>=high?2:v>=mid?1:0` מהחשבון
  (‏maxPoints=6, 3 רכיבים ⇒ כל אחד ∈{0,1,2}).
- ששת-הספים — const-שכנים לא-ניתנים-לשחזור, שקעים; ברירות-המחדל מוסקות ומתועדות.

## פלט / התנהגות (עוגני-שורה)
- `:66-67` — `f = _band(orderCount, freqHigh, freqMid)`, `m = _band(totalSpend, moneyHigh, moneyMid)`.
- `:70-79` — recency `r`: `null→-1` · `<=recentDays→2` · `<=staleDays→1` · אחרת `0`.
- `:81-82` — `hasR = r>=0`; `points = f+m+(hasR?r:0)`.
- `:83` — `maxPoints = hasR ? 6 : 4`.
- `:84` — `ratio = maxPoints==0 ? 0.0 : points/maxPoints`.
- `:86-95` — tier: `≥0.75 champion` · `≥0.5 loyal` · `≥0.25 occasional` · אחרת `dormant`.
- `:98` — `atRisk = hasR && r==0 && (f+m)>=3`.

## דוגמאות (ספי-ברירת-מחדל: freqHigh5/Mid2, moneyHigh1000/Mid300, recent30, stale90)
| # | orderCount | totalSpend | recencyDays | ⇒ f,m,r · points/max · tier · atRisk |
|---|-----------|-----------|-------------|--------------------------------------|
| 1 | 6 | 2000 | 10 | f2 m2 r2 · 6/6 · champion · false |
| 2 | 6 | 2000 | 200 | f2 m2 r0 · 4/6 · loyal · **true** (היה-בעל-ערך, התקרר) |
| 3 | 0 | 0 | `null` | f0 m0 r-1 · 0/4 · dormant · false |
| 4 | 3 | 500 | 50 | f1 m1 r1 · 3/6 · loyal · false |
| 5 | 3 | 500 | 200 | f1 m1 r0 · 2/6 · occasional · false (f+m=2<3) |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/score_customer.dart                    ⇒ No issues found!
dart run --enable-asserts new/dart/score_customer_test.dart  ⇒ exit 0 + "OK scoreCustomer: N asserts passed"
```
