# AiFinderScreen

- **screen:** `ai_finder_screen`
- **role:** composer

## עצם · object (8)

> registry 7 · mapped 7/7 · **unregistered 1**

- **cfgText** "🗣️ חיפוש חכם" · `ai_finder_screen.t01` ✅
- **cfgText** "💡 החיפוש החכם דורש חיבור לשרת." · `ai_finder_screen.t02` ✅
- **cfgText** "תאר במילים שלך מה אתה מחפש:" · `ai_finder_screen.t03` ✅
- **cfgVisible** · `ai_finder_screen.t04` ✅
- **text** "🔎" · — לא-רשום
- **cfgText** "מצא לי" · `ai_finder_screen.t04` ✅
- **cfgText** "משהו השתבש — נסה שוב." · `ai_finder_screen.t05` ✅
- **cfgText** "לא נמצאו תוצאות — נסה מילים אחרות." · `ai_finder_screen.t06` ✅

## חיבורים · connections (3)

- **reads** · `read` → `claudeGatewayProvider`
- **reads** · `watch` → `claudeGatewayProvider`
- **action** · `showLipskeyProductSheet` → `showLipskeyProductSheet`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `showLipskeyProductSheet(context, p, _products)` → open → showLipskeyProductSheet

## floor · external functions (3)

- `fuzzySearchProducts`
- `kbAiFinderNodes`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `initialQuery`
- **untangle:**
  - CustomScrollView = shared component → separate atom
  - KbScreen = shared component → separate atom
- **gaps:** 1 unregistered — "🔎"
