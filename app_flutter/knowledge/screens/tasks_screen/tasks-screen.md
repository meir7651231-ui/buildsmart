# TasksScreen

- **screen:** `tasks_screen`
- **role:** composer

## עצם · object (6)

> registry 4 · mapped 4/4 · **unregistered 2**

- **cfgText** "📋 משימות" · `tasks_screen.title` ✅
- **cfgVisible** · `tasks_screen.exit` ✅
- **cfgText** "‹ יציאה" · `tasks_screen.exit` ✅
- **text** "אתה רואה את כל משימות הצוות. אשר עבודות שהוגשו ועקוב אחרי ההתקדמות." · — לא-רשום
- **text** "אין משימות לצוות עדיין — משימות חדשות יופיעו כאן" · — לא-רשום
- **cfgText** "עובד הציע משימה חדשה — אשר כדי שתיכנס לביצוע, או דחה." · `tasks_screen.proposal_intro` ✅

## חיבורים · connections (7)

- **reads** · `watch` → `tasksProvider`
- **reads** · `watch` → `pendingApprovalTasksProvider`
- **reads** · `read` → `tasksProvider`
- **action** · `showToast` → `showToast`
- **reads** · `watch` → `pendingProposalsProvider`
- **reads** · `read` → `chatEngineProvider`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (4)

- `confirmDestructive`
- `promptRejectReason`
- `statusBranch`
- `taskLeaf`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - KbScreen = shared component → separate atom
  - _managerView = shared component → separate atom
- **gaps:** 2 unregistered — "אתה רואה את כל משימות הצוות. אשר עבודות שהוגשו ועקוב אחרי ההתקדמות." · "אין משימות לצוות עדיין — משימות חדשות יופיעו כאן"
