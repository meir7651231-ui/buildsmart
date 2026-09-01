# חוזה · `studioScopePrompt` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart:213-235`.
קובץ-המקור נעדר ⇒ הטיוטה היא מקור-האמת. כל ליטרל-עברי הועתק verbatim מהטיוטה.

## חתימה
```dart
String studioScopePrompt(String utterance, {
  required String Function(String) safeText,
  required Set<String> Function() scopeTokens,
  required String Function(String) scopeTokenHe,
  required String singlePrefix,
})
```

## שקעים (חוק-3/8)
- `safeText` — כובל את `promptSafeText(utterance, maxLen: kStudioMaxUtteranceChars, collapseWhitespace: true)` (‏:214-218); הקורא כובל את maxLen/collapse.
- `scopeTokens` — כובל את `studioScopeTokens(registry)` (‏:219); הקורא כובל את הרישום.
- `scopeTokenHe` — במקום הפונקציה-השכנה `_scopeTokenHe(t)` (‏:223).
- `singlePrefix` — במקום הקבוע `kScopeSinglePrefix` (‏:225; ערכו נעדר ⇒ שקע).

## פלט / התנהגות (עוגני-שורה; `StringBuffer.writeln` ⇒ שורה + `'\n'`)
- `:220` — כותרת `'טווחי-עריכה זמינים (token = תיאור):'`.
- `:221-224` — `scopeTokens().toList()..sort()` (מיון-עולה לקסיקוגרפי); לכל טוקן שורה `'$t = ${scopeTokenHe(t)}'`.
- `:225` — `'$singlePrefix<id> = אלמנט בודד (id אמיתי מהרישום)'`.
- `:226` — `writeln()` ⇒ שורה ריקה.
- `:227` — `'בקשת המנהל: "$safe".'` (‏safe = תוצאת safeText).
- `:228-230` — הוראת-הבחירה (‏שני ליטרלים סמוכים משורשרים): `'בחר token אחד בלבד … החזר שורה אחת: ה-token בלבד.'`.

## דוגמאות מספריות (‏golden — אומתו מול ה-SDK)
1. `utterance='ערוך את הכפתור  '`, `safeText=trim`, `scopeTokens={'scope:all','scope:screen:home'}`,
   `scopeTokenHe={all:'הכול', screen:home:'מסך הבית'}`, `singlePrefix='scope:single:'` ⇒
   ```
   טווחי-עריכה זמינים (token = תיאור):
   scope:all = הכול
   scope:screen:home = מסך הבית
   scope:single:<id> = אלמנט בודד (id אמיתי מהרישום)

   בקשת המנהל: "ערוך את הכפתור".
   בחר token אחד בלבד מהרשימה הסגורה שמתאר את טווח-העריכה, או השב AMBIGUOUS אם הבקשה אינה חד-משמעית. החזר שורה אחת: ה-token בלבד.
   ```
   (‏שים לב: הרווחים-הסוגרים ב-utterance נחתכו ע"י safeText.)
2. `scopeTokens={'zeta','alpha'}` (לא-ממוין) ⇒ הפלט מציג `alpha = …` לפני `zeta = …` (מיון).
3. `scopeTokens={'only'}` ⇒ שורת-טוקן יחידה בין הכותרת לשורת-הבודד.

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/studio_scope_prompt_test.dart  ⇒ exit 0 + "OK studioScopePrompt: N asserts passed"
```
