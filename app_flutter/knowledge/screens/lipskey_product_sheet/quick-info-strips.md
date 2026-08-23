# _QuickInfoStrips

- **screen:** `lipskey_product_sheet`
- **role:** section

## עצם · object (20)

> registry 10 · mapped 10/10 · **unregistered 10**

- **text** "אין קבוצה" · — לא-רשום
- **text** "אין מוצרים אחרים בקבוצה" · — לא-רשום
- **text** "אין מפרט תואם" · — לא-רשום
- **text** "לא נמצאו מוצרים שמשלימים את הקצוות" · — לא-רשום
- **text** "אין מוצרים משלימים" · — לא-רשום
- **text** "אין רשימת ערכת התקנה" · — לא-רשום
- **cfgText** "חובה (עץ חכם)" · `lipskey_product_sheet.must_smart_tree` ✅
- **cfgText** "אופציונלי (עץ חכם)" · `lipskey_product_sheet.optional_smart_tree` ✅
- **cfgText** "כלים ואיטומים (אוטומטי)" · `lipskey_product_sheet.tools_auto` ✅
- **cfgText** "חובה" · `lipskey_product_sheet.must_badge` ✅
- **text** "אין וריאנטים נוספים" · — לא-רשום
- **text** "אין דרישות תקינות מיוחדות" · — לא-רשום
- **cfgText** "חובה" · `lipskey_product_sheet.must_badge_compliance` ✅
- **text** "אין מפרט הנדסי מאומת" · — לא-רשום
- **cfgText** "צנרת PPR לאספקת מים חמים וקרים" · `lipskey_product_sheet.ppr_caption` ✅
- **cfgText** "SMART LOCK — מערכת דלוחין, צנרת ואביזרים מפוליפרופילן בקטרים 32-63 מ"מ בצבע שחור" · `lipskey_product_sheet.smartlock_caption` ✅
- **text** "אין הערכת מחיר לקטגוריה זו" · — לא-רשום
- **cfgText** "ליחידה" · `lipskey_product_sheet.per_unit` ✅
- **cfgText** "הערכה" · `lipskey_product_sheet.estimate_badge` ✅
- **cfgText** "הערכה לפי קטגוריה — מחיר אמיתי תלוי בספק, מותג ומידה ספציפית." · `lipskey_product_sheet.price_note` ✅

## חיבורים · connections (2)

- **reads** · `watch` → `catalogSettingsProvider`
- **gated-by** · `guard` → `rows.isEmpty`

## התנהגות · behaviour (1)

- **build** → _rule_ `if (rows.isEmpty)` → hidden (SizedBox.shrink)

## floor · external functions (21)

- `bsSuccess`
- `companyComplementsFor`
- `compatibleProductsCount`
- `compatibleProductsFor`
- `complianceTriggersFor`
- `connectionExplainHe`
- `currencySymbol`
- `engineeringSpecFor`
- `finderGroupFor`
- `formatCatalogPrice`
- `installKitFor`
- `onPickProduct`
- `priceFor`
- `priceWithVat`
- `productImage`
- `recommendedKitForProduct`
- `row`
- `setState`
- `smartProductForSku`
- `variantSiblingsCountFor`
- `variantSiblingsOf`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `product` · `onPickProduct`
- **gaps:** 10 unregistered — "אין קבוצה" · "אין מוצרים אחרים בקבוצה" · "אין מפרט תואם" · "לא נמצאו מוצרים שמשלימים את הקצוות" · "אין מוצרים משלימים" · "אין רשימת ערכת התקנה" · "אין וריאנטים נוספים" · "אין דרישות תקינות מיוחדות" · "אין מפרט הנדסי מאומת" · "אין הערכת מחיר לקטגוריה זו"
