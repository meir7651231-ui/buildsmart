# _ManagerProfileBody

- **screen:** `manager_profile_screen`
- **role:** section

## עצם · object (8)

> registry 5 · mapped 5/5 · **unregistered 3**

- **text** "👔" · — לא-רשום
- **cfgText** "מצב הדגמה" · `manager_profile_screen.t02` ✅
- **cfgText** "הזמנות — סטטיסטיקה" · `manager_profile_screen.t03` ✅
- **text** "⚙️" · — לא-רשום
- **cfgText** "הגדרות" · `manager_profile_screen.t04` ✅
- **text** "🖥️" · — לא-רשום
- **cfgText** "מעבר בין מסכים" · `manager_profile_screen.t05` ✅
- **cfgText** "צפייה בכל לוח — מצב מנהל" · `manager_profile_screen.t06` ✅

## חיבורים · connections (5)

- **reads** · `watch` → `boardAuthProvider`
- **gated-by** · `guard` → `session == null || session.role != BoardRole.manager`
- **reads** · `watch` → `sysOrdersProvider`
- **action** · `push` → `CatalogSettingsScreen`
- **action** · `showManagerScreensSheet` → `showManagerScreensSheet`

## התנהגות · behaviour (3)

- **build** → _rule_ `if (session == null || session.role != BoardRole.manager)` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `Navigator.of(context).push(CatalogSettingsScreen.route(showProfileRow: false))` → navigate → CatalogSettingsScreen
- **onTap** → _verb_ `showManagerScreensSheet(context)` → open → showManagerScreensSheet

## floor · external functions (1)

- `fMoney`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** 3 unregistered — "👔" · "⚙️" · "🖥️"
