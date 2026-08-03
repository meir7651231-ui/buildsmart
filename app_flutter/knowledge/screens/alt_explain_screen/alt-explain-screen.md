# AltExplainScreen

- **screen:** `alt_explain_screen`
- **role:** composer

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgText** "💡 למה החלופה שווה?" · `alt_explain_screen.t01` ✅
- **cfgText** "⚙️ המחירים מתוך נתוני-הקטלוג; ה-AI רק מנסח את ההשוואה." · `alt_explain_screen.t02` ✅

## חיבורים · connections (2)

- **reads** · `read` → `claudeGatewayProvider`
- **reads** · `watch` → `claudeGatewayProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `product` · `recName` · `recPrice` · `altName` · `altPrice`
- **gaps:** none (all registry-backed)
