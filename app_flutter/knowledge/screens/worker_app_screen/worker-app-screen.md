# WorkerAppScreen

- **screen:** `worker_app_screen`
- **role:** composer

## עצם · object (3)

> registry 3 · mapped 3/3 · **unregistered 0**

- **cfgText** "🦺 עובד" · `worker.section.title` ✅
- **cfgVisible** · `worker.action.exit` ✅
- **cfgText** "‹ יציאה" · `worker.action.exit` ✅

## חיבורים · connections (12)

- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `docsGateOverrideProvider`
- **reads** · `watch` → `workerDocsReadyProvider(session.username)`
- **reads** · `watch` → `tasksProvider`
- **reads** · `watch` → `taskRejectionLogProvider`
- **reads** · `read` → `taskRejectionLogProvider`
- **gated-by** · `modOn` → `chat`
- **action** · `push` → `WorkerTaskBoardScreen`
- **action** · `push` → `WorkerSettingsScreen`
- **action** · `openBarcodeScanner` → `openBarcodeScanner`
- **action** · `showToast` → `showToast`
- **action** · `showLipskeyProductSheet` → `showLipskeyProductSheet`

## התנהגות · behaviour (2)

- **onPressed** → _verb_ `Navigator.of(context).push(WorkerTaskBoardScreen.route())` → navigate → WorkerTaskBoardScreen
- **onPressed** → _verb_ `Navigator.of(context).push(WorkerSettingsScreen.route())` → navigate → WorkerSettingsScreen

## floor · external functions (7)

- `catalogSiblingsFor`
- `kbWorkerAppNodes`
- `productBySku`
- `setState`
- `submitWithProofPhoto`
- `workerDocsReadyProvider`
- `workerIndexForSession`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - ChatsScreen = shared component → separate atom
  - KbScreen = shared component → separate atom
  - WelcomeScreen = shared component → separate atom
  - WorkerProfileScreen = shared component → separate atom
- **gaps:** none (all registry-backed)
