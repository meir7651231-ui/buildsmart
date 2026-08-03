# ChatsScreen

- **screen:** `chats_screen`
- **role:** composer

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "שיחות" · `chats_screen.appbar_title` ✅

## חיבורים · connections (5)

- **writes** · `state=` → `tabHeaderHiddenProvider`
- **writes** · `state=` → `updatesChatOpenProvider`
- **reads** · `read` → `chatEngineProvider`
- **reads** · `read` → `chatLastReadProvider`
- **action** · `push` → `MaterialPageRoute<void>(builder: (_) …`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (3)

- `afterThisFrame`
- `consumePendingThread`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** `persona` · `audience` · `embedded`
- **untangle:**
  - onTabHeaderHidden(…) callback instead of direct tabHeaderHiddenProvider write
  - onUpdatesChatOpen(…) callback instead of direct updatesChatOpenProvider write
- **gaps:** none (all registry-backed)
