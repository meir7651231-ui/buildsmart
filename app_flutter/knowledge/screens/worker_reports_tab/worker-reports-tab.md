# WorkerReportsTab

- **screen:** `worker_reports_tab`
- **role:** composer

## עצם · object (11)

> registry 10 · mapped 10/10 · **unregistered 1**

- **cfgText** "📊 דוחות" · `worker.reports.title` ✅
- **cfgText** "אין עדיין מדידות זמן — הזמן נמדד אוטומטית מרגע תחילת משימה ועד אישורה." · `worker.reports.time_empty` ✅
- **cfgText** "האזור נגזר משם המשימה (אין שדה אתר במנוע המשימות). שיוך לאתרי פרויקט אמיתיים יחובר עם חיבור השרת." · `worker.reports.area_note` ✅
- **cfgText** "עוד לא הגשת משימות לאישור — ההגשות שלך יופיעו כאן." · `worker.reports.history_empty` ✅
- **cfgText** "אין משימות שנדחו לתיקון." · `worker.reports.rejections_empty` ✅
- **cfgVisible** · `worker.reports.send_daily_button` ✅
- **cfgText** "💬 שלח דוח יומי לקבלן" · `worker.reports.send_daily_button` ✅
- **cfgVisible** · `worker.reports.ai_button` ✅
- **text** "✨" · — לא-רשום
- **cfgText** "נסח דוח עם AI" · `worker.reports.ai_button` ✅
- **cfgText** "הדוח נשלח כהודעה אמיתית לשיחת הקבלן (טאב שיחות) — סיכום הסטטוסים הנוכחי, בלי המצאות." · `worker.reports.send_note` ✅

## חיבורים · connections (18)

- **reads** · `watch` → `tasksProvider`
- **reads** · `watch` → `taskClockProvider`
- **reads** · `watch` → `taskRejectNotesProvider`
- **reads** · `watch` → `taskRejectionLogProvider`
- **reads** · `watch` → `rewardsProvider`
- **action** · `showFirstPassDrilldown` → `showFirstPassDrilldown`
- **action** · `showCoinsDrilldown` → `showCoinsDrilldown`
- **action** · `showStreakDrilldown` → `showStreakDrilldown`
- **action** · `showWeekDayDrilldown` → `showWeekDayDrilldown`
- **action** · `showTaskTimeDrilldown` → `showTaskTimeDrilldown`
- **action** · `showAreaDrilldown` → `showAreaDrilldown`
- **action** · `showSubmissionDrilldown` → `showSubmissionDrilldown`
- **action** · `showRejectionDrilldown` → `showRejectionDrilldown`
- **reads** · `watch` → `claudeGatewayProvider`
- **reads** · `read` → `tasksProvider`
- **reads** · `read` → `chatEngineProvider`
- **action** · `showToast` → `showToast`
- **action** · `push` → `DailyReportScreen`

## התנהגות · behaviour (7)

- **onTap** → _verb_ `showFirstPassDrilldown(context, ref, worker: worker)` → open → showFirstPassDrilldown
- **onTap** → _verb_ `showCoinsDrilldown(context, ref)` → open → showCoinsDrilldown
- **onTap** → _verb_ `showStreakDrilldown(context, ref, worker: worker)` → open → showStreakDrilldown
- **onTap** → _verb_ `showTaskTimeDrilldown(context, ref, task: t)` → open → showTaskTimeDrilldown
- **onTap** → _verb_ `showAreaDrilldown(context, ref, worker: worker, area: e.key)` → open → showAreaDrilldown
- **onTap** → _verb_ `showSubmissionDrilldown(context, task: t, duration: clock[t.id]?.duration)` → open → showSubmissionDrilldown
- **onTap** → _verb_ `showRejectionDrilldown(context, ref, task: t)` → open → showRejectionDrilldown

## floor · external functions (6)

- `bsOnAccent`
- `count`
- `daysBetweenDst`
- `orgTerm`
- `startOfWeekSunday`
- `workerShortName`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `worker`
- **gaps:** 1 unregistered — "✨"
