# WorkerNotifsBell

- **screen:** `worker_notifs_sheet`
- **role:** composer

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (3)

- **reads** · `read` → `notifSettingsProvider`
- **reads** · `watch` → `currentWorkerUnreadCountProvider`
- **action** · `showWorkerNotifsSheet` → `showWorkerNotifsSheet`

## התנהגות · behaviour (1)

- **onPressed** → _verb_ `showWorkerNotifsSheet(context)` → open → showWorkerNotifsSheet

## floor · external functions (1)

- `playInAppNotifFeedback`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
