# CourierProfileBody

- **screen:** `courier_profile_screen`
- **role:** composer

## עצם · object (8)

> registry 5 · mapped 5/5 · **unregistered 3**

- **cfgText** "מסירות — סטטיסטיקה" · `courier_profile_screen.stats_heading` ✅
- **text** "⚙️" · — לא-רשום
- **cfgText** "הגדרות שליח" · `courier.profile.settings_title` ✅
- **text** "🔁" · — לא-רשום
- **cfgText** "החלפת תפקיד" · `courier.profile.role_switch_title` ✅
- **cfgText** "מוגן בקוד" · `courier_profile_screen.role_switch_subtitle` ✅
- **text** "🚪" · — לא-רשום
- **cfgText** "יציאה מהחשבון" · `courier.profile.logout_title` ✅

## חיבורים · connections (9)

- **reads** · `watch` → `boardAuthProvider`
- **gated-by** · `guard` → `session == null || session.role != BoardRole.courier`
- **reads** · `watch` → `courierProfileProvider.select((m) => m[session.username] ?? const CourierProfile())`
- **reads** · `watch` → `sysOrdersProvider`
- **reads** · `watch` → `fulfillmentProvider.select((m) {var delivered = 0; var pod = 0; var sum = 0; var unattributed = 0; for (final o in orders) {if (o.stage != OrderStage.delivered) continue; final f = m[o.id]; if (f != null && f.courierUser == session.username) {delivered++; sum += o.sum; if (f.podCaptured) pod++;} else if (f == null || f.courierUser == null) {unattributed++;}} return (delivered: delivered, pod: pod, sum: sum, unattributed: unattributed);})`
- **action** · `push` → `CourierSettingsScreen`
- **action** · `showDialog` → `showDialog`
- **action** · `showRolePicker` → `showRolePicker`
- **reads** · `read` → `boardAuthProvider`

## התנהגות · behaviour (2)

- **build** → _rule_ `if (session == null || session.role != BoardRole.courier)` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `Navigator.of(context).push(CourierSettingsScreen.route())` → navigate → CourierSettingsScreen

## floor · external functions (3)

- `cfgRadius`
- `confirmDestructive`
- `fMoney`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `standalone` · `vehicle`
- **gaps:** 3 unregistered — "⚙️" · "🔁" · "🚪"
