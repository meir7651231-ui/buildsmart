# StudioScreen

- **screen:** `studio_screen`
- **role:** composer

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgText** "🎬 סטודיו" · `studio_screen_old.t01` ✅
- **cfgText** "ערוך את האפליקציה — עורך ניסיוני" · `studio_screen_old.t02` ✅

## חיבורים · connections (2)

- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `studioCoEditorProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - StudioRulesScreen = shared component → separate atom
  - WelcomeScreen = shared component → separate atom
- **gaps:** none (all registry-backed)
