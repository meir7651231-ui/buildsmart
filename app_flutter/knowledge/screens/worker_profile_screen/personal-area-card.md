# _PersonalAreaCard

- **screen:** `worker_profile_screen`
- **role:** section

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (8)

- **reads** · `watch` → `workerAttendanceProvider`
- **reads** · `watch` → `workerFormsProvider`
- **reads** · `watch` → `vacationRequestsProvider`
- **reads** · `watch` → `workerCertsProvider`
- **action** · `push` → `WorkerAttendanceScreen`
- **action** · `push` → `WorkerFormsScreen`
- **action** · `push` → `WorkerSafetyScreen`
- **action** · `showWorkerPayslipsSheet` → `showWorkerPayslipsSheet`

## התנהגות · behaviour (4)

- **onTap** → _verb_ `Navigator.of(context).push(WorkerAttendanceScreen.route())` → navigate → WorkerAttendanceScreen
- **onTap** → _verb_ `Navigator.of(context).push(WorkerFormsScreen.route())` → navigate → WorkerFormsScreen
- **onTap** → _verb_ `Navigator.of(context).push(WorkerSafetyScreen.route())` → navigate → WorkerSafetyScreen
- **onTap** → _verb_ `showWorkerPayslipsSheet(context)` → open → showWorkerPayslipsSheet

## floor · external functions (1)

- `attendanceDateKey`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `session`
- **gaps:** none (all registry-backed)
