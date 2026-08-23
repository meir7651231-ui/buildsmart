# _TasksTab

- **screen:** `worker_app_screen`
- **role:** section

## עצם · object (31)

> registry 22 · mapped 22/22 · **unregistered 9**

- **cfgText** "📅 היומן שלי" · `worker.section.journal` ✅
- **cfgVisible** · `worker.action.fullMonth` ✅
- **cfgText** "חודש מלא ›" · `worker.action.fullMonth` ✅
- **cfgVisible** · `worker_app_screen.t01` ✅
- **cfgText** "✓ נרשמה נוכחות להיום" · `worker_app_screen.t01` ✅
- **cfgText** "לא נרשמה נוכחות ביום זה" · `worker_app_screen.t02` ✅
- **cfgVisible** · `worker_app_screen.t03` ✅
- **cfgText** "דמו" · `worker_app_screen.t03` ✅
- **cfgVisible** · `worker.action.checkEquipment` ✅
- **text** "🧰" · — לא-רשום
- **cfgText** "בדוק ציוד נדרש" · `worker.action.checkEquipment` ✅
- **cfgVisible** · `worker.action.employerStock` ✅
- **text** "📦" · — לא-רשום
- **cfgText** "מלאי הקבלן" · `worker.action.employerStock` ✅
- **cfgVisible** · `worker.action.addTask` ✅
- **text** "➕" · — לא-רשום
- **cfgText** "הוסף משימה" · `worker.action.addTask` ✅
- **cfgVisible** · `worker.action.gantt` ✅
- **text** "📊" · — לא-רשום
- **cfgText** "גאנט משימות" · `worker.action.gantt` ✅
- **cfgVisible** · `worker.action.defects` ✅
- **text** "🔧" · — לא-רשום
- **cfgText** "ליקויים" · `worker.action.defects` ✅
- **cfgText** "➕ הצעת משימה לקבלן" · `worker.section.proposeTitle` ✅
- **cfgText** "המשימה תישלח לקבלן לאישור" · `worker.propose.subtitle` ✅
- **text** "שם המשימה" · — לא-רשום
- **text** "תיאור" · — לא-רשום
- **text** "שלבי ביצוע — שלב בכל שורה" · — לא-רשום
- **text** "משך משוער (ימים)" · — לא-רשום
- **cfgVisible** · `worker.action.submit` ✅
- **cfgText** "📸 שלח לאישור" · `worker.action.submit` ✅

## חיבורים · connections (15)

- **reads** · `watch` → `tasksProvider`
- **reads** · `watch` → `workerAttendanceProvider`
- **action** · `push` → `WorkerAttendanceScreen`
- **action** · `showEquipmentChecklistSheet` → `showEquipmentChecklistSheet`
- **action** · `showEmployerStockSheet` → `showEmployerStockSheet`
- **action** · `showTasksGanttSheet` → `showTasksGanttSheet`
- **action** · `showDefectsSheet` → `showDefectsSheet`
- **reads** · `read` → `workerAttendanceProvider`
- **reads** · `read` → `boardAuthProvider`
- **action** · `showToast` → `showToast`
- **action** · `openNavSheet` → `openNavSheet`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`
- **reads** · `read` → `tasksProvider`
- **reads** · `watch` → `taskClockProvider`
- **action** · `showWorkerTaskDetailSheet` → `showWorkerTaskDetailSheet`

## התנהגות · behaviour (5)

- **onPressed** → _verb_ `showEquipmentChecklistSheet(context, ref, tasks: current)` → open → showEquipmentChecklistSheet
- **onPressed** → _verb_ `showEmployerStockSheet(context)` → open → showEmployerStockSheet
- **onPressed** → _verb_ `showTasksGanttSheet(context)` → open → showTasksGanttSheet
- **onPressed** → _verb_ `showDefectsSheet(context)` → open → showDefectsSheet
- **onTap** → _verb_ `showWorkerTaskDetailSheet(context, taskId: task.id)` → open → showWorkerTaskDetailSheet

## floor · external functions (10)

- `attendanceDateKey`
- `bsOnAccent`
- `buildDayStages`
- `cfgRadius`
- `currentGeoFix`
- `hasDot`
- `mapsQueryForDay`
- `onSelect`
- `setState`
- `workerShortName`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `worker` · `username` · `demo` · `onSubmit`
- **gaps:** 9 unregistered — "🧰" · "📦" · "➕" · "📊" · "🔧" · "שם המשימה" · "תיאור" · "שלבי ביצוע — שלב בכל שורה" · "משך משוער (ימים)"
