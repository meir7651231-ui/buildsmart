# חוזה-אטום · `allowedValues`

## תפקיד
מחזיר את **קבוצת-הערכים-המותרים** (`Set<String>`) של מאפיין `propKey` על גבי הרכיב
המזוהה ע"י `id`, כפי שהיא רשומה ברשומת-המתאר (descriptor) שלו. אם אין מתאר ל-`id`,
או שאין למתאר רשומה עבור `propKey` — מוחזרת **קבוצה-ריקה**. ערכים כפולים ברשימת-המקור
מתמזגים (סמנטיקת `Set`).

מוצא: `buildsmart/app_flutter/lib/logic/studio/registry_view.dart:192-197` (6 שורות; חוק-4).
עיגון-ההתנהגות: 6 שורות-הטיוטה (קוד-חלוץ). ⚠️ קובץ-המקור הנקוב **אינו קיים עוד בריפו**
(‏`grep -rn 'findDescriptor\|_descriptors\|allowedValues\|Descriptor' app_flutter/lib` ⇒ ריק);
אין שחזור-מומצא של הקופסה — רק הלוגיקה שבטיוטה קודמה.

## חתימה
```dart
Set<String> allowedValues<D>(
  String id,
  String propKey, {
  required D descriptors,
  required ({Map<String, Iterable<String>> allowedValues})? Function(D, String) findDescriptor,
})
```

## שקעים (חוק-3)
| שקע | טיפוס | מקור-אח | תפקיד |
|-----|-------|---------|-------|
| `findDescriptor` | `({Map<String, Iterable<String>> allowedValues})? Function(D, String)` | קריאה-לשכן `findDescriptor(_descriptors, id)` | מאתר את המתאר לפי id; `null` ⇒ לא-נמצא. הטיפוס-המוחזר צומצם לשדה היחיד שהאטום נוגע בו (`allowedValues`). |
| `descriptors` | `D` (גנרי, אטום) | שדה-המצב `_descriptors` | אוסף-המתארים; מועבר as-is ל-`findDescriptor` בלבד. |

הוטבע inline: `_empty` ⇒ `const <String>{}` (ענף ה-null).

## סמנטיקה (מקריאת-הטיוטה, שורה-שורה)
1. `vals = findDescriptor(descriptors, id)?.allowedValues[propKey]`
   — אם `findDescriptor` מחזיר `null` ⇒ כל הביטוי `null` (‏`?.`).
   — אחרת אינדוקס-מפה `[propKey]`: מפתח-חסר ⇒ `null`.
2. `return vals == null ? const <String>{} : Set<String>.of(vals);`
   — `null` ⇒ קבוצה-ריקה; אחרת עותק-קבוצה של `vals` (dedup, סדר-לא-מובטח).

## דוגמאות-מחייבות
נניח `find` = `(m, id) => m[id]` מעל
`descriptors = { 'door': (allowedValues: {'color': ['red','blue','red'], 'size': []}) }`.

| # | קלט | פלט | נימוק |
|---|-----|-----|-------|
| 1 | `allowedValues('door','color', descriptors: m, findDescriptor: find)` | `{'red','blue'}` | נמצא + propKey קיים; הכפילות `'red'` מתמזגת (Set). |
| 2 | `allowedValues('door','size', descriptors: m, findDescriptor: find)` | `{}` | נמצא, propKey קיים אך רשימה-ריקה ⇒ `Set.of([])` ריק. |
| 3 | `allowedValues('door','weight', descriptors: m, findDescriptor: find)` | `{}` | נמצא אך propKey חסר במפה ⇒ `[propKey]`==null ⇒ ריק. |
| 4 | `allowedValues('window','color', descriptors: m, findDescriptor: find)` | `{}` | `find` מחזיר `null` (לא-נמצא) ⇒ `?.` מקצר ⇒ ריק. |
| 5 | `allowedValues('door','color', descriptors: m, findDescriptor: (_,__) => null)` | `{}` | שקע שמחזיר null תמיד ⇒ ריק (מוכיח את ענף-ה-null). |

## אימות
- `dart analyze new/dart/allowed_values.dart` ⇒ **No issues found**.
- `dart run --enable-asserts new/dart/allowed_values_test.dart` ⇒ ירוק (golden, 5+ דוגמאות + קצוות).
