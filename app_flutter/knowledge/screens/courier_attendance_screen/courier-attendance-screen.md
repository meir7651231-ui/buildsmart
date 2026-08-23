# CourierAttendanceScreen

- **screen:** `courier_attendance_screen`
- **role:** composer

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "🕐 נוכחות" · `courier.attend.title` ✅

## חיבורים · connections (6)

- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `courierAttendanceProvider`
- **reads** · `read` → `courierAttendanceProvider`
- **action** · `showToast` → `showToast`
- **reads** · `read` → `chatEngineProvider`
- **reads** · `read` → `workerNotifsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (4)

- `attendanceDateKey`
- `attendanceMonth`
- `attendanceTotal`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - WelcomeScreen = shared component → separate atom
- **gaps:** none (all registry-backed)
