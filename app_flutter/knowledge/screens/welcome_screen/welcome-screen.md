# WelcomeScreen

- **screen:** `welcome_screen`
- **role:** composer

## עצם · object (26)

> registry 26 · mapped 26/26 · **unregistered 0**

- **cfgText** "כניסת מנהל המערכת" · `welcome_screen.mgr_login_title` ✅
- **cfgText** "חשבון הבעלים — כניסה מאובטחת עם חשבון Google." · `welcome_screen.mgr_login_subtitle` ✅
- **cfgVisible** · `welcome_screen.mgr_continue_google` ✅
- **cfgText** "המשך עם Google" · `welcome_screen.mgr_continue_google` ✅
- **cfgVisible** · `welcome_screen.mgr_needs_connection` ✅
- **cfgText** "כניסת מנהל דורשת חיבור לאינטרנט. נסה שוב כשיש חיבור." · `welcome_screen.mgr_needs_connection` ✅
- **cfgText** "או כניסה עם קוד (demo)" · `welcome_screen.mgr_or_code_login` ✅
- **cfgText** "כניסה ללקוח קיים" · `welcome_screen.board_existing_login_btn` ✅
- **cfgVisible** · `welcome_screen.board_demo_mode` ✅
- **cfgText** "מצב דמו" · `welcome_screen.board_demo_mode` ✅
- **cfgText** · `welcome.hero.title` ✅
- **cfgText** · `welcome.hero.tagline` ✅
- **cfgVisible** · `welcome_screen.owner_google_login` ✅
- **cfgText** "כניסה עם Google (בעלים)" · `welcome_screen.owner_google_login` ✅
- **cfgVisible** · `welcome_screen.existing_login_btn` ✅
- **cfgText** "כניסה ללקוח קיים" · `welcome_screen.existing_login_btn` ✅
- **cfgText** "או הירשם" · `welcome.signup.divider` ✅
- **cfgText** "רישום ראשוני" · `welcome.signup.heading` ✅
- **cfgText** "מלא את הפרטים — סימן ✓ יופיע כשהשדות תקינים" · `welcome.signup.subtitle` ✅
- **cfgText** "בהרשמה אתה מאשר את " · `welcome_screen.terms_prefix` ✅
- **cfgVisible** · `welcome_screen.terms_of_use` ✅
- **cfgText** "תנאי השימוש" · `welcome_screen.terms_of_use` ✅
- **cfgText** " ואת " · `welcome_screen.terms_and` ✅
- **cfgVisible** · `welcome_screen.privacy_policy` ✅
- **cfgText** "מדיניות הפרטיות" · `welcome_screen.privacy_policy` ✅
- **cfgText** · `welcome_screen.terms_suffix` ✅

## חיבורים · connections (13)

- **writes** · `state=` → `startupStepProvider`
- **reads** · `read` → `boardAuthProvider`
- **reads** · `read` → `userProfileProvider`
- **reads** · `read` → `authStateProvider`
- **action** · `showToast` → `showToast`
- **writes** · `state=` → `guestBrowsingProvider`
- **writes** · `state=` → `welcomeSeenProvider`
- **action** · `showLoginSheet` → `showLoginSheet`
- **reads** · `read` → `authGatewayProvider`
- **reads** · `read` → `usersProfileWriterProvider`
- **reads** · `read` → `userSystemSyncProvider`
- **writes** · `state=` → `promptRoleRequestProvider`
- **action** · `push` → `LegalScreen`

## התנהגות · behaviour (2)

- **onTap** → _verb_ `Navigator.of(context).push(LegalScreen.route(initialTab: LegalTab.terms))` → navigate → LegalScreen
- **onTap** → _verb_ `Navigator.of(context).push(LegalScreen.route(initialTab: LegalTab.privacy))` → navigate → LegalScreen

## floor · external functions (11)

- `confirmDestructive`
- `hebrewAuthError`
- `isOwnerEmail`
- `onSubmitted`
- `persistGuestBrowsing`
- `persistWelcomeSeen`
- `registrationValid`
- `setState`
- `unawaited`
- `validEmail`
- `validIsraeliMobile`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `boardRole`
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** none (all registry-backed)
