# _Header

- **screen:** `notifications_screen`
- **role:** section

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "התראות" · `notifications_screen.screen_title` ✅

## חיבורים · connections (7)

- **reads** · `watch` → `notifReadIdsProvider`
- **reads** · `watch` → `notifDismissedIdsProvider`
- **reads** · `watch` → `notifUnreadCountProvider`
- **writes** · `set` → `notifReadIdsProvider`
- **writes** · `set` → `notifDismissedIdsProvider`
- **reads** · `read` → `notifDismissedIdsProvider`
- **reads** · `read` → `notifReadIdsProvider`

## התנהגות · behaviour (2)

- **onPressed** → _verb_ `ref.read(notifReadIdsProvider.notifier).set(_activeNotifs.map((n) => n.id).to…` → write → notifReadIdsProvider
- **onPressed** → _verb_ `ref.read(notifDismissedIdsProvider.notifier).set(Set<String>.from(ref.read(no…` → write → notifDismissedIdsProvider

## floor · external functions (2)

- `addAll`
- `confirmDestructive`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onNotifDismissedIds(…) callback instead of direct notifDismissedIdsProvider write
  - onNotifReadIds(…) callback instead of direct notifReadIdsProvider write
- **gaps:** none (all registry-backed)
