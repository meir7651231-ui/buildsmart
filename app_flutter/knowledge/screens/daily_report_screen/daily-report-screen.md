# DailyReportScreen

- **screen:** `daily_report_screen`
- **role:** composer

## עצם · object (5)

> registry 4 · mapped 4/4 · **unregistered 1**

- **cfgText** "הדוח הועתק" · `daily_report_screen.copied` ✅
- **cfgText** "✨ ניסוח חכם" · `daily_report_screen.title` ✅
- **text** "📋" · — לא-רשום
- **cfgText** "העתק לשליחה" · `daily_report_screen.copy_send` ✅
- **cfgText** "⚙️ המספרים נרשמו במערכת; ה-AI רק מנסח אותם לדוח." · `daily_report_screen.footer_note` ✅

## חיבורים · connections (2)

- **reads** · `read` → `claudeGatewayProvider`
- **reads** · `watch` → `claudeGatewayProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `title` · `reportLines`
- **gaps:** 1 unregistered — "📋"
