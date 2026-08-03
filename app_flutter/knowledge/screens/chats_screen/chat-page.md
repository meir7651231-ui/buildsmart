# _ChatPage

- **screen:** `chats_screen`
- **role:** section

## עצם · object (8)

> registry 8 · mapped 8/8 · **unregistered 0**

- **cfgText** "העבר לארכיון" · `chats_screen.menu_archive` ✅
- **cfgText** "חיפוש בשיחה" · `chats_screen.menu_search` ✅
- **cfgText** "חסום איש קשר" · `chats_screen.menu_block` ✅
- **cfgText** "פעיל כעת" · `chats_screen.online_now` ✅
- **cfgText** "🔒 ההודעות בשיחה זו מוצפנות מקצה לקצה. רק המשתתפים יכולים לקרוא אותן." · `chats_screen.privacy_notice` ✅
- **cfgText** "מקליד..." · `chats_screen.typing` ✅
- **cfgVisible** · `chats_screen.retry` ✅
- **cfgText** "נסה שוב" · `chats_screen.retry` ✅

## חיבורים · connections (16)

- **reads** · `read` → `chatLastReadProvider`
- **reads** · `read` → `chatHistoryClearedProvider`
- **reads** · `read` → `chatSettingsProvider`
- **reads** · `watch` → `chatHistoryClearedProvider`
- **reads** · `watch` → `chatEngineProvider`
- **reads** · `read` → `currentUidProvider`
- **reads** · `read` → `chatEngineProvider`
- **reads** · `read` → `chatMutedIdsProvider`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`
- **action** · `showToast` → `showToast`
- **reads** · `read` → `chatArchivedIdsProvider`
- **action** · `showOnlinePresence` → `showOnlinePresence`
- **reads** · `watch` → `chatSettingsProvider.select((s) => s.lastSeenPrivacy)`
- **reads** · `watch` → `userProfileProvider.select((p) => p.contact)`
- **reads** · `watch` → `chatSettingsProvider.select((s) => s.readReceipts)`
- **action** · `openCameraSheet` → `openCameraSheet`

## התנהגות · behaviour (1)

- **onPressed** → _verb_ `openCameraSheet(context)` → open → openCameraSheet

## floor · external functions (4)

- `bsOnAccent`
- `onSend`
- `setState`
- `useCustomKeyboard`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `view`
- **gaps:** none (all registry-backed)
