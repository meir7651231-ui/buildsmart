# _OpeningFlow

- **screen:** `onboarding_screen`
- **role:** section

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "דלג" · `onboarding_screen.skip` ✅

## חיבורים · connections (5)

- **reads** · `watch` → `startupStepProvider`
- **writes** · `state=` → `startupStepProvider`
- **writes** · `state=` → `welcomeSeenProvider`
- **reads** · `watch` → `helpModeProvider`
- **reads** · `read` → `catalogSettingsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (3)

- `persistWelcomeSeen`
- `setState`
- `unawaited`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - ProfessionScreen = shared component → separate atom
  - WelcomeScreen = shared component → separate atom
- **gaps:** none (all registry-backed)
