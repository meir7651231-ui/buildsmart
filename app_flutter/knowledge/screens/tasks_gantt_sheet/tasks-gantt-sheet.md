# _TasksGanttSheet

- **screen:** `tasks_gantt_sheet`
- **role:** composer

## עצם · object (5)

> registry 5 · mapped 5/5 · **unregistered 0**

- **cfgText** "📊 גאנט משימות" · `tasks_gantt_sheet.header` ✅
- **cfgText** "לוח-הזמנים של המשימות לפי תאריך-התחלה מתוזמן (לצפייה בלבד)" · `tasks_gantt_sheet.subtitle` ✅
- **cfgText** "אין משימות" · `tasks_gantt_sheet.empty` ✅
- **cfgText** "📊 לוח-זמנים (גאנט)" · `tasks_gantt_sheet.timeline` ✅
- **cfgText** "משימות אלו לא ממוקמות על הציר — הקבלן יכול לשבץ להן תאריך התחלה." · `tasks_gantt_sheet.unscheduled_note` ✅

## חיבורים · connections (2)

- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `tasksProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (2)

- `buildTasksGantt`
- `workerIndexForSession`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
