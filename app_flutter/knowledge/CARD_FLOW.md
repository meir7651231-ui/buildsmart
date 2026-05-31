# SmartProduct Card — top-to-bottom flow

What the user sees when a SmartProduct card opens, in render order. For each
section: what it displays · which helper/provider feeds it · which ROADMAP
step shipped it. Written from the real `lib/screens/catalog_screen.dart` —
search for "Roadmap step <N>" comments to jump to the source.

## Header & diagram (top)

1. **Sheet handle + product title + emoji + category** — `widget.product`.
2. **Installation flow diagram** — `_DiagramFlow` (renders `p.stages`). Stage
   chips have a pop-in animation. Tap → `_tapStage(i)`.
3. **Explode chips** — when a stage is active, accessories whose name matches
   `p.stages[i].match` "explode" into chips below the diagram.
4. **Install progress tracker** — "מעקב התקנה N/M שלבים בוצעו" + tappable
   stage chips that toggle "done" state. Persisted via `stageProgressProvider`
   (`stage_progress.dart`). **Step 31**.

## Selectors

5. **בחר מותג** (`_SheetSection`) — collapsible brand list (`_brandCard`)
   filtered by `_filteredBrandIdx`. Includes a **"🌡 מים חמים בלבד"** quick
   filter via `brandSuitableForHot`. **Step 65**.
6. **בחר סוג** / **בחר מידה** — collapsible filters that narrow brands by
   type/size substrings on the brand name.

## 📦 נתוני קטלוג (main content)

The section header is a Row: title · **score badge** · `Spacer` · **☆ שמור**
· **📋 הצעה** · **מצב מורחב ▾**. Wrapped in `Builder(builder: (_) { final
prod = catalogProductForBrand(brand); ... })` — falls through if no SKU.

7. **Score badge** — "ציון N · מצוין" via `cardReadinessScore(prod)`. **Step 30**.
8. **Save toggle (☆/★)** — `savedConfigsProvider.toggle(p.key, brand.name)`.
   **Step 47**. Wrapped in `Semantics(button, label: 'שמור תצורה כמועדף')`
   (**step 85**).
9. **Copy-quote (📋)** — `Clipboard.setData(quoteTextFor(p, _selectedBrand))`.
   Quote text embeds the deep link (`deepLinkFor`). **Step 48 + 68**.
10. **Mode toggle (▾/▸)** — `cardDetailModeProvider.toggle()`. **Step 95**.

11. **One-line summary** — `smartCardSummaryHe(p, brand)`. **Step 59**.
12. **Discovery tags** — `discoveryTagsFor(p, brand)` (⭐ מומלץ · 💰 משתלם ·
    👑 פרימיום · 🎚 וריאנטים · 🔗 רב-תאימות). **Step 67**.
13. **System safety note** — `systemSafetyNoteHe(prod)` (🚰/🕳 שורה אחת על
    קו הזנה / ניקוז). **Step 24**.
14. **Physical-connection warning** — `connectionWarningHe(prod)` (אדום, רק
    כשאין מאטים בקטלוג). **Step 29**.
15. **"בקו שלך"** — `lineFitFor(prod, lineProducts)` shows "🧩 בקו שלך:
    N פריטים · מתחבר ל-M מהם" / "אין חיבור ישיר…". When 0 connects,
    `adapterSuggestionFor` proposes a bridging "🔌 מתאם מומלץ". **Steps
    28 + 27**.
16. **Hot-water suitability** — `hotWaterSuitabilityFor(p)` shows
    "🌡 מים חמים (60°C): X/Y מותגים מתאימים" (expert only). **Step 26**.

### Spec rows (from `engineeringSpecFor(prod)`) — step 11

17. חומר · לחץ · טמפ׳ מרבית · מערכת · קצוות (expert) · קוטר מינ׳ (expert) ·
    עמידות ★★★★☆ (expert, `durabilityRatingFor` — **step 15**) · מאתר
    (expert, `finderGroupFor`) · ערכת התקנה (expert, `installKitFor`) ·
    התקנה (expert, `installEffortFor` — **step 34**) · וריאנטים (expert) ·
    יצרן + מק"ט יצרן (expert, `manufacturerInfoFor` — **step 20**) ·
    מחיר משוער (`priceFor`).

### Price & line economics

18. **Cheaper alternative** — `cheaperAlternativeBrand(p, _selectedBrand)`
    shows "💰 חלופה זולה יותר: …" only when one exists. **Step 45**.
