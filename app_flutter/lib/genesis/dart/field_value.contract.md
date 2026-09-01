# חוזה · `fieldValue` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/rules_model.dart:420-435`
(‏`_fieldValue`). הקלט `Order` צומצם לשלושה ריאדרים-שקע (חוק-3/6); שלוש קבועי-המפתח
הפכו לשקעים (ערכיהם לא-נגישים — `studio/` חסר בצ׳קאאוט; חוק-9). ה-`switch` תורגם
לשרשרת-if שקולה (case-const ⇒ `==`) לשימור-סמנטיקה עם מפתחות-שקע.

**הערת-מקור:** תרגום switch→if הוא שימור-התנהגות מדויק (case-הראשון-שתואם / fallthrough
לברירת-מחדל 0), לא-שיפור — אילוץ טכני של מפתחות-שקע (Dart case דורש const).

## חתימה
```dart
num fieldValue<T>(String field, T order, DateTime now, {
  required DateTime? Function(T) createdAt,
  required num Function(T) sum,
  required num Function(T) items,
  required String ageDaysField,
  required String sumField,
  required String itemsField,
})
```

## קלט
- `field` — מזהה-השדה המבוקש.
- `order` — הישות (גנרית T).
- `now` — תאריך-ההשוואה (לחישוב-גיל).
- `createdAt`/`sum`/`items` — **שקעי-ריאדר**: במקור `order.createdAt` / `.sum` / `.items`.
- `ageDaysField`/`sumField`/`itemsField` — **שקעי-מפתח**: במקור const-ים.

## פלט / התנהגות (עוגני-שורה)
- `rules_model.dart:422-424` — `field == ageDaysField`: `created = createdAt(order)`;
  `created == null ? 0 : now.difference(created).inDays` (הפרש שלם-בימים).
- `rules_model.dart:426` — `field == sumField` ⇒ `sum(order)`.
- `rules_model.dart:428` — `field == itemsField` ⇒ `items(order)`.
- `rules_model.dart:434` — מפתח לא-מוכר ⇒ `0` (fallthrough).
- `now.difference(created).inDays` קוטם כלפי-מטה (מספר-ימים שלמים; פחות-מיום ⇒ 0).

## דוגמאות מספריות
שקעי-מפתח לבדיקה: `ageDaysField='ageDays'`, `sumField='sum'`, `itemsField='items'`.
`now = 2026-08-26T12:00`.

| # | field | createdAt | sum | items | ⇒ |
|---|-------|-----------|-----|-------|---|
| 1 | `'ageDays'` | `2026-08-16T12:00` | — | — | `10` (10 ימים) |
| 2 | `'ageDays'` | `null` | — | — | `0` (אין תאריך) |
| 3 | `'ageDays'` | `2026-08-26T00:00` | — | — | `0` (<יום שלם) |
| 4 | `'sum'` | — | `540` | — | `540` |
| 5 | `'items'` | — | — | `3` | `3` |
| 6 | `'unknown'` | — | — | — | `0` (fallthrough) |

## שקעים
- 3 ריאדרים + 3 מפתחות — הזרקה (חוק-3). הבדיקה מזריקה ישות-record סינתטית
  ומפתחות-דוגמה; הגולדן מאמת את הקסקדה + חישוב-הגיל, לא נוסח-const-מקור.

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/field_value_test.dart  ⇒ exit 0 + "OK fieldValue: N asserts passed"
```
