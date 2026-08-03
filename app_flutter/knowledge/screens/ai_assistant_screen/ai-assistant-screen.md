# AiAssistantScreen

- **screen:** `ai_assistant_screen`
- **role:** composer

## עצם · object (6)

> registry 5 · mapped 5/5 · **unregistered 1**

- **cfgText** "🤖 העוזר החכם" · `ai_assistant_screen.title` ✅
- **cfgText** "💡 העוזר החכם דורש חיבור לשרת." · `ai_assistant_screen.offline` ✅
- **text** "🤖" · — לא-רשום
- **cfgText** "שאל אותי כל דבר על אינסטלציה, רכש או עבודה." · `ai_assistant_screen.empty_prompt` ✅
- **cfgText** · `ai_assistant_screen.empty_examples` ✅
- **cfgText** "✓ נוסף לסל" · `ai_assistant_screen.added` ✅

## חיבורים · connections (4)

- **reads** · `read` → `claudeGatewayProvider`
- **reads** · `read` → `ordersEngineProvider`
- **reads** · `read` → `smartCartProvider`
- **reads** · `watch` → `claudeGatewayProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (8)

- `assistantIntentPrompt`
- `computeAnalyticsInsights`
- `fuzzySearchProducts`
- `matchRecipe`
- `parseAssistantIntent`
- `productsInCategory`
- `resolvedKitProducts`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** 1 unregistered — "🤖"
