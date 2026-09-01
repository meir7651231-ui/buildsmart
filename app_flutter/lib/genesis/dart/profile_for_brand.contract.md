# חוזה · `profileForBrand` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/brand_profile.dart:435-436`
(הקובץ קיים רק ב-commit ‏`6a7fdd79` בריפו buildsmart — ענף `claude/align-main`;
נקרא במלואו לאימות ההתנהגות):
```dart
BrandProfile profileForBrand(String? brandName) =>
    kBrandProfiles[brandName] ?? kLipskeyProfile;
```

## חתימה
```dart
T profileForBrand<T>(String? brandName, {required Map<String, T> profiles, required T fallback})
```

## שקעים (חוק-3 · הכרעת "אפס דאטה-צרובה במנוע", תקדים estimate_price)
- `profiles` — שקע במקום ה-const ‏`kBrandProfiles` (‏brand_profile.dart:425-429 — מפה לפי
  מחרוזות-המותג המדויקות של סולמות-ה-if: 'פולירול' / 'חוליות' / 'ליפסקי').
- `fallback` — שקע במקום ה-const ‏`kLipskeyProfile` (‏:416-422 — התנהגות-ה-else של כל סולם).
- `BrandProfile` ⇒ גנרי `T` (הטיפוס נושא דאטה-קטלוג + ‏WaterSystem חיצוני — לא מוטבע;
  המנוע הוא lookup-עם-fallback טהור, אדיש לצורת-הפרופיל).

## פלט / התנהגות (עוגני-שורה)
- `brand_profile.dart:436` — ‏lookup ישיר `profiles[brandName]`; קיים ⇒ מוחזר הערך.
- `:436` — לא-קיים **או** `brandName == null` ⇒ `fallback` (‏`??`). ב-Dart ‏`operator []`
  של Map מקבל `Object?` ⇒ מפתח null חוקי ומחזיר null ⇒ fallback.
- **אפס נרמול**: אין trim/lowercase — המפתח מושווה כמו-שהוא (‏:431-434: כל מחרוזת
  שאינה מפתח מדויק — כולל AQUATEC — מתנהגת כ-else/ליפסקי).
- לעולם לא זורק; לעולם לא מחזיר null (‏`fallback` תמיד קיים).

## דוגמאות מספריות
שקע: `profiles = {'פולירול': 'P', 'חוליות': 'H', 'ליפסקי': 'L'}`, ‏`fallback = 'L'`
(משקף את `kBrandProfiles`/`kLipskeyProfile` של המקור):

| # | brandName | ⇒ |
|---|-----------|---|
| 1 | `'פולירול'` | `'P'` |
| 2 | `'חוליות'` | `'H'` |
| 3 | `'ליפסקי'` | `'L'` (מפתח קיים — לא דרך ה-fallback) |
| 4 | `null` | `'L'` (‏fallback) |
| 5 | `'AQUATEC'` (לא-ממופה, ‏:433) | `'L'` (‏fallback) |
| 6 | `''` | `'L'` (‏fallback) |
| 7 | `' פולירול'` (רווח מוביל) | `'L'` (אפס-נרמול — לא תואם) |
| 8 | כל-מפתח עם `profiles = {}` | `fallback` |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/profile_for_brand_test.dart  ⇒ exit 0 + "OK profileForBrand: N asserts passed"
```
