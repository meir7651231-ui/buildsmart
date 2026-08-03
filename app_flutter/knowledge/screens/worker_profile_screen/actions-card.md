# _ActionsCard

- **screen:** `worker_profile_screen`
- **role:** section

## עצם · object (13)

> registry 10 · mapped 10/10 · **unregistered 3**

- **text** "⚙️" · — לא-רשום
- **cfgText** "הגדרות עובד" · `worker.profile.settings_title` ✅
- **text** "🔄" · — לא-רשום
- **cfgText** "החלפת תפקיד" · `worker.profile.role_switch_title` ✅
- **cfgText** "מוגן בקוד" · `worker.profile.role_switch_hint` ✅
- **text** "🚪" · — לא-רשום
- **cfgText** "יציאה" · `worker.profile.logout_title` ✅
- **cfgText** "החלפת תפקיד" · `worker_profile_screen.role_switch_dialog_title` ✅
- **cfgText** "מעבר בין לוחות מוגן בקוד. הזן את קוד החלפת התפקיד:" · `worker_profile_screen.role_switch_dialog_body` ✅
- **cfgVisible** · `worker_profile_screen.cancel` ✅
- **cfgText** "ביטול" · `worker_profile_screen.cancel` ✅
- **cfgVisible** · `worker_profile_screen.confirm` ✅
- **cfgText** "אישור" · `worker_profile_screen.confirm` ✅

## חיבורים · connections (4)

- **action** · `push` → `WorkerSettingsScreen`
- **action** · `showDialog` → `showDialog`
- **action** · `showRolePicker` → `showRolePicker`
- **reads** · `read` → `boardAuthProvider`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `Navigator.of(context).push(WorkerSettingsScreen.route())` → navigate → WorkerSettingsScreen

## floor · external functions (3)

- `confirmDestructive`
- `setState`
- `submit`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `session`
- **gaps:** 3 unregistered — "⚙️" · "🔄" · "🚪"
