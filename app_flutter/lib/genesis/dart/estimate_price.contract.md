> ♻️ **מנוע-נקי (הכרעת-בעלים "טהור כמו בתולה"):** הטבלה+fallback חולצו לדאטה מוזרקת (`priceTable`/`fallbackIls`). המנוע=מנגנון-בלבד; הדאטה ב-`dart-data/pipe-prices.dart`. התנהגות זהה-ביט כשמזריקים את טבלת-המקור+25.

# חוזה · `estimatePrice` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/price_estimate.dart:90-109`
(‏`estimatePrice`). שני שכנים הוטבעו verbatim (חוק-1): הטבלה `_categoryPriceILS`
(‏:12-72, grep יחיד — הטיוטה חסרת-ערכים) והמחלקה `PriceEstimate` (‏:74-85). הקלט
הפך גנרי והשדה `p.categoryHe` הפך שקע (חוק-3/6).

## חתימה
```dart
PriceEstimate estimatePrice<T>(List<T> items, {required String Function(T) categoryHe})
// PriceEstimate { int totalILS; int itemCount; bool lowConfidence; }
```

## קלט
- `items` — רשימת-מוצרים (גנרית).
- `categoryHe` — **שקע**: במקור `p.categoryHe`.

## פלט / התנהגות (עוגני-שורה)
- `price_estimate.dart:91-93` — `items.isEmpty` ⇒ `PriceEstimate(0, 0, lowConfidence:true)`.
- `price_estimate.dart:97` — לכל פריט: `v = _categoryPriceILS[categoryHe(p)]`.
- `price_estimate.dart:98-100` — התאמה (v≠null) ⇒ `total += v; matched++`.
- `price_estimate.dart:101-102` — אין-התאמה ⇒ `total += 25` (fallback גנרי; לא סופר matched).
- `price_estimate.dart:106` — `lowConfidence = matched < items.length / 2`
  (השוואת num — `items.length/2` הוא double).
- `itemCount = items.length` (כולל הלא-מותאמים).

**דגימת-מחירים מהטבלה (verbatim):** `'ברזי מטבח'`=420 · `'אביזרי נחושת'`=18 ·
`'אביזרי תבריג'`=15 · `'אטמים ופקקים'`=8 · `'מערכות אמבטיה'`=950.

## דוגמאות מספריות
| # | categories | total | count | matched | lowConf | נימוק |
|---|-----------|-------|-------|---------|---------|-------|
| 1 | `[]` | 0 | 0 | — | true | ריק ⇒ lowConf קבוע true |
| 2 | `['ברזי מטבח']` | 420 | 1 | 1 | false | 1 < 0.5 שקר |
| 3 | `['לא-קיים']` | 25 | 1 | 0 | true | fallback 25; 0 < 0.5 |
| 4 | `['ברזי מטבח','לא-קיים']` | 445 | 2 | 1 | false | 1 < 1.0 שקר |
| 5 | `['ברזי מטבח','x','y']` | 470 | 3 | 1 | true | 1 < 1.5 אמת (420+25+25) |
| 6 | `['אביזרי נחושת','אביזרי תבריג']` | 33 | 2 | 2 | false | 2 < 1.0 שקר |

## שקעים
- `categoryHe` — הזרקת-ריאדר (חוק-3). הטבלה עצמה **מוטבעת** (דאטה-מקור), כך שהגולדן
  מאמת מספרי-מחיר אמיתיים + חוק-הביטחון-הנמוך.

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/estimate_price_test.dart  ⇒ exit 0 + "OK estimatePrice: N asserts passed"
```
