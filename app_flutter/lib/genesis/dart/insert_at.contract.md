# חוזה · `insertAt` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/install_engine.dart` —
הטיוטה נחצבה מהגוף-המוגן שבענפי-העבודה (למשל `origin/claude/align-main:1019-1036`);
ב-`main` (קו-האמת 23.8) אותו גוף בדיוק **בלי גארד-האורך** ב-`:828-836`.
שתי הגרסאות זהות-ביט לכל שרשרת עם ≥2 פריטים; הגארד רק מונע `ArgumentError`
של `clamp(1,0)` על שרשרת-יחיד (הערת-המקור verbatim בגוף האטום).
במקור זו פונקציה-מקוננת בתוך `_autoAddCompliance` הסוגרת על `items`/`skus`/`qty`
ומפנה לשכן `_skuOf` — **הכרעת-קידום 🔌 (חוק-1/3): כולם הפכו שקעי-פרמטר**, והטיפוס
`LipskeyCatalogProduct` הפך גנרי `T` (המנוע לא מכיר את הקטלוג — אפס דאטה-צרובה).

## חתימה
```dart
void insertAt<T>(int position, Set<String> alternatives, String preferred, {
  required List<T> items,            // שקע: השרשרת — נכתבת (insert)
  required Set<String> skus,         // שקע: מק"טים נוכחיים — נקרא + add
  required Map<String, int> qty,     // שקע: כמויות — נכתב qty[preferred]=1
  required T? Function(String) skuOf, // שקע-פותר: במקור _skuOf (קטלוג)
})
```

## התנהגות (עוגני-שורה — מול הגוף-המוגן :1019-1036 / main :828-836)
1. `:1025` — `items.length < 2` ⇒ אפס-שינוי (אין חריץ-פְּנים; מונע clamp(1,0)).
   *ב-main אין השורה — שם הקריאה הזו הייתה זורקת; הטיוטה-החלוצה כוללת אותה.*
2. `:1026` / main `:829` — אחת מ-`alternatives` כבר ב-`skus` ⇒ אפס-שינוי.
3. `:1027-1028` / main `:830-831` — `skuOf(preferred) == null` ⇒ אפס-שינוי.
4. `:1029` / main `:832` — `clamped = position.clamp(1, items.length-1).toInt()`
   — לעולם לא בראש (0) ולא אחרי-הסוף: פריט-ציות נכנס בין-שני-קיימים.
5. `:1030-1032` / main `:833-835` — `items.insert(clamped, p)` ·
   `qty[preferred] = 1` (דריסה — גם אם היה ערך קודם) · `skus.add(preferred)`.

**קצה-נאמנות (verbatim):** הבדיקה היא על `alternatives` בלבד — `preferred` שכבר
ב-`skus` אך **לא** ברשימת-החלופות יוכנס שוב ו-`qty` יידרס ל-1. במקור כל הקוראים
מעבירים את preferred בתוך alternatives, ולכן זה לא-נצפה — אך האטום נאמן למקור.

## דוגמאות מספריות (items כ-List<String>, skuOf = מפה זעירה מוזרקת)
| # | items לפני | pos | alternatives | preferred | items אחרי | qty/skus |
|---|-----------|-----|--------------|-----------|------------|----------|
| 1 | [A,B,C] | 1 | {X} | X | [A,x,B,C] | qty{X:1} · skus+={X} |
| 2 | [A,B,C] | 0 | {X} | X | [A,x,B,C] | clamp-מטה ⇒ 1 |
| 3 | [A,B,C] | 99 | {X} | X | [A,B,x,C] | clamp-מעלה ⇒ len-1=2 |
| 4 | [A,B,C] | -5 | {X} | X | [A,x,B,C] | clamp-מטה ⇒ 1 |
| 5 | [A] · [] | 1 | {X} | X | ללא-שינוי | גארד len<2 — אפס-קריסה |
| 6 | [A,B,C], skus{B1} | 1 | {B1,B2} | B2 | ללא-שינוי | חלופה-קיימת ⇒ דילוג |
| 7 | [A,B,C] | 1 | {Z} | Z (פותר⇒null) | ללא-שינוי | אין-מוצר ⇒ דילוג |
| 8 | [A,x,B], skus{X}, qty{X:3} | 2 | {Y} | X | [A,x,x,B] | verbatim: הוכנס-שוב, qty{X:1} |

## שקעים
- `skuOf` — הזרקת-פותר (חוק-1): הקטלוג חי מחוץ למנוע; הבדיקה מזריקה מפה-זעירה.
- `items`/`skus`/`qty` — שקעי-מצב מוזרקים; המוטציה היא הפלט-המוצהר (כמו במקור).

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/insert_at_test.dart  ⇒ exit 0 + "OK insertAt: N asserts passed"
```
