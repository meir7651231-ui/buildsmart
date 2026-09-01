# חוזה · `templateFor` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/component_palette.dart:245-253`.
קובץ-המקור נעדר מהריפו הנוכחי ⇒ הטיוטה היא מקור-האמת.

## חתימה
```dart
T? templateFor<T, K>(K type, {required List<T> palette, required K Function(T) typeOf})
```

## שקעים (חוק-3)
- `palette` — שקע במקום ה-const-list `kComponentPalette` (‏:246).
- `typeOf` — שקע במקום גישת-השדה `t.type` (‏:247) — ההשוואה `typeOf(t) == type`.
- הטיפוסים `ComponentTemplate` (‏= `T`) ו-`ComponentType` (‏= `K`) הופשטו לגנריים (מקור נעדר).

## פלט / התנהגות (עוגני-שורה)
- `component_palette.dart:246-252` — לולאה על `palette`: מוחזר **הראשון** ש-`typeOf(t) == type`
  (‏`:248`); אם אף אחד לא תואם ⇒ `null` (‏`:252` — fail-closed, לא זריקה).
- ההשוואה `==` — לפי סמנטיקת-השוויון של `K` (enum/String/…).

## דוגמאות מספריות
שקע: `palette` = רשומות `({String type, String he})`, `typeOf = (t) => t.type`:
`[(type:'button', he:'כפתור'), (type:'text', he:'טקסט')]`.

| # | type | ⇒ |
|---|------|---|
| 1 | `'button'` | `(type:'button', he:'כפתור')` |
| 2 | `'text'` | `(type:'text', he:'טקסט')` |
| 3 | `'slider'` (לא-קיים) | `null` |
| 4 | `'button'` עם `palette = []` | `null` |
| 5 | `'dup'` עם שני איברים type='dup' ('a'/'b') | הראשון ('a') — first-match-wins |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/template_for_test.dart  ⇒ exit 0 + "OK templateFor: N asserts passed"
```
