# _HomeAppBar

- **screen:** `home_shell`
- **role:** section

## עצם · object (5)

> registry 5 · mapped 5/5 · **unregistered 0**

- **cfgText** · `home.topbar.brand` ✅
- **cfgText** · `home.status.smarttree` ✅
- **cfgText** "✏️ שיחה חדשה" · `home.newchat.title` ✅
- **cfgText** "בחר סוג איש קשר" · `home.newchat.subtitle` ✅
- **cfgText** "אין עדיין משתמשים" · `home.newchat.empty` ✅

## חיבורים · connections (34)

- **reads** · `watch` → `mainTabProvider`
- **gated-by** · `modOn` → `chat`
- **reads** · `watch` → `userProfileProvider`
- **action** · `showRolePicker` → `showRolePicker`
- **action** · `showProfileCard` → `showProfileCard`
- **reads** · `watch` → `catalogSectionProvider`
- **reads** · `watch` → `tabHeaderHiddenProvider`
- **gated-by** · `modOn` → `search`
- **writes** · `state=` → `tabHeaderHiddenProvider`
- **action** · `openCameraSheet` → `openCameraSheet`
- **reads** · `watch` → `updatesSubTabProvider`
- **reads** · `watch` → `helpModeProvider`
- **action** · `showIntroTour` → `showIntroTour`
- **writes** · `update` → `helpModeProvider`
- **gated-by** · `guard` → `!kUserSystem`
- **reads** · `watch` → `roleChipStateProvider`
- **reads** · `read` → `authStateProvider`
- **action** · `push` → `WelcomeScreen`
- **action** · `showRoleRequestSheet` → `showRoleRequestSheet`
- **reads** · `read` → `catalogSettingsProvider`
- **gated-by** · `modOn` → `ai`
- **action** · `push` → `AIHubScreen`
- **action** · `push` → `CatalogSettingsScreen`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`
- **action** · `push` → `ChatsArchiveScreen`
- **action** · `showToast` → `showToast`
- **action** · `push` → `NotifSettingsScreen`
- **writes** · `state=` → `storeSectionProvider`
- **action** · `push` → `StoreSettingsScreen`
- **action** · `openNewChatWith` → `openNewChatWith`
- **reads** · `watch` → `directoryProvider`
- **reads** · `watch` → `currentUidProvider`
- **reads** · `read` → `chatEngineProvider`
- **action** · `openChatThread` → `openChatThread`

## התנהגות · behaviour (9)

- **onTap** → _verb_ `showRolePicker(context)` → open → showRolePicker
- **onTap** → _verb_ `showProfileCard(context)` → open → showProfileCard
- **onPressed** → _verb_ `ref.read(tabHeaderHiddenProvider.notifier).state = false` → write → tabHeaderHiddenProvider
- **onPressed** → _verb_ `openCameraSheet(context)` → open → openCameraSheet
- **onPressed** → _verb_ `ref.read(helpModeProvider.notifier).update((on) => !on)` → write → helpModeProvider
- **build** → _rule_ `if (!kUserSystem)` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `openNewChatWith(context, emoji: c.emoji, name: c.label)` → open → openNewChatWith
- **onTap** → _verb_ `ref.read(chatEngineProvider.notifier).createOrGetThread([myUid, e.uid], name:…` → write → chatEngineProvider
- **onTap** → _verb_ `openChatThread(context, ref, threadId)` → open → openChatThread

## floor · external functions (6)

- `allChatsMuted`
- `bsSuccess`
- `confirmDestructive`
- `dismissAllNotifs`
- `markAllNotifsRead`
- `toggleMuteAllChats`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onHelpMode(…) callback instead of direct helpModeProvider write
  - onStoreSection(…) callback instead of direct storeSectionProvider write
  - onTabHeaderHidden(…) callback instead of direct tabHeaderHiddenProvider write
- **gaps:** none (all registry-backed)
