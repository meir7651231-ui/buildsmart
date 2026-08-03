# LipskeyProductSheet

- **screen:** `lipskey_product_sheet`
- **role:** composer

## עצם · object (18)

> registry 16 · mapped 16/16 · **unregistered 2**

- **cfgText** "נוסף לסל ✓" · `lipskey_product_sheet.added_to_cart` ✅
- **cfgText** "🔗 קשור" · `lipskey_product_sheet.related_rail_title` ✅
- **cfgText** "🔌 מה מתחבר לזה" · `lipskey_product_sheet.connects_rail_title` ✅
- **cfgText** "הוסף לקו" · `lipskey_product_sheet.add_to_line` ✅
- **cfgText** "נוסף לקו ✓" · `lipskey_product_sheet.added_to_line` ✅
- **cfgText** "📋 רשימת חומרים — קו" · `lipskey_product_sheet.line_bom_title` ✅
- **cfgText** "לא נמצאו פריטים לפתרון — בחר מוצרים אחרים לקו" · `lipskey_product_sheet.line_bom_empty` ✅
- **cfgText** "מק"ט הועתק" · `lipskey_product_sheet.sku_copied` ✅
- **cfgText** "חזרה למוצר הקודם" · `lipskey_product_sheet.hop_back` ✅
- **cfgText** "💡 צ׳יפ כתום ▾ — הקש להחלפת גודל/צבע/דגם" · `lipskey_product_sheet.chip_hint` ✅
- **text** "🧩" · — לא-רשום
- **cfgText** "ערכת התקנה מומלצת" · `lipskey_product_sheet.recommended_kit` ✅
- **cfgText** "+ ערכה" · `lipskey_product_sheet.add_kit` ✅
- **cfgText** "אביזרים נבחרים:" · `lipskey_product_sheet.selected_accessories` ✅
- **cfgText** "הוסף לסל" · `lipskey_product_sheet.add_to_cart_btn` ✅
- **text** "🌡️" · — לא-רשום
- **cfgText** "מתאים לתנאים שלי?" · `lipskey_product_sheet.spec_copilot_cta` ✅
- **cfgText** "מה עוד צריך להתקנה?" · `lipskey_product_sheet.paired_explain_cta` ✅

## חיבורים · connections (18)

- **reads** · `read` → `smartCartProvider`
- **writes** · `add` → `smartCartProvider`
- **reads** · `read` → `featureFlagsProvider`
- **gated-by** · `guard` → `neighbours.isEmpty`
- **gated-by** · `guard` → `connects.isEmpty`
- **reads** · `watch` → `cardPicksProvider`
- **reads** · `read` → `cardPicksProvider`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`
- **writes** · `clear` → `cardPicksProvider`
- **action** · `push` → `seed`
- **action** · `push` → `q`
- **reads** · `watch` → `catalogSettingsProvider`
- **action** · `showLipskeyProductSheet` → `showLipskeyProductSheet`
- **action** · `push` → `SpecCopilotScreen`
- **gated-by** · `guard` → `pairedTypes.isEmpty`
- **gated-by** · `guard` → `ref.watch(claudeGatewayProvider) == null`
- **reads** · `watch` → `claudeGatewayProvider`
- **action** · `push` → `PairedExplainScreen`

## התנהגות · behaviour (8)

- **build** → _rule_ `if (neighbours.isEmpty)` → hidden (SizedBox.shrink)
- **build** → _rule_ `if (connects.isEmpty)` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: CfgText('l…` → open → showSnackBar
- **onTap** → _verb_ `showLipskeyProductSheet(context, g.parts[i], _scanPool.where((x) => x.categor…` → open → showLipskeyProductSheet
- **onPressed** → _verb_ `Navigator.of(context).push(SpecCopilotScreen.route(p))` → navigate → SpecCopilotScreen
- **build** → _rule_ `if (pairedTypes.isEmpty)` → hidden (SizedBox.shrink)
- **build** → _rule_ `if (ref.watch(claudeGatewayProvider) == null)` → hidden (SizedBox.shrink)
- **onPressed** → _verb_ `Navigator.of(context).push(PairedExplainScreen.route(product: p.nameHe, types…` → navigate → PairedExplainScreen

## floor · external functions (14)

- `addParts`
- `cardReadinessScore`
- `chip`
- `dataCompletenessScore`
- `formatDimValue`
- `frequentlyPairedTypesFor`
- `genderRank`
- `lipskeyAccFor`
- `lipskeyStagesFor`
- `max`
- `methodRank`
- `planLineFromPicks`
- `scoreBandColors`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `product` · `categoryProducts` · `forceLive` · `hopSeedForTest`
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 2 unregistered — "🧩" · "🌡️"
