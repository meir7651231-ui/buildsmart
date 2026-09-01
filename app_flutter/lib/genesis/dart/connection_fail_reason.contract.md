> ♻️ **מנוע-נקי (הכרעת-בעלים "אפס-דאטה במנוע"):** 18 תוויות-ההסבר חולצו לדאטה מוזרקת `labels` (`dart-data/connection-fail-labels.dart`). המנוע=קסקדת-החלטה בלבד; בונה כל הודעה מתבנית+טוקנים דרך `_fmt` ({0}/{1}). התנהגות זהה-ביט כשמזריקים את התוויות-המקוריות.

# חוזה · connectionFailReason

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/logic/install_engine.dart:523-592`
**אטום:** `new/dart/connection_fail_reason.dart` — `String connectionFailReason(InferPart a, InferPart b, {verifiedOf, required Map<String,String> labels})`

## קלט
- `a`, `b` — `InferPart`: `sku` (String) · `connectionSizes` (List&lt;String&gt; גדלי-DN) · `connectionGender` (String? — 'male'/'female'/null) · `connectionMethod` (String? — 'thread'/'glue'/'electrofusion'/null). מקור-השדות: lipskey_catalog.dart:131/148/160.
- `verifiedOf` — שקע `VerifiedView? Function(String sku)`, מייצג את `kVerifiedSpecs[sku]` (install_engine.dart:525). מחזיר `null` כשאין מפרט-מאומת ל-sku. חסר ⇒ `null` (name-inference).
- `VerifiedView` — `ends` (List&lt;VerifiedEnd&gt;: `type` תג-מחרוזתי זהה-שם ל-EndType · `size`) + `material` (String). התגים הנקראים: `hdpeCompression` · `pexPress` · `copperPress` · `bspMale` · `bspFemale`.
- `labels` — **שקע-required**: מפת-תוויות (⇔ `kConnectionFailLabelsHe`, 18 מפתחות). התבניות נושאות טוקני-`{0}`/`{1}` שהמנוע מחליף בערכים. תג-מפתח→תבנית: `sizeDiffDn`/`pexDiff`/`copperDiff`/`bothMaleVerified`/`bothFemaleVerified`/`threadSizeDiff`/`materialAdapter`/`noCommon`/`sizeUnknown`/`sizeDiff`/`genderUnknown`/`bothEnds`/`methodDiff`/`genderMale`/`genderFemale`/`methodThread`/`methodGlue`/`methodElse`. **הנחת-בטיחות:** ערכי-הטוקנים אינם מכילים `{n}` ⇒ אין החלפה-כפולה (זהה-ביט).

## פלט
`String` — הסבר-עברית מדוע המוצרים אינם יכולים להתחבר.

## התנהגות (עוגני-שורה למקור)
**ענף-מאומת** — רק כאשר `verifiedOf(a.sku) != null && verifiedOf(b.sku) != null` (install_engine.dart:527). `sizes(view, tag)` = קבוצת ה-`size` של הקצוות בעלי אותו תג (install_engine.dart:529-530). מדורג, הראשון-שמתקיים מנצח:
1. שני צדדים בעלי `hdpeCompression` **ללא חיתוך-גודל** ⇒ `'גודל שונה: DN{A} ↔ DN{B}'` (:538-539).
2. אותו דבר ל-`pexPress` ⇒ `'גודל PEX שונה: {A} ↔ {B}'` (:541-542).
3. אותו דבר ל-`copperPress` ⇒ `'גודל נחושת שונה: DN{A} ↔ DN{B}'` (:544-545).
4. חיתוך `bspMale`∩`bspMale` **לא-ריק** ⇒ `'שני קצוות זכר {size}" — אין חיבור'` (:549-550).
5. חיתוך `bspFemale`∩`bspFemale` לא-ריק ⇒ `'שני קצוות נקבה {size}" — אין חיבור'` (:552-553).
6. `bspMale(A)` ו-`bspFemale(B)` קיימים **ללא חיתוך** ⇒ `'גודל תבריג שונה: {A}" ↔ {B}"'` (:557-558).
7. `bspFemale(A)` ו-`bspMale(B)` קיימים ללא חיתוך ⇒ `'גודל תבריג שונה: {A}" ↔ {B}"'` (:560-561).
8. חומרים שונים ⇒ `'נדרש מתאם מעבר: {matA} ↔ {matB}'` (:565-566).
9. אחרת ⇒ `'אין נקודת חיבור משותפת'` (:568).

**ענף name-inference** — כשלא-לשניהם מפרט-מאומת (install_engine.dart:571-591), מדורג:
10. `sA` או `sB` ריקים ⇒ `'גודל חיבור לא ידוע'` (:574).
11. אין חיתוך-גדלים ⇒ `'גודל שונה: {sA.first} ↔ {sB.first}'` (:575).
12. מין חסר בצד כלשהו ⇒ `'מין חיבור לא ידוע'` (:578).
13. שני המינים שווים ⇒ `'שני קצוות {זכר|נקבה} — אין חיבור'` (:579-581).
14. שתי שיטות מפורשות ושונות ⇒ `'שיטה שונה: {lA} ↔ {lB}'`; התוויות: thread→תבריג · glue→הדבקה · אחר→אלקטרו (:585-588).
15. אחרת ⇒ `'אין נקודת חיבור משותפת'` (:591).

## דוגמאות מספריות (מוכחות ב-connection_fail_reason_test.dart)
`V(...)` = צד עם קצוות מאומתים; `I(...)` = צד name-inference בלבד. הזרקת שקע `verifiedOf` ממפה sku→VerifiedView.

| # | קלט | פלט | עוגן |
|---|-----|-----|------|
| 1 | מאומת: compr A={'16'} · B={'20'} | `גודל שונה: DN16 ↔ DN20` | :539 |
| 2 | מאומת: pex A={'16'} · B={'20'} | `גודל PEX שונה: 16 ↔ 20` | :542 |
| 3 | מאומת: copper A={'15'} · B={'22'} | `גודל נחושת שונה: DN15 ↔ DN22` | :545 |
| 4 | מאומת: bspMale A={'1/2'} · B={'1/2'} | `שני קצוות זכר 1/2" — אין חיבור` | :550 |
| 5 | מאומת: bspFemale A={'3/4'} · B={'3/4'} | `שני קצוות נקבה 3/4" — אין חיבור` | :553 |
| 6 | מאומת: bspMale A={'1/2'} · bspFemale B={'3/4'} | `גודל תבריג שונה: 1/2" ↔ 3/4"` | :558 |
| 7 | מאומת: bspFemale A={'1/2'} · bspMale B={'3/4'} | `גודל תבריג שונה: 1/2" ↔ 3/4"` | :561 |
| 8 | מאומת: compr {'16'} בשניהם · matA='hdpe' matB='pex' | `נדרש מתאם מעבר: hdpe ↔ pex` | :566 |
| 9 | מאומת: compr {'16'} בשניהם · אותו חומר 'hdpe' | `אין נקודת חיבור משותפת` | :568 |
| 10 | inference: sizes []·['20'] (אין שקע) | `גודל חיבור לא ידוע` | :574 |
| 11 | inference: sizes ['20']·['25'] | `גודל שונה: 20 ↔ 25` | :575 |
| 12 | inference: sizes ['20']·['20'] · gender null | `מין חיבור לא ידוע` | :578 |
| 13 | inference: sizes ['20']·['20'] · gender 'male'·'male' | `שני קצוות זכר — אין חיבור` | :581 |
| 14 | inference: sizes ['20']·['20'] · gender 'female'·'female' | `שני קצוות נקבה — אין חיבור` | :581 |
| 15 | inference: gender 'male'·'female' · method 'thread'·'glue' | `שיטה שונה: תבריג ↔ הדבקה` | :588 |
| 16 | inference: gender 'male'·'female' · method 'electrofusion'·'thread' | `שיטה שונה: אלקטרו ↔ תבריג` | :588 |
| 17 | inference: gender 'male'·'female' · method 'thread'·'thread' | `אין נקודת חיבור משותפת` | :591 |

