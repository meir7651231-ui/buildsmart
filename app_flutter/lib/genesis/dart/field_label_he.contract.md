# חוזה · `fieldLabelHe` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/rules_model.dart:444-451`
(‏`fieldLabelHe`). ה-const-האחות `kRuleFields` הפכה לשקע `fields` (חוק-3, תקדים
`branch_label`). טיפוס-האיבר (רשומה id+labelHe) הוטבע inline כ-record.

**הערת-מקור (עוגן חסר):** תיקיית `studio/` אינה בצ׳קאאוט הנוכחי של buildsmart ⇒
ערכי `kRuleFields` **אינם נגישים**; לכן `fields` הוא שקע (חוק-9: לא מזייפים ערך).
מבנה-האיבר (`.id`, `.labelHe`) נגזר מגוף-הטיוטה: `f.id == id` ⇒ `return f.labelHe`.

## חתימה
```dart
String fieldLabelHe(String id, {
  required List<({String id, String labelHe})> fields,
})
```

## קלט
- `id` — מזהה-שדה לחיפוש.
- `fields` — **שקע**: רשימת רשומות `(id, labelHe)` בסדר; במקור `kRuleFields`.

## פלט / התנהגות (עוגני-שורה)
- `rules_model.dart:445-447` — לולאה על `fields`; ה-**ראשון** ש-`f.id == id` ⇒
  `return f.labelHe`.
- `rules_model.dart:450` — אף התאמה ⇒ `return id` (ה-id הגולמי, לא-מתורגם).

## דוגמאות מספריות (‏fields סינתטי: `[(sum,סכום),(items,פריטים),(ageDays,גיל)]`)
| # | id | ⇒ |
|---|----|---|
| 1 | `'sum'` | `'סכום'` |
| 2 | `'items'` | `'פריטים'` |
| 3 | `'ageDays'` | `'גיל'` |
| 4 | `'unknown'` | `'unknown'` (אין התאמה ⇒ id גולמי) |
| 5 | `'sum'` (fields ריק) | `'sum'` (רשימה ריקה ⇒ id גולמי) |
| 6 | `''` | `''` (id ריק, אין התאמה) |

## שקעים
- `fields` — הזרקת-רשימת-רשומות (חוק-3). ⚠️ הבדיקה מזריקה ערכים סינתטיים
  (המקור לא נגיש) — הגולדן מאמת את **הזרימה** (התאמה-ראשונה / נפילה-ל-id), לא נוסח-מקור.

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/field_label_he_test.dart  ⇒ exit 0 + "OK fieldLabelHe: N asserts passed"
```