19. **Line cost estimate** — `lineCostEstimateFor(p, _selectedBrand)` shows
    "🧮 עלות קו משוערת: ~₪N (מוצר · אביזרים · עבודה)". **Step 42**.

### Compat & engine

20. **🔗 מתחבר ל-N מוצרים** — header from `compatibleProductsFor(prod)`.
    First 3 hits shown with `connectionExplainHe` labels. **Step 21**.
21. **Frequently paired types** (expert) — `frequentlyPairedTypesFor(prod)`
    surfaces the top 4 productTypes that connect. **Step 56**.
22. **Inline materialized chain** — when the cart is non-empty,
    `buildInstallation([...cart, prod])` + `chainArrowText(plan.items)`
    shows "🔗 שרשרת: …". **Step 23**.
23. **🔧 בנה לי קו (BOM) button** — `_showLineBom(prod)`. Dialog lists
    `plan.items` with quantities + gap count. **Step 22**. Wrapped in
    `Semantics(button, label: 'פתח קו פריטים מומחש')`.
24. **🛡 ערכת בטיחות (auto)** — `safetyKitItems` between
    `buildInstallation(autoCompliance:true)` and `false` plans. **Step 25**.
25. **🛒 + בטיחות לסל** — `buildSafetyAccessories` converts kit SKUs to
    `SmartCartAcc`, attached to a new `SmartCartLine`. **Step 46**.

### Project actions (from `cardProjectsProvider`)

26. **➕ הוסף לפרויקט** — `notifier.add(ProjectItem(...))`. **Step 71**.
27. **×3 חדרים** — `notifier.addToLocations(template, ['חדר 1','חדר 2','חדר 3'])`.
    **Step 72**.
28. **🧩 תבניות** — `projectTemplates()` chips (אמבטיה/מטבח סטנדרטי) call
    `notifier.applyTemplate(...)`. **Step 80**.
29. **Project counter** — "📋 בפרויקט 'הפרויקט שלי': N יחידות · M מיקומים"
    when `units > 0`. **Step 74**.
30. **📋 BOM פרויקט מלא** — `_showProjectBom(proj)` resolves all
    `ProjectItem.sku` → catalog products → `buildInstallation`. **Step 74**.
31. **📋 הצעת מחיר לפרויקט** — `projectQuoteText(proj, items)` copied to
    clipboard. **Step 75**.

### Compliance & detail (expert)

32. **תקינות נדרשת** — `complianceTriggersFor(prod)` (always). Each trigger:
    label · reason. Below each (expert): **↳ "למה זה חשוב"** via
    `complianceWhyHe`. **Steps 19 + 58**.
33. **מה הקו צריך לחיבור** (expert) — `connectionNeedsHe(prod)`. **Step 73**.
34. **בדיקת קבלה** (expert) — `acceptanceChecklistFor(prod)`. **Step 38**.
35. **תקן ישראלי רלוונטי** (expert) — `israeliStandardsFor(prod)`. **Step 12**.
36. **כלי עבודה** (expert) — `installToolsFor(prod)`. **Step 33**.
37. **טעויות נפוצות וטיפים** (expert) — `installTipsFor(prod)`. **Step 35**.
38. **גרסאות נוספות במשפחה** (expert) — `variantSiblingsOf(prod)`. **Step 63**.
39. **💾 שמור גרסה** + chips (expert) — `cardVersionsProvider.save(label:
    brand.name, productKey, brandName)` and chips listing
    `notif.forProduct(p.key)`. **Step 76**.
40. **מתי לבחור איזה מותג** (expert) — `brandDecisionGuide(p)`. **Step 16**.
41. **נצפו לאחרונה** (expert) — `recentlyViewedProvider.touch(sku)` recorded
    in `initState`; the list shows up to 5 other recently-viewed SKUs.
    **Step 66**.

## Footer (bottom of sheet)

42. **פריטי חובה ⚡** — `p.acc.where((a)=>a.must)` checkboxes + qty steppers.
43. **פריטים אופציונליים 💡** — `p.acc.where((a)=>!a.must)` checkboxes + qty.
44. **הוסף לסל ₪total** — builds `SmartCartLine` from selected accessories.

## Cross-cutting state

- **`_selectedBrand`** is initialised in `initState` to `cardSelectionProvider`
  if the user previously chose a brand for this product (**step 7**), else
  the recommended brand.
- **Recently-viewed** is touched once per card open (`initState`
  post-frame callback).
- Mode toggle and save-toggle are wrapped in `Semantics` for screen-reader
  support (**step 85**).
