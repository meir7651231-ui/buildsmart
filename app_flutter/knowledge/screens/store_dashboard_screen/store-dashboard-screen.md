# StoreDashboardScreen

- **screen:** `store_dashboard_screen`
- **role:** composer

## עצם · object (12)

> registry 12 · mapped 12/12 · **unregistered 0**

- **cfgVisible** · `store.action.exit` ✅
- **cfgText** "‹ יציאה" · `store.action.exit` ✅
- **cfgVisible** · `store_dashboard_screen.t01` ✅
- **cfgText** "✓ אין הזמנות שממתינות לאישור" · `store_dashboard_screen.t01` ✅
- **cfgVisible** · `store_dashboard_screen.t02` ✅
- **cfgText** "➕ סימולציית הזמנה נכנסת (כלי הדגמה)" · `store_dashboard_screen.t02` ✅
- **cfgText** "שלום 👋" · `store.home.greeting` ✅
- **cfgText** "📥 הזמנות" · `store.section.orders` ✅
- **cfgText** "אין הזמנות בקטגוריה זו ✓" · `store_dashboard_screen.t03` ✅
- **cfgVisible** · `store.action.newProduct` ✅
- **cfgText** "➕ הוסף מוצר חדש" · `store.action.newProduct` ✅
- **cfgText** "לא נמצאו מוצרים תואמים." · `store_dashboard_screen.t04` ✅

## חיבורים · connections (20)

- **reads** · `watch` → `visibleOrderIdsProvider`
- **reads** · `watch` → `sysOrdersProvider`
- **reads** · `watch` → `storeProductsProvider`
- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `storeProfileProvider.select((m) => (m[session.username]?.businessName ?? '').trim())`
- **gated-by** · `modOn` → `chat`
- **action** · `push` → `StoreProfileScreen`
- **action** · `push` → `SupplierSettingsScreen`
- **reads** · `read` → `boardAuthProvider`
- **reads** · `watch` → `storeOosProvider.select((oos) => oos.length)`
- **reads** · `watch` → `fulfillmentProvider`
- **action** · `showPickingSheet` → `showPickingSheet`
- **action** · `showPortalSheet` → `showPortalSheet`
- **reads** · `read` → `sysOrdersProvider`
- **action** · `showToast` → `showToast`
- **reads** · `watch` → `screenSectionsProvider`
- **reads** · `read` → `screenSectionsProvider`
- **reads** · `watch` → `storeOosProvider`
- **reads** · `read` → `storeOosProvider`
- **writes** · `remove` → `storeProductsProvider`

## התנהגות · behaviour (8)

- **onPressed** → _verb_ `Navigator.of(context).push(StoreProfileScreen.route())` → navigate → StoreProfileScreen
- **onPressed** → _verb_ `Navigator.of(context).push(SupplierSettingsScreen.route())` → navigate → SupplierSettingsScreen
- **onTap** → _verb_ `showPickingSheet(context, held.first.id)` → open → showPickingSheet
- **onTap** → _verb_ `showPortalSheet(context, kStorePortalTiles.firstWhere((t) => t.kind == Portal…` → open → showPortalSheet
- **onPressed** → _verb_ `ref.read(sysOrdersProvider.notifier).simulateIncomingOrder()` → write → sysOrdersProvider
- **onPressed** → _verb_ `showToast(context, 'הזמנת הדגמה $id נוצרה — נכנסה לתור ✓')` → toast
- **onTap** → _verb_ `showPickingSheet(context, o.id)` → open → showPickingSheet
- **onTap** → _verb_ `showPortalSheet(context, t)` → open → showPortalSheet

## floor · external functions (7)

- `cfgRadius`
- `confirmDestructive`
- `fMoney`
- `kbStoreDashboardNodes`
- `sectionChildren`
- `setState`
- `sort`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - ChatsScreen = shared component → separate atom
  - KbScreen = shared component → separate atom
  - SingleChildScrollView = shared component → separate atom
  - WelcomeScreen = shared component → separate atom
- **gaps:** none (all registry-backed)
