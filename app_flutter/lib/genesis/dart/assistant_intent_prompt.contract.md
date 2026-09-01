> ♻️ **מנוע-נקי (הכרעת-בעלים "אפס-דאטה במנוע"):** 15 מקטעי-נוסח-ה-prompt חולצו לדאטה מוזרקת `copy` (`dart-data/assistant-prompt-copy.dart`). המנוע=הרכבת-buffer בלבד. `maxLen:600` נשאר במנוע (קבוע-קיצוץ-בטיחות). התנהגות זהה-ביט כשמזריקים את הנוסח-המקורי.

# חוזה · `assistantIntentPrompt` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/assistant_intent.dart:124-169`.

## תפקיד
בונה את מחרוזת-ה-prompt לסיווג-כוונת-משתמש (BuildSmart): חלון-שיחה-אחרון + רשימת-קטגוריות + רשימת-ערכות (key=name), עטופים בהוראות ה-JSON-שורה-אחת.

## חתימה
```dart
String assistantIntentPrompt(
  List<IntentTurn> history, String userText, {
  required int historyWindow,
  required List<String> categories,
  required List<({String key, String name})> recipes,
  required String Function(String text, {required int maxLen}) promptSafeText,
  required Map<String, String> copy,   // ⇔ kAssistantIntentPromptCopyHe (15 מקטעים)
})
// IntentTurn{ bool user; String text } — מוטבע inline
```

## התנהגות (עוגן assistant_intent.dart:124-169)
- `recent` = history החתוך ל-[historyWindow] האחרונים (אם ארוך יותר).
- אם recent לא-ריק ⇒ בלוק "השיחה עד כה:" עם `${user?"משתמש":"עוזר"}: ${promptSafeText(text,maxLen:600)}` לכל תור.
- שורת `המשתמש כתב: "${promptSafeText(userText,maxLen:600)}".`
- 5 שורות-הפעולות + רשימת-הקטגוריות (join '\n') + רשימת-הערכות ('key=name' join '\n') + שורת-הפורמט הסופית.

## שקעים
- `historyWindow` — const-מודול `kIntentHistoryWindow` (לא-בטיוטה) ⇒ שקע.
- `categories` — תוצאת `assistantCategories()` ⇒ שקע.
- `recipes` — `kSmartProducts` (seed; נקרא כ-key/name) ⇒ שקע-רשומות; בניית שורות ה-'key=name' נשארה inline.
- `promptSafeText` — שקע-פונקציה (טקסט-בטוח באורך חסום; maxLen:600 verbatim, נשאר במנוע כקבוע-מנגנון).
- `copy` — **שקע-required**: 15 מקטעי-נוסח (⇔ `kAssistantIntentPromptCopyHe`). מפתחות: `historyHeader`/`roleUser`/`roleAsst`/`userWrotePre`/`userWroteSuf`/`chooseLine`/`optAnswer`/`optFindProduct`/`optSummarize`/`optBudget`/`optAddToCart`/`catsHeader`/`recipesHeader`/`formatLine`/`fallbackLine`. שורת-המשתמש מורכבת `pre + safeText + suf` (בלי החלפת-טוקן ⇒ בטוח לתוכן-משתמש). ⚠️ מקטעי-ה-opt* צמודי-פרוטוקול ל-actionFromString.
- `assistantIntentSystem` (const-אח נפרד) הושמט — אינו חלק מהפונקציה.

## דוגמאות-מחייבות
| # | קלט | קובע |
|---|------|------|
| 1 | history=[] | אין בלוק "השיחה עד כה"; יש `המשתמש כתב: "שלום".`; יש `kitPipe=ערכת צנרת`; יש `ברזים\nצנרת` |
| 2 | 2 תורים, window=5 | יש "השיחה עד כה:"; `משתמש: א`; `עוזר: ב` |
| 3 | 3 תורים, window=1 | "ראשון"/"אמצע" נחתכו; יש `משתמש: אחרון` |
| 4 | userText באורך 700 | promptSafeText חותך ל-600 (‏601-x נעדר, 600-x נוכח) |
| 5 | תמיד | מכיל `{"action":"...","key":"...","say":"..."}` |
| 6 | swap `copy['historyHeader']='CONV:'` | ה-prompt מכיל `CONV:` ולא `השיחה עד כה` — **הדאטה מוחלפת ⇒ הפלט משתנה** |

הבדיקה מזריקה את הנוסח-המקורי verbatim ⇒ 5 דוגמאות-החוזה עוברות ביט-זהה; דוגמה 6 מוכיחה שהנוסח מוזרק, לא צרוב.

## DoD
```
dart run --enable-asserts new/dart/assistant_intent_prompt_test.dart  ⇒ exit 0 + "OK assistantIntentPrompt: 6 asserts passed"
```
