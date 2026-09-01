# חוזה · `matchClosed` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/rules_model.dart:180-200` (`_matchClosed`).
דדופ (הכרעה-5): גוף-קוד זהה-ביט ב-`registry_view.dart:237-259` (רק הערות שונות) — אטום-אחד.

## תפקיד
פותר-קבוצה-סגורה: ממפה תשובת-מודל חופשית למפתח-אמת יחיד מתוך קבוצה-סגורה, או `null`
(fail-closed). הבסיס ל-matchElementId/matchPropKey/matchValue/matchActionId/
matchComponentType (חיווט-קופסה מעל האטום, כל אחד מזריק קבוצה-סגורה אחרת).

## חתימה
```dart
String? matchClosed(Set<String> closed, String reply)
```

## התנהגות (עוגן rules_model.dart:180-200)
1. `r = reply.trim()`. אם `r.isEmpty` ⇒ **`null`** (נכשל-סגור).
2. **מדויק-קודם**: הלולאה הראשונה מחזירה `k` אם `r == k` (short-circuit — מפתח-מדויק
   קצר לא מואפל ע"י מפתח-ארוך שמכיל אותו).
3. **מוכל-הארוך-ביותר**: אחרת, מבין ה-`k` ש-`k.isNotEmpty && r.contains(k)` — נבחר
   הארוך-ביותר (`k.length > best.length`, **strictly** ⇒ בשוויון-אורך נשמר הראשון-בסדר-האיטרציה).
4. אין מוכל ⇒ **`null`**.
- מפתח-ריק (`''`) נדחה תמיד ע"י `k.isNotEmpty` (מחרוזת-ריקה מוכלת בכול).

## דוגמאות-מחייבות (Set = LinkedHashSet, סדר-הכנסה)
| # | closed | reply | ⇒ | למה |
|---|--------|-------|---|-----|
| 1 | `{a,b}` | `''` | `null` | reply-ריק |
| 2 | `{a,b}` | `'   '` | `null` | trim⇒ריק |
| 3 | `{card, card.order}` | `'card'` | `'card'` | מדויק מנצח (לא card.order הארוך) |
| 4 | `{faucet, kitchenFaucet}` | `'the kitchenFaucet pls'` | `'kitchenFaucet'` | מוכל-ארוך |
| 5 | `{faucet, kitchenFaucet}` | `'the faucet pls'` | `'faucet'` | רק faucet מוכל |
| 6 | `{a,b,c}` | `'xyz'` | `null` | אין מוכל |
| 7 | `{}` | `'anything'` | `null` | קבוצה-ריקה |
| 8 | `{'', abc}` | `'abc'` | `'abc'` | מפתח-ריק נדחה, abc מדויק |
| 9 | `{ab, abcd}` | `'  abcd  '` | `'abcd'` | trim ואז מדויק |
| 10 | `{xx, yy}` | `'zz xx yy'` | `'xx'` | שוויון-אורך (2,2) — הראשון-בסדר-הכנסה (xx) |
| 11 | `{cat, category}` | `'pick category'` | `'category'` | ארוך-מוכל גובר על תת-מחרוזת cat |

## שקעים
אין (dart:core בלבד — `String.trim`/`String.contains`/`Set` איטרציה).

## DoD
```
dart run --enable-asserts new/dart/match_closed_test.dart  ⇒ exit 0 + "OK matchClosed: N asserts passed"
```
