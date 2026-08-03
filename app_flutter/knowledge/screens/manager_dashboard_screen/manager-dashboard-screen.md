# ManagerDashboardScreen

- **screen:** `manager_dashboard_screen`
- **role:** composer

## עצם · object (4)

> registry 4 · mapped 4/4 · **unregistered 0**

- **cfgText** "מרכז השליטה" · `manager.dash.title` ✅
- **cfgText** "מנהל המערכת" · `manager.dash.subtitle` ✅
- **cfgVisible** · `manager.dash.exit` ✅
- **cfgText** "‹ יציאה" · `manager.dash.exit` ✅

## חיבורים · connections (6)

- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `orgConfigProvider`
- **reads** · `watch` → `managerTabProvider`
- **action** · `push` → `ChatsScreen`
- **action** · `push` → `ManagerProfileScreen`
- **action** · `push` → `CatalogSettingsScreen`

## התנהגות · behaviour (3)

- **onPressed** → _verb_ `Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const Chat…` → navigate → ChatsScreen
- **onPressed** → _verb_ `Navigator.of(context).push(ManagerProfileScreen.route())` → navigate → ManagerProfileScreen
- **onPressed** → _verb_ `Navigator.of(context).push(CatalogSettingsScreen.route(showProfileRow: false))` → navigate → CatalogSettingsScreen

## floor · external functions (2)

- `kbManagerDashboardNodes`
- `moduleOn`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - KbScreen = shared component → separate atom
  - WelcomeScreen = shared component → separate atom
- **gaps:** none (all registry-backed)
