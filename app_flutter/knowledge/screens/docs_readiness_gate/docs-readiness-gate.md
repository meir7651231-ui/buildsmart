# DocsReadinessGate

- **screen:** `docs_readiness_gate`
- **role:** composer

## עצם · object (5)

> registry 4 · mapped 4/4 · **unregistered 1**

- **cfgText** "🔒 מסמכים חסרים" · `docs_readiness_gate.t01` ✅
- **cfgVisible** · `docs_readiness_gate.t02` ✅
- **cfgText** "‹ יציאה" · `docs_readiness_gate.t02` ✅
- **text** "🔒" · — לא-רשום
- **cfgText** "🔒 מסמכים חסרים — לא ניתן להתחיל עבודה" · `docs_readiness_gate.t03` ✅

## חיבורים · connections (4)

- **action** · `push` → `WorkerFormsScreen`
- **action** · `push` → `WorkerSafetyScreen`
- **action** · `push` → `CourierCertsScreen`
- **reads** · `read` → `boardAuthProvider`

## התנהגות · behaviour (3)

- **onPressed** → _verb_ `Navigator.of(context).push(WorkerFormsScreen.route())` → navigate → WorkerFormsScreen
- **onPressed** → _verb_ `Navigator.of(context).push(WorkerSafetyScreen.route())` → navigate → WorkerSafetyScreen
- **onPressed** → _verb_ `Navigator.of(context).push(CourierCertsScreen.route())` → navigate → CourierCertsScreen

## floor · external functions (2)

- `courierDocsReadyProvider`
- `workerDocsReadyProvider`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `role` · `readiness`
- **untangle:**
  - KbScreen = shared component → separate atom
- **gaps:** 1 unregistered — "🔒"
