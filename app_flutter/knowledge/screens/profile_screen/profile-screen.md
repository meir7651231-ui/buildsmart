# ProfileScreen

- **screen:** `profile_screen`
- **role:** composer

## עצם · object (13)

> registry 9 · mapped 9/9 · **unregistered 4**

- **cfgText** "מחיקת חשבון" · `profile_screen.t01` ✅
- **cfgText** "החשבון וכל הנתונים האישיים יימחקו לצמיתות. את הפעולה אי אפשר לבטל." · `profile_screen.t02` ✅
- **cfgVisible** · `profile_screen.t03` ✅
- **cfgText** "ביטול" · `profile_screen.t03` ✅
- **cfgVisible** · `profile_screen.t04` ✅
- **cfgText** "מחק לצמיתות" · `profile_screen.t04` ✅
- **cfgText** "הפרופיל שלי" · `profile_screen.t05` ✅
- **text** "פרטים אישיים" · — לא-רשום
- **text** "תחום מקצועי" · — לא-רשום
- **cfgVisible** · `profile_screen.t06` ✅
- **cfgText** "שמור" · `profile_screen.t06` ✅
- **text** "עוד" · — לא-רשום
- **text** "חשבון" · — לא-רשום

## חיבורים · connections (16)

- **reads** · `read` → `userProfileProvider`
- **writes** · `update` → `userProfileProvider`
- **action** · `showToast` → `showToast`
- **reads** · `read` → `authStateProvider`
- **action** · `showDialog` → `showDialog`
- **reads** · `watch` → `userProfileProvider`
- **reads** · `watch` → `activePersonaProvider`
- **reads** · `watch` → `authStateProvider`
- **reads** · `watch` → `authGatewayProvider`
- **reads** · `watch` → `roleSwitchLockedProvider`
- **gated-by** · `modOn` → `rewards`
- **action** · `showRolePicker` → `showRolePicker`
- **action** · `push` → `RewardsHubScreen`
- **action** · `showLoginSheet` → `showLoginSheet`
- **action** · `showRoleRequestSheet` → `showRoleRequestSheet`
- **action** · `push` → `RoleRequestsInboxScreen`

## התנהגות · behaviour (5)

- **onTap** → _verb_ `showRolePicker(context)` → open → showRolePicker
- **onTap** → _verb_ `Navigator.of(context).push(RewardsHubScreen.route())` → navigate → RewardsHubScreen
- **onTap** → _verb_ `showLoginSheet(context)` → open → showLoginSheet
- **onTap** → _verb_ `showRoleRequestSheet(context)` → open → showRoleRequestSheet
- **onTap** → _verb_ `Navigator.of(context).push(RoleRequestsInboxScreen.route())` → navigate → RoleRequestsInboxScreen

## floor · external functions (10)

- `approvableRolesForClaims`
- `bsOnAccent`
- `cfgRadius`
- `hebrewAuthError`
- `kbProfileNodes`
- `orgTerm`
- `setState`
- `validBusinessId`
- `validEmail`
- `validIsraeliMobile`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - KbScreen = shared component → separate atom
- **gaps:** 4 unregistered — "פרטים אישיים" · "תחום מקצועי" · "עוד" · "חשבון"
