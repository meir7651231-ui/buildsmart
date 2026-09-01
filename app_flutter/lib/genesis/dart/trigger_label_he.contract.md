# חוזה · `triggerLabelHe` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/rules_model.dart:436-443`.
קובץ-המקור נעדר מהריפו הנוכחי ⇒ הטיוטה היא מקור-האמת; ערכי `kRuleTriggers` אינם בטיוטה.

## חתימה
```dart
String triggerLabelHe(String id, {required List<({String id, String labelHe})> triggers})
```

## שקעים (חוק-3)
- `triggers` — **שקע** במקום ה-const-list `kRuleTriggers` (‏rules_model.dart:437). כל איבר
  נקרא אך-ורק דרך `.id` ו-`.labelHe` ⇒ הוטבע כ-record `({String id, String labelHe})`.
  ערכי-המקור נעדרים ⇒ הבדיקה מזריקה נציגים מייצגים.

## קלט
- `id` — מזהה טריגר / שדה-תנאי לחיפוש.

## פלט / התנהגות (עוגני-שורה)
- `rules_model.dart:437-441` — לולאה על `triggers`: האיבר **הראשון** ש-`t.id == id` ⇒
  `t.labelHe`. אם אף איבר לא תואם ⇒ `return id` (המזהה הגולמי, :442 — fallback, לא זריקה).

## דוגמאות מספריות
שקע `triggers = [(id:'order:new', labelHe:'הזמנה חדשה'), (id:'order:open', labelHe:'הזמנה פתוחה')]`:

| # | id | ⇒ |
|---|----|---|
| 1 | `'order:new'` | `'הזמנה חדשה'` |
| 2 | `'order:open'` | `'הזמנה פתוחה'` |
| 3 | `'order:zzz'` (לא-קיים) | `'order:zzz'` (fallback = id) |
| 4 | `''` | `''` (אין תאום ⇒ id הריק) |
| 5 | id עם `triggers = []` (רשימה ריקה) | `id` (אין מה לסרוק) |
| 6 | `'dup'` עם שני איברים id='dup' (labelHe 'ראשון'/'שני') | `'ראשון'` (הראשון-תואם מנצח) |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/trigger_label_he_test.dart  ⇒ exit 0 + "OK triggerLabelHe: N asserts passed"
```
