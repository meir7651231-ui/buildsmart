> ♻️ **מנוע-נקי (הכרעת-בעלים "אפס-דאטה במנוע"):** מילון-אוצר-המילים חולץ לדאטה מוזרקת (7 שקעים). המנוע=מנגנון-בלבד; הדאטה ב-`dart-data/lipskey-vocab.dart` (משותף עם `findTypeSiblings`). התנהגות זהה-ביט כשמזריקים את vocab-המקור.

# חוזה · `findAttrSiblings`

## תפקיד
מחזיר את מוצרי-האחים שעבורם ניתן לגלגל צ'יפ-מאפיין מסוג `kind` (מידה/צבע/דגם/
תת-סוג/חומר/יצרן…) על כרטיס-המוצר `p`. ארבעה ענפי-חיפוש נפרדים: **יצרן**
(אותו spec, יצרן שונה), **PPR** (כל צ'יפ = ממד נבחר בתוך אותו סוג-מוצר), **דגם**
(נציג לכל מילת-דגם בקטגוריה), ו**מסגרת** (ברירת-מחדל: אותה מסגרת-שם + מילת-`kind`).
כשאין חלופה אמיתית ⇒ `[p]`.

מוצא: `buildsmart/app_flutter/lib/screens/lipskey_products_screen.dart:1839-1910`
(`findAttrSiblings`; חוק-2 — verbatim, לא-משופר).

## חתימה
```dart
List<LipRow> findAttrSiblings(LipRow p, String word, AttrKind kind, {
  required List<LipRow> catalog,
  required List<String> models, types, subtypes, colors,   // ⇔ kLipskey*
  required Set<String> pprMaterials, colorModifiers,        // ⇔ _kPprMaterials/_kColorModifiers
  required String polyrollBrand,                            // ⇔ kPolyrollBrand
});
class LipRow { final String nameHe, brand, categoryHe; final Map<String,dynamic>? dims; }
enum AttrKind { size, color, colorMod, model, subtype, type, material, pressure, sdr, maker }
```

## שקעים (קטלוג + 7 מילון) + מקור-הדאטה
- `catalog` — הקטלוג הגלובלי `resolvedCatalogProducts` (:1850,1872,1888,1902) ⇒ פרמטר-שקע.
- **7 שקעי-מילון** — כל אוצר-המילים (models/types/subtypes/colors/pprMaterials/colorModifiers/
  polyrollBrand) חי ב-`dart-data/lipskey-vocab.dart` ומוזרק. **מנגנון שנשאר במנוע:** הנגזרות
  `colorWords/modelWords/subtypeWords` (פיצול-מילים≥2) מחושבות במנוע מהרשימות המוזרקות, וכל
  העוזרים (‏isSizeToken · _attrKindFor · _stripWordsOfKind · _getCompoundType · עוזרי-היצרן).

## הערת-verbatim
הפרמטר `word` נשמר מהחתימה המקורית אך **אינו-נקרא** בגוף (:1839-1910) — קלט-רפאים;
הסיווג נגזר כולו מ-`kind`. שוכפל כמות-שהוא (חוק-2 — לא-משופר).

## התנהגות (מקריאת-הקוד)
- **יצרן** (kind==maker, :1845-1857): `sig=_makerSignature(p)`; עובר על `catalog`,
  שומר מוצרי-פולירול עם אותו sig, נציג-יחיד לכל `_makerOf(q)` לא-ריק וחדש; ‏≤1 ⇒ `[p]`.
- **PPR** (p.brand==kPolyrollBrand, :1862-1883): `pType=_getCompoundType(p)`;
  `sameLineOnly = kind==size` (מגביל לאותה קטגוריה); לכל מוצר-פולירול מאותו סוג —
  ערך `v` = מילות-ה-`kind` שבשמו; נציג-יחיד לכל `v` לא-ריק וחדש; ‏≤1 ⇒ `[p]`.
- **דגם** (kind==model, :1884-1898): נציג-יחיד לכל מילת-דגם ראשונה בקטגוריה; ‏≤1 ⇒ `[p]`.
- **מסגרת** (ברירת-מחדל, :1900-1909): `pFrame=_stripWordsOfKind(p.nameHe,kind)`;
  ‏אורך<2 ⇒ `[p]`; אחרת כל מוצר באותה קטגוריה עם אותה מסגרת ש**גם** נושא מילת-`kind`
  (‏colorMod ⇒ תמיד עובר).
- טוטאלי: לעולם לא זורק.

## דוגמאות-מחייבות (מקריאת-הקוד · עוגן-שורה)
brand ברירת-מחדל 'ליפסקי'; PPR מסומן brand:'פולירול'.

**ד1 — מסגרת/צבע** (:1900-1909):
```
p =  'מחסום עגול לבן'  cat:'ניקוז'
q1 = 'מחסום עגול שחור' cat:'ניקוז'   q2 = 'מחסום עגול אדום' cat:'ניקוז'
q4 = 'סיפון כפול לבן'  cat:'ניקוז'   q5 = 'מחסום עגול שחור' cat:'אחר'
findAttrSiblings(p,'',color,[p,q1,q2,q4,q5]) → ['מחסום עגול לבן','מחסום עגול שחור','מחסום עגול אדום']
   (frame='מחסום עגול'; q4 מסגרת-שונה, q5 קטגוריה-אחרת)
```

**ד2 — דגם** (:1884-1898):
```
p =  'מושב קיסר' cat:'מושבים'   q1='מושב דיור' cat:'מושבים'   q2='מושב קיסר משופר' cat:'מושבים'
findAttrSiblings(p,'',model,[p,q1,q2]) → ['מושב קיסר','מושב דיור']   (q2 דגם-'קיסר' כפול-מדולג)
```

**ד3 — יצרן** (:1845-1857):
```
pm = 'מצמד PPR 20'   brand:'פולירול' cat:'מצמדים' dims:{יצרן:'הליארומה', 'dn נומינלי':'20', PN:'20'}
q1 = 'מצמד PPRCT 20' brand:'פולירול' cat:'מצמדים' dims:{יצרן:'אקוותרם', 'dn נומינלי':'20', PN:'20'}
q2 = 'מצמד PPR 20'   brand:'פולירול' cat:'מצמדים' dims:{יצרן:'הליארומה', 'dn נומינלי':'20', PN:'20'}
findAttrSiblings(pm,'',maker,[pm,q1,q2]) → ['מצמד PPR 20','מצמד PPRCT 20']  (q2 יצרן-כפול מדולג)
```

**ד4 — PPR/מידה** (:1862-1883):
```
pp = 'מצמד 20' brand:'פולירול' cat:'מצמדים'   qp1='מצמד 25' brand:'פולירול' cat:'מצמדים'
qp2= 'מצמד 20' brand:'פולירול' cat:'מצמדים'   qp3='מצמד 32' brand:'פולירול' cat:'אחר'
findAttrSiblings(pp,'',size,[pp,qp1,qp2,qp3]) → ['מצמד 20','מצמד 25']
   (qp2 מידה-'20' כפולה; qp3 sameLineOnly ⇒ קטגוריה-אחרת מסוננת)
```

**ד5 — מסגרת קצרה ⇒ [p]** (:1901):
```
findAttrSiblings(LipRow(nameHe:'לבן'),'',color,[…]) → ['לבן']   (frame לאחר-הפשטה ריק, אורך<2)
```

## מילון מוזרק בבדיקה + הוכחת-הזרקה
הבדיקה מזריקה תת-קבוצת-מקור זעירה: `models=[קיסר,דיור]` · `types=[מצמד]` · `colors=[לבן,שחור,אדום]` ·
`pprMaterials={PPR,PPRCT}` · `colorModifiers={מוברש,מט}` · `polyrollBrand='פולירול'` (subtypes ריק).
**הדאטה-מוחלפת ⇒ הפלט-משתנה:** ד1 עם `colors=[לבן,שחור]` (בלי 'אדום') ⇒ `['מחסום עגול לבן','מחסום עגול שחור']`
בלבד — q2 יוצא. מוכיח שהמילון מוזרק, לא צרוב.

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/find_attr_siblings_test.dart  ⇒ exit 0 + "OK findAttrSiblings: 6 asserts passed"
```
