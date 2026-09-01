# חוזה · couplingFor

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/logic/install_engine.dart:1047-1063` (‏`_couplingFor`)
**אטום:** `new/dart/coupling_for.dart` — `P? couplingFor<P>(String dn, Set<String> mats, {catalog, isPipe, specOf, drainageFamily})`
**הערת-מוצא:** כותרת-הטיוטה ציינה שורות 1259-1318 ולולאה על `chainUniverse`; בעץ-האמת
הנוכחי (ענף-הסשן, יושר-מול-main 23.8) הפונקציה ב-‏:1047-1063 והלולאה על `kCompatCatalog`
(‏:1049). שני השמות קורסים לשקע `catalog` — התנהגות זהה.

## קלט
- `dn` — `String`: קוטר-נומינלי של קצה-הצינור (למשל `'50'`).
- `mats` — `Set<String>`: חומרי שני-הצינורות המחוברים (‏:1047).
- `catalog` — שקע `Iterable<P>` — היה `kCompatCatalog` (‏:1049); סדר-הסריקה = סדר-האיטרציה.
- `isPipe` — שקע `bool Function(P)` — היה `_isPipeProductE(p)` (‏:986-989,1050).
- `specOf` — שקע `ConnSpec? Function(P)` — היה `kVerifiedSpecs[p.sku]` (‏:1051); `null` ⇒ דילוג (‏:1052).
- `drainageFamily` — שקע-דאטה `Set<String>` — היה `_kDrainageFamily` (‏:991); ערך-המקור
  להזרקה: `{'PVC', 'PP', 'רב-שכבתי', 'ceramic'}` (דאטה לא-נצרבת במנוע).
- טיפוסים מוטבעים verbatim: `EndType` (‏lvc.dart:24) · `ConnEnd` (‏lvc.dart:32-36) ·
  `ConnSpec` = {material, ends} (השדות-הנקראים מ-`VerifiedSpec`, lvc.dart:67-70).

## פלט
`P?` — המצמד (fitting לא-צינור) המחבר שני צינורות `dn`: מצמד-ישר (שני-קצוות
hdpeCompression בגודל `dn`) אם קיים, אחרת ה-fitting התואם-הראשון עם קצה-אחד-כזה,
אחרת `null` (‏:1062).

## התנהגות (עוגני-שורה למקור)
1. סריקה בסדר-הקטלוג (‏:1049); צינור (`isPipe`) ⇒ דילוג (‏:1050); אין spec ⇒ דילוג (‏:1052).
2. תאימות-חומר (‏:1054-1055): `mats.contains(m)` **או** (`m` במשפחת-הניקוז **וגם** לפחות
   חומר-אחד מ-`mats` במשפחת-הניקוז). לא-תואם ⇒ דילוג.
3. ספירת-קצוות (‏:1057-1059): רק `EndType.hdpeCompression` **וגם** `size == dn`.
4. ‏`dnEnds >= 2` ⇒ החזרה-מיידית (מצמד-ישר, ‏:1060) — גם אם fallback כבר נתפס.
5. ‏`dnEnds >= 1` ⇒ `fallback ??=` — רק ה-**ראשון** נשמר (‏:1061).
6. סוף-הסריקה ⇒ `fallback` (או `null` כשאין, ‏:1062).

## דוגמאות מספריות (מוכחות ב-coupling_for_test.dart)
קטלוג-בדיקה (סדר-נתון): `PIPE50`(צינור, PVC, 2×hdpe-50) · `ELBOW1`(‏PVC, 1×hdpe-50) ·
`STRAIGHT`(‏PVC, 2×hdpe-50) · `NOSPEC` · `PPFIT`(‏PP, 2×hdpe-50) · `PEXFIT`(‏PEX, 2×hdpe-50) ·
`BSP50`(‏PVC, 2×bspMale-50) · `ELBOW2`(‏PVC, 1×hdpe-50). ‏drainageFamily=ערך-המקור.
| # | קלט | פלט | עוגן |
|---|-----|-----|------|
| 1 | dn=50, mats={PVC} | `STRAIGHT` | :1060 (מצמד-ישר עוקף fallback שנתפס ב-ELBOW1) |
| 2 | dn=50, mats={PVC}, קטלוג בלי STRAIGHT/PPFIT | `ELBOW1` | :1061-1062 (‏fallback ראשון, לא ELBOW2) |
| 3 | dn=50, mats={PVC}, קטלוג=[PIPE50] בלבד | `null` | :1050,1062 (צינור מדולג) |
| 4 | dn=50, mats={רב-שכבתי}, קטלוג=[PPFIT] | `PPFIT` | :1054-1055 (חציית-משפחת-ניקוז PP↔רב-שכבתי) |
| 5 | dn=50, mats={PEX}, קטלוג=[PPFIT] | `null` | :1054-1055 (‏PP בניקוז אבל PEX לא ⇒ לא-תואם) |
| 6 | dn=50, mats={PVC}, קטלוג=[BSP50] | `null` | :1057-1059 (‏bspMale אינו hdpeCompression) |
| 7 | dn=40, mats={PVC} (קטלוג-מלא) | `null` | :1058 (אין קצה בגודל 40) |
| 8 | dn=50, mats={PVC}, קטלוג=[NOSPEC] | `null` | :1052 |

## עדשה-עוינת
- ‏#1: ‏ELBOW1 נתפס כ-fallback **לפני** ש-STRAIGHT נמצא — ההחזרה-המיידית ב-‏:1060
  גוברת; הסריקה לא נעצרת על fallback.
- ‏#2: ‏`??=` ⇒ ‏ELBOW2 (תואם-זהה, מאוחר-יותר) **לא** מחליף את ELBOW1 — תלות-סדר verbatim.
- ‏#4 מול #5: תנאי-הניקוז דו-צדדי — גם חומר-ה-spec וגם לפחות אחד מ-mats חייבים
  במשפחה; ‏PEX (אספקה) מול PP (ניקוז) נדחה למרות ש-PP במשפחה.
- ‏PEXFIT (חומר PEX, קצוות-hdpe): נדחה בשער-החומר כש-mats={PVC} — ספירת-הקצוות
  לא-מגיעה; שער-החומר קודם לשער-הקצוות (‏:1054 לפני :1057).
