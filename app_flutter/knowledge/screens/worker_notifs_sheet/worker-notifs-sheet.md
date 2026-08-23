# _WorkerNotifsSheet

- **screen:** `worker_notifs_sheet`
- **role:** section

## עצם · object (6)

> registry 6 · mapped 6/6 · **unregistered 0**

- **cfgText** "🔔 התראות" · `worker_notifs_sheet.t01` ✅
- **cfgText** "אין התראות עדיין.
אישורים, החזרות לתיקון ומשימות חדשות יופיעו כאן." · `worker_notifs_sheet.t02` ✅
- **cfgVisible** · `worker_notifs_sheet.t03` ✅
- **cfgText** "סמן הכל כנקרא" · `worker_notifs_sheet.t03` ✅
- **cfgVisible** · `worker_notifs_sheet.t04` ✅
- **cfgText** "נקה הכל" · `worker_notifs_sheet.t04` ✅

## חיבורים · connections (4)

- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `currentWorkerNotifsProvider`
- **reads** · `read` → `workerNotifsProvider`
- **writes** · `clear` → `workerNotifsProvider`

## התנהגות · behaviour (3)

- **onPressed** → _verb_ `ref.read(workerNotifsProvider.notifier).markAllRead(username)` → write → workerNotifsProvider
- **onPressed** → _verb_ `ref.read(workerNotifsProvider.notifier).clear(username)` → write → workerNotifsProvider
- **onTap** → _verb_ `ref.read(workerNotifsProvider.notifier).markRead(username, n.id)` → write → workerNotifsProvider

## floor · external functions (1)

- `confirmDestructive`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onWorkerNotifs(…) callback instead of direct workerNotifsProvider write
- **gaps:** none (all registry-backed)
