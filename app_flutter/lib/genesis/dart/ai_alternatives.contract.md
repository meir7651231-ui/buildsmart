# חוזה · `aiAlternatives` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/ai_hub_logic.dart:202-238`
(‏כלי "חלופות זולות" של מרכז-ה-AI, ‏proto `aiAlternatives` @21232; ‏AiAlt: ‏:170-186;
‏`_pricedSmartProduct`: ‏:190-200).
⚠️ הקובץ אינו בעץ-העבודה של buildsmart (‏`lib/logic/` בענף-העבודה מכיל 4 קבצים אחרים
בלבד) — חולץ verbatim מ-git ‏`origin/main` (קו-האמת של buildsmart, L16 — יושר 23.8).

הכרעת-הקידום (טיוטה-"קשה", **מסלול 1 + מסלול 2**):
- **מסלול 1 — שכנים/דאטה ⇒ שקעים** (חוק-1/3, דיבר-3):
  - `kHomeProductBrands` + `_pricedSmartProduct(pb)` (‏:207-208) ⇒ שקע `pricedProducts`
    — הקופסה ממפה את קטלוג-הטירים (‏contractor_seeds.dart:526-542) למוצרים-מתומחרים
    ומזריקה; האטום לא מכיר את הקטלוג (אפס דאטה-במנוע, כתקדים `estimate_price`).
  - `pb.product` (‏:213,215 — מפתח-הדדופ + `cat`; ‏`_pricedSmartProduct` ‏:191-194 קובע
    ‏key=name=cat=pb.product, כך שריאדר-יחיד נאמן-למקור) ⇒ שקע-ריאדר `productKey`.
  - `sp.brands` / `b.rec` / `rec.name` / `rec.price` (‏:209-212,216-217) ⇒ שקעי-ריאדר
    `brands` / `isRec` / `brandName` / `brandPrice` — ‏`brandPrice` מחזיר **int?**
    (‏smart_tree.dart:91 — "null = מחיר לפי ספק").
  - `cheaperAlternativeBrand(sp, i)` (‏:211; השכן `related_info.dart:1630-1646`) ⇒
    שקע `cheaperAlternativeBrand` בטיפוס-ההחזרה המקורי **בדיוק**:
    ‏`({String name, int price})?` — record; ‏`alt.price` מובטח non-null (‏:1640-1642),
    ולכן ‏`toPrice: alt.price` בלי-`!` נאמן-למקור (‏:219).
  - `cheaperAlternativesAcrossCatalog()` (‏:225; השכן `contractor_tools_sheets.dart:125-150`)
    ⇒ שקע-דאטה `crossCatalog` — הקופסה קוראת לשכן ומזריקה את **התוצאה**; ריאדרים
    ‏`crossProduct/crossRecName/crossRecPrice/crossAltName/crossAltPrice`
    (‏CheaperAlt ‏:106-120 — כל השדות non-null).
- **מסלול 2 — טיפוס-מותאם ⇒ הטבעה:** ‏`AiAlt` (‏:170-186, כולל ‏`save = fromPrice-toPrice`
  ‏:185) הוטבע verbatim בקובץ-האטום. אין `ai_alternatives`/`AiAlt` קודמים ב-new/dart
  (נבדק ב-ls) — לא-כפול.

## חתימה
```dart
List<AiAlt> aiAlternatives<P, B, C>({
  required List<P> pricedProducts,                 // שקע-דאטה: kHomeProductBrands→_pricedSmartProduct
  required String Function(P) productKey,          // שקע-ריאדר: pb.product (≡ sp.cat/key)
  required List<B> Function(P) brands,             // שקע-ריאדר: sp.brands
  required bool Function(B) isRec,                 // שקע-ריאדר: b.rec
  required String Function(B) brandName,           // שקע-ריאדר: rec.name
  required int? Function(B) brandPrice,            // שקע-ריאדר: rec.price (null = לפי-ספק)
  required ({String name, int price})? Function(P product, int recIndex)
      cheaperAlternativeBrand,                     // שקע-שכן: related_info.dart:1630
  required List<C> crossCatalog,                   // שקע-דאטה: תוצאת cheaperAlternativesAcrossCatalog()
  required String Function(C) crossProduct,        // שקע-ריאדר: a.product
  required String Function(C) crossRecName,        // שקע-ריאדר: a.recName
  required int Function(C) crossRecPrice,          // שקע-ריאדר: a.recPrice
  required String Function(C) crossAltName,        // שקע-ריאדר: a.altName
  required int Function(C) crossAltPrice,          // שקע-ריאדר: a.altPrice
})
```

