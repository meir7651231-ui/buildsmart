# ManagerCopilotScreen

- **screen:** `manager_copilot_screen`
- **role:** composer

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgText** "🤖 קו-פיילוט" · `manager_copilot_screen.title` ✅
- **cfgText** "שאל את העסק שלך" · `manager_copilot_screen.subtitle` ✅

## חיבורים · connections (5)

- **reads** · `read` → `ordersEngineProvider`
- **reads** · `read` → `managerAnalyticsProvider`
- **reads** · `read` → `managerCustomersProvider`
- **reads** · `read` → `claudeGatewayProvider`
- **reads** · `watch` → `claudeGatewayProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (4)

- `buildManagerContext`
- `managerCopilotPrompt`
- `managerMorningBriefPrompt`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
