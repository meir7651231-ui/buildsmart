# חוזה · `actionFromString`

## תפקיד
ממפה מחרוזת-פעולה מתשובת-המודל אל חבר סגור של `AssistantAction` (קבוצת-הפעולות
של קופיילוט-הרכש BuildSmart), או `null` לכל מחרוזת שאינה אחת מחמש הפעולות.
זהו שער-הקבוצה-הסגורה: `parseAssistantIntent` נשען עליו כדי לדחות action לא-מוכר
לשיחה חופשית (`answer`).

מוצא: `buildsmart/app_flutter/lib/logic/assistant_intent.dart:99-123`
(`_actionFromString`; חוק-4 — התנהגות זהה, לא-משופרת).

## חתימה
```dart
enum AssistantAction { answer, findProduct, summarizeOrders, checkBudget, addToCart }
AssistantAction? actionFromString(String s);
```

## שקעים (הזרקות-שכן)
אין. אפס קריאות-חוץ (שקעים-מועמדים בטיוטה: —). ה-enum `AssistantAction`
(טיפוס-ההחזרה) הוטבע inline כטיפוס-שכן-קטן — חבריו verbatim מסדר ה-case-ים.

## התנהגות
- השוואה **מדויקת ותלוית-רישיות** (מבנה `switch` על מחרוזת).
- שם-פעולה מוכר ⇒ חבר-ה-enum התואם.
- כל מחרוזת אחרת (כולל ריקה, רווחים-עודפים, רישיות שונה) ⇒ `null` (ענף `default`).
- טוטאלי: לעולם לא זורק.

## דוגמאות-מחייבות (מקריאת-הקוד)
| קלט `s`        | פלט                             |
|----------------|----------------------------------|
| `'answer'`          | `AssistantAction.answer`         |
| `'findProduct'`     | `AssistantAction.findProduct`    |
| `'summarizeOrders'` | `AssistantAction.summarizeOrders`|
| `'checkBudget'`     | `AssistantAction.checkBudget`    |
| `'addToCart'`       | `AssistantAction.addToCart`      |
| `'Answer'`          | `null` (רישיות שונה)             |
| `' answer'`         | `null` (רווח מוביל)              |
| `''`                | `null`                           |
| `'delete'`          | `null` (מחוץ-לקבוצה)             |
