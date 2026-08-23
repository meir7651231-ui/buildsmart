# WorkerProfileScreen

- **screen:** `worker_profile_screen`
- **role:** composer

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "פרופיל עובד" · `worker_profile_screen.appbar_title` ✅

## חיבורים · connections (4)

- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `tasksProvider`
- **reads** · `watch` → `workerProfileProvider`
- **reads** · `watch` → `workerFormsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `kbWorkerProfileNodes`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `embedded`
- **untangle:**
  - KbScreen = shared component → separate atom
  - WelcomeScreen = shared component → separate atom
- **gaps:** none (all registry-backed)
