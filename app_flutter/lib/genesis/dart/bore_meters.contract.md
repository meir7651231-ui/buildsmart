# חוזה · `boreMeters` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/pressure_drop.dart:72-93`
(‏`_boreMeters`). המפה-שקע: const-מקומית `inchToMm` ב-`pressure_drop.dart:85-88`.
טיפוסי-הקלט: `EndType` (`lipskey_verified_connections.dart:24`), `ConnectorEnd` (:32).

## חתימה
```dart
double? boreMeters(ConnectorEnd e, {required Map<String, int> bspInchToMm})
```

## קלט
- `e.type` — ‏`EndType` (6 ערכים סגורים: hdpeCompression · pexPress · copperPress ·
  bspMale · bspFemale · drainOpening).
- `e.size` — מחרוזת-מידה. עבור DN: ספרה שלמה ("32"). עבור BSP: אינץ׳ עם/בלי `"` ("1/2\"").
- `bspInchToMm` — **שקע** (חוק-3): מפת אינץ׳→מ״מ. ערכי-המקור (‏pressure_drop.dart:85-88):
  `{'1/4':8, '3/8':10, '1/2':15, '3/4':20, '1':25, '1-1/4':32, '1-1/2':40, '2':50, '2-1/2':65}`.

## פלט / התנהגות (עוגני-שורה)
- `pressure_drop.dart:75-81` — אם `type ∈ {hdpeCompression, pexPress, copperPress, drainOpening}`:
  `dn = int.tryParse(size)`; אם `dn != null` ⇒ **`dn / 1000.0`** (מ״מ→מטר). אחרת נופל הלאה.
- `pressure_drop.dart:83-88` — אם `type ∈ {bspMale, bspFemale}`:
  מסירים `"` ו-trim, מחפשים במפה; אם קיים ⇒ **`mm / 1000.0`**. אחרת נופל הלאה.
- `pressure_drop.dart:89` — בכל מקרה אחר ⇒ **`null`**.
- דין-קצה מהמקור: קבוצת-DN שמידתה אינה שלם (‏`int.tryParse`=null, למשל "1/2")
  **אינה** מוחזרת בענף-ה-DN, ממשיכה לענף-BSP (שנכשל לטיפוס-DN) ⇒ `null`.

## דוגמאות מספריות (מקריאת-הקוד+המפה)
| # | type | size | ⇒ |
|---|------|------|---|
| 1 | hdpeCompression | `"32"` | `0.032` |
| 2 | drainOpening | `"50"` | `0.050` |
| 3 | pexPress | `"16"` | `0.016` |
| 4 | copperPress | `"22"` | `0.022` |
| 5 | bspMale | `1/2"` | `0.015` (‏map['1/2']=15) |
| 6 | bspFemale | `3/4"` | `0.020` (‏map['3/4']=20) |
| 7 | bspMale | `1` (בלי `"`) | `0.025` (‏map['1']=25) |
| 8 | bspMale | `2-1/2"` | `0.065` (‏map['2-1/2']=65) |
| 9 | hdpeCompression | `"0"` | `0.0` (‏tryParse("0")=0, לא-null) |
| 10 | hdpeCompression | `"1/2"` | `null` (‏tryParse נכשל ⇒ ענף-BSP לא-חל) |
| 11 | bspMale | `5/8"` | `null` (לא במפה) |
| 12 | bspFemale | `2` | `0.050` (‏map['2']=50; בלי גרש — trim בלבד) |
| 13 | bspMale | `" 1/2\" "` | `0.015` (הסרת-גרש+trim) |
| 14 | hdpeCompression | `"-5"` | `-0.005` (‏tryParse("-5")=-5 — נאמנות-מקור) |

## שקעים
- `bspInchToMm` — הזרקת-מפה. הבדיקה מספקת את ערכי-המקור verbatim.
- `int.tryParse`, `String.replaceAll`, `String.trim` — שפה/סטנדרט (לא-שקע).

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/bore_meters_test.dart  ⇒ exit 0 + "OK boreMeters: N asserts passed"
```
