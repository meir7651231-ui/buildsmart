# חוזה · `parseBore` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/brand_profile.dart:292-310`
(‏`parseBore`, מתודת-מופע על `BrandProfile`). ממצה קוטר-פנימי (bore, מ"מ) ממפת-מידות.

## הטבעה/שקעים
- `boreDimsKey`, `boreParse` — שדות-מופע במקור ⇒ **שקעים** (חוק-3).
- `BoreParseStrategy` — enum-אח, **הוטבע verbatim** (שלושת ה-case בגוף-הטיוטה):
  `diRangeMax` · `dnDirect` · `none`.
- `kDiRangeNumberPattern` — const-אח (RegExp). ערכו לא בגוף-הטיוטה והמקור אינו
  בריפו ⇒ **הוסק** ל-`\d+(?:\.\d+)?` (מספרים שלמים/עשרוניים). **דגל-סיכון**: אם
  המקור-החי מרחיב — לעדכן; הגולדן מאפיין את ההטבעה הזו.

## חתימה
```dart
double? parseBore(Map<String,dynamic>? dims, {required String? boreDimsKey, required BoreParseStrategy boreParse})
```

## התנהגות (עוגני-שורה)
- `brand_profile.dart:293-294` — `boreDimsKey == null` ⇒ `null`.
- `:295` — `raw = dims?[key]?.toString()` (null אם המפה null או השדה חסר).
- `:296-305` (`diRangeMax`) — כל המספרים ב-`raw` דרך הדפוס; ריק ⇒ `null`,
  אחרת ה**מקסימום** (קצה-הטווח העליון).
- `:306` (`dnDirect`) — `raw == null ? null : double.tryParse(raw)`.
- `:308` (`none`) — תמיד `null`.

## דוגמאות מספריות
| # | dims | boreDimsKey | boreParse | ⇒ |
|---|------|-------------|-----------|---|
| 1 | `{}` | `null` | `dnDirect` | `null` (אין מפתח) |
| 2 | `{'di':'13.6–14.7'}` | `'di'` | `diRangeMax` | `14.7` (מקס-טווח) |
| 3 | `null` | `'di'` | `diRangeMax` | `null` (מפה null) |
| 4 | `{'di':'N/A'}` | `'di'` | `diRangeMax` | `null` (אין מספרים) |
| 5 | `{'dn':'50'}` | `'dn'` | `dnDirect` | `50.0` |
| 6 | `{'dn':'abc'}` | `'dn'` | `dnDirect` | `null` (tryParse נכשל) |
| 7 | `{'dn':'50'}` | `'dn'` | `none` | `null` (אסטרטגיית-none) |

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/parse_bore_test.dart  ⇒ exit 0 + "OK parseBore: N asserts passed"
```
