# _ThreadList

- **screen:** `chats_screen`
- **role:** section

## עצם · object (4)

> registry 3 · mapped 3/3 · **unregistered 1**

- **text** "💬" · — לא-רשום
- **cfgText** "אין שיחות" · `chats_screen.empty_title` ✅
- **cfgText** "כשיהיו שיחות — הן יופיעו כאן" · `chats_screen.empty_hint` ✅
- **cfgText** "שיחה הועברה לארכיון" · `chats_screen.archived_snack` ✅

## חיבורים · connections (12)

- **reads** · `watch` → `updatesChatSearchProvider`
- **reads** · `watch` → `_chatFilterProvider`
- **reads** · `watch` → `chatArchivedIdsProvider`
- **reads** · `watch` → `chatLastReadProvider`
- **reads** · `watch` → `_audienceChipIndexProvider`
- **reads** · `watch` → `currentUidProvider`
- **reads** · `watch` → `chatEngineProvider`
- **reads** · `read` → `chatArchivedIdsProvider`
- **reads** · `watch` → `chatMutedIdsProvider.select((ids) => ids.contains(thread.id))`
- **action** · `showOnlinePresence` → `showOnlinePresence`
- **reads** · `watch` → `chatSettingsProvider.select((s) => s.lastSeenPrivacy)`
- **action** · `push` → `MaterialPageRoute<void>(builder: (_) …`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _ChatPage(…` → navigate → MaterialPageRoute<void>(builder: (_) …

## floor · external functions (1)

- `bsOnAccent`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `persona` · `audience`
- **gaps:** 1 unregistered — "💬"
