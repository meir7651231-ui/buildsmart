# WorkerAttendanceScreen

- **screen:** `worker_attendance_screen`
- **role:** composer

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "🕐 נוכחות" · `worker_attendance_screen.title` ✅

## חיבורים · connections (8)

- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `workerAttendanceProvider`
- **reads** · `watch` → `tasksProvider`
- **reads** · `read` → `workerAttendanceProvider`
- **reads** · `read` → `boardAuthProvider`
- **action** · `showToast` → `showToast`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`
- **reads** · `read` → `chatEngineProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (6)

- `attendanceDateKey`
- `attendanceMonth`
- `attendanceTotal`
- `currentGeoFix`
- `setState`
- `workerIndexForSession`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - WelcomeScreen = shared component → separate atom
- **gaps:** none (all registry-backed)