## התנהגות (עוגני-שורה — verbatim ‏:202-238)
- `ai_hub_logic.dart:207-211` — **שלב 1:** לכל מוצר-מתומחר: ‏`recI = indexWhere(rec)`;
  אין דגל-rec (‏recI<0) ⇒ נפילה לאינדקס **0** (‏:210-211 — `recI >= 0 ? recI : 0`,
  פעמיים: גם ל-rec וגם לקריאת-השכן).
- `ai_hub_logic.dart:212` — ‏`alt == null` (אין-זול-יותר) **או** ‏`rec.price == null`
  ⇒ המוצר מדולג בשלב-1 (ועדיין ניתן-לכיסוי משלב-2).
- `ai_hub_logic.dart:213` — דדופ ב-`Set` על מפתח-המוצר; הראשון-מנצח.
- `ai_hub_logic.dart:214-220` — פליטת ‏`AiAlt(cat=productKey, from=rec.name/price!,
  to=alt.name/alt.price)`.
- `ai_hub_logic.dart:225-234` — **שלב 2:** מיזוג סריקת-הקטלוג; רק מוצר שטרם-נראה
  (‏`!seen.add`) נוסף — שלב-1 גובר.
- `ai_hub_logic.dart:236-237` — מיון חיסכון-יורד (‏`b.save.compareTo(a.save)`);
  ‏top-5: ‏`length > 5 ⇒ sublist(0,5)`.
- ⚠️ נאמנות-למקור: מוצר עם `brands` **ריק** ⇒ ‏RangeError (‏:210 — `sp.brands[0]`);
  בקטלוג-האמת אין מוצר בלי-טירים. לא-מרוכך (דיבר-2: לא "משפרים" את החלוץ).
- דטרמיניזם: אפס אקראיות/‏DateTime/‏I/O.

## דוגמאות מספריות
**A · הקטלוג-האמיתי** (‏contractor_seeds.dart:526-542 — 3 מוצרים, rec תמיד idx-0):
ברז לכיור 189→139 · אסלה תלויה 740→560 · סוללת מקלחת 520→380; ‏crossCatalog (אותו
דאטה, ממוין) מכוסה-כולו-בדדופ ⇒ פלט **3** שורות בסדר חיסכון-יורד:
| # | cat | from | to | save |
|---|-----|------|----|------|
| 1 | אסלה תלויה | מותג סטנדרט·740 | מותג כלכלי·560 | **180** |
| 2 | סוללת מקלחת | מותג סטנדרט·520 | מותג כלכלי·380 | **140** |
| 3 | ברז לכיור | מותג סטנדרט·189 | מותג כלכלי·139 | **50** |

**B · קצוות:** ‏rec.price=null ⇒ דילוג-שלב-1 אך כיסוי-משלב-2 · מוצר-בלי-rec ⇒ idx-0 ·
‏alt=null ⇒ דילוג · 7 מועמדים ⇒ 5 בלבד, החיסכון-הגדול ראשון · הכול-ריק ⇒ `[]` ·
‏cross-כפול-לשלב-1 ⇒ לא-נוסף (שלב-1 מנצח).

## DoD (פקודה+פלט-צפוי — דיבר 12; נרשם לפני הקוד)
```
dart run --enable-asserts new/dart/ai_alternatives_test.dart  ⇒ exit 0 + "OK aiAlternatives: N asserts passed"
```
