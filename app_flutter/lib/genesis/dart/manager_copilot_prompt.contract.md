# חוזה · `managerCopilotPrompt` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/manager_copilot.dart:101-108`
(‏`managerCopilotPrompt`).

## חתימה
```dart
String managerCopilotPrompt(
  String context,
  String question, {
  required String Function(String text, {int maxLen}) promptSafeText,
})
```

## קלט
- `context` — מצב-העסק (נתוני-אמת) כטקסט, מוטבע verbatim.
- `question` — שאלת-הבעלים הגולמית, מועברת דרך השקע לחיטוי.
- `promptSafeText` — **שקע** (חוק-3): `promptSafeText` verbatim; נקרא `promptSafeText(question, maxLen: 400)`.

## פלט / התנהגות (עוגני-שורה)
- `:102` — `final q = promptSafeText(question, maxLen: 400)` (ה-const 400 verbatim).
- `:103-106` — התבנית:
  ```
  מצב-העסק כעת (נתוני-אמת):
  <context>

  שאלת-הבעלים: "<q>"
  ענה בעברית, אך ורק לפי הנתונים שלמעלה.
  ```
- טהור: הפלט נקבע בלעדית מ-`context` ו-`q`; אין state/IO.

## דוגמאות (‏promptSafeText זהותי — מחזיר את הטקסט כפי-שהוא)
1. `context='3 הזמנות פתוחות'`, `question='מה דחוף?'`
   ⇒ `'מצב-העסק כעת (נתוני-אמת):\n3 הזמנות פתוחות\n\nשאלת-הבעלים: "מה דחוף?"\nענה בעברית, אך ורק לפי הנתונים שלמעלה.'`
2. `context=''`, `question=''` ⇒ `'מצב-העסק כעת (נתוני-אמת):\n\n\nשאלת-הבעלים: ""\nענה בעברית, אך ורק לפי הנתונים שלמעלה.'`
3. `promptSafeText` חותך ל-5 תווים: `question='abcdefgh'` ⇒ `q='abcde'` ⇒ המחרוזת מכילה `"abcde"`.

## שקעים
- `promptSafeText` — הזרקת-פונקציה עם named-param `maxLen` (חוק-3). הבדיקה בוחנת גם זהותי וגם חותך.

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/manager_copilot_prompt_test.dart  ⇒ exit 0 + "OK managerCopilotPrompt: N asserts passed"
```
