# AdapterExplainScreen

- **screen:** `adapter_explain_screen`
- **role:** composer

## עצם · object (3)

> registry 3 · mapped 3/3 · **unregistered 0**

- **cfgText** "🔌 איך לגשר?" · `adapter_explain_screen.t01` ✅
- **cfgText** "הקצוות שלו:" · `adapter_explain_screen.t02` ✅
- **cfgText** "⚙️ הקצוות מנתוני-המפרט; ה-AI רק מסביר איזה סוג-מתאם מגשר." · `adapter_explain_screen.t03` ✅

## חיבורים · connections (2)

- **reads** · `read` → `claudeGatewayProvider`
- **reads** · `watch` → `claudeGatewayProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `productName` · `sku`
- **gaps:** none (all registry-backed)
