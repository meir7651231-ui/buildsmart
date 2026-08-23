# CourierDashboardScreen

- **screen:** `courier_dashboard_screen`
- **role:** composer

## עצם · object (8)

> registry 7 · mapped 7/7 · **unregistered 1**

- **cfgText** "🛵 שליח" · `courier.dash.appbar_title` ✅
- **cfgVisible** · `courier.dash.exit` ✅
- **cfgText** "‹ יציאה" · `courier.dash.exit` ✅
- **text** "🛵" · — לא-רשום
- **cfgText** "הרכב שלי היום" · `courier.gate.vehicle_title` ✅
- **cfgText** "בחר רכב כדי להתחיל את המשמרת — רשימת המשלוחים תסונן לפי הקיבולת" · `courier.gate.vehicle_sub` ✅
- **cfgText** "המשלוחים שלך להיום" · `courier.dash.subtitle` ✅
- **cfgText** "הרכב שלי היום" · `courier.dash.vehicle_title` ✅

## חיבורים · connections (18)

- **reads** · `read` → `sysOrdersProvider`
- **reads** · `read` → `boardAuthProvider`
- **reads** · `read` → `workerNotifsProvider`
- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `docsGateOverrideProvider`
- **reads** · `watch` → `courierDocsReadyProvider(session.username)`
- **reads** · `watch` → `courierProfileProvider.select((m) => m[session.username]?.preferredHaul ?? '')`
- **action** · `push` → `CourierProfileScreen`
- **action** · `push` → `CourierSettingsScreen`
- **reads** · `watch` → `visibleOrderIdsProvider`
- **reads** · `watch` → `sysOrdersProvider`
- **reads** · `watch` → `fulfillmentProvider`
- **reads** · `watch` → `courierProfileProvider.select((m) => m[session.username]?.displayName ?? '')`
- **action** · `showPodSheet` → `showPodSheet`
- **action** · `showCourierDeliveryDetailSheet` → `showCourierDeliveryDetailSheet`
- **action** · `showToast` → `showToast`
- **reads** · `read` → `rewardsProvider`
- **reads** · `read` → `fulfillmentProvider`

## התנהגות · behaviour (3)

- **onPressed** → _verb_ `Navigator.of(context).push(CourierProfileScreen.route())` → navigate → CourierProfileScreen
- **onPressed** → _verb_ `Navigator.of(context).push(CourierSettingsScreen.route())` → navigate → CourierSettingsScreen
- **onTap** → _verb_ `showCourierDeliveryDetailSheet(context, o.id)` → open → showCourierDeliveryDetailSheet

## floor · external functions (10)

- `cfgRadius`
- `confirmDestructive`
- `courierDocsReadyProvider`
- `haulInfo`
- `jsonDecode`
- `jsonEncode`
- `kbCourierDashboardNodes`
- `setState`
- `stampCourierClock`
- `vehicleCanCarry`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - KbScreen = shared component → separate atom
  - WelcomeScreen = shared component → separate atom
- **gaps:** 1 unregistered — "🛵"
