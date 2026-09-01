# חוזה · `minBoreMmOf` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/install_engine.dart:852-874`
(‏`_minBoreMmOf`, פרטי-במקור). מקודם ל-public (כלל-הגלגול). הקוטר-הפנימי המינימלי
(מ"מ) על-פני קצוות-מוצר — הצוואר-ההידראולי.

## הטבעה/שקעים
- `kVerifiedSpecs[p.sku]` (const-קטלוג ענק) — במקור: SKU→מפרט→קצוות. **סוקט** ע"י
  הזרקת `ends` ישירות. `spec == null` (מקור) ≡ `ends == null` (כאן) ⇒ `null`.
- `kBspInchToMm` (const-מפה, ערכיה חסרים מהטיוטה) ⇒ **שקע** `bspInchToMm`
  (‏`Map<String,double>` — במקור `num` עם `.toDouble()`; שקיל).
- `EndType` — enum-אח, **הוטבע verbatim** (ששת ה-case בגוף-הטיוטה).
- קצה = **record** `({EndType type, String size})` (טיפוס-שכן קטן inline).

## חתימה
```dart
double? minBoreMmOf({required List<({EndType type, String size})>? ends, required Map<String,double> bspInchToMm})
```

## התנהגות (עוגני-שורה)
- `install_engine.dart:853-854` — אין מפרט ⇒ `null` (כאן `ends == null`).
- `:857-866` — לכל קצה: `hdpeCompression|pexPress|copperPress|drainOpening` ⇒
  `double.tryParse(e.size)` (מטרי-ישיר); `bspMale|bspFemale` ⇒
  `bspInchToMm[e.size.replaceAll('"','').trim()]` (תווית-אינץ' ⇒ מ"מ).
- `:869-871` — `mm == null` ⇒ מדלגים; אחרת מעדכנים את המינימום.
- `:873` — מחזירים את המינימום (או `null` אם אף קצה לא פוּרק).

## דוגמאות (‏bspInchToMm = `{'1': 25.0, '3/4': 20.0}`)
| # | ends | ⇒ |
|---|------|---|
| 1 | `null` | `null` (אין מפרט) |
| 2 | `[]` | `null` (אין קצוות) |
| 3 | `[(copperPress,'22')]` | `22.0` |
| 4 | `[(copperPress,'22'),(pexPress,'16')]` | `16.0` (מינימום) |
| 5 | `[(bspFemale,'3/4"')]` | `20.0` (תווית-אינץ' ⇒ מ"מ) |
| 6 | `[(drainOpening,'abc')]` | `null` (לא-פריק ⇒ מדולג) |
| 7 | `[(copperPress,'22'),(bspMale,'1"')]` | `22.0` (מטרי<BSP) |

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/min_bore_mm_of_test.dart  ⇒ exit 0 + "OK minBoreMmOf: N asserts passed"
```
