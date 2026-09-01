# חוזה · `parseAssistantIntent` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/assistant_intent.dart:170-213`
(‏`parseAssistantIntent`). קובץ-המקור הוסר מ-working-tree של בנייה-חכמה; אומת
**ביט-זהה** מול `git show claude/align-main:app_flutter/lib/logic/assistant_intent.dart`
(הטיוטה בדרגת-מחצבה = הקוד-החלוץ, זהה לענף).

זהו שער-האנטי-הזיה של "🤖 העוזר החכם": פונקציה **טוטאלית** — כל תשובת-מודל
פגומה/חלקית/עטופה-בפרוזה מתדרדרת ל-`answer` (לעולם לא זורקת, לעולם לא פולטת
פעולה לא-מאומתת).

## הכרעת-הקידום (טיוטה-"קשה")
- 🔌 **שלושה שכנים ⇒ שקעי-פרמטר** (חוק-1/חוק-3 — חוט לא מייבא חוט):
  - `_actionFromString` (‏:99-123) ⇒ שקע `actionFromString` (האטום-האח `action_from_string.dart`).
  - `matchAssistantCategory` (‏:60-81) ⇒ שקע `matchCategory` (האח `match_assistant_category.dart` —
    שם הקטגוריות כבר-שקע; כאן מזריקים closure סגור-על-הקבוצה, בדיוק כצורת-הקריאה במקור `matchAssistantCategory(key)`).
  - `matchAssistantRecipeKey` (‏:82-98) ⇒ שקע `matchRecipeKey` (האח `match_assistant_recipe_key.dart`).
- ⚛️ **שני טיפוסי-שכן הוטבעו verbatim** (הכרעה-2): ‏`enum AssistantAction` (‏:27-33; אותה הטבעה
  כבר-תקדים ב-`action_from_string.dart`) + ‏`class AssistantIntent` כולל ‏`factory .answer`
  (‏:37-48). הבדיקה מייבאת רק את האטום-שלה ⇒ אין התנגשות-שמות.
- `jsonDecode` — ‏dart:convert = ספריית-שפה/סטנדרט (מותר באטום, LAW סעיף-המבנה); לא שקע.
- מחרוזות-הנפילה העבריות ('לא הבנתי…') = **התנהגות-המקור** verbatim (חוק-4 — לא דאטה-קטלוג).

## חתימה
```dart
AssistantIntent parseAssistantIntent(
  String raw, {
  required AssistantAction? Function(String) actionFromString,
  required String? Function(String) matchCategory,
  required String? Function(String) matchRecipeKey,
})
// AssistantIntent { AssistantAction action; String key(=''); String say(='') }
```

## התנהגות (עוגני-שורה — דיבר 11)
- ‏:171-176 — ‏`text=raw.trim()`; ‏`start=indexOf('{')`, ‏`end=lastIndexOf('}')`;
  ‏`start<0 || end<=start` ⇒ `answer(text)` (לא-JSON ⇒ שיחה).
- ‏:178-179 — ‏`jsonDecode(text.substring(start, end+1))`; ‏`decoded is! Map` ⇒ `answer(text)`.
- ‏:180-185 — ‏action/key/say נשלפים **רק אם String** (אחרת ''), עם `.trim()`.
- ‏:186-190 — ‏`actionFromString(actionStr)==null` ⇒ `answer(say.isNotEmpty ? say : text)`.
- ‏:191-198 — ‏findProduct: ‏`matchCategory(key)==null` ⇒
  ‏`answer(say.isNotEmpty ? say : 'לא הבנתי איזה מוצר — נסה לתאר אחרת.')`;
  אחרת ⇒ ‏`AssistantIntent(action, key: cat, say: say)` (המפתח **המקורקע**, לא הגולמי).
- ‏:199-206 — ‏addToCart: אותו-דין עם ‏`matchRecipeKey` ונפילה
  ‏'לא הבנתי איזו ערכה — נסה לתאר אחרת.'.
- ‏:207-208 — כל פעולה אחרת (answer/summarizeOrders/checkBudget) ⇒
  ‏`AssistantIntent(action, say: say)` (‏key='').
- ‏:209-211 — ‏JSON פגום (throw) ⇒ `answer(text)`. **טוטאלית — אפס-חריגות החוצה.**
- ‏:46-47 — ‏`AssistantIntent.answer(say)` ⇒ ‏action=answer, ‏key=''.

## דוגמאות מספריות (מוכחות אחת-לאחת בבדיקה)
| # | raw | פלט |
|---|-----|-----|
| 1 | `'שלום, מה שלומך?'` | answer, say=`'שלום, מה שלומך?'` |
| 2 | `'  טקסט עם רווחים  '` | answer, say=`'טקסט עם רווחים'` (trim) |
| 3 | `'סוגר} לפני {פותח'` | answer (end<=start) |
| 4 | `'{"action":"answer","key":"","say":"שלום!"}'` | answer, say=`'שלום!'`, key='' |
| 5 | `'{"action":"checkBudget","say":" נשאר 500 "}'` | checkBudget, say=`'נשאר 500'` (trim), key='' |
| 6 | `'בטח! {"action":"summarizeOrders","say":"הנה"} תודה'` | summarizeOrders (עטיפת-פרוזה נחתכת) |
| 7 | `'{"action":"deleteAll","say":"מוחק"}'` | answer, say=`'מוחק'` (פעולה-זרה + say) |
| 8 | `'{"action":"deleteAll"}'` | answer, say=`'{"action":"deleteAll"}'` (say ריק ⇒ הטקסט) |
| 9 | `'{"action":"findProduct","key":"ברזי מטבח","say":"מצאתי"}'` | findProduct, key=`'ברזי מטבח'` |
| 10 | `'{"action":"findProduct","key":"זבל"}'` | answer, say=`'לא הבנתי איזה מוצר — נסה לתאר אחרת.'` |
| 11 | `'{"action":"findProduct","key":"זבל","say":"אולי ברז?"}'` | answer, say=`'אולי ברז?'` |
| 12 | `'{"action":"addToCart","key":"kitchenFaucet","say":"מוסיף"}'` | addToCart, key=`'kitchenFaucet'` |
| 13 | `'{"action":"addToCart","key":"זבל"}'` | answer, say=`'לא הבנתי איזו ערכה — נסה לתאר אחרת.'` |
| 14 | `'{"action":"checkBudget","broken'` | answer (JSON פגום ⇒ catch) |
| 15 | `'{"action":42,"say":"מס"}'` | answer, say=`'מס'` (action לא-String ⇒ '' ⇒ null) |
| 16 | ‏findProduct עם key שהמקרקע מתקן (מוכל) | key=**המקורקע** (לא הגולמי) |

## שקעים
- `actionFromString` — הזרקת האח (חוק-3); בבדיקה: switch-מראה של הקבוצה-הסגורה.
- `matchCategory` / `matchRecipeKey` — הזרקת-האחים; בבדיקה: מקרקעים-זעירים סגורי-קבוצה.

## DoD (פקודה+פלט-צפוי — דיבר 12, נכתב לפני הקוד)
```
dart run --enable-asserts new/dart/parse_assistant_intent_test.dart  ⇒ exit 0 + "OK parseAssistantIntent: N asserts passed"
```
