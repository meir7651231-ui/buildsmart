# AIHubScreen

- **screen:** `ai_hub_screen`
- **role:** composer

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "הדפדפן לא תומך בחיפוש קולי" · `ai_hub_screen.t01` ✅

## חיבורים · connections (10)

- **action** · `openBarcodeScanner` → `openBarcodeScanner`
- **action** · `showLipskeyProductSheet` → `showLipskeyProductSheet`
- **writes** · `state=` → `searchQueryProvider`
- **writes** · `state=` → `mainTabProvider`
- **action** · `push` → `DescribeToCartScreen`
- **action** · `push` → `AiAssistantScreen`
- **action** · `openCheaperAlternativesSheet` → `openCheaperAlternativesSheet`
- **action** · `openScanPlanSheet` → `openScanPlanSheet`
- **action** · `push` → `_AIFeatureScreen`
- **reads** · `watch` → `smartCartProvider.select((lines) => lines.isNotEmpty)`

## התנהגות · behaviour (5)

- **onTap** → _verb_ `Navigator.of(context).push(DescribeToCartScreen.route())` → navigate → DescribeToCartScreen
- **onTap** → _verb_ `Navigator.of(context).push(AiAssistantScreen.route())` → navigate → AiAssistantScreen
- **onTap** → _verb_ `openCheaperAlternativesSheet(context)` → open → openCheaperAlternativesSheet
- **onTap** → _verb_ `openScanPlanSheet(context)` → open → openScanPlanSheet
- **onTap** → _verb_ `Navigator.of(context).push(_AIFeatureScreen.route(t.id))` → navigate → _AIFeatureScreen

## floor · external functions (3)

- `catalogProductForSku`
- `catalogSiblingsFor`
- `unawaited`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - KbScreen = shared component → separate atom
- **gaps:** none (all registry-backed)
