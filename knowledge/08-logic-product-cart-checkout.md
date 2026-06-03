# ליבת המוצר · עץ · אביזרים · סורק · סל · checkout (9000–11000)

## נתוני-מוצר משלימים
- `ICN` (9362) — סט SVG icons לדיאגרמות (parts/manifold/roughin/valve/finished/cistern/seal/shower/wall/pipe/tiles).
- **`DIAGRAMS`** (9375) — דיאגרמת-התקנה לכל מוצר: `{title, stages:[{ic, l, s, match[], final?}]}`; **`match[]`** = מילות-אביזר השייכות לשלב. faucet: רכיבים→הזנת-מים→חיבור-גס→ברז-גמור.
- `ACC_PRICE_BOOK` (9518) — `[regex, price]` fallback למחיר-אביזר (טפלון→9 · מפתח→89 · חותך→145 · אטם→6).
- `SPECS` (9894) — מפרט-הנדסי/קטגוריה: `{material, standard(ת"י), warranty}` (אסלות=חרס · ת"י1385 · 10ש׳).
- `CAT_DESC` (9906) — תיאור פשוט/קטגוריה.
- **`ACC_TYPES`** (9991) — ידע-אביזר לפי `kw`: `{kw[], material, standard, tip}` (טפלון 5–7 סיבובים · סיליקון יבש 24ש׳ · אטם זול-אך-קריטי).
- **`ACC_GROUPS`** (10025) — **12 קבוצות פונקציונליות** (כלי-עבודה/אטמים/חומרי-איטום/ברזים-שסתומים/מסננים/צנרת/חיבורים/ברגים/מיכלים-סמויים/חשמל-חימום/בנייה/גמר), כל אחת `kw[]`.
- `HOME_PRODUCTS` (10614) = `['faucet','toilet','shower']` (מומלצי-בית).
- `CATEGORY_STORE` (10816) — קטגוריה→חנות-ספק: **s1**=ברזים/ניקוז/חימום/חיבורים/נלווים · **s2**=אסלות/מקלחות/תברואה/מטבח · **s3**=בנייה/גמר.
- `DELIVERY_SLOTS` (10908) — 5 חלונות: היום(אקספרס≤שעתיים · 14–16) · מחר(7–9 · 12–14 · 16–18).

## עץ-המוצרים + דיאגרמות (9418–9650)
`renderTreeDiagram`/`pickDiagramStage` · `dayDiagramHTML`/`pickDayStage` · `accMatchesStage` (התאמת-אביזר-לשלב ע"י `DIAGRAMS.match`). `accTypePrice`/`attachSize`. **`openTree`** (9546)/`closeTree` (overlay עץ-המוצרים). `openOrder`/`closeOrder` (סדר-הרכבה).

## סורק-תוכניות (9658–9893)
`PLAN_TYPES` (9658) — סוגי-תוכנית (plumbing/electrical/…): `steps`(אנימציה) · `blueprint`(SVG) · `dots`(נקודות-זיהוי) · `zones`(אזורים + `conf`% + מחירי-חנות). `renderPlanPicker`/`pickPlan`/`bestStore` · **`startScan`**/`renderScanResults`/`resetScan`/`addScanToCart`.

## כרטיס-מוצר + אביזרים (9894–10314)
`productDetailCard`/`openProductDetail`/`editProductMaterial`. accessory engine: `accGroupOf`/`accProfile`/`productCategoryMap`/`allAccessories`/`accessoriesForCategory` · `openAccCard`/`openAccDetail` · `stockInfo`/`cycleAccStock` · **`accBox`**/`toolBox`/`renderAccessories`.

## כרטיס-קטלוג + כמויות (10315–10460)
`catalogDetailCard`/`pickCatalogSize`/`pickCatalogStore`/`catalogStoreIndex` · `imgFallback` · `togglePick`/`setQty`/`stepQty`/`openQtyInput` · `catQty`/`setCatQty`/`stepCatQty`.

## אינטראקציית-עץ + הוספה-לסל (10461–10630)
`toggleTreeTool`/`toggleToolbag`/`updateTreeTotal`/`refreshRootCheck`/`toggleRootInTree` · **`addTreeToCart`** (10513). `productInCart`/`toggleProductInCart`/`refreshProductCartItem`/`addSingle`/`addMainProduct` · `renderHomeProducts`.

## בוררי מותג / וריאציה / מידה (10687–10780)
`openBrands`/`pickBrand` · `openVariants`/`pickVariant` · `openAccSize`/`pickAccSize`.

## ⭐ סל + checkout (10780–11000)
`updateCartCount` · `pickSlot`/`pickHaul` · `assignStore`/`storeForProduct` (לפי `CATEGORY_STORE`).
**`computeCheckout()`** (10838) — מנוע-החיוב:
1. מקבץ `cart` לפי חנות-ספק → `storeGroups` (subtotal/חנות).
2. משלוח/חנות = `baseShipping + haulExtra` (סוג-הובלה).
3. **split-shipment** (`cartHasSplit`): כל גל = שיגור-רכב נפרד → מחויב `Σ(base כל ספק בגל) + haul-fee`; `breakdown` per-wave.
4. `expressFee` (אם express) → `taxable = subtotal+shipping+express` → **`vat = taxable·VAT_RATE`** → `grandTotal`.
מחזיר `{storeGroups, itemsSubtotal, shippingTotal, shipmentShipping, expressFee, vat, grandTotal, itemCount}`.
עריכת-סל: `stepCartQty`/`removeCartItem`/`syncCartToProject` · `openCartSitePicker`/`chooseCartSite` · `openPaymentDetail`.