## עדשה-עוינת (קלטי-קצה — CURRICULUM #6)
- **ענף-מאומת רק כששני הצדדים מאומתים:** צד-אחד `verifiedOf`=null ⇒ נופלים ל-name-inference (install_engine.dart:527) — נבדק ב-#18.
- **הדירוג קדוש (L18):** בדיקת זכר-זכר/נקבה-נקבה (#4/#5) קודמת לאי-התאמת-גודל-תבריג (#6/#7); שינוי-סדר = באג. #8 נבחר כך ש**כל** שערי-הגודל נכשלים (compr חופף) והחומר הוא שמפיל — מבודד את שלב-8.
- **גדלים-ריקים חוסמים לפני חיתוך** (isEmpty לפני intersection, מונע חיתוך-ריק-כוזב) — #10.
- **תווית-שיטת-ברירת-מחדל:** כל method שאינו 'thread'/'glue' ⇒ 'אלקטרו' (else-branch, לא רק 'electrofusion') — #16.

## הזרקת-תוויות (הוכחת דאטה-מוזרקת · #19)
הבדיקה מזריקה את התוויות-המקוריות verbatim ⇒ 17 דוגמאות-החוזה עוברות ביט-זהה. **הדאטה-מוחלפת ⇒ הפלט-משתנה:**
עם `{..._labels, 'sizeDiff':'DIFF {0}/{1}'}` הקלט `sizes 20↔25` מחזיר `DIFF 20/25` במקום `גודל שונה: 20 ↔ 25` — מוכיח שהתוויות מוזרקות, לא צרובות.

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/connection_fail_reason_test.dart  ⇒ exit 0 + "connectionFailReason OK — 19/19"
```
