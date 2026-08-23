# _DashboardTab

- **screen:** `manager_dashboard_screen`
- **role:** section

## עצם · object (7)

> registry 4 · mapped 4/4 · **unregistered 3**

- **text** "🤖" · — לא-רשום
- **cfgText** "שאל את העסק שלך" · `manager.cockpit.copilot.title` ✅
- **text** "🎬" · — לא-רשום
- **cfgText** "סטודיו — ערוך את האפליקציה" · `manager_dashboard_screen.studio_hero_title` ✅
- **cfgText** "ניסיוני" · `manager_dashboard_screen.studio_experimental_badge` ✅
- **text** "🔔 דורש טיפול" · — לא-רשום
- **cfgText** "צינור ההזמנות" · `manager.dash.pipeline.title` ✅

## חיבורים · connections (13)

- **reads** · `watch` → `managerAnalyticsProvider`
- **reads** · `watch` → `ordersEngineProvider`
- **reads** · `watch` → `screenSectionsProvider`
- **reads** · `read` → `screenSectionsProvider`
- **reads** · `watch` → `claudeGatewayProvider`
- **action** · `push` → `ManagerCopilotScreen`
- **reads** · `watch` → `studioCoEditorProvider`
- **gated-by** · `guard` → `!gate.manager`
- **action** · `push` → `StudioScreen`
- **reads** · `watch` → `attentionItemsProvider`
- **gated-by** · `guard` → `items.isEmpty`
- **writes** · `state=` → `managerTabProvider`
- **gated-by** · `guard` → `!elementVisible(ref, cfgId)`

## התנהגות · behaviour (7)

- **onTap** → _verb_ `Navigator.of(context).push(ManagerCopilotScreen.route())` → navigate → ManagerCopilotScreen
- **build** → _rule_ `if (!gate.manager)` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `Navigator.of(context).push(StudioScreen.route())` → navigate → StudioScreen
- **build** → _rule_ `if (items.isEmpty)` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `ref.read(managerTabProvider.notifier).state = 1` → write → managerTabProvider
- **onTap** → _verb_ `ref.read(managerTabProvider.notifier).state = item.navTab` → write → managerTabProvider
- **build** → _rule_ `if (!elementVisible(ref, cfgId))` → hidden (SizedBox.shrink)

## floor · external functions (5)

- `cfgRadius`
- `childrenFor`
- `elementVisible`
- `featEnabled`
- `go`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onManagerTab(…) callback instead of direct managerTabProvider write
- **gaps:** 3 unregistered — "🤖" · "🎬" · "🔔 דורש טיפול"
