# _HeroImage

- **screen:** `lipskey_product_sheet`
- **role:** section

## עצם · object (4)

> registry 4 · mapped 4/4 · **unregistered 0**

- **cfgText** "חזרה למוצר" · `lipskey_product_sheet.back_to_product` ✅
- **cfgText** "PPR-CT" · `lipskey_product_sheet.ppr_ct_badge` ✅
- **cfgText** "פרטים / מפרט" · `lipskey_product_sheet.details_spec` ✅
- **cfgText** "הגדלה" · `lipskey_product_sheet.zoom` ✅

## חיבורים · connections (1)

- **reads** · `read` → `catalogSettingsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (4)

- `productImage`
- `rotateY`
- `setEntry`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `product` · `screenH`
- **gaps:** none (all registry-backed)
