# מודל-המוצר — `TREES` (index.html 5441–6044)

> ⚠️ **שיטת-לכידה ל-JS:** מבני-הנתונים הם שורות ענק (10–13K תווים כל מוצר `pl_`).
> אין טעם להעתיק 200KB data verbatim — **הידע = הסכמה + המצאי + דוגמה**, לא הביטים.
> מיקומי-שורות מדויקים; ערכים מצוטטים verbatim כשהם קצרים.

`const TREES = {…}` (5441–6044) הוא **לב הדמו**: בחירת מוצר-אב → "עץ-מוצרים חכם"
שמקפיץ את כל האביזרים הנדרשים. **202 מוצרים top-level** (אומת מהמקור). מכיל **3 סכמות**:

## סכמה 1 — מוצרי-קטלוג `pl_*` (5443–5465, 23 פריטים)
מחולץ מ-PDF קטלוג **פלסאון** (הערה 5442). מפתח = מק"ט (`pl_0712060200`). שורה אחת/מוצר.
שדות: `name · img(emoji) · cat · series · secondary · productType · note · image · data · catalogProduct · acc[{name,img,why,qty,price,must}]`.
תוכן: אביזרי-אינסטלציה מכניים — פקק · הסתעפות 90°/45° · זוית · מסעף · מתאם אוגן/תבריג · אטם · ערכת-הפחתה. (כולם `cat:"אביזרים מכניים"`.)

## סכמה 2 — שלבי-פרויקט (5466–5521, 5 פריטים)
סכמה ישנה: `name · img · unit · qty · note · acc[{name,img,price,qty,why}]`.
כל שלב = עץ-אביזרים לשלב-בנייה:
| key | שלב | דוגמת-אביזרים |
|---|---|---|
| `infra` | תשתית ואינסטלציה גסה | גוף-סמוי, מיכל-הדחה, PEX, ניקוז 50מ"מ, נקזון |
| `sealing` | איטום והכנת רצפה | יריעה ביטומנית, פריימר, מסטיק-פינות, מדה-שיפוע |
| `tiling` | ריצוף וחיפוי | דבק-אריחים, אריחים, רובה-אפוקסי, פרופיל-סיום |
| `cable` | התקנת מעגל-תאורה | שרוול-שרשורי, קופסת-התפצלות, וואגו, סרט-בידוד |
| `profile` | הרכבת מחיצת-גבס | בורג-גבס, מסילה, סרט-בד, דיבל, שפכטל |
> `unit` = מחיר-יחידה למוצר-האב (0 אם אין); `acc[].why` = הסבר למה צריך.

