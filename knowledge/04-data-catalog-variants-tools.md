# שכבת-הקטלוג — CATALOG · VARIANTS · SIZES · STOCK_DEMO · TOOLS (6046–6320)

כולם ממופתחים ב-**product-key** (מ-`TREES`) או ב-**accessory-name**.

## `CATALOG` (6046–6058) — אינדקס-קטגוריות לתצוגה
מערך 11 קטגוריות: `{cat, icon, items:[product-keys]}`. ממפה קטגוריה → מפתחות-מוצרים (rich + `acc_N`).
| icon | קטגוריה | items (דוגמה) |
|---|---|---|
| 🚰 | ברזים וכיורים | faucet · kitchenFaucet · basin · acc_* |
| 🚽 | אסלות | toilet · toiletFloor · acc_* |
| 🚿 | מקלחות ואמבטיות | shower · bathtub · acc_* |
| ♨️ | חימום מים | boilerElectric · boilerSolar |
| 🍽️ | מטבח | kitchenSink · dishwasher · washingPoint |
| 🕳️ | ניקוז וצנרת | pipes · floorDrain · pressureReg |
| 🚾 | גופי תברואה | showerCabin · bidet |
| 🔗 | אביזרי קצה וחיבורים | endTaps · elbows · extenders · connectors · seals |
| 🧱 | בנייה ומחיצות | wall · door |
| 🎨 | גמר | seal · floor |
| 🧰 | אביזרים נלווים | acc_1 … acc_148 |

## `VARIANTS` (6060–6184) — ציר-וריאציה לכל מוצר
- **pl_*** (23 SKU): `{label:"מידה / קוטר", sku:true, opts:[{name,sku}]}` — מידות נושאות-מק"ט.
- **rich** (~22): `{label, opts:[…]}` — ציר-בחירה אחד לכל מוצר-אב:
  `faucet`=גובה הברז · `kitchenFaucet`=סוג · `basin`=סוג הכיור · `toilet`=צבע/גימור ·
  `toiletFloor`=סוג ההדחה · `shower`=סוג הסוללה · `bathtub`=מידה · `wall`=סוג הגבס ·
  `door`=מידה · `floor`=מידת האריח · `seal`=סוג מערכת-איטום · `pipes`=סוג הצנרת ·
  `boilerElectric/boilerSolar`=נפח · `kitchenSink`=מספר כיורים · `dishwasher/washingPoint`=סוג התקנה ·
  `floorDrain`=סוג המחסום · `pressureReg`=סוג · `showerCabin`=צורה · `bidet`=סוג התקנה.

## `SIZES` (6185–6199) — מידות-אביזר עם delta-מחיר
`'accessoryName':[{name, delta}]` — אופציות-מידה לאביזר; **`delta`** = תוספת/הנחה למחיר-הבסיס.
דוגמה: `'צינורות מים PEX':[{16מ"מ,0},{20מ"מ,+55}]` · `'מאריך 1/2"':[{2ס"מ,-2},{5ס"מ,0}]` (delta שלילי = זול יותר).

## `STOCK_DEMO` (6202–6214) — seed-מלאי-הדגמה
`'accessoryName':'warehouse'|'site'` — מצב-מלאי התחלתי לפי שם-אביזר (במחסן / באתר). מזין את `view-stock`.

## `TOOLS` (6216–6320) — כלים-נדרשים לכל מוצר
`productKey:[{name, img, why, price}]` — רשימת-הכלים להתקנת ~21 מוצרי-אב.
דוגמה `faucet`: מפתח-צינורות מתכוונן (why:"להידוק האום", ₪—) · מפתח-אלן (₪24) · מברגה (₪280).

---
**תובנה:** שכבת-הקטלוג עוטפת את `TREES` — CATALOG=ארגון-תצוגה · VARIANTS=בחירה · SIZES=תמחור-מידה · STOCK_DEMO=מצב-התחלתי · TOOLS=השלמת-כלים. מפתח משותף: product-key / accessory-name.

---

## 🔄 Preact (`app/src/data/`) — דלתא מול אב-הטיפוס (שכבת-קטלוג)
> כולם **auto-generated מ-`/index.html`** (`scripts/extract-catalog.mjs`), מטוייפים.

⬆️ **שודרג (מטוייף, אותו תוכן):**
- `VARIANTS` → **`variants.ts`** (2366 ש׳): `VARIANTS: Record<string, VariantDef>` + types `VariantDef`/`VariantOption`.
- `TOOLS` → **`tools.ts`** (425 ש׳): `TOOL_BUNDLES: Record<string, ToolItem[]>` + `ToolItem`.
- `SUPPLIER_STORES`+`STORE_PRICING` → **`suppliers.ts`** (759 ש׳): `SUPPLIERS`(s1/s2/s3) + `STORE_PRICING`(per-store SKU) + `DEFAULT_SUPPLIER_ID='s1'`. (גם דוח 10.)
- `CATALOG`/`CATEGORIES` → `catalog.ts` (דוח 03).

➖ **הוחסר משכבת-ה-data:** `SIZES` (delta-מחיר) · `STOCK_DEMO` · `ACC_TYPES`/`ACC_GROUPS`/`ACC_PRICE_BOOK`/`SPECS`/`CAT_DESC`/`DIAGRAMS`/`ICN` — לא נמצאים כמבני-data אוטו-מחולצים (חלקם אולי inline בקומפוננטה). **ה-`brands[]` נגזם לחלוטין** (`grep brand` ב-`data/`→0).

---

## 📱 Flutter (`app_flutter/lib/data/`) — דלתא
⭐ נכתב-מחדש: `catalog_tree.dart` (עץ-ניווט **153 nodes / ~108 leaves**, אומת — לא ~210) · `variant_families.dart` (זיהוי משפחות size/color/model/subtype) · `chip_hierarchy.dart` · `fuzzy_search.dart` · `lipskey_smart_data.dart` (accessories/stages per-SKU) · `menu_trees.dart` (`kHomeTree`/`kCartTree`/**`kFinanceHub`**/`projectsTree`).
🔧 **מול אב-הטיפוס:** VARIANTS → `variant_families` (computed) · SIZES → **`_size_norm.dart`** (`SizeFamily`/`SizeToken` — ראה SIZE_FILTER-protocol, דוח 22) · TOOLS → `install_kit.dart` (לוגיקה, לא bundles). הקטלוג = **1,877 מוצרים** (935+772+170, אומת שורה-שורה — דוח 03), לא ה-`pl_`/SIZES/TOOLS של הפרוטוטייפ.
