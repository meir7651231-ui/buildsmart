# מנוע-המסחר — תמחור · ספקים · VAT · SYS_ORDERS (11908–12061)

## תמחור לפי-חנות (11908–11929)
- **`STORE_PRICING`** (11908) — מפת-מחיר SKU לכל חנות: `store0/store1/store2:{sku:price}`. **אותו SKU עולה אחרת בכל חנות.** `activeCatalogStore='store0'`. `skuPrice`/`catalogProductPrice` — מחיר ה-`pl_` מכאן.
- `STORES` (11930) — 3 חנויות-תצוגה (תל-אביב/השרון/הרצליה, eta "עד שעתיים").

## ⭐ תצורת-checkout (11936–11968)
- **`VAT_RATE = 0.18`** (מע"מ ישראלי 18%, מ-Jan-2025; single-source-of-truth).
- **`SUPPLIER_STORES`** (11942) — 3 ספקי-checkout + דמי-משלוח:
  | id | שם | icon | shipping |
  |---|---|---|---|
  | `s1` | מחסני אינסטלציה תל-אביב | 🔧 | ₪90 |
  | `s2` | ספקי סניטריה השרון | 🚿 | ₪65 |
  | `s3` | חומרי בניין הרצליה | 🧱 | ₪45 |
  `STORE_IDS`=מפתחות. (תואם ל-`CATEGORY_STORE` ב-08.)
- **`HAUL_TYPES`** (11950) — סוג-הובלה (נוסף ל-shipping): `small` 🛵 +0 · `van` 🚐 +40 · `truck` 🚛 +90. `storeHaul{}` · `haulFor`/`haulExtra`.
- `EXPRESS_FEE = 80`.

## ⭐ מערכת-ההזמנות המשותפת (11969–12061)
- `BS_ORDERS_KEY = 'buildsmart:sharedOrders'` (מפתח localStorage).
- **`SYS_ORDERS_SEED`** (11970) — 4 הזמנות-משותפות: `{id, who, site, items, sum, stage, lines[{name,qty}]}`:
  BS-1042 (יוסי כהן · מגדל הרצליה · ₪1240) · BS-1041 (אבי מזרחי · רמת גן · ₪680) · BS-1040 (משה אברהם · וילה סביון · ₪3150) · BS-1039 (דוד לוי · משרדים ת"א · ₪420).
- `loadSysOrders`/`saveSysOrders` (persist) · `SYS_ORDERS=loadSysOrders()`.
- **`ORDER_STAGE`** (12041) — 6 שלבים: `new`(התקבלה) · `preparing`(בהכנה) · `ready`(מוכן לאיסוף) · `pickup`(נאסף) · `transit`(בדרך לאתר) · `delivered`(נמסר ✓).
- `STORE_STOCK={}` (12050) — מלאי ממופתח ל-`TREES`; מנהל/חנות מחליפים זמינות.

---
**עמוד-השדרה החוצה-פרסונות:** `SYS_ORDERS` (ב-localStorage) הוא המאגר המשותף — קבלן מזמין (`checkout`→`syncOrderToSystem`), והחנות/שליח/מנהל קוראים אותו ומקדמים `stage`. זרימת-מחיר: `pl_` מ-`STORE_PRICING` (לפי חנות) · rich מ-`brands.price+delta` (08) · checkout מוסיף `SUPPLIER_STORES.shipping + haulExtra + EXPRESS_FEE + VAT(18%)`.

---

## 🔄 Preact (`app/src/`) — דלתא מול אב-הטיפוס (מנוע-מסחר)
⬆️ `SUPPLIER_STORES`+`STORE_PRICING` → **`suppliers.ts`** (auto-gen מ-index.html): `SUPPLIERS`(s1/s2/s3, אותם shipping/eta) + `STORE_PRICING`(per-store SKU) + `DEFAULT_SUPPLIER_ID='s1'`, מטוייפים.
➖ **הסל פושט:** `app-store.ts` — `cart`/`setQty`/`incQty`/`decQty`/`cartCount` (signals בלבד). ✅ **אומת (grep=0):** `computeCheckout`/`SYS_ORDERS`/`syncOrderToSystem`/`checkout`/split-shipment/VAT — **לא הומרו ל-Preact כלל** (פרסונות placeholder, אין מנוע-checkout).

---

## 📱 Flutter — דלתא
⭐ נכתב-מחדש: ✅ **VAT 18% מיושם** (checkout ב-`store_screen`, inclusive/exclusive) · משלוח (express ₪120/standard ₪45/pickup) · **`price_estimate.dart`** (אומדן לפי-קטגוריה). ➖ **`SYS_ORDERS`/sync-חוצה-פרסונות/`SUPPLIER_STORES` המלא — אין** (אין backend; הזמנות=mock). ⚠️ **מחירים:** `brandPrice` ברוב המוצרים = **0** (ממתין לנתוני-ספק — חוסם-launch). persist ב-`shared_preferences`.
