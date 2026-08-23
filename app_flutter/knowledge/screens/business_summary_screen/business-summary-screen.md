# BusinessSummaryScreen

- **screen:** `business_summary_screen`
- **role:** composer

## עצם · object (3)

> registry 3 · mapped 3/3 · **unregistered 0**

- **cfgText** "✨ סיכום עסקי" · `business_summary_screen.t01` ✅
- **cfgText** "התובנות שחושבו:" · `business_summary_screen.t02` ✅
- **cfgText** "⚙️ המספרים מנתוני-המערכת; ה-AI רק מנסח אותם לסיכום." · `business_summary_screen.t03` ✅

## חיבורים · connections (2)

- **reads** · `read` → `claudeGatewayProvider`
- **reads** · `watch` → `claudeGatewayProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `insightLines`
- **gaps:** none (all registry-backed)
