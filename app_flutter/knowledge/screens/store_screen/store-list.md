# _StoreList

- **screen:** `store_screen`
- **role:** section

## עצם · object (53)

> registry 49 · mapped 49/49 · **unregistered 4**

- **text** "🛒" · — לא-רשום
- **cfgText** "הסל ריק" · `shop.emptycart.title` ✅
- **cfgText** "הוסיפו מוצרים מהקטלוג" · `shop.emptycart.hint` ✅
- **cfgVisible** · `store_screen.service_under_construction` ✅
- **cfgText** "🚧 בבנייה" · `store_screen.service_under_construction` ✅
- **text** "🔍" · — לא-רשום
- **text** "🔒" · — לא-רשום
- **cfgText** "היסטוריית הרכישות מוסתרת" · `shop.orders.hidden` ✅
- **cfgText** "הפעלת "היסטוריית רכישות" בהגדרות תציג שוב את ההזמנות." · `store_screen.orders_hidden_hint` ✅
- **cfgVisible** · `store_screen.orders_hidden_show` ✅
- **cfgText** "הצג היסטוריה" · `store_screen.orders_hidden_show` ✅
- **text** "📦" · — לא-רשום
- **cfgText** "🏗️ שיוך לפרויקט" · `store_screen.proj_assign_title` ✅
- **cfgVisible** · `store_screen.proj_add_chip` ✅
- **cfgText** "+ הוסף" · `store_screen.proj_add_chip` ✅
- **cfgText** "הוספת פרויקט" · `store_screen.proj_add_dialog_title` ✅
- **cfgVisible** · `store_screen.proj_add_cancel` ✅
- **cfgText** "ביטול" · `store_screen.proj_add_cancel` ✅
- **cfgVisible** · `store_screen.proj_add_confirm` ✅
- **cfgText** "הוסף" · `store_screen.proj_add_confirm` ✅
- **cfgText** "אספקה: יום-יומיים" · `store_screen.supplier_lead_time` ✅
- **cfgText** "🚚 אפשרויות משלוח" · `shop.delivery.title` ✅
- **cfgText** "📝 הערות לשליח" · `shop.notes.title` ✅
- **cfgText** "💳 אמצעי תשלום" · `shop.payment.title` ✅
- **cfgVisible** · `cart.cta` ✅
- **cfgText** · `cart.cta` ✅
- **cfgText** "אישור הזמנה גדולה" · `store_screen.large_order_title` ✅
- **cfgVisible** · `store_screen.large_order_cancel` ✅
- **cfgText** "ביטול" · `store_screen.large_order_cancel` ✅
- **cfgVisible** · `store_screen.large_order_confirm` ✅
- **cfgText** "אשר והמשך" · `store_screen.large_order_confirm` ✅
- **cfgText** "שמור סל כרשימה" · `store_screen.save_list_title` ✅
- **cfgVisible** · `store_screen.save_list_cancel` ✅
- **cfgText** "ביטול" · `store_screen.save_list_cancel` ✅
- **cfgVisible** · `store_screen.save_list_confirm` ✅
- **cfgText** "שמור" · `store_screen.save_list_confirm` ✅
- **cfgText** "🔖 רשימות שמורות" · `store_screen.saved_lists_title` ✅
- **cfgText** "אין רשימות שמורות עדיין" · `store_screen.saved_lists_empty` ✅
- **cfgVisible** · `store_screen.actions_lists` ✅
- **cfgText** "רשימות" · `store_screen.actions_lists` ✅
- **cfgVisible** · `store_screen.actions_save` ✅
- **cfgText** "שמור" · `store_screen.actions_save` ✅
- **cfgVisible** · `store_screen.actions_share` ✅
- **cfgText** "שתף" · `store_screen.actions_share` ✅
- **cfgVisible** · `store_screen.actions_clear` ✅
- **cfgText** "נקה" · `store_screen.actions_clear` ✅
- **cfgText** "סיכום הזמנה" · `shop.checkout.title` ✅
- **cfgText** "פרויקט" · `store_screen.checkout_project_label` ✅
- **cfgText** "📦 משלוח" · `store_screen.checkout_delivery_label` ✅
- **cfgText** "💳 תשלום" · `store_screen.checkout_payment_label` ✅
- **cfgText** "סה"כ לתשלום" · `store_screen.checkout_total_label` ✅
- **cfgVisible** · `shop.checkout.confirm` ✅
- **cfgText** "אישור הזמנה" · `shop.checkout.confirm` ✅

