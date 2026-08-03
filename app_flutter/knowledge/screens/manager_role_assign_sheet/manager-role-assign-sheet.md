# ManagerRoleAssignSheet

- **screen:** `manager_role_assign_sheet`
- **role:** composer

## עצם · object (4)

> registry 3 · mapped 3/3 · **unregistered 1**

- **text** "🔑" · — לא-רשום
- **cfgText** "שיוך תפקיד למשתמש" · `manager_role_assign_sheet.t01` ✅
- **cfgText** "אתר משתמש לפי טלפון (או הדבק מזהה uid) ובחר תפקיד להקצאה." · `manager_role_assign_sheet.t02` ✅
- **cfgText** "תפקיד" · `manager_role_assign_sheet.t03` ✅

## חיבורים · connections (5)

- **action** · `showToast` → `showToast`
- **reads** · `read` → `usersLookupProvider`
- **reads** · `read` → `authStateProvider`
- **reads** · `read` → `telemetryProvider`
- **reads** · `watch` → `authGatewayProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (2)

- `setState`
- `unawaited`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 1 unregistered — "🔑"
