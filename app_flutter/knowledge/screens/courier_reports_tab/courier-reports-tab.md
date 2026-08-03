# CourierReportsTab

- **screen:** `courier_reports_tab`
- **role:** composer

## עצם · object (14)

> registry 12 · mapped 12/12 · **unregistered 2**

- **cfgText** "📊 דוחות" · `courier.reports.title` ✅
- **cfgText** "נתונים חיים ממנוע ההזמנות המשותף — ללא המצאות" · `courier.reports.subtitle` ✅
- **cfgText** "מסירות ישנות ללא ייחוס אינן נספרות" · `courier_reports_tab.t01` ✅
- **cfgText** "אין עדיין מדידות זמן — הזמן נמדד אוטומטית מרגע אישור האיסוף ועד המסירה ללקוח." · `courier_reports_tab.t02` ✅
- **cfgText** "היסטוריית מסירות" · `courier.reports.history_title` ✅
- **text** "📭" · — לא-רשום
- **cfgText** "אין עדיין מסירות שהושלמו" · `courier.reports.empty_title` ✅
- **cfgText** "משלוח שיסומן "נמסר ללקוח" יופיע כאן" · `courier_reports_tab.t03` ✅
- **cfgVisible** · `courier.reports.send_report` ✅
- **cfgText** "🏪 שלח דוח-יומי לחנות" · `courier.reports.send_report` ✅
- **cfgVisible** · `courier_reports_tab.t04` ✅
- **text** "✨" · — לא-רשום
- **cfgText** "נסח דוח עם AI" · `courier_reports_tab.t04` ✅
- **cfgText** "הדוח נשלח כהודעה אמיתית לשיחת "חנות ליפסקי" (מנוע הצ׳אט המשותף — החנות משתתפת בשיחה) + התראת-פעמון לחנות. מוני המסירות והערך מיוחסים לשליח המחובר בלבד, בלי המצאות." · `courier_reports_tab.t05` ✅

## חיבורים · connections (15)

- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `sysOrdersProvider`
- **reads** · `watch` → `fulfillmentProvider`
- **reads** · `watch` → `courierClockProvider`
- **reads** · `watch` → `podPhotosProvider`
- **reads** · `watch` → `rewardsProvider`
- **reads** · `watch` → `claudeGatewayProvider`
- **reads** · `read` → `boardAuthProvider`
- **action** · `showToast` → `showToast`
- **reads** · `read` → `sysOrdersProvider`
- **reads** · `read` → `fulfillmentProvider`
- **reads** · `read` → `courierClockProvider`
- **action** · `push` → `DailyReportScreen`
- **reads** · `read` → `chatEngineProvider`
- **reads** · `read` → `workerNotifsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (5)

- `bsOnAccent`
- `daysBetweenDst`
- `fMoney`
- `orgTerm`
- `startOfWeekSunday`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** 2 unregistered — "📭" · "✨"