## חיבורים · connections (55)

- **reads** · `watch` → `storeSectionProvider`
- **gated-by** · `featOn` → `orders.services`
- **action** · `openPriceCompareSheet` → `openPriceCompareSheet`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`
- **reads** · `watch` → `storeSearchQueryProvider`
- **writes** · `state=` → `storeSectionProvider`
- **reads** · `watch` → `storeFavoritesProvider`
- **reads** · `watch` → `cartQtysProvider`
- **reads** · `watch` → `smartCartProvider`
- **reads** · `watch` → `storeOrdersProvider`
- **reads** · `watch` → `storeSettingsProvider.select((s) => s.displayMode)`
- **writes** · `toggle` → `storeFavoritesProvider`
- **reads** · `watch` → `storeSettingsProvider.select((s) => s.purchaseHistory)`
- **reads** · `watch` → `storeSettingsProvider.select((s) => s.sortDefault)`
- **reads** · `read` → `cartNotesProvider`
- **writes** · `state=` → `cartNotesProvider`
- **reads** · `read` → `intelBusProvider`
- **reads** · `read` → `cartQtysProvider`
- **reads** · `read` → `smartCartProvider`
- **reads** · `watch` → `cartDeliveryProvider`
- **reads** · `watch` → `cartProjectProvider`
- **reads** · `watch` → `cartPaymentProvider`
- **reads** · `watch` → `storeSettingsProvider.select((s) => s.vatInclusive)`
- **reads** · `watch` → `storeSettingsProvider.select((s) => s.saveCartToProject)`
- **action** · `showToast` → `showToast`
- **writes** · `update` → `storeSettingsProvider`
- **reads** · `watch` → `projectsProvider`
- **writes** · `state=` → `cartProjectProvider`
- **action** · `showDialog` → `showDialog`
- **reads** · `read` → `projectsProvider`
- **writes** · `remove` → `smartCartProvider`
- **writes** · `state=` → `cartQtysProvider`
- **writes** · `state=` → `cartDeliveryProvider`
- **reads** · `watch` → `storeSettingsProvider.select((s) => s.supplierCreditEnabled)`
- **writes** · `state=` → `cartPaymentProvider`
- **reads** · `read` → `storeSettingsProvider`
- **reads** · `read` → `cartListsProvider`
- **writes** · `add` → `smartCartProvider`
- **reads** · `watch` → `cartListsProvider`
- **reads** · `watch` → `storeSettingsProvider.select((s) => s.shareCartWithTeam)`
- **reads** · `read` → `shareTextProvider`
- **writes** · `state=` → `shipToProvider`
- **writes** · `clear` → `smartCartProvider`
- **reads** · `read` → `activeProjectProvider`
- **reads** · `read` → `authStateProvider`
- **reads** · `read` → `pendingApprovalProvider`
- **action** · `showLoginSheet` → `showLoginSheet`
- **action** · `showRoleRequestSheet` → `showRoleRequestSheet`
- **reads** · `read` → `shipToProvider`
- **reads** · `read` → `userProfileProvider`
- **reads** · `read` → `currentUidProvider`
- **reads** · `read` → `currentOrgIdProvider`
- **reads** · `read` → `ordersEngineProvider`
- **reads** · `read` → `cartProjectProvider`
- **reads** · `read` → `telemetryProvider`

## התנהגות · behaviour (31)

- **build** → _formula_ `ordersPreview = storeOrders.isEmpty ? … : …` → text: 'אין הזמנות פעילות' | 'הזמנה ${storeOrders.first.id} · ${storeOrders.first.stageLabel}'
- **onTap** → _verb_ `showToast(context, '${r.label} — בבנייה')` → toast
- **onTap** → _verb_ `showToast(context, '${item.title} — בבנייה')` → toast
- **onPressed** → _verb_ `ref.read(storeSettingsProvider.notifier).update((s) => s.copyWith(purchaseHis…` → write → storeSettingsProvider
- **onTap** → _verb_ `showModalBottomSheet<void>(context: context, isScrollControlled: true, backgr…` → open → showModalBottomSheet
- **onTap** → _verb_ `ref.read(cartProjectProvider.notifier).state = p` → write → cartProjectProvider
- **onPressed** → _verb_ `ref.read(projectsProvider.notifier).addProject(name: name)` → write → projectsProvider
- **onPressed** → _verb_ `ref.read(cartProjectProvider.notifier).state = name` → write → cartProjectProvider
- **onPressed** → _verb_ `ref.read(smartCartProvider.notifier).remove(index)` → write → smartCartProvider
- **onTap** → _verb_ `ref.read(cartDeliveryProvider.notifier).state = _kDeliveryOptions[i].method` → write → cartDeliveryProvider
- **onTap** → _verb_ `ref.read(cartPaymentProvider.notifier).state = options[i].method` → write → cartPaymentProvider
- **onPressed** → _verb_ `showToast(context, 'שם הרשימה לא יכול להיות ריק')` → toast
- **onPressed** → _verb_ `showToast(context, 'הסל ריק')` → toast
- **onPressed** → _verb_ `ref.read(cartListsProvider.notifier).saveCart(controller.text.trim(), items)` → write → cartListsProvider
- **onPressed** → _verb_ `showToast(context, 'הרשימה נשמרה בהצלחה')` → toast
- **onPressed** → _verb_ `ref.read(cartListsProvider.notifier).deleteList(list.id)` → write → cartListsProvider
- **onTap** → _verb_ `showToast(context, 'הרשימה "${list.name}" נטענה לסל')` → toast
- **onPressed** → _verb_ `ref.read(smartCartProvider.notifier).clear()` → write → smartCartProvider
- **onPressed** → _verb_ `showToast(context, 'הסל נוקה')` → toast
- **onPressed** → _verb_ `ref.read(cartQtysProvider.notifier).state = const {}` → write → cartQtysProvider
- **onPressed** → _verb_ `ref.read(cartNotesProvider.notifier).state = ''` → write → cartNotesProvider
- **onPressed** → _verb_ `ref.read(shipToProvider.notifier).state = ''` → write → shipToProvider
- **onPressed** → _verb_ `ref.read(cartDeliveryProvider.notifier).state = cartDeliveryFor(ref.read(stor…` → write → cartDeliveryProvider
- **onPressed** → _verb_ `ref.read(cartPaymentProvider.notifier).state = cartPaymentFor(ref.read(storeS…` → write → cartPaymentProvider
- **onPressed** → _verb_ `ref.read(cartProjectProvider.notifier).state = ref.read(activeProjectProvider…` → write → cartProjectProvider
- **onPressed** → _verb_ `showToast(context, 'יש להירשם כדי לבצע הזמנה')` → toast
- **onPressed** → _verb_ `showLoginSheet(context)` → open → showLoginSheet
- **onPressed** → _verb_ `showToast(context, 'החשבון ממתין לאישור — אפשר לשלוח בקשת תפקיד')` → toast
- **onPressed** → _verb_ `showRoleRequestSheet(context)` → open → showRoleRequestSheet
- **onPressed** → _verb_ `ref.read(ordersEngineProvider.notifier).placeOrder(who: contractor.isEmpty ? …` → write → ordersEngineProvider
- **onPressed** → _verb_ `showToast(context, 'הזמנה ${placed.id} אושרה! 🎉')` → toast

## floor · external functions (9)

- `bsOnAccent`
- `btn`
- `checkoutBlock`
- `confirmDestructive`
- `onFavToggle`
- `parsePrice`
- `setQty`
- `setState`
- `unawaited`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 4 unregistered — "🛒" · "🔍" · "🔒" · "📦"
