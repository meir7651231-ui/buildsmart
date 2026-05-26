# Architecture — app_flutter

Flutter 3.x · Dart · Riverpod (`StateProvider` / `StateNotifierProvider`).
RTL, Hebrew, light theme. Entry: `lib/main.dart` → `MaterialApp` → `HomeShell`.

## Shell & navigation (`home_shell.dart`)
WhatsApp-style shell: AppBar + 4 bottom tabs in an `IndexedStack`, plus FAB
dial overlays.

- Tabs (RTL, right→left): **קטלוג (0) · שיחות (1) · התראות (2) · חנות (3)** —
  `mainTabProvider` (`dial_state.dart`).
- FAB dials (one open at a time, `openDialProvider`): BS · search · menu.
- Per-tab AppBar 3-dot menu: `_CatalogMenuButton` / `_ChatsMenuButton` /
  `_NotificationsMenuButton` / `_StoreMenuButton`.
- `_CartFab` — floating cart shortcut; hidden on the store tab (`tabIndex != 3`).

## Screens (`lib/screens/`)
- **Catalog**: `catalog_screen.dart` (overview + drill + grid/list + smart-tree),
  `lipskey_products_screen.dart` (product list + grid card), `lipskey_product_sheet.dart`
  (product sheet), `lipskey_product_detail_screen.dart`, `lipskey_brand_screen.dart`,
  `brand_products_screen.dart`, `suppliers_screen.dart`.
- **Chats**: `chats_screen.dart` (list + conversation + archive screen).
- **Notifications**: `notifications_screen.dart`.
- **Store**: `store_screen.dart` (sections: all/cart/orders/services + checkout).
- **Settings**: `catalog_settings_screen.dart`, `chat_settings_screen.dart`,
  `notif_settings_screen.dart`, `store_settings_screen.dart`.
- **Install studio / compatibility**: `install_studio_screen.dart` (BFS line builder).
- **Dials/util**: `bs_dial_widget.dart`, `menu_dial_widget.dart`,
  `search_dial_widget.dart`, `camera_sheet.dart`, `barcode_scanner.dart`,
  `regression_panel_screen.dart` (in-app test runner).

## State (`lib/state/`)
`app_settings`, `dial_state`, `menu_state`, `catalog_settings`, `chat_settings`,
`notif_settings`, `store_settings`, `smart_cart`, `cart_lists_state`,
`product_favorites`. Settings notifiers persist via SharedPreferences.

## Data (`lib/data/`)
`lipskey_catalog.dart` (935 products + lazy inverted word index
`lipskeyWordIndex` / `indexableWord`), `lipskey_smart_data`, `lipskey_hotwater`,
`lipskey_verified_connections`, `catalog_tree`, `smart_tree`, `brands`,
`personas`, `projects`, `sections`, `settings_tree`, `menu_trees`, `search_index`.

## Theming (`theme/`)
`AppTheme.light({highContrast})` / `.dark(...)` — scaffold `0xFFF5F6FA`, cards
white, primary `BsTokens.brand` (orange `0xFFFF7A18`), ink `0xFF1A1A1A`.
`main.dart` applies global `textScaler` (catalog `textSize`) and `highContrast`.

## Pure logic helpers (testable, no widget context)
- store: `deliveryFeeFor` · `cartVat` · `cartTotal` · `cartBelowMinimum` ·
  `cartNeedsLargeConfirm` · `cartPaymentFor` · `cartDeliveryFor`
- notifications: `notifMutedSections` · `notifPasses` · `passesImportance` ·
  `shouldCollapseNotifRun` · `isNewDateGroup`
- chats: `showOnlinePresence` · cart `qtyForKey` / `setQtyForKey`
- catalog: `indexableWord` / `kIndexMinWordLen`
