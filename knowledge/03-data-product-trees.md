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

## 📱 Flutter (`app_flutter/lib/data/`) — האפליקציה האמיתית (מודל-מוצר) ⭐ נכתב-מחדש מ-whats-happening
> ⚠️ הגרסה הקודמת תיארה snapshot מיושן (~30 מוצרים, smart_tree 433ש׳). המציאות שונה לחלוטין — **קטלוג-מותגים אמיתי, לא port של TREES.**

⭐ **קטלוג-אמת: 1,337 מוצרים** ב-`kCatalogProducts` = **Lipskey 255 + Polyroll 779 + Huliot-SmartLock 170 + HW-סינתטי 133**. מחולץ מ-PDFים אמיתיים (Lipskey-Barkan · Polyroll/AQUATEC · Huliot 44-עמ׳) עם **QA דו-שכבתי** (`scripts/catalog_qa.py`, 100+ כללים · R8 verbatim-מ-PDF · override-tables append-only).
- **`LipskeyCatalogProduct`** = `{sku, nameHe/En, brand, categoryHe/En, page, dims, imageFile/specImageFile, qtyPack/Pallet, color}`. **SKU = מפתח-העל** לכל המערכת.
- **`SmartProduct`** (`smart_tree.dart`, **~81 כרטיסים-מובחרים**) = `{key, name, emoji, cat, brands[], acc[], stages[]}` · `SmartBrand{name, tag, price?, rec, sku?}` (**ה-SKU על ה-brand, לא על המוצר**) · `SmartAcc{name, emoji, why, must, price?, sku?}` · `SmartStage{emoji,label,sub,isFinal,match[]}`. reverse-index `smartProductForSku`.
- ⭐ **`VerifiedSpec`** (`lipskey_verified_connections` + `polyroll_specs`, **808+ specs**) = מנוע-ההתאמה: `{sku, material, ends[ConnectorEnd{type,size}], pressureRating, maxTempC(ברירת 40), systemOverride}`. enums **EndType**(hdpeCompression/pexPress/copperPress/bspMale/bspFemale/drainOpening) · **WaterSystem**(supply/drainage). `main.dart` מסנתז specs ל-~779 מוצרי-Polyroll באתחול.
- תומכים: `catalog_tree.dart` (עץ-ניווט ~210 leaves) · `variant_families.dart` (זיהוי משפחות size/color/model/subtype) · `fuzzy_search.dart` · `brands.dart` (8 מותגים) · `lipskey_hotwater`/`lipskey_smart_data`/`polyroll_specs`/`huliot_smartlock_catalog`.
- כל הנתונים **קבועי-Dart** (אין DB/REST). תמונות → CDN (Cloudflare R2) דרך `product_images.dart`.

🔧 **מול אב-הטיפוס:** מותגים **אמיתיים** (Lipskey/Polyroll/Huliot — לא "סטנדרט/כלכלי/פרימיום" גנרי) · מוצרי-אינסטלציה אמיתיים (255+779+170) במקום 202 ה-TREES; ה-`pl_`/שלבי-הפרויקט של הפרוטוטייפ **אינם רלוונטיים** (קטלוג-מותג אחר לגמרי). מנוע-ה-`VerifiedSpec` (חיבוריות פיזיקלית) — **חדש לגמרי, אין לו מקבילה בפרוטוטייפ/Preact.**
⚠️ **doc-vs-code drift:** מסמכי-ה-KB אומרים **1,879 מוצרים (Lipskey 935)** — הקוד אומר **1,337 (Lipskey 255)**. הקוד קובע (R6).
