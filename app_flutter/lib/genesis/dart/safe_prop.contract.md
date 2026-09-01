# חוזה · `safeProp` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/component_palette.dart:284-296`
(‏`_safeProp`, פרטי-במקור). שאר-הטיוטה (‏`validateAddComponent` ואחרים) אינו היעד. הקובץ
אינו קיים עוד ⇒ הטיוטה = מקור-האמת.

## חתימה
```dart
String safeProp(String key, String value, {
  required Set<String> labelProps,
  required Set<String> bodyProps,
  required String Function(String value, {int maxLen, bool collapseWhitespace}) promptSafeText,
})
```

## שקעים (חוק-3)
- `labelProps`/`bodyProps` — `kLabelProps`/`kBodyProps` (קבוצות-מפתחות const-שכנות לא-ניתנות-לשחזור).
- `promptSafeText` — עוזר-החיטוי-השכן. ברירות-המחדל שלו (מהתיעוד במקור): `maxLen:600`,
  `collapseWhitespace:false`.

## פלט / התנהגות (עוגני-שורה)
- `component_palette.dart:285-287` — `labelProps.contains(key)` ⇒ `promptSafeText(value, maxLen:200, collapseWhitespace:true)`.
- `:288-292` — `bodyProps.contains(key)` ⇒ `promptSafeText(value)` (בברירות-המחדל של העוזר).
- `:293` — אחרת ⇒ `value.trim()` (‏ללא העוזר כלל).
- סדר-הבדיקה: label לפני body; מפתח שאינו באף-קבוצה ⇒ trim בלבד.

## דוגמאות (labelProps={'title'}, bodyProps={'body'}, promptSafeText מסמן את הפרמטרים)
עם עוזר-מבחן `pst(v,{maxLen=600,collapseWhitespace=false}) => 'PST(len=$maxLen,collapse=$collapseWhitespace):$v'`:
| # | key | value | ⇒ |
|---|-----|-------|---|
| 1 | `'title'` | `'x'` | `'PST(len=200,collapse=true):x'` (מסלול-תווית) |
| 2 | `'body'` | `'y'` | `'PST(len=600,collapse=false):y'` (מסלול-גוף, ברירות-מחדל) |
| 3 | `'other'` | `'  z  '` | `'z'` (‏trim בלבד, ללא עוזר) |
| 4 | `'other'` | `'no-space'` | `'no-space'` |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/safe_prop.dart                    ⇒ No issues found!
dart run --enable-asserts new/dart/safe_prop_test.dart  ⇒ exit 0 + "OK safeProp: N asserts passed"
```
