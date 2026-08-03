# PairedExplainScreen

- **screen:** `paired_explain_screen`
- **role:** composer

## עצם · object (3)

> registry 3 · mapped 3/3 · **unregistered 0**

- **cfgText** "🧩 מה עוד צריך?" · `paired_explain_screen.title` ✅
- **cfgText** "מותקן לרוב יחד עם:" · `paired_explain_screen.paired_with` ✅
- **cfgText** "⚙️ הרשימה מנתוני-הקטלוג; ה-AI רק מסביר למה כל אביזר נחוץ." · `paired_explain_screen.footer` ✅

## חיבורים · connections (2)

- **reads** · `read` → `claudeGatewayProvider`
- **reads** · `watch` → `claudeGatewayProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `product` · `types`
- **gaps:** none (all registry-backed)
