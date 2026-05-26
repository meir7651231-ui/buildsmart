# Functional Spec — app_flutter (אפיון מלא)

Complete characterization of every screen, element, flow, state, and its wiring
status. Grounded in source (R8 — no invention). Status: ✅ wired · 🚧 placeholder
· ⛔ blocked. Wiring details live in `../WIRING.md`; this is the behavioral map.

---

## 1. App model
- **Platform**: Flutter, RTL Hebrew, light theme. Entry `main.dart` →
  `MaterialApp` (global `textScaler` from catalog `textSize`, `highContrast`
  theme) → `HomeShell`.
- **Shell**: AppBar + 4 bottom tabs in an `IndexedStack` (state preserved per
  tab) + FAB-dial overlays + floating cart button.
- **One dial at a time** (`openDialProvider`): BS · search · menu. Tapping the
  scrim closes any dial.

## 2. AppBar (`_HomeAppBar`)
- Right (RTL leading): **"BuildSmart"** wordmark — tap opens the **BS dial**.
  Subtitle: green status line with version label, OR a pulsing "עץ חכם הופעל"
  when the catalog smart-tree is active.
- Left (actions): 📷 camera (opens barcode/camera sheet) · ⋮ per-tab 3-dot menu.
- Per-tab ⋮ menus:
  - Catalog: list-management / item-picker actions.
  - Chats: שיחה חדשה ✅ · ארכיון שיחות ✅ · השתק הכל/בטל ✅ · הגדרות ✅.
  - Notifications: סמן הכל כנקרא ✅ · נקה הכל ✅ · הגדרות התראות ✅.
  - Store: הסל / הזמנות / שירותים (jump to section) · הגדרות ✅.

## 3. Bottom tabs

### 3.1 קטלוג (tab 0 · `catalog_screen.dart`)
- **Section chips** (top): הכל · קטגוריות · חיפושים אחרונים · תאימות · מועדפים · עץ חכם.
- **"הכל" overview**: preview block per section (3 examples each) with "הצג הכל",
  thin orange dividers, count badges.
- **קטגוריות**: 12 categories (ברזים וכיורים, אסלות, מקלחות ואמבטיות, חימום מים,
  מטבח, ניקוז וצנרת, גופי תברואה, אביזרי קצה וחיבורים, בנייה ומחיצות, גמר,
  אביזרים נלווים, גינון והשקיה). Light rows + in-tab drill (fixed drill bar with
  breadcrumb chips). Categories without tree data → designed "בקרוב".
- **Drill → products**: faceted drilling (derived from the most characterizing
  word), product list **or grid** (`viewMode`/`gridColumns` ✅), "מיון לפי"
  (`quickFilterBar` ✅), product count badge.
- **חיפושים אחרונים**: persisted recents (`searchHistoryEnabled` ✅, clear ✅).
- **תאימות**: 935-product compatibility engine (DN sizes, connection gender/method).
- **מועדפים**: favorite SKUs (`product_favorites`).
- **עץ חכם**: smart product tree — green drill bar, חובה(red)/סה"כ(green) badges,
  scoped search, light product sheet with collapsible מותג/סוג/מידה + explode chips.
- **States**: empty sections show designed empty rows; products honor
  `imageSize`/`compactMode` ✅.

### 3.2 שיחות (tab 1 · `chats_screen.dart`)
- **Search bar** + filter chips (הכל/נציגים/ספקים/בוט) ✅.
- **Thread list** (6 seeded threads): avatar + online dot (gated by
  `lastSeenPrivacy` ✅), name (missed=orange), arrow, time, unread badge
  (grey when muted), mute icon when muted. Swipe-left = archive (persistent) +
  undo ✅.
- **Conversation** (`_ChatPage`): WhatsApp-style — encryption notice, date chip,
  bubbles (mine = green, read-receipt ticks blue/grey per `readReceipts` ✅),
  typing bubble (`typingIndicator`+`botEnabled` ✅), send → bubble + canned
  auto-reply if `botEnabled` ✅; haptic on send (`chatVibration` ✅). New chats
  start empty unless `greetingEnabled` ✅. Header presence per `lastSeenPrivacy`.
  Header video/call/more 🚧; input camera/attach/emoji 🚧; mic → toast.
- **Archive screen**: lists archived threads, per-row restore ✅.
- **Mute-all**: 3-dot toggle, persistent, label flips ✅.

### 3.3 התראות (tab 2 · `notifications_screen.dart`)
- **Header** "התראות" + unread badge. Search + section chips
  (הכל/משלוחים/הזמנות/בטיחות/תקציב/מבצעים).
- **List** (10 seeded): grouped by date; consecutive same-type runs ≥3 collapse
  behind "הצג עוד" (`shouldCollapseNotifRun`). High-priority rows are red.
  Per-row action chip; swipe to dismiss; mark-all-read / clear-all.
