# SpecCopilotScreen

- **screen:** `spec_copilot_screen`
- **role:** composer

## עצם · object (6)

> registry 5 · mapped 5/5 · **unregistered 1**

- **cfgText** "🌡️ מתאים לתנאים שלי?" · `spec_copilot_screen.t01` ✅
- **cfgText** "טמפרטורת הקו:" · `spec_copilot_screen.t02` ✅
- **cfgText** "אין מפרט מאומת למוצר זה — לא ניתן לקבוע." · `spec_copilot_screen.t03` ✅
- **cfgText** "💡 הסבר-AI דורש חיבור לשרת." · `spec_copilot_screen.t04` ✅
- **cfgText** "מנסח הסבר…" · `spec_copilot_screen.t05` ✅
- **text** "🤖" · — לא-רשום

## חיבורים · connections (2)

- **reads** · `read` → `claudeGatewayProvider`
- **reads** · `watch` → `claudeGatewayProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `product`
- **gaps:** 1 unregistered — "🤖"
