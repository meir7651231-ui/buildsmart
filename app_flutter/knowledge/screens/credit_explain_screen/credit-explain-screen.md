# CreditExplainScreen

- **screen:** `credit_explain_screen`
- **role:** composer

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgText** "💳 הסבר אשראי" · `credit_explain_screen.title` ✅
- **cfgText** "⚙️ המספרים מנתוני-המערכת; ה-AI רק מסביר אותם." · `credit_explain_screen.note` ✅

## חיבורים · connections (2)

- **reads** · `read` → `claudeGatewayProvider`
- **reads** · `watch` → `claudeGatewayProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `name` · `creditLimit` · `used` · `balance` · `pct`
- **gaps:** none (all registry-backed)
