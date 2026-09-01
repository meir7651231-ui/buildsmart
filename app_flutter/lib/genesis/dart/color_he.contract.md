# חוזה · `colorHe` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/diff_preview.dart:196-206` (‏`_colorHe`).

## תפקיד
תרגום token-צבע אנגלי לשם-צבע עברי; token לא-מוכר ⇒ מוחזר כמות-שהוא (ברירת-מחדל `_`).

## חתימה
```dart
String colorHe(String token)
```

## התנהגות (עוגן diff_preview.dart:196-206)
switch מפורש על 7 tokens; `_ => token`. תלוי רישיות (case-sensitive).

## דוגמאות-מחייבות
| # | token | ⇒ |
|---|-------|---|
| 1 | success | ירוק |
| 2 | danger | אדום |
| 3 | warn | כתום |
| 4 | muted | אפור |
| 5 | ink | כהה |
| 6 | brand | מותג |
| 7 | brandDark | מותג כהה |
| 8 | purple (לא-מוכר) | purple |
| 9 | '' | '' |
| 10 | Brand (רישיות) | Brand |

## שקעים
אין.

## DoD
```
dart run --enable-asserts new/dart/color_he_test.dart  ⇒ exit 0 + "OK colorHe: 10 asserts passed"
```