## סכמה 3 — מוצרים-עשירים (5523–5894, ~26 מוצרי-אב) ⭐
הסכמה המרכזית: `productType:"מוצר ראשי" · name · img · cat · brands[{brand,price,tag,rec}] · acc[{name,img,price,why,must}]`.
- **`brands[]`** = בחירת-מותג (3 בד"כ): `rec:true` = "הבחירה שלנו" ⭐; `tag` = "הכי משתלם"/"איכות גבוהה".
- **`acc[]`** = עץ-האביזרים: **`must:true`** = חובה (מודגש), `must:false` = אופציונלי; `why` = הסבר verbatim.

מצאי לפי קטגוריה (הערות-מקור):
| קטגוריה (5524–5894) | מוצרי-אב |
|---|---|
| ברזים וכיורים | `faucet` (ברז לכיור) · `kitchenFaucet` (ברז למטבח) · `basin` (כיור אמבטיה) |
| אסלות | `toilet` (תלויה) · `toiletFloor` (רצפתית) |
| מקלחות ואמבטיות | `shower` (סוללת מקלחת) · `bathtub` (אמבטיה) |
| בנייה | `wall` (קיר גבס) · `door` (דלת שירותים) · `floor` (ריצוף) · `seal` (איטום) |
| שלבי-פרויקט (בלי מותג) | `pipes` (אינסטלציה) … |
| חימום מים | `boilerElectric` (דוד חשמלי) · `boilerSolar` (מערכת סולארית) |
| מטבח (תוספות) | `kitchenSink` · `dishwasher` · `washingPoint` |
| ניקוז וצנרת | `floorDrain` (מחסום-רצפה) · `pressureReg` (וסת-לחץ) |
| גופי תברואה | `showerCabin` (מקלחון) · `bidet` |
| אביזרי-קצה וחיבורים | `endTaps` · `elbows` · `extenders` · `connectors` · `seals` |

**דוגמה verbatim — `faucet` (5525):**
```
faucet:{productType:"מוצר ראשי", name:'ברז לכיור', img:'🚰', cat:'ברזים וכיורים',
  brands:[ {brand:'מותג סטנדרט',price:189,tag:'הבחירה שלנו',rec:true},
           {brand:'מותג כלכלי',price:139,tag:'הכי משתלם'},
           {brand:'מותג פרימיום',price:329,tag:'איכות גבוהה'} ],
  acc:[ {name:'צינורות חיבור גמישים',price:28,why:'מחבר את הברז למים',must:true},
        {name:'ברזי ניל זוויתיים',price:22,why:'לסגור מים בעת תיקון',must:true},
        {name:'סרט טפלון',price:4,why:'אוטם את ההברגה',must:true},
        {name:'סיליקון סניטרי',price:21,why:'אם הברז יושב על המשטח',must:false},
        {name:'מפתח צינורות',price:39,why:'רק אם אין לך בערכה',must:false}, … ]}
```

## סכמה 4 — 148 אביזרים-נלווים (5895–6043)
`productType:"אביזרים נלווים"` — מוצרים מן-המניין (לא רק תת-פריטי-עץ). מרחיב את הקטלוג ל-~200 SKU.

---
**הבנה מרכזית:** TREES הוא גם הקטלוג וגם מנוע-ההמלצות. `must`/`why` הם ה"חוכמה"
שהדמו מוכר ("האביזרים שהצוות תמיד שוכח"). מוצר-אב נבחר → `acc[]` שלו מוצג בעץ
(`overlay#overlay` ב-`02`), עם `must` מסומן וברירת-מחדל, ו-`brands[].rec` כברירת-מחדל.

---

## 🔄 Preact (`app/src/data/catalog.ts`) — דלתא מול אב-הטיפוס (מודל-מוצר)
> ⭐ **auto-generated מ-`/index.html`** ע"י `scripts/extract-catalog.mjs` — קטלוג-Preact הוא **היטל מטוייפ של ה-TREES**. 4544 ש׳.

⬆️ **שודרג:**
- **3 הסכמות (pl_/stages/rich) → טיפוס אחד `CatalogProduct`** (שדות אופציונליים: `productType/series/material/catalogProduct/accessoryProduct/price/image/accessories`). `Accessory` מטוייפ: `{name, emoji, price, qty, why?, must, sizes?}`.
- **CATALOG (11 קטגוריות שטוחות) → `CATEGORIES` עץ-עמוק** (`{id, name, emoji, parentId}`): top→sub (למשל "אביזרים מכניים" → "הברגה פנימית"/"90° מעבר"). מאפשר drill-down circles (`childrenOf`).
- `PRODUCTS` שטוח — כל מוצר עם `categoryTopId`+`categoryLeafId` (נתיב לעץ).

➕ **נוסף:** **תמונות-אמת** (`image:/catalog/pl_*.jpg`) · helpers (`childrenOf`/`productsForPath`/`productById`/`categoryById`) · `accessoryProduct` flag · `material`.

➖ **הוחסר/שונה:** ה-**`brands[]`** (בחירת-מותג) **נגזם** (אין ב-`CatalogProduct`; `grep brand`→0). ✅ **שלבי-הפרויקט שרדו** — infra/sealing/tiling/cable/profile קיימים ב-Preact כ-5 קטגוריות (אומת).

---

## 📱 Flutter (`app_flutter/lib/data/smart_tree.dart`) — דלתא מול אב-הטיפוס (מודל-מוצר)
> typed Dart (433 ש׳) + `catalog.dart` (`kCatalogCats`).

⬆️ **שחזר + שודרג:** `SmartProduct {key, name, emoji, cat, brands[], acc[]}` + helpers `mustCount`/`recBrand`.
- ⭐ **ה-`brands[]` שוחזרו** (`SmartBrand {name, price, tag, rec}`) — **בניגוד ל-Preact שגזם אותם!** Flutter קרוב יותר לסכמת-rich של אב-הטיפוס.
- `SmartAcc {name, emoji, price, why, must}` = עץ-האביזרים (אותו must/why). `kSmartProducts` + `kSmartTreeCats`.
➖ (מול אב-הטיפוס) `kSmartProducts` = **סט-rich נבחר (~30 מוצרים בלבד, מול 202 בפרוטוטייפ/Preact)** — בלי ה-`pl_` (23 SKU מ-PDF) **ובלי שלבי-הפרויקט** (infra/sealing/… → 0 ב-smart_tree, בניגוד ל-Preact ששמר אותם). ⭐ **ארכיטקטורת-פיצול (אומת מהמקור):** `catalog.dart` (17 ש׳) = רק `kCatalogCats` (11 קטגוריות-עליונות לניווט) · `smart_tree.dart` (433) = מודל-המוצר המלא עם brands — מול ה-monolith של Preact (`catalog.ts` 4544, 202 מוצרים).
