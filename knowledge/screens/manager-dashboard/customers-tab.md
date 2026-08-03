# _CustomersTab

- **screen:** `manager-dashboard`
- **role:** section

## עצם · object (12)

> registry 4 · mapped 4/4 · **unregistered 8**

- **text** "⬆️ ייבוא לקוחות מ-CSV" · — לא-רשום
- **cfgText** "לא נמצאו קבלנים תואמים." · `manager.customers.empty` ✅
- **text** "🔔" · — לא-רשום
- **text** "👷" · — לא-רשום
- **cfgVisible** · `manager_dashboard_screen.credit_explain_btn` ✅
- **text** "💳" · — לא-רשום
- **cfgText** "הסבר אשראי" · `manager_dashboard_screen.credit_explain_btn` ✅
- **text** "⏳ ממתין" · — לא-רשום
- **text** "💬" · — לא-רשום
- **text** "צ'אט עם הלקוח" · — לא-רשום
- **text** "אין פרטי לקוח שמורים עדיין" · — לא-רשום
- **cfgText** "🧭 מסע הלקוח" · `manager_dashboard_screen.journey_title` ✅

## חיבורים · connections (22)

- **reads** · `watch` → `_customerViewsProvider`
- **reads** · `watch` → `fleetCreditProvider`
- **reads** · `watch` → `boardAuthProvider`
- **action** · `showCustomerImportSheet` → `showCustomerImportSheet`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`
- **reads** · `read` → `userApproverProvider`
- **action** · `showToast` → `showToast`
- **reads** · `watch` → `directoryProvider`
- **gated-by** · `guard` → `pending.isEmpty`
- **reads** · `watch` → `customerCreditProvider(c.name)`
- **reads** · `watch` → `customerScoreProvider(c.name)`
- **reads** · `watch` → `ordersEngineProvider`
- **reads** · `watch` → `claudeGatewayProvider`
- **action** · `push` → `CreditExplainScreen`
- **reads** · `watch` → `orgConfigProvider`
- **reads** · `watch` → `intelLogProvider`
- **reads** · `read` → `currentUidProvider`
- **reads** · `read` → `chatEngineProvider`
- **action** · `openChatThread` → `openChatThread`
- **reads** · `read` → `usersLookupProvider`
- **reads** · `watch` → `savedCustomerForProvider(widget.customer.name)`
- **reads** · `watch` → `savedCustomerForProvider(displayName)`

## התנהגות · behaviour (3)

- **onPressed** → _verb_ `showCustomerImportSheet(context)` → open → showCustomerImportSheet
- **build** → _rule_ `if (pending.isEmpty)` → hidden (SizedBox.shrink)
- **onPressed** → _verb_ `Navigator.of(context).push(CreditExplainScreen.route(name: c.name, creditLimi…` → navigate → CreditExplainScreen

## floor · external functions (25)

- `approver`
- `bsOnAccent`
- `cfgRadius`
- `chip`
- `customerCreditProvider`
- `customerScoreProvider`
- `featEnabled`
- `fuzzyNameMatch`
- `intelEventEmoji`
- `intelEventHe`
- `journeyConverted`
- `journeyEventsFor`
- `journeyRelTime`
- `journeyRowStuck`
- `moduleOn`
- `onChanged`
- `onSelect`
- `orgTerm`
- `pendingDirectoryEntries`
- `resolveApproveTargets`
- `row`
- `savedCustomerForProvider`
- `setState`
- `stat`
- `tile`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 8 unregistered — "⬆️ ייבוא לקוחות מ-CSV" · "🔔" · "👷" · "💳" · "⏳ ממתין" · "💬" · "צ'אט עם הלקוח" · "אין פרטי לקוח שמורים עדיין"
