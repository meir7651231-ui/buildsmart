# UpdatesScreen

- **screen:** `updates_screen`
- **role:** composer

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (4)

- **gated-by** · `modOn` → `chat`
- **reads** · `watch` → `updatesSubTabProvider`
- **reads** · `watch` → `pendingPushThreadProvider`
- **action** · `showGlobalToast` → `showGlobalToast`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (2)

- `afterThisFrame`
- `consumePendingThread`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - ChatsScreen = shared component → separate atom
  - NotificationsScreen = shared component → separate atom
- **gaps:** none (all registry-backed)
