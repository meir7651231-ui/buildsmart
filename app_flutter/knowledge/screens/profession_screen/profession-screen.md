# ProfessionScreen

- **screen:** `profession_screen`
- **role:** composer

## עצם · object (5)

> registry 5 · mapped 5/5 · **unregistered 0**

- **cfgVisible** · `profession_screen.t01` ✅
- **cfgText** "חזור" · `profession_screen.t01` ✅
- **cfgText** "מה התחום שלך?" · `profession_screen.t02` ✅
- **cfgText** "נתאים לך את האפליקציה — קטלוג, כלים והמלצות לפי המקצוע" · `profession_screen.t03` ✅
- **cfgText** "תוכל לשנות את הבחירה בכל עת מההגדרות" · `profession_screen.t04` ✅

## חיבורים · connections (3)

- **action** · `push` → `ComingSoonScreen`
- **reads** · `read` → `userProfileProvider`
- **writes** · `state=` → `startupStepProvider`

## התנהגות · behaviour (1)

- **onPressed** → _verb_ `ref.read(startupStepProvider.notifier).state = 0` → write → startupStepProvider

## floor · external functions (1)

- `pick`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onStartupStep(…) callback instead of direct startupStepProvider write
- **gaps:** none (all registry-backed)