- **Filtering** ✅: per-type toggles hide categories (`notifMutedSections`);
  `importanceFilter` shows only high-priority; snooze banner mutes temporarily.

### 3.4 חנות (tab 3 · `store_screen.dart`)
- **Section chips**: הכל / הסל / הזמנות / שירותים. Summary chips
  (פריטים בסל / הזמנות פתוחות / הצעות ספקים). Quick actions: שיחה / תזמון /
  מועדים / מועדפים (sheets).
- **הכל / שירותים**: `_StoreRow` list (הסל שלי, ההזמנות שלי, השכרת כלים,
  פקדונות, החזרה חדשה, מכרז ספקים, גיליונות בטיחות, השוואת מחירים).
- **הזמנות**: order cards (BS-1234…) with status chips (בדרך/מוכן/בהכנה/הסתיימה),
  item counts, prices.
- **הסל** (`_CartView`): project selector (`saveCartToProject` ✅), supplier-grouped
  items with steppers, smart-cart lines, delivery selector (express/standard/
  pickup, default per `selfPickupDefault` ✅), notes, **summary** (subtotal, VAT
  per `vatInclusive` ✅, delivery, total — all via pure `cartVat`/`cartTotal`),
  payment selector (default per `defaultPayment` ✅), **checkout**: blocks below
  `minOrderAmount` ✅, confirms when total ≥ `largeOrderThreshold` ✅, then sheet.

## 4. FAB dials
- **BS dial** (`bs_dial_widget.dart`): 5 personas — 👷 קבלן · 👔 מנהל המערכת ·
  🏪 חנות ספק · 🛵 שליח · 🦺 עובד. 4 have sub-trees (drill via `bsDrillPathProvider`);
  6/6 legacy hubs embedded (AI/Site/Finance/Rewards/Security/Service).
- **Search dial** (`search_dial_widget.dart`): 🎤 קולי · 📷 ברקוד · ⚙️ פילטרים
  (עם תמונה / עם מחיר) · ↕️ מיון (ברירת מחדל/שם/מחיר) · catalog.
- **Menu dial** (`menu_dial_widget.dart`): 4 tabs — 🏠 בית · 🏗️ הפרויקטים ·
  🛒 רכש · ⚙️ הגדרות. Each is a multi-level dial (data: `kHomeTree`,
  `projectsTree()`, `kCartTree`, settings tree).
- **Cart FAB**: orange, white border, count badge; jumps to store; hidden on store tab.

## 5. Settings (4 screens, light, count-badge headers)
- **קטלוג** (9 sections): wired — searchHistory, quickFilterBar, imageSize,
  compactMode, reducedMotion, highContrast, textSize, viewMode, gridColumns;
  blocked — prices/currency/VAT, suppliers, AI, units, sortDefault, radius.
- **שיחות** (9): wired — readReceipts, typingIndicator, botEnabled, chatVibration,
  greetingEnabled, lastSeenPrivacy; blocked — media/backup/lang/business/privacy.
- **התראות** (9): wired — type toggles, importanceFilter, snooze; blocked —
  push/email/sms, quiet-hours, summaries, sound, lock-screen, by-role.
- **חנות** (9): wired — defaultPayment, selfPickupDefault, vatInclusive,
  minOrderAmount, confirmLargeOrder/threshold, saveCartToProject; blocked —
  addresses/invoices/suppliers/rental/warranty/biometric/credit.
- Every screen: reset-to-defaults, persisted via SharedPreferences.

## 6. Secondary screens
- **lipskey product sheet / detail / brand**, **suppliers** — product info,
  specs, brand grids (all light-mode).
- **install studio** (`install_studio_screen.dart`): BFS/Dijkstra line builder +
  `buildInstallation` (full BOM with connectors, branch warnings, gaps).
- **regression panel** (`regression_panel_screen.dart`, from BS dial): runs the
  in-app harness; pass/fail per check.
- **barcode scanner / camera sheet**: capture entry points.

## 7. Data & persistence
- **Catalog**: `kLipskeyCatalog` (935 products, brand/SKU/category/connections),
  lazy inverted word index (`lipskeyWordIndex`, min token len 2).
- **Trees**: catalog_tree, smart_tree, menu_trees, settings_tree, sections, personas.
- **Persisted (SharedPreferences)**: catalog/chat/notif/store settings, chat
  archived ids, chat muted ids. **In-memory**: smart cart, recent searches,
  dial/tab state, favorites.

## 8. Cross-cutting
- **Theme**: light (`0xFFF5F6FA`/white/`0xFF1A1A1A`/brand orange); high-contrast
  + text-scale are app-wide.
- **Verification**: `flutter test` (~170 checks) + in-app harness + mutation
  testing (domain logic 50/50) + the protocol enforcement test.
- **Known gaps**: media/telephony/notification-engine/pricing/AI are ⛔ (no
  backend); a few chat/conversation buttons are 🚧.
