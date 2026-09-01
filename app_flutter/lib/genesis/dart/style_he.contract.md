# חוזה · `styleHe` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/diff_preview.dart:184-195`
(‏`_styleHe`, פרטי-במקור — גולגל). קובץ-המקור נעדר ⇒ הטיוטה היא מקור-האמת.

**אח-שסוקט:** `_colorHe` (בטיוטה כתיעוד בלבד) — אטום נפרד, לא הועתק (מוזרק כשקע `colorHe`).

## חתימה
```dart
String styleHe(String id, {
  required String? colorToken,
  required List<String> Function(String id, String attr) allowedValues,
  required String Function(String) colorHe,
})
```

## שקעים (חוק-3)
- `colorToken` — במקום `style?.colorToken` (‏:185; `CfgStyle` נקרא רק דרך שדה זה ⇒ פורק לשקע).
- `allowedValues` — במקום `registry.allowedValues(id, 'color')` (‏:189). הליטרל `'color'` נשמר בגוף.
- `colorHe` — במקום הפונקציה-השכנה `_colorHe(token)` (‏:190).

## פלט / התנהגות (עוגני-שורה)
- `:185-186` — `colorToken == null` ⇒ `'שינוי עיצוב: $id'` (מסלול-העיצוב-הכללי).
- `:188-191` — `allowedValues(id, 'color').contains(token)` ⇒ `'שינוי צבע: $id ← ${colorHe(token)}'`.
- `:192` — טוקן קיים אך לא-מאושר ע"י הרישום ⇒ `'שינוי צבע: $id'` (בלי החץ / השם).

## דוגמאות מספריות
שקעים: `allowedValues('btn','color') = ['primary','danger']` (אחרת `[]`) ·
`colorHe = {'primary':'ראשי','danger':'אדום'}` (מדרדר לטוקן עצמו).

| # | id | colorToken | ⇒ |
|---|----|-----------|---|
| 1 | `'btn'` | `null` | `'שינוי עיצוב: btn'` |
| 2 | `'btn'` | `'primary'` (מאושר) | `'שינוי צבע: btn ← ראשי'` |
| 3 | `'btn'` | `'danger'` (מאושר) | `'שינוי צבע: btn ← אדום'` |
| 4 | `'btn'` | `'neon'` (לא-מאושר) | `'שינוי צבע: btn'` |
| 5 | `'box'` | `'primary'` (‏allowedValues('box',..)=[]) | `'שינוי צבע: box'` |
| 6 | `'btn'` | `'gray'` (מאושר אך אין ב-colorHe) | `'שינוי צבע: btn ← gray'` (דרדור-לטוקן) |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/style_he_test.dart  ⇒ exit 0 + "OK styleHe: N asserts passed"
```
